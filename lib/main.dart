import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cmproject/connectivity_module.dart';
import 'package:cmproject/data/generic_data_source.dart';
//import 'package:cmproject/data/http_generic_data_source.dart';
import 'package:cmproject/data/http_metro_datasource.dart';
import 'package:cmproject/data/metro_repository.dart';
import 'package:cmproject/data/sqflite_metro_datasource.dart';
import 'package:cmproject/location_module.dart';
import 'package:cmproject/screens/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final local = SqfliteMetroDataSource();
  await local.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<HttpMetroDataSource>.value(value: HttpMetroDataSource()),
        Provider<SqfliteMetroDataSource>.value(value: local),
        Provider<ConnectivityModule>.value(value: ConnectivityModule()),
        Provider<LocationModule>.value(value: LocationModule()),
        //Provider<GenericDataSource>.value(value: HttpGenericDataSource()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        GenericDataSource? generic;
        try {
          generic = context.read<GenericDataSource>();
        } catch (_) {}

        return MetroRepository(
          remote: context.read<HttpMetroDataSource>(),
          local: context.read<SqfliteMetroDataSource>(),
          connectivity: context.read<ConnectivityModule>(),
          generic: generic,
        );
      },
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MainPage(),
      ),
    );
  }
}