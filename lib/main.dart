import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cmproject/data/metro_repository.dart';
import 'package:cmproject/models/station.dart';
import 'package:cmproject/screens/main_page.dart';

void main() {
  final repository = MetroRepository();

  repository.insertStation(
    Station(
      id: '1',
      name: 'Oriente',
      latitude: 38.7678,
      longitude: -9.0988,
      lineName: 'Linha Rosa',
    ),
  );

  repository.insertStation(
    Station(
      id: '2',
      name: 'Marquês de Pombal',
      latitude: 38.7926,
      longitude: -9.1738,
      lineName: 'Linha Azul',
    ),
  );

  repository.insertStation(
    Station(
      id: '3',
      name: 'Baixa-Chiado',
      latitude: 38.7107,
      longitude: -9.1406,
      lineName: 'Linha Verde',
    ),
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