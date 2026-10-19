"use client"

import Link from "next/link"
import { FormEvent, useState } from "react"
import { useSearchParams } from "next/navigation"
import { createSupabaseBrowserClient } from "@/lib/supabase-browser"

export default function LoginPage() {
  const searchParams = useSearchParams()
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState("")
  const [message, setMessage] = useState("")
  const [busy, setBusy] = useState(false)

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setBusy(true)
    setMessage("")
    try {
      const supabase = createSupabaseBrowserClient()
      const { error } = await supabase.auth.signInWithPassword({ email: email.trim(), password })
      if (error) {
        setMessage("Email atau kata sandi tidak cocok, atau email belum diverifikasi.")
        return
      }
      window.location.assign("/")
    } catch {
      setMessage("Login belum tersedia. Periksa konfigurasi Supabase dan coba lagi.")
    } finally {
      setBusy(false)
    }
  }

  return <main className="flex min-h-screen items-center justify-center bg-slate-950 px-4 py-10 text-slate-100"><section className="w-full max-w-md rounded-3xl border border-slate-800 bg-slate-900 p-7 shadow-2xl sm:p-9"><p className="text-sm font-semibold tracking-wide text-indigo-400">NEXUSLIFE</p><h1 className="mt-3 text-3xl font-bold">Masuk</h1><p className="mt-2 text-sm leading-6 text-slate-400">Masuk untuk melanjutkan ke ruang kerjamu.</p>{searchParams.get("registered") === "1" && <p role="status" className="mt-5 rounded-xl bg-emerald-950 p-3 text-sm text-emerald-200">Pendaftaran dikirim. Jika verifikasi email aktif, buka emailmu terlebih dahulu.</p>}{searchParams.get("error") && <p role="status" className="mt-5 rounded-xl bg-rose-950 p-3 text-sm text-rose-200">Verifikasi/login belum berhasil. Coba lagi.</p>}<form onSubmit={submit} className="mt-6 space-y-4"><label className="block text-sm font-medium">Email<input type="email" autoComplete="email" required value={email} onChange={e => setEmail(e.target.value)} className="mt-2 w-full rounded-xl border border-slate-700 bg-slate-950 px-4 py-3 outline-none focus:border-indigo-400" /></label><label className="block text-sm font-medium">Kata sandi<input type="password" autoComplete="current-password" required value={password} onChange={e => setPassword(e.target.value)} className="mt-2 w-full rounded-xl border border-slate-700 bg-slate-950 px-4 py-3 outline-none focus:border-indigo-400" /></label>{message && <p role="alert" className="text-sm text-rose-300">{message}</p>}<button disabled={busy} className="w-full rounded-xl bg-indigo-600 px-4 py-3 font-semibold text-white hover:bg-indigo-500 disabled:opacity-60">{busy ? "Memeriksa…" : "Masuk"}</button></form><p className="mt-6 text-center text-sm text-slate-400">Belum punya akun? <Link className="font-semibold text-indigo-300 hover:text-indigo-200" href="/register">Daftar</Link></p><p className="mt-5 text-xs leading-5 text-slate-500">Akses dashboard saat ini masih berupa kerangka lokal. Data akun dan sesi perlu diverifikasi melalui pengujian sebelum digunakan untuk data penting.</p></section></main>
}
