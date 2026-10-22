"use client"

import Link from "next/link"
import { useEffect, useState } from "react"
import { createSupabaseBrowserClient } from "@/lib/supabase-browser"

export default function AuthControls() {
  const [email, setEmail] = useState("")
  const [busy, setBusy] = useState(false)
  const [message, setMessage] = useState("Memeriksa sesi…")

  useEffect(() => {
    let active = true
    async function loadUser() {
      try {
        const supabase = createSupabaseBrowserClient()
        const { data, error } = await supabase.auth.getUser()
        if (!active) return
        if (error || !data.user) {
          window.location.replace("/login")
          return
        }
        setEmail(data.user.email ?? "Akun NexusLife")
        setMessage("")
      } catch {
        if (active) setMessage("Sesi belum dapat diverifikasi")
      }
    }
    void loadUser()
    return () => { active = false }
  }, [])

  async function signOut() {
    if (busy) return
    setBusy(true)
    setMessage("")
    try {
      const response = await fetch("/api/auth/signout", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
      })
      if (!response.ok) {
        setMessage("Logout gagal. Coba lagi.")
        setBusy(false)
        return
      }
      window.location.replace("/login")
    } catch {
      setMessage("Server tidak dapat dijangkau; sesi belum dipastikan berakhir.")
      setBusy(false)
    }
  }

  return (
    <div className="flex flex-wrap items-center gap-3">
      <div className="min-w-0 text-right">
        <p className="max-w-56 truncate text-sm font-medium text-slate-700">{email || "Akun NexusLife"}</p>
        {message && <p role="status" className="text-xs text-rose-600">{message}</p>}
      </div>
      <Link href="/account" className="rounded-full border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-50">
        Akun saya
      </Link>
      <button type="button" onClick={signOut} disabled={busy || !email} className="rounded-full border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-60">
        {busy ? "Keluar…" : "Logout"}
      </button>
    </div>
  )
}
