import { NextResponse } from "next/server"
import { createSupabaseServerClient } from "@/lib/supabase-server"

export const runtime = "nodejs"
export const dynamic = "force-dynamic"

export async function GET(request: Request) {
  const url = new URL(request.url)
  const code = url.searchParams.get("code")
  if (!code) return NextResponse.redirect(new URL("/login?error=auth_callback", url.origin))

  try {
    const supabase = await createSupabaseServerClient()
    const { error } = await supabase.auth.exchangeCodeForSession(code)
    if (error) return NextResponse.redirect(new URL("/login?error=auth_callback", url.origin))
    return NextResponse.redirect(new URL("/", url.origin))
  } catch {
    console.error("Auth callback failed; redirecting to login.")
    return NextResponse.redirect(new URL("/login?error=auth_callback", url.origin))
  }
}
