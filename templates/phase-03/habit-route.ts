import { NextResponse } from "next/server"
import { prisma } from "@/lib/prisma"
import { auth } from "@/lib/auth"
import { createHabitSchema } from "@/lib/validations/habit"

export const runtime = "nodejs"
export const dynamic = "force-dynamic"

function utcDay(date = new Date()) {
  return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()))
}

export async function GET() {
  try {
    const session = await auth()
    if (!session) return NextResponse.json({ error: "Authentication is required." }, { status: 401 })
    const today = utcDay()
    const habits = await prisma.habit.findMany({
      where: { workspaceId: session.workspaceId, deletedAt: null, isActive: true },
      include: { logs: { where: { date: today }, take: 1 } },
      orderBy: { createdAt: "asc" },
    })
    return NextResponse.json({ habits: habits.map(({ logs, ...habit }) => ({ ...habit, todayCompleted: logs[0]?.isCompleted ?? false })) })
  } catch {
    // Do not send or log database/provider details to clients or routine logs.
    console.error("Habit list API failed.")
    return NextResponse.json({ error: "Could not read habits from the database." }, { status: 500 })
  }
}

export async function POST(request: Request) {
  try {
    const session = await auth()
    if (!session) return NextResponse.json({ error: "Authentication is required." }, { status: 401 })
    const body: unknown = await request.json().catch(() => undefined)
    if (body === undefined) return NextResponse.json({ error: "Request body must be valid JSON." }, { status: 400 })
    const parsed = createHabitSchema.safeParse(body)
    if (!parsed.success) return NextResponse.json({ error: "Invalid habit data.", details: parsed.error.flatten() }, { status: 400 })
    const habit = await prisma.habit.create({
      data: {
        workspaceId: session.workspaceId,
        name: parsed.data.name.trim(),
        description: parsed.data.description,
        icon: parsed.data.icon,
        color: parsed.data.color,
        frequency: parsed.data.frequency,
        customDays: parsed.data.customDays ?? [],
        targetPerPeriod: parsed.data.targetPerPeriod,
      },
    })
    return NextResponse.json({ habit: { ...habit, todayCompleted: false } }, { status: 201 })
  } catch {
    console.error("Habit create API failed.")
    return NextResponse.json({ error: "Could not save habit to the database." }, { status: 500 })
  }
}
