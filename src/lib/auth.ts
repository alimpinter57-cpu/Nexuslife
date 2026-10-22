import "server-only"

import { ensureNexusIdentity } from "@/lib/ensure-nexus-identity"
import { createSupabaseServerClient } from "@/lib/supabase-server"
import { prisma } from "@/lib/prisma"

/** Verify the Supabase identity, then resolve its internal user and workspace. */
export async function auth() {
  try {
    // Isolated local-only test scope. Never enable this bypass in production.
    const localWorkspaceId = process.env.NEXUSLIFE_LOCAL_WORKSPACE_ID
    if (process.env.NODE_ENV !== "production" && localWorkspaceId) {
      const workspace = await prisma.workspace.findFirst({
        where: { id: localWorkspaceId, deletedAt: null },
        select: { id: true, ownerId: true, owner: { select: { id: true, email: true } } },
      })
      if (!workspace) return null
      return { user: workspace.owner, workspaceId: workspace.id }
    }

    const supabase = await createSupabaseServerClient()
    const { data, error } = await supabase.auth.getUser()
    if (error || !data.user) return null

    return await ensureNexusIdentity(data.user)
  } catch {
    // Do not log tokens, database URLs, or provider error payloads.
    console.error("Authentication check failed; request denied.")
    return null
  }
}
