import 'package:cmproject/data/metro_repository.dart';
import 'package:cmproject/models/station.dart';
import 'package:cmproject/screens/list_detail_screen.dart';
import 'package:flutter/material.dart';

class ListScreen extends StatefulWidget {
  ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<Station> stations = [];
  String searchStation = '';
  final MetroRepository repository = MetroRepository();

  @override
  void initState() {
    super.initState();
    stations = repository.getStations();
  }


  @override
  Widget build(BuildContext context) {



    final filteredStations = stations.where((station) {
      final name = station.name.toLowerCase();
      final line = station.lineName.toLowerCase();
      final query = searchStation.toLowerCase();

      return name.contains(query) || line.contains(query);
    }).toList();

    return Scaffold(
        key: Key('list-screen'),
        appBar: AppBar(
          title: const Text('Lista'),
        ),
        body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(9),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchStation = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search stations...',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: buildList(filteredStations),
                  ),
                ],
            ),
    );
  }

  Widget buildList(List<Station> filteredStations) {
    return ListView.separated(
      key: const Key('list-view'),
      itemCount: filteredStations.length,
      separatorBuilder: (_, index) => const Divider(color: Colors.white, thickness: 0.5),
      itemBuilder: (context, index) {
        // Criamos uma referência para a estação correta (a filtrada)
        final station = filteredStations[index];

        return ListTile(
          title: Text(station.name), // Agora usamos a estação da lista filtrada
          subtitle: Text(station.lineName),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StationDetailPage(
                stationId: station.id,
                stationName: station.name,
                lineName: station.lineName,
                longitude: station.longitude,
                latitude: station.latitude,
                reports: station.reports, // Use os reports que já vêm na estação
              ),
            ),
          ),
        );
      },
    );
  }
}
