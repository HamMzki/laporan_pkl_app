<h1 align="center">📱📊 Laporan PKL App</h1>

<p align="center">
Aplikasi mobile Flutter yang terhubung dengan backend REST API Laravel untuk manajemen laporan PKL.<br>
Frontend dibuat dengan <strong>Flutter</strong> dan backend memakai <strong>Laravel API</strong> untuk data, autentikasi, dan logika server.
</p>

<hr>

<h2>📌 Tentang Proyek</h2>

<p>
<strong>Laporan PKL App</strong> adalah aplikasi hasil kerja kolaboratif antara frontend Flutter dan backend Laravel. Aplikasi ini dibuat untuk mempermudah pencatatan, peninjauan, dan manajemen laporan hasil Praktik Kerja Lapangan (PKL).
</p>

<p>
Backend Laravel menyediakan REST API yang dapat diakses oleh aplikasi Flutter melalui HTTP. Di sisi Flutter, aplikasi menangani tampilan pengguna, navigasi, dan interaksi data melalui API tersebut. Flutter dan Laravel saling terhubung menggunakan JSON API standar.
</p>

<hr>

<h2>🛠️ Teknologi</h2>

<ul>
  <li><strong>Flutter</strong> — Frontend aplikasi mobile (Android/iOS)</li>
  <li><strong>Dart</strong> — Bahasa utama Flutter</li>
  <li><strong>Laravel</strong> — Backend dan REST API</li>
  <li><strong>MySQL / Database</strong> — Penyimpanan data</li>
  <li><strong>HTTP / JSON</strong> — Komunikasi antara frontend & backend</li>
</ul>

<hr>

<h2>📂 Struktur Project</h2>

<details>
<summary><strong>Frontend (Flutter)</strong></summary>

<pre>
study_quest_flutter/
├── android/
├── ios/
├── lib/
│   ├── api/                # Kelas API service
│   ├── models/             # Model data dari backend
│   ├── screens/            # Layar UI
│   ├── widgets/            # Komponen UI reusable
│   └── main.dart           # Entry point aplikasi
├── pubspec.yaml            # Dependencies Flutter
└── README.md
</pre>

</details>

<details>
<summary><strong>Backend (Laravel)</strong></summary>

<pre>
laravel_pkl_backend/
├── app/
│   ├── Http/
│   │   ├── Controllers/    # API Controllers
│   │   └── Middleware/
├── database/
│   ├── migrations/         # Tabel & skema database
│   └── seeders/
├── routes/
│   └── api.php             # API routes
├── composer.json
├── .env.example
└── README.md
</pre>

</details>

<hr>

<h2>🚀 Instalasi & Setup</h2>

<h3>🔧 Backend Laravel</h3>

<ol>
  <li>Clone backend project:</li>
</ol>

<pre>
git clone https://github.com/HamMzki/laporan_pkl_app.git
</pre>

<ol start="2">
  <li>Install dependencies Laravel:</li>
</ol>

<pre>
composer install
</pre>

<ol start="3">
  <li>Salin file konfigurasi environment:</li>
</ol>

<pre>
cp .env.example .env
</pre>

<ol start="4">
  <li>Sesuaikan koneksi database di <strong>.env</strong> lalu jalankan migrasi:</li>
</ol>

<pre>
php artisan migrate
</pre>

<ol start="5">
  <li>Jalankan server Laravel:</li>
</ol>

<pre>
php artisan serve
</pre>

<hr>

<h3>📱 Frontend Flutter</h3>

<ol>
  <li>Pastikan Flutter SDK terinstal.</li>
  <li>Clone project Flutter:</li>
</ol>

<pre>
git clone https://github.com/HamMzki/laporan_pkl_app.git
</pre>

<ol start="3">
  <li>Masuk folder Flutter kemudian install dependencies:</li>
</ol>

<pre>
flutter pub get
</pre>

<ol start="4">
  <li>Sesuaikan base URL API di kelas API service dengan alamat Laravel server kamu.</li>
  <li>Jalankan aplikasi di emulator atau perangkat fisik:</li>
</ol>

<pre>
flutter run
</pre>

<hr>

<h2>📊 Arsitektur Sistem</h2>

<p>
Backend Laravel menyediakan sejumlah endpoint API yang mengembalikan data dalam format JSON, yang kemudian dikonsumsi oleh Flutter melalui HTTP request (GET, POST, PUT, DELETE). Flutter memodelkan data API ke dalam model Dart dan menampilkan setiap layar sesuai kebutuhan.
</p>

<p>
Pendekatan REST API ini membuat frontend dan backend bisa dikembangkan secara terpisah, fleksibel, dan dapat diskalakan. :contentReference[oaicite:0]{index=0}
</p>

<hr>

<h2>🎯 Fitur Utama</h2>

<ul>
  <li>Login/Autentikasi pengguna via API</li>
  <li>Kirim dan ambil data laporan PKL</li>
  <li>CRUD laporan (frontend & backend)</li>
  <li>Organisasi data hasil PKL sesuai kebutuhan</li>
</ul>

<hr>

<h2>📌 Ide Pengembangan</h2>

<ul>
  <li>Tambah fitur upload file/foto laporan</li>
  <li>Admin panel untuk manajemen data via web</li>
  <li>Push notification untuk update status</li>
  <li>Testing otomatis untuk API dan UI</li>
</ul>

<hr>

<h2>🤝 Kontribusi</h2>

<p>
Kolaborasi terbuka bagi siapa saja yang ingin menambahkan fitur baru atau memperbaiki bug. Silakan buat pull request dengan dokumentasi perubahan yang jelas.
</p>

<hr>

<h2>📄 Lisensi</h2>

<p>
Proyek ini bebas dipakai, dikembangkan, dan dipelajari.
</p>

<hr>

<p align="center">
Made with ❤️ by <strong>Muhammad Ilham Muzaki</strong> & Team
</p>
