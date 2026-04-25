import 'package:cmproject/data/metro_repository.dart';
import 'package:cmproject/models/station.dart';
import 'package:cmproject/screens/list_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  String searchStation = '';

  @override
  Widget build(BuildContext context) {
    final repository = Provider.of<MetroRepository>(context);
    final stations = repository.getStations();

    final filteredStations = stations.where((station) {
      final name = station.name.toLowerCase();
      final line = station.lineName.toLowerCase();
      final query = searchStation.toLowerCase();

      return name.contains(query) || line.contains(query);
    }).toList();

    return Scaffold(
      key: const Key('list-screen'),
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
      separatorBuilder: (context, index) {
        return const Divider(
          color: Colors.white,
          thickness: 0.5,
        );
      },
      itemBuilder: (context, index) {
        final station = filteredStations[index];

        return ListTile(
          title: Text(station.name),
          subtitle: Text(station.lineName),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return StationDetailPage(
                    stationId: station.id,
                    stationName: station.name,
                    lineName: station.lineName,
                    latitude: station.latitude,
                    longitude: station.longitude,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}