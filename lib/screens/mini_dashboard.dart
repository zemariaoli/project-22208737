import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cmproject/data/metro_repository.dart';
import 'package:cmproject/models/station.dart';

class MiniDashboardScreen extends StatefulWidget {
  const MiniDashboardScreen({super.key});

  @override
  State<MiniDashboardScreen> createState() => _MiniDashboardScreenState();
}

class _MiniDashboardScreenState extends State<MiniDashboardScreen> {

  Future<List<Station>>? _stationsFuture;

  @override
  void initState() {
    super.initState();
    _stationsFuture = context.read<MetroRepository>().getStations();
  }


  @override
  Widget build(BuildContext context) {
    final repository = context.read<MetroRepository>();

    return Scaffold(
      body: FutureBuilder<List<Station>>(
        future: _stationsFuture,
        builder: (context, snapshot) {

          final stations = repository.cachedStations.isNotEmpty
              ? repository.cachedStations
              : snapshot.data ?? [];

          int estacoesDaLinhaVerde = 0;
          int estacoesDaLinhaAzul = 0;

          for (Station s in stations) {
            if (s.lineName == '[Verde]'){
              estacoesDaLinhaVerde++;
            }else if (s.lineName == '[Azul]'){
              estacoesDaLinhaAzul++;
            }
          }


          return Column(

            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              Row(
                children: [
                  const SizedBox(width: 80,),
                  Text(
                      'Mini Dashboard',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      )
                  ),
                ],
              ),

              const SizedBox(height: 120),


              Row(
                children: [
                  const SizedBox(width: 120,),
                  Text(
                   'Verde: $estacoesDaLinhaVerde',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.green
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [

                  const SizedBox(width: 120,),

                  Text(
                    'Azul: $estacoesDaLinhaAzul',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  )
                ],
              ),

              const SizedBox(height: 250),


              ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: (
                    Text(
                      'OK',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    )
                  )
              )
            ],
          );
        },
      ),
    );
  }







}