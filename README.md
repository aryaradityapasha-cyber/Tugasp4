# Tugas Praktikum 4 - Pemrograman Mobile (CRUD & Local Storage)

Aplikasi demonstrasi implementasi database **SQFlite (SQLite Relasional)** dan teknologi local storage alternatif **Hive (NoSQL Key-Value)** pada Flutter.

Dibuat untuk memenuhi tugas Praktikum Pemrograman Mobile - Universitas Pakuan.

## Fitur Utama
1. **SQFlite Database CRUD**:
   - Create: Tambah tugas/catatan mahasiswa
   - Read: Tampil data terurut, pencarian keyword, filter kategori
   - Update: Edit data form & toggle status selesai
   - Delete: Hapus data dengan modal konfirmasi
2. **Hive Local Storage CRUD (Alternatif)**:
   - Full CRUD identik menggunakan engine NoSQL Box murni Dart (*pure Dart*)
3. **Tab Ringkasan & Dokumentasi Terintegrasi**:
   - Menampilkan tabel perbandingan SQFlite vs Hive dan hasil uji coba langsung di dalam aplikasi
4. **Automated Unit & Widget Tests**:
   - 9 test cases teruji dan lulus 100%

## Cara Menjalankan
```powershell
cd tugas_crud
flutter pub get
flutter test
flutter run
```

Laporan lengkap dapat dibaca pada file: `LAPORAN_TUGAS_P4.md`
