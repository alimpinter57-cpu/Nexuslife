#!/usr/bin/env bash
# ============================================================================
# NEXUSLIFE - AUTOMATED SETUP SCRIPT
# Deskripsi: Setup otomatis boilerplate NexusLife (Next.js + Prisma + Shadcn)
# Penggunaan: chmod +x setup-nexuslife.sh && ./setup-nexuslife.sh
# ============================================================================

set -e  # Exit on error

# Resolve repository path so templates work from any current directory.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Warna untuk output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Helper functions
print_step() { echo -e "\n${BLUE}▶ $1${NC}"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }

PROJECT_NAME="nexuslife"

echo -e "\n${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   🚀 NEXUSLIFE - AUTOMATED SETUP SCRIPT                 ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}\n"

# ============================================================================
# STEP 1: Create Next.js App
# ============================================================================
print_step "Step 1/8: Membuat Next.js app dengan App Router..."

if [ -e "$PROJECT_NAME" ]; then
    print_error "Folder '$PROJECT_NAME' sudah ada. Demi keamanan, setup dihentikan tanpa menghapus data."
    print_warning "Pindahkan atau ganti nama folder tersebut secara manual, lalu jalankan ulang."
    exit 1
fi

npx create-next-app@latest $PROJECT_NAME \
    --typescript \
    --tailwind \
    --eslint \
    --app \
    --src-dir \
    --import-alias "@/*" \
    --use-npm \
    --turbopack

cd $PROJECT_NAME

# Replace the default landing page with the first NexusLife app shell.
cat > src/app/page.tsx << 'NEXUS_PAGE_EOF'
"use client"

import { FormEvent, useEffect, useState } from "react"
import { Activity, BookOpen, Check, ChevronRight, Dumbbell, LayoutDashboard, Plus, Sparkles, Target, Trash2 } from "lucide-react"

type Habit = { id: string; name: string; detail: string; done: boolean }
const STORAGE_KEY = "nexuslife-habits-v1"
const starterHabits: Habit[] = [
  { id: "starter-1", name: "Belajar teknologi", detail: "30 menit", done: false },
  { id: "starter-2", name: "Olahraga", detail: "Sesi hari ini", done: true },
  { id: "starter-3", name: "Membaca / mencatat", detail: "10 menit", done: false },
]

