import 'package:flutter/material.dart';
import 'sqflite_tab.dart';
import 'hive_tab.dart';
import 'summary_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    SqfliteTab(),
    HiveTab(),
    SummaryTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tugas Praktikum 4 - CRUD & Local Storage',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Pemrograman Mobile • Universitas Pakuan',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Tentang Aplikasi',
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'CRUD & Local Storage Flutter',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.storage, size: 40, color: Colors.indigo),
                children: const [
                  Text(
                    'Aplikasi demonstrasi implementasi database SQFlite dan teknologi local storage alternatif (Hive NoSQL) di Flutter.',
                  ),
                  SizedBox(height: 8),
                  Text('Fitur yang diimplementasikan:'),
                  Text('1. SQLite CRUD (Create, Read, Update, Delete)'),
                  Text('2. Hive NoSQL CRUD'),
                  Text('3. Filter Kategori, Status & Pencarian Data'),
                  Text('4. Analisis & Perbandingan Arsitektur Storage'),
                ],
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.table_rows_outlined),
            selectedIcon: Icon(Icons.table_rows, color: Colors.indigo),
            label: 'SQFlite',
          ),
          NavigationDestination(
            icon: Icon(Icons.dataset_outlined),
            selectedIcon: Icon(Icons.dataset, color: Colors.amber),
            label: 'Hive (Alternatif)',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics, color: Colors.teal),
            label: 'Ringkasan',
          ),
        ],
      ),
    );
  }
}
