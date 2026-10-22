import Link from "next/link"
import { createSupabaseServerClient } from "@/lib/supabase-server"
import { prisma } from "@/lib/prisma"
import AuthControls from "@/components/auth-controls"

export const dynamic = "force-dynamic"

export default async function AccountPage() {
  const supabase = await createSupabaseServerClient()
  const { data, error } = await supabase.auth.getUser()

  if (error || !data.user) {
    return (
      <main className="flex min-h-screen items-center justify-center bg-slate-950 px-4 text-slate-100">
        <section className="w-full max-w-lg rounded-3xl border border-slate-800 bg-slate-900 p-8">
          <h1 className="text-2xl font-bold">Sesi tidak valid</h1>
          <p className="mt-3 text-sm leading-6 text-slate-400">Masuk kembali untuk melihat informasi akunmu.</p>
          <Link href="/login" className="mt-6 inline-flex rounded-xl bg-indigo-600 px-4 py-3 font-semibold text-white">Kembali ke login</Link>
        </section>
      </main>
    )
  }

  let profile: {
    id: string
    name: string | null
    email: string
    emailVerified: boolean
    createdAt: Date
    workspaces: { id: string; name: string; createdAt: Date }[]
  } | null = null
  let profileLookupFailed = false

  try {
    profile = await prisma.user.findFirst({
      where: { supabaseAuthId: data.user.id, deletedAt: null },
      select: {
        id: true,
        name: true,
        email: true,
        emailVerified: true,
        createdAt: true,
        workspaces: {
          where: { deletedAt: null },
          orderBy: { createdAt: "asc" },
          select: { id: true, name: true, createdAt: true },
        },
      },
    })
  } catch {
    profileLookupFailed = true
  }

  const displayName = profile?.name || (typeof data.user.user_metadata?.name === "string" ? data.user.user_metadata.name : null) || "Pengguna NexusLife"
  const email = data.user.email ?? profile?.email ?? "Email tidak tersedia"
  const verified = Boolean(data.user.email_confirmed_at)

  return (
    <main className="min-h-screen bg-slate-950 px-4 py-8 text-slate-100 sm:px-6">
      <div className="mx-auto max-w-4xl">
        <header className="flex flex-wrap items-center justify-between gap-4">
          <Link href="/" className="text-sm font-semibold text-indigo-300 hover:text-indigo-200">← Kembali ke dashboard</Link>
          <AuthControls />
        </header>

        <section className="mt-8 overflow-hidden rounded-3xl border border-slate-800 bg-slate-900">
          <div className="bg-gradient-to-r from-indigo-950 via-slate-900 to-slate-900 px-6 py-8 sm:px-9">
            <p className="text-sm font-semibold tracking-widest text-indigo-300">NEXUSLIFE · AKUN SAYA</p>
            <div className="mt-5 flex items-center gap-4">
              <div className="grid h-16 w-16 shrink-0 place-items-center rounded-2xl bg-indigo-600 text-2xl font-bold">
                {displayName.slice(0, 1).toUpperCase()}
              </div>
              <div className="min-w-0">
                <h1 className="break-words text-2xl font-bold sm:text-3xl">{displayName}</h1>
                <p className="mt-1 break-all text-sm text-slate-400">{email}</p>
              </div>
            </div>
          </div>

          <div className="grid gap-4 p-6 sm:grid-cols-2 sm:p-9">
            <article className="rounded-2xl border border-slate-800 bg-slate-950/60 p-5">
              <p className="text-sm text-slate-400">Status autentikasi</p>
              <p className="mt-2 font-semibold text-emerald-300">Sesi Supabase valid</p>
              <p className="mt-2 text-sm leading-6 text-slate-500">Identitas sesi diperiksa oleh server, bukan hanya berdasarkan data di browser.</p>
            </article>
            <article className="rounded-2xl border border-slate-800 bg-slate-950/60 p-5">
              <p className="text-sm text-slate-400">Verifikasi email</p>
              <p className={`mt-2 font-semibold ${verified ? "text-emerald-300" : "text-amber-300"}`}>{verified ? "Email terverifikasi" : "Email belum terverifikasi"}</p>
              <p className="mt-2 text-sm leading-6 text-slate-500">{verified ? "Akun telah menyelesaikan verifikasi email Supabase." : "Periksa kotak masuk untuk tautan verifikasi jika diwajibkan oleh pengaturan Supabase."}</p>
            </article>

            <article className="rounded-2xl border border-slate-800 bg-slate-950/60 p-5 sm:col-span-2">
              <h2 className="font-semibold">Profil NexusLife</h2>
              {profileLookupFailed ? (
                <p role="status" className="mt-3 text-sm leading-6 text-amber-300">Sesi login valid, tetapi profil database belum dapat diperiksa. Coba lagi nanti; status ini tidak berarti data sudah tersinkron.</p>
              ) : profile ? (
                <>
                  <p className="mt-3 text-sm leading-6 text-slate-300">Akun Supabase terhubung ke profil NexusLife.</p>
                  <dl className="mt-4 grid gap-4 sm:grid-cols-2">
                    <div><dt className="text-xs uppercase tracking-wide text-slate-500">ID profil internal</dt><dd className="mt-1 break-all font-mono text-xs text-slate-300">{profile.id}</dd></div>
                    <div><dt className="text-xs uppercase tracking-wide text-slate-500">Bergabung</dt><dd className="mt-1 text-sm text-slate-300">{profile.createdAt.toLocaleDateString("id-ID", { day: "numeric", month: "long", year: "numeric", timeZone: "UTC" })}</dd></div>
                    <div><dt className="text-xs uppercase tracking-wide text-slate-500">Workspace aktif</dt><dd className="mt-1 text-sm text-slate-300">{profile.workspaces.length}</dd></div>
                    <div><dt className="text-xs uppercase tracking-wide text-slate-500">Workspace utama</dt><dd className="mt-1 text-sm text-slate-300">{profile.workspaces[0]?.name ?? "Belum tersedia"}</dd></div>
                  </dl>
                </>
              ) : (
                <div className="mt-3 rounded-xl border border-amber-900/70 bg-amber-950/30 p-4">
                  <p className="font-medium text-amber-200">Profil belum terhubung ke database NexusLife</p>
                  <p className="mt-2 text-sm leading-6 text-amber-100/70">Login Supabase berhasil, tetapi tidak ditemukan profil dengan ID autentikasi ini. Demi keamanan, jangan gunakan fitur data pribadi sampai pemetaan akun diperbaiki.</p>
                </div>
              )}
            </article>
          </div>
        </section>
      </div>
    </main>
  )
}
