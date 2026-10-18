import { prisma } from "@/lib/prisma"

/**
 * Authentication is intentionally fail-closed until the dedicated auth phase.
 * Optional local testing may identify an existing user/workspace via environment
 * variables, but this helper is disabled in production.
 */
export async function auth() {
  if (process.env.NODE_ENV === "production") return null
  if (process.env.NEXUSLIFE_LOCAL_USER_ID === undefined || process.env.NEXUSLIFE_LOCAL_WORKSPACE_ID === undefined) return null

  const user = await prisma.user.findFirst({
    where: { id: process.env.NEXUSLIFE_LOCAL_USER_ID, deletedAt: null },
    select: { id: true, email: true },
  })
  if (!user) return null

  const workspace = await prisma.workspace.findFirst({
    where: {
      id: process.env.NEXUSLIFE_LOCAL_WORKSPACE_ID,
      ownerId: user.id,
      deletedAt: null,
    },
    select: { id: true },
  })
  if (!workspace) return null

  return { user, workspaceId: workspace.id }
}
