import "server-only"

import type { User as SupabaseUser } from "@supabase/supabase-js"
import { prisma } from "@/lib/prisma"

/**
 * Resolve a Supabase identity to an internal NexusLife user and personal workspace.
 * Existing email-only accounts are linked only after Supabase confirms the email.
 */
export async function ensureNexusIdentity(identity: SupabaseUser) {
  const email = identity.email?.trim().toLowerCase()
  if (!email) return null

  return prisma.$transaction(async (tx) => {
    let user = await tx.user.findFirst({
      where: { supabaseAuthId: identity.id, deletedAt: null },
      select: { id: true, email: true, name: true },
    })

    if (!user) {
      const existingByEmail = await tx.user.findUnique({
        where: { email },
        select: { id: true, email: true, name: true, supabaseAuthId: true, deletedAt: true },
      })

      if (existingByEmail?.deletedAt) return null

      if (existingByEmail) {
        // Never attach an unverified external identity to an existing account by email alone.
        if (!identity.email_confirmed_at || existingByEmail.supabaseAuthId) return null
        user = await tx.user.update({
          where: { id: existingByEmail.id },
          data: {
            supabaseAuthId: identity.id,
            emailVerified: true,
            ...(typeof identity.user_metadata?.name === "string" && !existingByEmail.name
              ? { name: identity.user_metadata.name.slice(0, 100) }
              : {}),
          },
          select: { id: true, email: true, name: true },
        })
      } else {
        user = await tx.user.create({
          data: {
            email,
            supabaseAuthId: identity.id,
            emailVerified: Boolean(identity.email_confirmed_at),
            name: typeof identity.user_metadata?.name === "string"
              ? identity.user_metadata.name.slice(0, 100)
              : null,
          },
          select: { id: true, email: true, name: true },
        })
      }
    }

    let workspace = await tx.workspace.findFirst({
      where: { ownerId: user.id, deletedAt: null },
      orderBy: { createdAt: "asc" },
      select: { id: true },
    })

    if (!workspace) {
      const suffix = user.id.replace(/-/g, "").slice(0, 12)
      workspace = await tx.workspace.create({
        data: {
          ownerId: user.id,
          name: "Ruang Kerja Saya",
          slug: `ruang-${suffix}`,
        },
        select: { id: true },
      })
    }

    return { user, workspaceId: workspace.id }
  })
}
