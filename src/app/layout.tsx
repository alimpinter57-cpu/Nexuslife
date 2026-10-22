import type { Metadata } from "next"
import "./globals.css"

export const metadata: Metadata = { title: "NexusLife — Ruang Kerja Pribadi", description: "Dashboard pribadi NexusLife dengan autentikasi akun." }

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="id"><body>{children}</body></html>
}
