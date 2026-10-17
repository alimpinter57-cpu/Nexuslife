#!/usr/bin/env bash
# ============================================================================
# NEXUSLIFE - AUTOMATED SETUP SCRIPT
# Deskripsi: Setup otomatis boilerplate NexusLife (Next.js + Prisma + Shadcn)
# Penggunaan: chmod +x setup-nexuslife.sh && ./setup-nexuslife.sh
# ============================================================================

set -e  # Exit on error

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
print_success "Next.js app berhasil dibuat!"

# ============================================================================
# STEP 2: Install Dependencies
# ============================================================================
print_step "Step 2/8: Menginstall dependencies..."

npm install \
    @prisma/client@6 \
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

cat > prisma/schema.prisma << 'EOF'
// ============================================================================
// NEXUSLIFE DATABASE SCHEMA
// ============================================================================

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ============================================================================
// ENUMS
// ============================================================================

enum UserRole {
  FREE
  PRO
  ADMIN
}

enum HabitFrequency {
  DAILY
  WEEKLY
  MONTHLY
  CUSTOM
}

enum WorkoutSplitType {
  PUSH_PULL_LEGS
  UPPER_LOWER
  FULL_BODY
  CUSTOM
  CARDIO
  YOGA
  REST
}

enum BlockType {
  PARAGRAPH
  HEADING_1
  HEADING_2
  HEADING_3
  CHECKLIST
  CODE
  CALLOUT
  TOGGLE
  TABLE
  DIVIDER
  IMAGE
  EMBED
  WIDGET
}

enum DocumentVisibility {
  PRIVATE
  SHARED
  PUBLIC
}

// ============================================================================
// USER & AUTH
// ============================================================================

model User {
  id            String    @id @default(uuid())
  email         String    @unique
  passwordHash  String
  name          String?
  avatar        String?
  role          UserRole  @default(FREE)
  emailVerified Boolean   @default(false)
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt
  deletedAt     DateTime?

  workspaces    Workspace[]
  
  @@index([email])
}

// ============================================================================
// WORKSPACE
// ============================================================================

model Workspace {
  id          String   @id @default(uuid())
  name        String
  slug        String   @unique
  icon        String?
  ownerId     String
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  deletedAt   DateTime?

  owner       User     @relation(fields: [ownerId], references: [id], onDelete: Cascade)
  habits      Habit[]
  workoutPlans WorkoutPlan[]
  folders     Folder[]
  documents   Document[]
  tags        Tag[]

  @@index([ownerId])
}

// ============================================================================
// HABIT MODULE
// ============================================================================

model Habit {
  id              String          @id @default(uuid())
  workspaceId     String
  name            String
  description     String?
  icon            String?
  color           String?
  frequency       HabitFrequency  @default(DAILY)
  customDays      Int[]          @default([])
  targetPerPeriod Int             @default(1)
  reminderTime    DateTime?
  reminderEnabled Boolean         @default(false)
  isActive        Boolean         @default(true)
  startDate       DateTime        @default(now())
  endDate         DateTime?
  createdAt       DateTime        @default(now())
  updatedAt       DateTime        @updatedAt
  deletedAt       DateTime?

  workspace       Workspace       @relation(fields: [workspaceId], references: [id], onDelete: Cascade)
  logs            HabitLog[]
  microHabits     MicroHabit[]

  @@index([workspaceId])
  @@index([isActive, deletedAt])
}

model HabitLog {
  id          String   @id @default(uuid())
  habitId     String
  date        DateTime
  isCompleted Boolean  @default(false)
  notes       String?
  completedAt DateTime?
  createdAt   DateTime @default(now())

  habit       Habit    @relation(fields: [habitId], references: [id], onDelete: Cascade)

  @@unique([habitId, date])
  @@index([habitId])
  @@index([date])
}

model MicroHabit {
  id          String   @id @default(uuid())
  habitId     String
  name        String
  order       Int      @default(0)
  isRequired  Boolean  @default(false)
  createdAt   DateTime @default(now())

  habit       Habit    @relation(fields: [habitId], references: [id], onDelete: Cascade)

  @@index([habitId])
}

// ============================================================================
// WORKOUT MODULE
// ============================================================================

model WorkoutPlan {
  id            String           @id @default(uuid())
  workspaceId   String
  name          String
  description   String?
  splitType     WorkoutSplitType
  isActive      Boolean          @default(true)
  createdAt     DateTime         @default(now())
  updatedAt     DateTime         @updatedAt
  deletedAt     DateTime?

  workspace     Workspace        @relation(fields: [workspaceId], references: [id], onDelete: Cascade)
  sessions      WorkoutSession[]
  exercises     WorkoutExercise[]

  @@index([workspaceId])
}

model WorkoutExercise {
  id              String   @id @default(uuid())
  workoutPlanId   String
  name            String
  category        String
  muscleGroup     String?
  equipment       String?
  createdAt       DateTime @default(now())

  workoutPlan     WorkoutPlan     @relation(fields: [workoutPlanId], references: [id], onDelete: Cascade)
  exerciseLogs    ExerciseLog[]

  @@index([workoutPlanId])
}

