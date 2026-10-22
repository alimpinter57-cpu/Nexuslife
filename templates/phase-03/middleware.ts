import { createServerClient } from "@supabase/ssr"
import { NextResponse, type NextRequest } from "next/server"

/**
 * Protect rendered app pages with a verified Supabase session.
 * API routes are excluded here and must enforce auth independently.
 */
export async function middleware(request: NextRequest) {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL
  const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

  // Fail closed for protected pages if Supabase configuration is missing.
  if (!url || !anonKey) {
    const pathname = request.nextUrl.pathname
    if (pathname === "/login" || pathname === "/register") return NextResponse.next()
    return NextResponse.redirect(new URL("/login?error=configuration", request.url))
  }

  let response = NextResponse.next({ request })
  const supabase = createServerClient(url, anonKey, {
    cookies: {
      getAll() {
        return request.cookies.getAll()
      },
      setAll(cookiesToSet) {
        for (const { name, value } of cookiesToSet) {
          request.cookies.set(name, value)
        }
        response = NextResponse.next({ request })
        for (const { name, value, options } of cookiesToSet) {
          response.cookies.set(name, value, options)
        }
      },
    },
  })

  // getUser validates the token with Supabase; do not trust getSession alone.
  let hasValidUser = false
  try {
    const { data, error } = await supabase.auth.getUser()
    hasValidUser = !error && Boolean(data.user)
  } catch {
    // Provider/network failures must never grant access to protected pages.
    hasValidUser = false
  }

  const pathname = request.nextUrl.pathname
  const isAuthPage = pathname === "/login" || pathname === "/register"

  if (!hasValidUser && !isAuthPage) {
    const redirect = NextResponse.redirect(new URL("/login", request.url))
    for (const cookie of response.cookies.getAll()) {
      redirect.cookies.set(cookie)
    }
    return redirect
  }

  return response
}

export const config = {
  matcher: [
    "/((?!api|_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
}
