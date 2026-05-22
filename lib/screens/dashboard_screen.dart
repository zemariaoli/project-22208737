import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cmproject/data/metro_repository.dart';
import 'package:cmproject/models/station.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<MetroRepository>();

    return Scaffold(
      key: const Key('dashboard-screen'),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blueGrey[100],
      ),
      body: FutureBuilder<List<Station>>(
        future: repository.getStations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final stations = snapshot.data ?? [];

          final totalStations = stations.length;
          final totalIncidents =
          stations.fold(0, (acc, s) => acc + s.reports.length);
          final mediaGeral = totalIncidents > 0
              ? (stations.fold(0.0, (acc, s) {
            final total =
            s.reports.fold(0.0, (sum, r) => sum + r.rate);
            return acc + total;
          }) / totalIncidents)
              : 0.0;

          Station? stationDestaque;
          int maiorNumeroIncidentes = 0;

          for (final s in stations) {
            if (s.reports.length > maiorNumeroIncidentes) {
              maiorNumeroIncidentes = s.reports.length;
              stationDestaque = s;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ESTAÇÃO EM DESTAQUE
                if (stationDestaque != null)
                  Card(
                    color: Colors.blueGrey[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.train,
                        size: 40,
                        color: Colors.blueGrey,
                      ),
                      title: const Text('Estação com Mais Incidentes'),
                      subtitle: Text(
                        '${stationDestaque.name}\nLinha: ${stationDestaque.lineName} — $maiorNumeroIncidentes incidente(s)',
                      ),
                    ),
                  )
                else
                  const Text(
                    'Sem incidentes registados.',
                    style: TextStyle(color: Colors.grey),
                  ),

                const SizedBox(height: 16),

                // INDICADORES
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _DashboardIndicator(
                      title: 'Estações',
                      value: '$totalStations',
                      icon: Icons.location_on,
                    ),
                    _DashboardIndicator(
                      title: 'Incidentes',
                      value: '$totalIncidents',
                      icon: Icons.warning_amber_rounded,
                    ),
                    _DashboardIndicator(
                      title: 'Média',
                      value: '${mediaGeral.toStringAsFixed(1)} ★',
                      icon: Icons.star,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // FACTO CURIOSO
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 32, color: Colors.deepPurple),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Sabias que o Metro de Lisboa transporta mais de 170 milhões de passageiros por ano?',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // COMENTÁRIOS
                const Text(
                  'O que dizem os utilizadores:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Text(
                  '🗣️ "Linha Azul sempre pontual e muito organizada!"',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 4),
                const Text(
                  '🗣️ "Estação do Oriente muito bem sinalizada e acessível!"',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DashboardIndicator extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _DashboardIndicator({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: Key('dashboard-indicator-$title'),
      children: [
        Icon(icon, size: 32, color: Colors.teal),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(title, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}