"use client"

import Link from "next/link"
import { FormEvent, useState } from "react"

export default function RegisterPage() {
  const [name, setName] = useState("")
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState("")
  const [message, setMessage] = useState("")
  const [success, setSuccess] = useState(false)
  const [busy, setBusy] = useState(false)

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setBusy(true)
    setMessage("")
    setSuccess(false)
    try {
      const response = await fetch("/api/auth/signup", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ name, email, password }),
      })
      const result: { message?: string; error?: string } = await response.json().catch(() => ({}))
      if (!response.ok) {
        setMessage(result.error ?? "Pendaftaran belum berhasil. Coba lagi.")
        return
      }
      setSuccess(true)
      setMessage(result.message ?? "Pendaftaran dikirim. Periksa email jika verifikasi diaktifkan.")
      setName("")
      setEmail("")
      setPassword("")
    } catch {
      setMessage("Server tidak dapat dijangkau. Coba lagi nanti.")
    } finally {
      setBusy(false)
    }
  }

  return <main className="flex min-h-screen items-center justify-center bg-slate-950 px-4 py-10 text-slate-100"><section className="w-full max-w-md rounded-3xl border border-slate-800 bg-slate-900 p-7 shadow-2xl sm:p-9"><p className="text-sm font-semibold tracking-wide text-indigo-400">NEXUSLIFE</p><h1 className="mt-3 text-3xl font-bold">Buat akun</h1><p className="mt-2 text-sm leading-6 text-slate-400">Mulai ruang kerja pribadimu.</p><form onSubmit={submit} className="mt-6 space-y-4"><label className="block text-sm font-medium">Nama<input autoComplete="name" required minLength={1} maxLength={80} value={name} onChange={e => setName(e.target.value)} className="mt-2 w-full rounded-xl border border-slate-700 bg-slate-950 px-4 py-3 outline-none focus:border-indigo-400" /></label><label className="block text-sm font-medium">Email<input type="email" autoComplete="email" required maxLength={254} value={email} onChange={e => setEmail(e.target.value)} className="mt-2 w-full rounded-xl border border-slate-700 bg-slate-950 px-4 py-3 outline-none focus:border-indigo-400" /></label><label className="block text-sm font-medium">Kata sandi<input type="password" autoComplete="new-password" required minLength={8} maxLength={128} value={password} onChange={e => setPassword(e.target.value)} className="mt-2 w-full rounded-xl border border-slate-700 bg-slate-950 px-4 py-3 outline-none focus:border-indigo-400" /><span className="mt-1 block text-xs text-slate-500">Minimal 8 karakter.</span></label>{message && <p role={success ? "status" : "alert"} className={`rounded-xl p-3 text-sm ${success ? "bg-emerald-950 text-emerald-200" : "bg-rose-950 text-rose-200"}`}>{message}</p>}<button disabled={busy} className="w-full rounded-xl bg-indigo-600 px-4 py-3 font-semibold text-white hover:bg-indigo-500 disabled:opacity-60">{busy ? "Mendaftarkan…" : "Daftar"}</button></form><p className="mt-6 text-center text-sm text-slate-400">Sudah punya akun? <Link className="font-semibold text-indigo-300 hover:text-indigo-200" href="/login">Masuk</Link></p></section></main>
}