export default function Home() {
  const [habits, setHabits] = useState<Habit[]>(starterHabits)
  const [activeTab, setActiveTab] = useState("Overview")
  const [newName, setNewName] = useState("")
  const [newDetail, setNewDetail] = useState("")
  const [storageReady, setStorageReady] = useState(false)
  const completed = habits.filter((habit) => habit.done).length

  useEffect(() => {
    try {
      const saved = window.localStorage.getItem(STORAGE_KEY)
      if (saved) {
        const parsed: unknown = JSON.parse(saved)
        if (Array.isArray(parsed) && parsed.every((item) => item && typeof item.id === "string" && typeof item.name === "string" && typeof item.detail === "string" && typeof item.done === "boolean")) {
          setHabits(parsed as Habit[])
        }
      }
    } catch {
      // If browser storage is unavailable or invalid, keep the in-memory starter data.
    } finally {
      setStorageReady(true)
    }
  }, [])

  useEffect(() => {
    if (!storageReady) return
    try {
      window.localStorage.setItem(STORAGE_KEY, JSON.stringify(habits))
    } catch {
      // The tracker remains usable for this session if storage is blocked or full.
    }
  }, [habits, storageReady])

  function addHabit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    const name = newName.trim()
    if (!name) return
    setHabits((current) => [...current, { id: crypto.randomUUID(), name, detail: newDetail.trim() || "Belum ada target", done: false }])
    setNewName("")
    setNewDetail("")
  }

  function toggleHabit(id: string) {
    setHabits((current) => current.map((habit) => habit.id === id ? { ...habit, done: !habit.done } : habit))
  }

  function deleteHabit(id: string) {
    setHabits((current) => current.filter((habit) => habit.id !== id))
  }

  const navItems = [
    { label: "Overview", icon: LayoutDashboard },
    { label: "Habit Tracker", icon: Target },
    { label: "Workout", icon: Dumbbell },
    { label: "Notes", icon: BookOpen },
  ]

  return (
    <main className="min-h-screen bg-[#f7f8fc] text-slate-900">
      <div className="mx-auto flex min-h-screen max-w-7xl">
        <aside className="hidden w-64 shrink-0 border-r border-slate-200 bg-white p-6 md:flex md:flex-col">
          <a href="#" className="mb-10 flex items-center gap-3">
            <span className="grid h-10 w-10 place-items-center rounded-2xl bg-indigo-600 text-white"><Sparkles size={20} /></span>
            <span><span className="block text-lg font-bold tracking-tight">NexusLife</span><span className="text-xs text-slate-500">Personal workspace</span></span>
          </a>
          <p className="mb-3 px-3 text-xs font-semibold uppercase tracking-widest text-slate-400">Workspace</p>
          <nav className="space-y-1">
            {navItems.map(({ label, icon: Icon }) => (
              <button key={label} onClick={() => setActiveTab(label)} className={`flex w-full items-center gap-3 rounded-xl px-3 py-3 text-left text-sm font-medium transition ${activeTab === label ? "bg-indigo-50 text-indigo-700" : "text-slate-600 hover:bg-slate-50"}`}>
                <Icon size={18} />{label}
              </button>
            ))}
          </nav>
          <div className="mt-auto rounded-2xl bg-slate-50 p-4">
            <p className="text-sm font-semibold">Satu langkah kecil.</p>
            <p className="mt-1 text-xs leading-5 text-slate-500">Konsistensi dibangun dari tindakan yang bisa diulang.</p>
          </div>
        </aside>

        <section className="min-w-0 flex-1 p-5 sm:p-8 lg:p-10">
          <header className="mb-8 flex flex-wrap items-center justify-between gap-4">
            <div><p className="text-sm font-medium text-indigo-600">PERSONAL OPERATING SYSTEM</p><h1 className="mt-2 text-3xl font-bold tracking-tight sm:text-4xl">{activeTab === "Overview" ? "Ringkasan hari ini" : activeTab}</h1><p className="mt-2 text-sm text-slate-500">Bangun progres yang terlihat, satu hari dalam satu waktu.</p></div>
            <div className="rounded-full border border-slate-200 bg-white px-4 py-2 text-sm text-slate-600">Mode lokal · {storageReady ? "Penyimpanan browser aktif" : "Memuat data…"}</div>
          </header>

          {activeTab === "Habit Tracker" ? (
            <div className="space-y-6">
              <section className="rounded-2xl border border-slate-200 bg-white p-5 sm:p-6">
                <div className="flex flex-wrap items-start justify-between gap-3"><div><h2 className="text-lg font-bold">Kebiasaanmu</h2><p className="mt-1 text-sm text-slate-500">Tambahkan kebiasaan yang realistis, lalu tandai saat selesai.</p></div><span className="rounded-full bg-emerald-50 px-3 py-1 text-sm font-semibold text-emerald-700">{completed}/{habits.length} selesai</span></div>
                <div className="mt-5 h-2 overflow-hidden rounded-full bg-slate-100"><div className="h-full rounded-full bg-emerald-500 transition-all" style={{ width: `${habits.length ? completed / habits.length * 100 : 0}%` }} /></div>
                {habits.length === 0 ? <p className="mt-6 rounded-xl border border-dashed border-slate-300 p-6 text-center text-sm text-slate-500">Belum ada kebiasaan. Tambahkan satu di bawah.</p> : <div className="mt-5 space-y-3">{habits.map((habit) => <div key={habit.id} className="flex items-center gap-3 rounded-xl border border-slate-100 p-4"><button aria-label={habit.done ? `Tandai ${habit.name} belum selesai` : `Tandai ${habit.name} selesai`} onClick={() => toggleHabit(habit.id)} className={`grid h-6 w-6 shrink-0 place-items-center rounded-lg border ${habit.done ? "border-emerald-500 bg-emerald-500 text-white" : "border-slate-300 bg-white text-transparent"}`}><Check size={15} /></button><div className="min-w-0 flex-1"><p className={`font-semibold ${habit.done ? "text-slate-400 line-through" : "text-slate-800"}`}>{habit.name}</p><p className="mt-1 text-xs text-slate-500">{habit.detail}</p></div><button aria-label={`Hapus ${habit.name}`} onClick={() => deleteHabit(habit.id)} className="rounded-lg p-2 text-slate-400 hover:bg-rose-50 hover:text-rose-600"><Trash2 size={17} /></button></div>)}</div>}
              </section>
              <section className="rounded-2xl border border-slate-200 bg-white p-5 sm:p-6">
                <h2 className="text-lg font-bold">Tambah kebiasaan</h2>
                <form onSubmit={addHabit} className="mt-4 grid gap-3 sm:grid-cols-2">
                  <label className="text-sm font-medium text-slate-700">Nama kebiasaan<input value={newName} onChange={(event) => setNewName(event.target.value)} maxLength={80} required placeholder="Contoh: Belajar Python" className="mt-2 w-full rounded-xl border border-slate-200 px-3 py-3 font-normal outline-none focus:border-indigo-400 focus:ring-2 focus:ring-indigo-100" /></label>
                  <label className="text-sm font-medium text-slate-700">Target / catatan<input value={newDetail} onChange={(event) => setNewDetail(event.target.value)} maxLength={120} placeholder="Contoh: 20 menit" className="mt-2 w-full rounded-xl border border-slate-200 px-3 py-3 font-normal outline-none focus:border-indigo-400 focus:ring-2 focus:ring-indigo-100" /></label>
                  <button type="submit" className="inline-flex items-center justify-center gap-2 rounded-xl bg-indigo-600 px-4 py-3 text-sm font-semibold text-white hover:bg-indigo-700 sm:col-span-2"><Plus size={17} /> Tambahkan kebiasaan</button>
                </form>
                <p className="mt-3 text-xs leading-5 text-slate-500">Data disimpan di browser/perangkat ini. Belum tersinkron ke akun atau database, dan belum memiliki riwayat harian.</p>
              </section>
            </div>
          ) : activeTab === "Overview" ? (
            <>
              <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
                <div className="rounded-2xl border border-slate-200 bg-white p-5"><div className="flex items-center justify-between"><span className="text-sm text-slate-500">Habit selesai</span><span className="rounded-xl bg-emerald-50 p-2 text-emerald-600"><Check size={18} /></span></div><p className="mt-4 text-3xl font-bold">{completed}<span className="text-lg font-medium text-slate-400"> / {habits.length}</span></p><div className="mt-4 h-2 overflow-hidden rounded-full bg-slate-100"><div className="h-full rounded-full bg-emerald-500 transition-all" style={{ width: `${habits.length ? completed / habits.length * 100 : 0}%` }} /></div></div>
                <div className="rounded-2xl border border-slate-200 bg-white p-5"><div className="flex items-center justify-between"><span className="text-sm text-slate-500">Fokus utama</span><span className="rounded-xl bg-indigo-50 p-2 text-indigo-600"><Activity size={18} /></span></div><p className="mt-4 text-xl font-bold">Progres konsisten</p><p className="mt-2 text-sm text-slate-500">Utamakan langkah kecil yang realistis.</p></div>
                <div className="rounded-2xl border border-slate-200 bg-white p-5 sm:col-span-2 xl:col-span-1"><div className="flex items-center justify-between"><span className="text-sm text-slate-500">Target hari ini</span><span className="rounded-xl bg-amber-50 p-2 text-amber-600"><Target size={18} /></span></div><p className="mt-4 text-xl font-bold">Mulai, lalu catat</p><p className="mt-2 text-sm text-slate-500">Selesaikan satu hal sebelum menambah target.</p></div>
              </div>
              <div className="mt-8 grid gap-6 xl:grid-cols-[1.4fr_1fr]">
                <section className="rounded-2xl border border-slate-200 bg-white p-5 sm:p-6">
                  <div className="mb-5 flex items-center justify-between"><div><h2 className="text-lg font-bold">Habit hari ini</h2><p className="mt-1 text-sm text-slate-500">Centang setelah kamu menyelesaikannya.</p></div><span className="rounded-full bg-slate-100 px-3 py-1 text-xs font-semibold text-slate-600">{completed} selesai</span></div>
                  <div className="space-y-3">{habits.slice(0, 5).map((habit) => <button key={habit.id} onClick={() => toggleHabit(habit.id)} className="flex w-full items-center gap-4 rounded-xl border border-slate-100 p-4 text-left transition hover:border-indigo-200 hover:bg-slate-50"><span className={`grid h-6 w-6 shrink-0 place-items-center rounded-lg border ${habit.done ? "border-emerald-500 bg-emerald-500 text-white" : "border-slate-300 bg-white text-transparent"}`}><Check size={15} /></span><span className="min-w-0 flex-1"><span className={`block font-semibold ${habit.done ? "text-slate-400 line-through" : "text-slate-800"}`}>{habit.name}</span><span className="mt-1 block text-xs text-slate-500">{habit.detail}</span></span><ChevronRight size={17} className="text-slate-300" /></button>)}</div>
                  <button onClick={() => setActiveTab("Habit Tracker")} className="mt-4 rounded-xl px-3 py-2 text-sm font-semibold text-indigo-600 hover:bg-indigo-50">Kelola semua kebiasaan <ChevronRight size={15} className="inline" /></button>
                </section>
                <section className="rounded-2xl border border-slate-200 bg-white p-5 sm:p-6">
                  <h2 className="text-lg font-bold">Area kerja</h2><p className="mt-1 text-sm text-slate-500">Modul akan dibangun bertahap.</p>
                  <div className="mt-5 space-y-3">{[{ title: "Habit Tracker", desc: "Kebiasaan, log, dan progres", icon: Target }, { title: "Workout", desc: "Latihan, set, repetisi", icon: Dumbbell }, { title: "Notes", desc: "Catatan dan ide penting", icon: BookOpen }].map(({ title, desc, icon: Icon }) => <button key={title} onClick={() => setActiveTab(title === "Workout" ? "Workout" : title)} className="flex w-full items-center gap-3 rounded-xl border border-slate-100 p-4 text-left hover:border-indigo-200 hover:bg-slate-50"><span className="rounded-xl bg-indigo-50 p-3 text-indigo-600"><Icon size={19} /></span><span className="flex-1"><span className="block text-sm font-semibold">{title}</span><span className="mt-1 block text-xs text-slate-500">{desc}</span></span><ChevronRight size={17} className="text-slate-300" /></button>)}</div>
                  <div className="mt-5 rounded-xl bg-amber-50 p-4 text-sm leading-6 text-amber-900"><strong>Catatan:</strong> Habit Tracker kini dapat digunakan secara lokal. Login, database, dan sinkronisasi belum aktif.</div>
                </section>
              </div>
            </>
          ) : (
            <section className="rounded-2xl border border-slate-200 bg-white p-8 sm:p-10"><div className="grid h-12 w-12 place-items-center rounded-2xl bg-indigo-50 text-indigo-600">{activeTab === "Workout" ? <Dumbbell size={23} /> : <BookOpen size={23} />}</div><h2 className="mt-5 text-xl font-bold">{activeTab} akan dikembangkan berikutnya</h2><p className="mt-2 max-w-xl text-sm leading-6 text-slate-500">{activeTab === "Workout" ? "Modul untuk mencatat sesi latihan, gerakan, set, repetisi, dan perkembangan." : "Modul untuk menyimpan catatan, ide, dan refleksi pribadi."} Untuk sekarang, gunakan Habit Tracker yang sudah aktif.</p><button onClick={() => setActiveTab("Habit Tracker")} className="mt-6 rounded-xl bg-indigo-600 px-4 py-3 text-sm font-semibold text-white hover:bg-indigo-700">Buka Habit Tracker</button></section>
          )}
          <footer className="mt-8 text-center text-xs text-slate-400">NexusLife · Tahap 02 — Habit Tracker lokal</footer>
        </section>
      </div>
    </main>
  )
}

