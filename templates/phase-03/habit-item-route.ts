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
}).refine((value) => Object.keys(value).length > 0, { message: "No changes supplied." })

function utcDay(date = new Date()) {
  return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()))
}

type RouteContext = { params: Promise<{ habitId: string }> }

export async function PATCH(request: Request, context: RouteContext) {
  try {
    const session = await auth()
    if (!session) return NextResponse.json({ error: "Authentication is not configured." }, { status: 401 })
    const { habitId } = await context.params
    const parsed = updateSchema.safeParse(await request.json())
    if (!parsed.success) return NextResponse.json({ error: "Invalid update.", details: parsed.error.flatten() }, { status: 400 })

    const existing = await prisma.habit.findFirst({
      where: { id: habitId, workspaceId: session.workspaceId, deletedAt: null },
      select: { id: true },
    })
    if (!existing) return NextResponse.json({ error: "Habit not found." }, { status: 404 })

    const { todayCompleted, ...updates } = parsed.data
    const habit = await prisma.$transaction(async (tx) => {
      const updated = Object.keys(updates).length
        ? await tx.habit.update({ where: { id: habitId }, data: updates })
        : await tx.habit.findUniqueOrThrow({ where: { id: habitId } })
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
  } catch (error) {
    console.error("Habit update API failed", error)
    return NextResponse.json({ error: "Could not update habit." }, { status: 500 })
  }
}
