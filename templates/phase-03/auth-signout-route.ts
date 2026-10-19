import { NextResponse } from "next/server"
import { createSupabaseServerClient } from "@/lib/supabase-server"

export const runtime = "nodejs"
export const dynamic = "force-dynamic"

export async function POST() {
  try {
    const supabase = await createSupabaseServerClient()
    const { error } = await supabase.auth.signOut()
    if (error) return NextResponse.json({ error: "Logout belum berhasil." }, { status: 503 })
    return NextResponse.json({ signedOut: true })
  } catch {
    console.error("Signout endpoint failed.")
    return NextResponse.json({ error: "Logout sementara tidak tersedia." }, { status: 503 })
  }
}