NEXUS_PAGE_EOF

cat > src/app/layout.tsx << 'NEXUS_LAYOUT_EOF'
import type { Metadata } from "next"
import "./globals.css"

export const metadata: Metadata = {
  title: "NexusLife — Personal Workspace",
  description: "Ruang pribadi untuk habit, workout, dan catatan.",
}

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="id">
      <body>{children}</body>
    </html>
  )
}
NEXUS_LAYOUT_EOF

print_success "Next.js app berhasil dibuat!"

# ============================================================================
# STEP 2: Install Dependencies
# ============================================================================
print_step "Step 2/8: Menginstall dependencies..."

npm install \
    @prisma/client@6 \
    @supabase/ssr \
    @supabase/supabase-js \
    server-only \
    zod \
    react-hook-form \
    @hookform/resolvers \
    sonner \
    lucide-react \
    class-variance-authority \
    clsx \
    tailwind-merge \
    date-fns \
    bcryptjs \
    @types/bcryptjs

npm install -D prisma@6

print_success "Dependencies berhasil diinstall!"

# ============================================================================
# STEP 3: Initialize Prisma
# ============================================================================
print_step "Step 3/8: Menginisialisasi Prisma..."

npx prisma init --datasource-provider postgresql

print_success "Prisma berhasil diinisialisasi!"

