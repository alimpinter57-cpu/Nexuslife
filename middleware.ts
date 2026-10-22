import { createServerClient } from "@supabase/ssr"
import { NextResponse, type NextRequest } from "next/server"

/**
 * Protect rendered app pages with a verified Supabase session.
 * API routes are excluded here and must enforce auth independently.
 */
export async function middleware(request: NextRequest) {
  const pathname = request.nextUrl.pathname
  const isAuthPage = pathname === "/login" || pathname === "/register"
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL
  const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

  // Keep public auth screens reachable so configuration failures can be explained.
  // Protected pages fail closed and never trust a missing/invalid auth configuration.
  if (!url || !anonKey) {
    if (isAuthPage) {
      const response = NextResponse.next()
      response.headers.set("x-nexuslife-auth-config", "missing")
      return response
    }
    return NextResponse.redirect(new URL("/login?error=configuration", request.url))
  }

  let response = NextResponse.next({ request })
  let supabase
  try {
    supabase = createServerClient(url, anonKey, {
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
  } catch {
    console.error("Supabase middleware configuration is invalid.")
    if (isAuthPage) {
      const publicResponse = NextResponse.next()
      publicResponse.headers.set("x-nexuslife-auth-config", "invalid")
      return publicResponse
    }
    return NextResponse.redirect(new URL("/login?error=configuration", request.url))
  }

  // getUser validates the token with Supabase; do not trust getSession alone.
  let hasValidUser = false
  try {
    const { data, error } = await supabase.auth.getUser()
    hasValidUser = !error && Boolean(data.user)
  } catch {
    // Provider/network failures must never grant access to protected pages.
    hasValidUser = false
  }

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
