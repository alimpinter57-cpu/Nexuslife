# NexusLife — Personal Operating System

NexusLife dirancang sebagai aplikasi pribadi yang menggabungkan:
- **Habit Tracker** — kebiasaan, log harian, streak, dan progres.
- **Workout Logger** — rencana latihan, sesi, gerakan, set, dan repetisi.
- **Notes** — dokumen, folder, blok konten, dan tag.

## Status saat ini

Repositori ini masih berisi blueprint/setup dan halaman statis awal. Fitur-fitur tersebut **belum menjadi aplikasi yang berfungsi**.

## Prasyarat setup lokal

- Node.js versi LTS yang didukung Next.js.
- npm.
- Git for Windows / Git Bash pada Windows.
- PostgreSQL yang dapat diakses untuk menjalankan fitur database.

## Cara menjalankan setup

### Windows
1. Instal Git for Windows agar perintah Bash tersedia.
2. Buka terminal di folder repositori.
3. Jalankan `setup.bat` dari CMD, atau `bash setup-nexuslife.sh` dari Git Bash.

### Linux / macOS / Git Bash
```bash
bash setup-nexuslife.sh
```

**Perlindungan data:** skrip akan berhenti jika folder `nexuslife` sudah ada. Skrip tidak menghapus folder tersebut dan tidak menimpa `.env.local` yang sudah tersedia. Simpan salinan cadangan sebelum melakukan perubahan besar.

## Setelah setup

```bash
cd nexuslife
# Isi .env.local dengan DATABASE_URL PostgreSQL yang valid.
npx prisma generate
npx prisma migrate dev --name init
npm run dev
```

Buka alamat lokal yang ditampilkan Next.js (biasanya http://localhost:3000).

## Catatan teknis

- `setup-nexuslife.sh` adalah skrip Bash; `setup.bat` hanya launcher Windows.
- Prisma memerlukan database PostgreSQL yang aktif dan konfigurasi `DATABASE_URL` yang benar.
- Autentikasi dalam blueprint awal masih placeholder demo dan **tidak aman untuk penggunaan nyata**.
- GitHub Pages hanya cocok untuk konten statis. Aplikasi Next.js yang memakai backend Prisma membutuhkan hosting yang mendukung server dan database.
- Jangan commit file rahasia seperti `.env.local`, token, atau password ke Git.

## Rencana implementasi

1. Audit setup dan keamanan.
2. Buat kerangka Next.js dan layout responsif.
3. Implementasikan Habit Tracker end-to-end.
4. Hubungkan database dan migrasi.
5. Implementasikan Workout Logger.
6. Implementasikan Notes.
7. Implementasikan autentikasi sungguhan, isolasi data pengguna, pengujian, dan deployment.
