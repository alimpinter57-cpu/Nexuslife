import { NextResponse } from "next/server"
import { prisma } from "@/lib/prisma"

export const runtime = "nodejs"
export const dynamic = "force-dynamic"

/** Runtime readiness check; migrations remain a separate, deliberate release step. */
export async function GET() {
  const missing = [
    ["DATABASE_URL", process.env.DATABASE_URL],
    ["NEXT_PUBLIC_SUPABASE_URL", process.env.NEXT_PUBLIC_SUPABASE_URL],
    ["NEXT_PUBLIC_SUPABASE_ANON_KEY", process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY],
    ["NEXT_PUBLIC_APP_URL", process.env.NEXT_PUBLIC_APP_URL],
  ].filter(([, value]) => !value).map(([name]) => name)

  if (missing.length) {
    return NextResponse.json(
      { status: "not_ready", checks: { configuration: "missing", database: "not_checked" }, missing },
      { status: 503, headers: { "Cache-Control": "no-store" } },
    )
  }

  try {
    await prisma.$queryRaw\`SELECT 1\`
    return NextResponse.json(
      { status: "ok", checks: { configuration: "ok", database: "ok" } },
      { headers: { "Cache-Control": "no-store" } },
    )
  } catch {
    console.error("Health check database probe failed.")
    return NextResponse.json(
      { status: "not_ready", checks: { configuration: "ok", database: "failed" } },
      { status: 503, headers: { "Cache-Control": "no-store" } },
    )
  }
}