# ============================================================================
# STEP 4: Initialize Shadcn UI
# ============================================================================
print_step "Step 4/8: Menginisialisasi Shadcn UI..."

npx shadcn@latest init --defaults

print_success "Shadcn UI berhasil diinisialisasi!"

# ============================================================================
# STEP 5: Install Shadcn Components
# ============================================================================
print_step "Step 5/8: Menginstall komponen Shadcn UI..."

npx shadcn@latest add \
    button \
    card \
    input \
    textarea \
    checkbox \
    select \
    dialog \
    dropdown-menu \
    badge \
    tabs \
    separator \
    progress \
    scroll-area \
    tooltip \
    calendar \
    command \
    avatar \
    label \
    form \
    toast \
    sheet \
    popover \
    switch \
    table \
    skeleton

print_success "Komponen Shadcn berhasil diinstall!"

# ============================================================================
# STEP 6: Create Folder Structure
# ============================================================================
print_step "Step 6/8: Membuat struktur folder..."

mkdir -p src/app/\(dashboard\)/habits/_components
mkdir -p src/app/\(dashboard\)/workout/_components
mkdir -p src/app/\(dashboard\)/notes/_components
mkdir -p src/app/\(dashboard\)/calendar/_components
mkdir -p src/app/\(auth\)/login
mkdir -p src/app/\(auth\)/register
mkdir -p src/app/api/habits
mkdir -p src/app/api/workout
mkdir -p src/app/api/notes
mkdir -p src/app/api/auth
mkdir -p src/actions
mkdir -p src/lib/validations
mkdir -p src/lib/hooks
mkdir -p src/components/ui
mkdir -p src/components/layout
mkdir -p src/components/habit
mkdir -p src/components/workout
mkdir -p src/components/notes
mkdir -p src/components/shared
mkdir -p src/types
mkdir -p src/hooks
mkdir -p src/styles
mkdir -p prisma/migrations
mkdir -p public/images
mkdir -p public/icons

