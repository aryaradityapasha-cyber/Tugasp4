import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/sqflite_helper.dart';
import 'services/hive_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi engine SQLite FFI untuk platform Windows / Linux
  SqfliteHelper.initializePlatform();

  // Inisialisasi Hive NoSQL Storage
  await HiveHelper.initHive();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tugas P4 Mopro - CRUD & Local Storage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 2,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
