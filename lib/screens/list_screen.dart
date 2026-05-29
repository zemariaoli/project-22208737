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
  Future<List<Station>>? _stationsFuture;

  @override
  void initState() {
    super.initState();
    _stationsFuture = context.read<MetroRepository>().getStations();
  }

  String formatLineName(String lineName) {
    if (lineName.startsWith('Linha ')) return lineName;
    return 'Linha $lineName';
  }

  @override
  Widget build(BuildContext context) {
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
                hintText: 'Pesquisar estação...',
                border: UnderlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Station>>(
              future: _stationsFuture,
              builder: (context, snapshot) {
                // A carregar
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Erro
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 8),
                        Text('Erro: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _stationsFuture =
                                  context.read<MetroRepository>().getStations();
                            });
                          },
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                // Sem dados
                final stations = snapshot.data ?? [];
                final filteredStations = stations.where((station) {
                  final name = station.name.toLowerCase();
                  final line = formatLineName(station.lineName).toLowerCase();
                  final query = searchStation.toLowerCase();
                  return name.contains(query) || line.contains(query);
                }).toList();

                if (filteredStations.isEmpty) {
                  return const Center(child: Text('Sem estações disponíveis.'));
                }

                return buildList(filteredStations);
              },
            ),
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
        return const Divider(color: Colors.white, thickness: 0.5);
      },
      itemBuilder: (context, index) {
        final station = filteredStations[index];

        return ListTile(
          title: Text(station.name),
          subtitle: Text(formatLineName(station.lineName)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StationDetailPage(
                  stationId: station.id,
                  stationName: station.name,
                  lineName: formatLineName(station.lineName),
                  latitude: station.latitude,
                  longitude: station.longitude,
                ),
              ),
            );
          },
        );
      },
    );
  }
}