# Create .gitkeep files untuk folder kosong
find src -type d -empty -exec touch {}/.gitkeep \;

print_success "Struktur folder berhasil dibuat!"

# ============================================================================
# STEP 7: Create Configuration Files
# ============================================================================
print_step "Step 7/8: Membuat file konfigurasi..."

# Create lib/utils.ts (jika belum ada dari shadcn)
cat > src/lib/utils.ts << 'EOF'
import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function formatDate(date: Date | string, format: string = "dd MMM yyyy"): string {
  const d = typeof date === 'string' ? new Date(date) : date
  return d.toLocaleDateString('id-ID', { 
    day: 'numeric', 
    month: 'short', 
    year: 'numeric' 
  })
}

export function getTodayDate(): Date {
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  return today
}
EOF

# Create types/index.ts
cat > src/types/index.ts << 'EOF'
export * from './habit'
export * from './workout'
export * from './notes'
export * from './user'
EOF

# Create types/habit.ts
cat > src/types/habit.ts << 'EOF'
export type HabitFrequency = 'DAILY' | 'WEEKLY' | 'MONTHLY' | 'CUSTOM'

export interface Habit {
  id: string
  name: string
  description?: string | null
  icon?: string | null
  color?: string | null
  frequency: HabitFrequency
  customDays?: number[] | null
  targetPerPeriod: number
  isActive: boolean
  streak: number
  completionRate: number
  todayCompleted: boolean
  createdAt: Date
  updatedAt: Date
}

export interface HabitLog {
  id: string
  habitId: string
  date: Date
  isCompleted: boolean
  notes?: string | null
}

export interface CreateHabitInput {
  name: string
  description?: string
  icon?: string
  color?: string
  frequency: HabitFrequency
  customDays?: number[]
  targetPerPeriod?: number
}
EOF

# Create types/workout.ts
cat > src/types/workout.ts << 'EOF'
export type WorkoutSplitType = 
  | 'PUSH_PULL_LEGS' 
  | 'UPPER_LOWER' 
  | 'FULL_BODY' 
  | 'CUSTOM' 
  | 'CARDIO' 
  | 'YOGA' 
  | 'REST'

export interface WorkoutPlan {
  id: string
  name: string
  splitType: WorkoutSplitType
  isActive: boolean
}

