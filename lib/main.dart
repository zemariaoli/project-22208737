import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cmproject/connectivity_module.dart';
import 'package:cmproject/data/http_metro_datasource.dart';
import 'package:cmproject/data/metro_repository.dart';
import 'package:cmproject/data/sqflite_metro_datasource.dart';
import 'package:cmproject/screens/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa a base de dados
  final db = await openDatabase(
    join(await getDatabasesPath(), 'metro.db'),
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE stations (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          lineName TEXT NOT NULL,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL
        )
      ''');
    },
  );

  final repository = MetroRepository(
    remote: HttpMetroDataSource(),
    local: SqfliteMetroDataSource(db),
    connectivity: ConnectivityModule(),
  );

  runApp(
    Provider<MetroRepository>.value(
      value: repository,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}