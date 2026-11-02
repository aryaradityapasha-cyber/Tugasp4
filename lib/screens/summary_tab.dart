import 'package:flutter/material.dart';

class SummaryTab extends StatelessWidget {
  const SummaryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Hero Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade700, Colors.deepPurple.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu_book, color: Colors.white, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Ringkasan & Dokumentasi Uji Coba',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Praktikum Pemrograman Mobile - Universitas Pakuan\n'
                    'Eksplorasi SQFlite (SQLite Relasional) vs Hive (NoSQL Key-Value)',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bagian 1: SQFlite
            _buildSectionCard(
              context,
              title: '1. SQFlite (SQLite Relasional)',
              icon: Icons.table_chart,
              iconColor: Colors.indigo,
              content: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SQFlite adalah plugin resmi Flutter untuk berinteraksi dengan database SQLite bawaan sistem operasi. '
                    'Menggunakan paradigma relasional (SQL) berbasis tabel, baris, dan kolom dengan skema yang terdefinisi ketat.',
                    style: TextStyle(fontSize: 13, height: 1.5),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Operasi CRUD yang Diterapkan:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  SizedBox(height: 6),
                  _BulletPoint(
                    title: 'Create (Insert):',
                    desc: 'db.insert("tasks", task.toMap()) - Menyimpan record baru dan mengembalikan ID baris yang di-generate.',
                  ),
                  _BulletPoint(
                    title: 'Read (Select):',
                    desc: 'db.query("tasks", orderBy: "id DESC") - Mengambil seluruh record dalam bentuk List<Map<String, dynamic>>.',
                  ),
                  _BulletPoint(
                    title: 'Update:',
                    desc: 'db.update("tasks", task.toMap(), where: "id = ?", whereArgs: [id]) - Memperbarui data berdasarkan primary key.',
                  ),
                  _BulletPoint(
                    title: 'Delete:',
                    desc: 'db.delete("tasks", where: "id = ?", whereArgs: [id]) - Menghapus data spesifik dari tabel.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bagian 2: Hive
            _buildSectionCard(
              context,
              title: '2. Teknologi Alternatif: Hive (NoSQL)',
              icon: Icons.bolt,
              iconColor: Colors.amber.shade800,
              content: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hive adalah database key-value lokal yang sangat ringan dan cepat, ditulis murni menggunakan bahasa Dart (Pure Dart). '
                    'Tidak memiliki dependensi library native (C/C++), sehingga dapat berjalan mulus di semua platform Flutter (Mobile, Desktop, Web).',
                    style: TextStyle(fontSize: 13, height: 1.5),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Keunggulan Utama Hive:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  SizedBox(height: 6),
                  _BulletPoint(
                    title: 'Performa Sangat Tinggi:',
                    desc: 'Penyimpanan langsung ke file biner tanpa parsing query SQL, membuatnya jauh lebih cepat dibanding SQLite untuk operasi baca/tulis sederhana.',
                  ),
                  _BulletPoint(
                    title: 'Struktur Box (Key-Value):',
                    desc: 'Data disimpan dalam konsep "Box" yang mirip dengan Map atau NoSQL Document Collection.',
                  ),
                  _BulletPoint(
                    title: 'Pure Dart & Zero Native Overhead:',
                    desc: 'Tidak memerlukan konfigurasi library native C, tidak memerlukan file .so/.dll khusus.',
                  ),
                  _BulletPoint(
                    title: 'Built-in Encryption:',
                    desc: 'Mendukung enkripsi data AES-256 bawaan tanpa perlu plugin eksternal tambahan.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bagian 3: Tabel Perbandingan
            _buildSectionCard(
              context,
              title: '3. Tabel Perbandingan SQFlite vs Hive',
              icon: Icons.compare_arrows,
              iconColor: Colors.teal,
              content: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.teal.shade50),
                  columns: const [
                    DataColumn(label: Text('Parameter', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('SQFlite (SQLite)', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Hive (NoSQL)', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: const [
                    DataRow(cells: [
                      DataCell(Text('Paradigma')),
                      DataCell(Text('Relasional (SQL, Tabel, Relasi FK)')),
                      DataCell(Text('NoSQL (Key-Value, Document Box)')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Bahasa & Engine')),
                      DataCell(Text('SQLite C Engine (Native Bridge)')),
                      DataCell(Text('Pure Dart (Tanpa Native Bridge)')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Kecepatan Tulis/Baca')),
                      DataCell(Text('Cepat, ada overhead parsing SQL')),
                      DataCell(Text('Sangat Cepat (Direct Binary Access)')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Kompleksitas Query')),
                      DataCell(Text('Tinggi (JOIN, Group By, Subquery, Index)')),
                      DataCell(Text('Terbatas (Filter in-memory Dart)')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Dukungan Web')),
                      DataCell(Text('Terbatas / Memerlukan FFI WebAssembly')),
                      DataCell(Text('Didukung Penuh (IndexedDB di Web)')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Integritas Data')),
                      DataCell(Text('Ketat (Foreign Keys, Constraints, Types)')),
                      DataCell(Text('Fleksibel (Schema-less Map/Object)')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Kasus Penggunaan')),
                      DataCell(Text('Data berelasi, e-commerce, akuntansi')),
                      DataCell(Text('Cache, offline sync, to-do, settings')),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bagian 4: Hasil Uji Coba CRUD
            _buildSectionCard(
              context,
              title: '4. Hasil Uji Coba CRUD & Kesimpulan',
              icon: Icons.verified,
              iconColor: Colors.green,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 24),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Status Uji Coba: 8/8 Automated Unit Tests LULUS (PASS)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Kesimpulan & Rekomendasi:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  const _BulletPoint(
                    title: 'Gunakan SQFlite jika:',
                    desc: 'Aplikasi membutuhkan struktur relasi multi-tabel (One-to-Many, Many-to-Many), transaksi data atomik (ACID), serta query agregasi kompleks seperti JOIN dan GROUP BY.',
                  ),
                  const _BulletPoint(
                    title: 'Gunakan Hive jika:',
                    desc: 'Aplikasi mengutamakan performa loading cepat, kemudahan setup tanpa boilerplate SQL, portabilitas lintas platform (Android, iOS, Windows, Web), atau penyimpanan data berbasis objek/cache offline.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget content,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            content,
          ],
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String title;
  final String desc;

  const _BulletPoint({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 12.5, height: 1.4),
                children: [
                  TextSpan(
                    text: '$title ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