export interface ExerciseSet {
  id: string
  setNumber: number
  reps: number
  weight: number | null
  weightUnit: string
  rpe: number | null
  isWarmup: boolean
}

export interface ExerciseLog {
  id: string
  exerciseId: string
  exerciseName: string
  sets: ExerciseSet[]
}

export interface WorkoutSession {
  id: string
  date: Date
  duration?: number | null
  exercises: ExerciseLog[]
  mood?: number | null
  energyLevel?: number | null
}
EOF

# Create types/notes.ts
cat > src/types/notes.ts << 'EOF'
export type BlockType = 
  | 'PARAGRAPH' 
  | 'HEADING_1' 
  | 'HEADING_2' 
  | 'HEADING_3' 
  | 'CHECKLIST' 
  | 'CODE' 
  | 'CALLOUT' 
  | 'TOGGLE' 
  | 'TABLE' 
  | 'DIVIDER' 
  | 'IMAGE' 
  | 'EMBED' 
  | 'WIDGET'

export interface Block {
  id: string
  type: BlockType
  content: any
  order: number
  parentId?: string | null
}

export interface Document {
  id: string
  title: string
  icon?: string | null
  folderId?: string | null
  blocks: Block[]
  tags: string[]
  wordCount: number
  createdAt: Date
  updatedAt: Date
}

export interface Folder {
  id: string
  name: string
  parentId?: string | null
  children?: Folder[]
  documents?: Document[]
}
EOF

# Create types/user.ts
cat > src/types/user.ts << 'EOF'
export type UserRole = 'FREE' | 'PRO' | 'ADMIN'

export interface User {
  id: string
  email: string
  name?: string | null
  avatar?: string | null
  role: UserRole
  emailVerified: boolean
}

export interface Session {
  user: User
  expires: Date
}
EOF

# Create lib/validations/habit.ts
cat > src/lib/validations/habit.ts << 'EOF'
import { z } from 'zod'

export const createHabitSchema = z.object({
  name: z
    .string()
    .min(1, 'Nama habit wajib diisi')
    .max(100, 'Nama terlalu panjang (maks 100 karakter)'),
  description: z.string().max(500).optional(),
  icon: z.string().max(10).optional(),
  color: z.string().regex(/^#[0-9A-F]{6}$/i, 'Format warna tidak valid').optional(),
  frequency: z.enum(['DAILY', 'WEEKLY', 'MONTHLY', 'CUSTOM']),
  customDays: z.array(z.number().min(0).max(6)).optional(),
  targetPerPeriod: z.number().min(1).max(30).default(1),
})

export type CreateHabitInput = z.infer<typeof createHabitSchema>
EOF

# Create lib/prisma.ts
cat > src/lib/prisma.ts << 'EOF'
import { PrismaClient } from '@prisma/client'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
  })

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma
EOF

# Create lib/auth.ts (placeholder)
cat > src/lib/auth.ts << 'EOF'
// TODO: Implement authentication (NextAuth.js / Clerk / Supabase Auth)
export async function auth() {
  // Placeholder - ganti dengan auth provider pilihan kamu
  return {
    user: {
      id: 'demo-user-id',
      email: 'demo@nexuslife.app',
      name: 'Demo User',
    },
  }
}
EOF

print_success "File konfigurasi berhasil dibuat!"

# ============================================================================
# STEP 8: Create Prisma Schema
# ============================================================================
print_step "Step 8/8: Membuat Prisma Schema..."

cp "$SCRIPT_DIR/prisma/schema.prisma" prisma/schema.prisma

if ! grep -q '^datasource db' prisma/schema.prisma; then
    print_error "Schema Prisma kanonis tidak ditemukan atau tidak valid."
    exit 1
fi

print_success "Prisma Schema berhasil dibuat!"