model WorkoutSession {
  id              String   @id @default(uuid())
  workoutPlanId   String
  date            DateTime
  duration        Int?
  notes           String?
  mood            Int?
  energyLevel     Int?
  completedAt     DateTime?
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt
  deletedAt       DateTime?

  workoutPlan     WorkoutPlan     @relation(fields: [workoutPlanId], references: [id], onDelete: Cascade)
  exerciseLogs    ExerciseLog[]

  @@unique([workoutPlanId, date])
  @@index([workoutPlanId])
  @@index([date])
}

model ExerciseLog {
  id              String   @id @default(uuid())
  workoutSessionId String
  exerciseId      String
  order           Int      @default(0)
  notes           String?
  createdAt       DateTime @default(now())

  workoutSession  WorkoutSession  @relation(fields: [workoutSessionId], references: [id], onDelete: Cascade)
  exercise        WorkoutExercise @relation(fields: [exerciseId], references: [id], onDelete: Cascade)
  sets            ExerciseSet[]

  @@index([workoutSessionId])
  @@index([exerciseId])
}

model ExerciseSet {
  id              String   @id @default(uuid())
  exerciseLogId   String
  setNumber       Int
  reps            Int
  weight          Float?
  weightUnit      String   @default("kg")
  duration        Int?
  rpe             Int?
  isWarmup        Boolean  @default(false)
  isFailure       Boolean  @default(false)
  completedAt     DateTime?
  createdAt       DateTime @default(now())

  exerciseLog     ExerciseLog @relation(fields: [exerciseLogId], references: [id], onDelete: Cascade)

  @@index([exerciseLogId])
}

// ============================================================================
// NOTES MODULE
// ============================================================================

model Folder {
  id            String   @id @default(uuid())
  workspaceId   String
  parentId      String?
  name          String
  icon          String?
  order         Int      @default(0)
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  deletedAt     DateTime?

  workspace     Workspace @relation(fields: [workspaceId], references: [id], onDelete: Cascade)
  parent        Folder?   @relation("FolderHierarchy", fields: [parentId], references: [id])
  children      Folder[]  @relation("FolderHierarchy")
  documents     Document[]

  @@index([workspaceId])
  @@index([parentId])
}

model Document {
  id              String              @id @default(uuid())
  workspaceId     String
  folderId        String?
  title           String
  icon            String?
  coverImage      String?
  visibility      DocumentVisibility  @default(PRIVATE)
  isTemplate      Boolean             @default(false)
  wordCount       Int                 @default(0)
  createdAt       DateTime            @default(now())
  updatedAt       DateTime            @updatedAt
  deletedAt       DateTime?

  workspace       Workspace           @relation(fields: [workspaceId], references: [id], onDelete: Cascade)
  folder          Folder?             @relation(fields: [folderId], references: [id])
  blocks          Block[]
  tags            DocumentTag[]
  backlinksFrom   Backlink[]          @relation("BacklinkSource")
  backlinksTo     Backlink[]          @relation("BacklinkTarget")

  @@index([workspaceId])
  @@index([folderId])
}

model Block {
  id          String    @id @default(uuid())
  documentId  String
  type        BlockType
  content     Json
  order       Int       @default(0)
  parentId    String?
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt

  document    Document  @relation(fields: [documentId], references: [id], onDelete: Cascade)
  parent      Block?    @relation("BlockHierarchy", fields: [parentId], references: [id])
  children    Block[]   @relation("BlockHierarchy")

  @@index([documentId])
  @@index([order])
}

model Tag {
  id          String   @id @default(uuid())
  workspaceId String
  name        String
  color       String?
  parentId    String?
  createdAt   DateTime @default(now())

  workspace   Workspace @relation(fields: [workspaceId], references: [id], onDelete: Cascade)
  documents   DocumentTag[]

  @@unique([workspaceId, name])
  @@index([workspaceId])
}

model DocumentTag {
  id          String   @id @default(uuid())
  documentId  String
  tagId       String
  createdAt   DateTime @default(now())

  document    Document @relation(fields: [documentId], references: [id], onDelete: Cascade)
  tag         Tag      @relation(fields: [tagId], references: [id], onDelete: Cascade)

  @@unique([documentId, tagId])
}

model Backlink {
  id            String   @id @default(uuid())
  sourceDocId   String
  targetDocId   String
  context       String?
  createdAt     DateTime @default(now())

  sourceDoc     Document @relation("BacklinkSource", fields: [sourceDocId], references: [id], onDelete: Cascade)
  targetDoc     Document @relation("BacklinkTarget", fields: [targetDocId], references: [id], onDelete: Cascade)

  @@unique([sourceDocId, targetDocId])
}
EOF

print_success "Prisma Schema berhasil dibuat!"

# ============================================================================
# STEP 9: Update .env.example
# ============================================================================
print_step "Bonus: Membuat file .env.example..."

cat > .env.example << 'EOF'
# Database
DATABASE_URL="postgresql://user:password@localhost:5432/nexuslife?schema=public"

# Auth (NextAuth.js example)
NEXTAUTH_URL="http://localhost:3000"
NEXTAUTH_SECRET="your-secret-key-here"

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

# 4. Run database migrations
npx prisma migrate dev --name init

# 5. (Optional) Seed database
npx prisma db seed

# 6. Start development server
npm run dev
EOF

print_success "README proyek berhasil dibuat!"

echo
print_success "Setup selesai. Langkah berikutnya:"
echo "  cd $PROJECT_NAME"
echo "  Edit .env dengan URL PostgreSQL yang valid"
echo "  npx prisma generate"
echo "  npx prisma migrate dev --name init"
echo "  npm run dev"
