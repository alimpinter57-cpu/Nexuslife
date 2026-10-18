# Supabase + Prisma — NexusLife

Panduan ini menyiapkan koneksi; tidak berisi kredensial dan tidak mengklaim bahwa database sudah diuji.

## 1. Jenis koneksi yang dipilih

- **DATABASE_URL**: gunakan URI **Session pooler** dari Supabase untuk koneksi aplikasi. Pastikan memilih mode session, bukan transaction pooler, untuk pola koneksi Prisma yang memerlukan koneksi sesi.
- **DIRECT_URL**: utamakan URI **Direct connection** untuk migrasi Prisma jika jaringan mendukungnya.
- Jika Supabase memperingatkan bahwa Direct connection tidak mendukung jaringan IPv4 yang sedang digunakan, gunakan URI **Session pooler** dengan port/mode session yang diberikan Supabase sebagai `DIRECT_URL` juga. Jangan gunakan Transaction pooler untuk `DIRECT_URL` migrasi.
- Gunakan host, port, nama database, dan username persis seperti yang ditampilkan dashboard. Jangan menebak atau menyalin port dari contoh.

## 2. Simpan koneksi secara lokal

Di folder proyek Next.js yang dibuat oleh `setup-nexuslife.sh`, buka atau buat file `.env`:

```dotenv
DATABASE_URL="PASTE_SESSION_POOLER_URI_DI_SINI"
DIRECT_URL="PASTE_DIRECT_URI_ATAU_SESSION_POOLER_URI_DI_SINI"
```

Ganti nilai contoh dengan URI dari proyek Supabase sendiri. Jangan menambahkan awalan `NEXT_PUBLIC_`. Jangan commit file `.env` ke GitHub dan jangan kirim password/URI lengkap melalui chat.

## 3. Konfigurasi Prisma

Skema kanonis `prisma/schema.prisma` sudah menggunakan `DATABASE_URL` untuk runtime dan `DIRECT_URL` sebagai URL langsung untuk operasi Prisma CLI. `setup-nexuslife.sh` menyalin skema kanonis tersebut ke proyek baru.

Setelah mengisi `.env`, jalankan dari folder proyek Next.js:

```bash
npx prisma validate
npx prisma generate
```

Jika validasi berhasil dan proyek Supabase memang baru/kosong, tinjau skema lalu jalankan migrasi awal:

```bash
npx prisma migrate dev --name init
```

Jangan jalankan migrasi pada database yang sudah berisi data penting tanpa meninjau perubahan dan membuat cadangan terlebih dahulu.

## Keamanan dan batasan

- Jangan commit `.env`, password database, access token, atau Supabase service-role key.
- Jangan mengekspos service-role key di kode browser.
- Validasi skema tidak membuktikan koneksi database aktif; migrasi sukses adalah pemeriksaan terpisah.
- Endpoint API yang ada masih menggunakan helper autentikasi demo yang fail-closed di production. Jangan anggap login/otorisasi multi-pengguna sudah siap sebelum autentikasi nyata dan pemeriksaan kepemilikan workspace diterapkan.
- GitHub Pages tidak dapat menjalankan Next.js API routes atau Prisma. Aplikasi backend harus dideploy ke hosting yang mendukung server-side runtime.
