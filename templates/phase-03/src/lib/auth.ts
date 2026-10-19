import { prisma } from "@/lib/prisma"
import { createSupabaseServerClient } from "@/lib/supabase-server"

/** Validate the Supabase session on the server and resolve an internal workspace. */
export async function auth() {
  try {
    const supabase = await createSupabaseServerClient()
    const { data, error } = await supabase.auth.getUser()
    if (error || !data.user || !data.user.email) return null

    const user = await prisma.user.findFirst({
      where: { supabaseAuthId: data.user.id, deletedAt: null },
      select: { id: true, email: true },
    })
    if (!user) return null

    const workspace = await prisma.workspace.findFirst({
      where: { ownerId: user.id, deletedAt: null },
      orderBy: { createdAt: "asc" },
      select: { id: true },
    })
    if (!workspace) return null

    return { user, workspaceId: workspace.id }
  } catch (error) {
    // Keep secrets and session tokens out of logs. Missing configuration fails closed.
    console.error("Authentication check failed; request denied.")
    return null
  }
}
