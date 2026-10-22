import Link from "next/link"
import AuthControls from "@/components/auth-controls"
import { createSupabaseServerClient } from "@/lib/supabase-server"

export const dynamic = "force-dynamic"

export default async function HomePage() {
  const supabase = await createSupabaseServerClient()
  const { data } = await supabase.auth.getUser()
  const name = typeof data.user?.user_metadata?.name === "string" ? data.user.user_metadata.name : "Pengguna NexusLife"
  return <main className="min-h-screen px-4 py-8 sm:px-8"><div className="mx-auto max-w-5xl"><header className="flex flex-wrap items-center justify-between gap-4 border-b border-slate-800 pb-5"><Link href="/" className="text-xl font-bold tracking-tight">NexusLife<span className="text-indigo-400">.</span></Link><AuthControls /></header><section className="py-12 sm:py-16"><p className="text-sm font-semibold uppercase tracking-[0.2em] text-indigo-300">Ruang kerja pribadi</p><h1 className="mt-4 max-w-3xl text-4xl font-bold tracking-tight sm:text-5xl">Selamat datang, {name}.</h1><p className="mt-4 max-w-2xl leading-7 text-slate-400">Fondasi aplikasi NexusLife dengan autentikasi yang diverifikasi server. Modul lain akan disambungkan setelah tahap akun lolos pengujian.</p><div className="mt-8 grid gap-4 sm:grid-cols-2"><Link href="/account" className="rounded-2xl border border-slate-800 bg-slate-900 p-6 hover:border-indigo-500"><p className="text-lg font-semibold">Profil akun →</p><p className="mt-2 text-sm leading-6 text-slate-400">Periksa status sesi, verifikasi email, dan hubungan profil database.</p></Link><div className="rounded-2xl border border-slate-800 bg-slate-900 p-6"><p className="text-lg font-semibold">Modul aplikasi</p><p className="mt-2 text-sm leading-6 text-slate-400">Habit, Workout, dan Notes belum dianggap tersinkron sampai integrasi dan pengujiannya selesai.</p></div></div></section><footer className="border-t border-slate-800 pt-5 text-xs leading-5 text-slate-500">Versi pengembangan autentikasi. Jangan masukkan data sensitif sebelum pengujian runtime dan database selesai.</footer></div></main>
}
