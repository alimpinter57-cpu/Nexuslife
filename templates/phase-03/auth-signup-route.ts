import { NextResponse } from "next/server"
import { z } from "zod"
import { prisma } from "@/lib/prisma"
import { createSupabaseServerClient } from "@/lib/supabase-server"

export const runtime = "nodejs"
export const dynamic = "force-dynamic"

const signupSchema = z.object({
  email: z.string().trim().email().max(254),
  password: z.string().min(8).max(128),
  name: z.string().trim().min(1).max(80),
}).strict()

export async function POST(request: Request) {
  const parsed = signupSchema.safeParse(await request.json().catch(() => null))
  if (!parsed.success) return NextResponse.json({ error: "Isi nama, email, dan kata sandi minimal 8 karakter." }, { status: 400 })

  const email = parsed.data.email.toLowerCase()
  const supabase = await createSupabaseServerClient()
  const { data, error } = await supabase.auth.signUp({
    email,
    password: parsed.data.password,
    options: { data: { name: parsed.data.name } },
  })
  if (error || !data.user) {
    // Avoid exposing provider internals or whether an email already exists.
    return NextResponse.json({ error: "Pendaftaran belum berhasil. Periksa data atau coba masuk jika sudah memiliki akun." }, { status: 400 })
  }
  if (Array.isArray(data.user.identities) && data.user.identities.length === 0) {
    // Supabase may return an obfuscated user for an existing email; never provision it.
    return NextResponse.json({ error: "Pendaftaran belum berhasil. Periksa data atau coba masuk jika sudah memiliki akun." }, { status: 400 })
  }

  try {
    await prisma.$transaction(async (tx) => {
      const existingByAuthId = await tx.user.findUnique({ where: { supabaseAuthId: data.user.id }, select: { id: true } })
      if (existingByAuthId) return
      const existingByEmail = await tx.user.findUnique({ where: { email }, select: { id: true } })
      if (existingByEmail) {
        // Never link accounts based on email alone; an existing account requires a reviewed linking flow.
        throw new Error("ACCOUNT_LINK_REQUIRES_REVIEW")
      }
      const user = await tx.user.create({
        data: {
          email,
          supabaseAuthId: data.user.id,
          passwordHash: null,
          name: parsed.data.name,
          emailVerified: Boolean(data.user.email_confirmed_at),
          workspaces: { create: { name: "Workspace pribadi", slug: `personal-${data.user.id}` } },
        },
        select: { id: true },
      })
      return user
    })
  } catch {
    // A Supabase account may exist, but do not create an unsafe mapping or disclose DB details.
    return NextResponse.json({ error: "Akun autentikasi dibuat tetapi penyiapan workspace perlu bantuan admin. Jangan daftar berulang; hubungi pengelola." }, { status: 503 })
  }

  return NextResponse.json({ message: data.session ? "Pendaftaran berhasil." : "Periksa email untuk menyelesaikan verifikasi." }, { status: 201 })
}