# Install the database-backed Habit API templates after the base scaffold exists.
print_step "Bonus: Menambahkan API Habit berbasis PostgreSQL..."
mkdir -p src/app/api/habits/\[habitId\] src/lib
cp "$SCRIPT_DIR/templates/phase-03/src/lib/auth.ts" src/lib/auth.ts
cp "$SCRIPT_DIR/templates/phase-03/src/lib/prisma.ts" src/lib/prisma.ts
cp "$SCRIPT_DIR/templates/phase-03/src/lib/supabase-server.ts" src/lib/supabase-server.ts
cp "$SCRIPT_DIR/templates/phase-03/src/lib/supabase-browser.ts" src/lib/supabase-browser.ts
cp "$SCRIPT_DIR/templates/phase-03/login-page.tsx" 'src/app/(auth)/login/page.tsx'
cp "$SCRIPT_DIR/templates/phase-03/register-page.tsx" 'src/app/(auth)/register/page.tsx'
cp "$SCRIPT_DIR/templates/phase-03/src/lib/validations/habit.ts" src/lib/validations/habit.ts
mkdir -p src/app/api/auth/signup src/app/api/auth/callback src/app/api/auth/signout
cp "$SCRIPT_DIR/templates/phase-03/auth-signup-route.ts" src/app/api/auth/signup/route.ts
cp "$SCRIPT_DIR/templates/phase-03/auth-callback-route.ts" src/app/api/auth/callback/route.ts
cp "$SCRIPT_DIR/templates/phase-03/auth-signout-route.ts" src/app/api/auth/signout/route.ts
cp "$SCRIPT_DIR/templates/phase-03/habit-route.ts" src/app/api/habits/route.ts
cp "$SCRIPT_DIR/templates/phase-03/habit-item-route.ts" 'src/app/api/habits/[habitId]/route.ts'
print_success "Template API Habit berhasil disalin. Autentikasi tetap fail-closed sampai tahap auth selesai."

# ============================================================================
# STEP 9: Update .env.example
# ============================================================================
print_step "Bonus: Membuat file .env.example..."

cat > .env.example << 'EOF'
# Database
DATABASE_URL="postgresql://user:password@localhost:5432/nexuslife?schema=public"

# Supabase Auth (public anon key only; never put service-role keys here)
NEXT_PUBLIC_SUPABASE_URL=""
NEXT_PUBLIC_SUPABASE_ANON_KEY=""

# App
NEXT_PUBLIC_APP_URL="http://localhost:3000"
NEXT_PUBLIC_APP_NAME="NexusLife"

# Optional: Email (Resend)
RESEND_API_KEY=""

# Optional: Analytics (PostHog)
NEXT_PUBLIC_POSTHOG_KEY=""
NEXT_PUBLIC_POSTHOG_HOST=""
EOF

if [ ! -f .env ]; then
    cp .env.example .env
    print_warning "File .env dibuat dari template. Isi DATABASE_URL sebelum menjalankan migrasi."
else
    print_warning ".env sudah ada; tidak ditimpa."
fi

print_success "File .env.example berhasil dibuat!"

# ============================================================================
# STEP 10: Create README
# ============================================================================
print_step "Bonus: Membuat README.md..."

cat > README.md << 'EOF'
# 🚀 NexusLife - Personal Operating System

Aplikasi produktivitas serbaguna yang menggabungkan Habit Tracker, Workout Logger, dan Notes dalam satu platform.

## 🛠️ Tech Stack

- **Framework:** Next.js (App Router)
- **Language:** TypeScript
- **Styling:** Tailwind CSS + Shadcn UI
- **Database:** PostgreSQL + Prisma ORM
- **Validation:** Zod + React Hook Form
- **Notifications:** Sonner

## 📦 Getting Started

### Prerequisites
- Node.js 20.9+
- PostgreSQL 15+
- npm / yarn / pnpm

### Installation

```bash
# 1. Install dependencies
npm install

# 2. Setup environment variables
# Edit file .env yang sudah dibuat oleh Prisma; isi DATABASE_URL PostgreSQL yang valid.
# Jangan menyalin .env.example ke .env jika .env sudah berisi konfigurasi.

# 3. Generate Prisma Client
npx prisma generate

# 4. Database migration (do not run automatically on the existing NexusLife Supabase project)
# Review prisma/migrations and the target database migration history first.
# For a fresh local database only, create/apply a migration intentionally.
# npx prisma migrate dev --name init

# 5. Seed only a disposable development database after reviewing the seed script.
# npx prisma db seed

# 6. Start development server
npm run dev
```
EOF

print_success "README proyek berhasil dibuat!"

echo
print_success "Setup selesai. Langkah berikutnya:"
echo "  cd $PROJECT_NAME"
echo "  Edit .env dengan URL PostgreSQL yang valid"
echo "  npx prisma generate"
echo "  Pastikan auth dan environment sudah dikonfigurasi sebelum menguji API."
echo "  Jangan jalankan migrate dev/seed terhadap Supabase yang sudah berisi data tanpa audit."
echo "  npm run dev"
