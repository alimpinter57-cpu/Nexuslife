import { NextResponse } from "next/server"
import { prisma } from "@/lib/prisma"
import { auth } from "@/lib/auth"
import { z } from "zod"

export const runtime = "nodejs"
export const dynamic = "force-dynamic"

const updateSchema = z.object({
  name: z.string().trim().min(1).max(100).optional(),
  description: z.string().max(500).nullable().optional(),
  isActive: z.boolean().optional(),
  todayCompleted: z.boolean().optional(),
}).strict().refine((value) => Object.keys(value).length > 0, { message: "No changes supplied." })

function utcDay(date = new Date()) {
  return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()))
}

type RouteContext = { params: Promise<{ habitId: string }> }

export async function PATCH(request: Request, context: RouteContext) {
  try {
    const session = await auth()
    if (!session) return NextResponse.json({ error: "Authentication is required." }, { status: 401 })
    const { habitId } = await context.params
    const body: unknown = await request.json().catch(() => undefined)
    if (body === undefined) return NextResponse.json({ error: "Request body must be valid JSON." }, { status: 400 })
    const parsed = updateSchema.safeParse(body)
    if (!parsed.success) return NextResponse.json({ error: "Invalid update.", details: parsed.error.flatten() }, { status: 400 })

    const existing = await prisma.habit.findFirst({
      where: { id: habitId, workspaceId: session.workspaceId, deletedAt: null },
      select: { id: true },
    })
    if (!existing) return NextResponse.json({ error: "Habit not found." }, { status: 404 })

    const { todayCompleted, ...updates } = parsed.data
    const habit = await prisma.$transaction(async (tx) => {
      const updated = Object.keys(updates).length
        ? await tx.habit.update({ where: { id: habitId, workspaceId: session.workspaceId, deletedAt: null }, data: updates })
        : await tx.habit.findFirstOrThrow({ where: { id: habitId, workspaceId: session.workspaceId, deletedAt: null } })
      if (typeof todayCompleted === "boolean") {
        const date = utcDay()
        await tx.habitLog.upsert({
          where: { habitId_date: { habitId, date } },
          create: { habitId, date, isCompleted: todayCompleted, completedAt: todayCompleted ? new Date() : null },
          update: { isCompleted: todayCompleted, completedAt: todayCompleted ? new Date() : null },
        })
      }
      return updated
    })
    return NextResponse.json({ habit: { ...habit, todayCompleted: todayCompleted ?? undefined } })
  } catch {
    console.error("Habit update API failed.")
    return NextResponse.json({ error: "Could not update habit." }, { status: 500 })
  }
}

/** Soft-delete a habit only inside the authenticated user's workspace. */
export async function DELETE(_request: Request, context: RouteContext) {
  try {
    const session = await auth()
    if (!session) return NextResponse.json({ error: "Authentication is required." }, { status: 401 })

    const { habitId } = await context.params
    const result = await prisma.habit.updateMany({
      where: {
        id: habitId,
        workspaceId: session.workspaceId,
        deletedAt: null,
      },
      data: { deletedAt: new Date(), isActive: false },
    })

    if (result.count === 0) {
      return NextResponse.json({ error: "Habit not found." }, { status: 404 })
    }

    return new NextResponse(null, { status: 204 })
  } catch {
    console.error("Habit deletion API failed.")
    return NextResponse.json({ error: "Could not delete habit." }, { status: 500 })
  }
}
