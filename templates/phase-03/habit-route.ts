import { NextResponse } from "next/server"

export async function GET() {
  return NextResponse.json({ error: "Habit database routes are being wired to the authenticated workspace." }, { status: 501 })
}
