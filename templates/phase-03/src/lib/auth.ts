import { prisma } from "@/lib/prisma"
import { createSupabaseServerClient } from "@/lib/supabase-server"

/** Validate the Supabase session on the server and resolve an internal workspace. */
export async function auth() {
  try {
    // Optional local-only scope for isolated development/test databases.
    // Never enable this bypass in production; production always requires a verified Supabase session.
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
