import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:tugas_crud/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    tempDir = await Directory.systemTemp.createTemp('hive_widget_test_');
    Hive.init(tempDir.path);
    await Hive.openBox('student_tasks_box');
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  testWidgets('App renders Home with navigation tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // Verify AppBar title exists
    expect(find.text('Tugas Praktikum 4 - CRUD & Local Storage'), findsOneWidget);

    // Verify BottomNavigationBar destinations
    expect(find.text('SQFlite'), findsOneWidget);
    expect(find.text('Hive (Alternatif)'), findsOneWidget);
    expect(find.text('Ringkasan'), findsOneWidget);
  });
}
