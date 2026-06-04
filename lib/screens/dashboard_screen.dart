import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cmproject/data/metro_repository.dart';
import 'package:cmproject/models/station.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  Future<List<Station>>? _stationsFuture;

  @override
  void initState() {
    super.initState();
    context.read<MetroRepository>().getStations();
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<MetroRepository>();

    return Scaffold(
      key: const Key('dashboard-screen'),
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Metro de Lisboa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Station>>(
        future: _stationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildError();
          }

          final stations = repository.cachedStations.isNotEmpty
              ? repository.cachedStations
              : snapshot.data ?? [];

          final totalStations = stations.length;
          final totalIncidents =
          stations.fold(0, (acc, s) => acc + s.reports.length);
          final avgRating = totalIncidents > 0
              ? stations.fold(0.0, (acc, s) {
            return acc +
                s.reports.fold(0.0, (sum, r) => sum + r.rate);
          }) /
              totalIncidents
              : 0.0;

          Station? topStation;
          int maxIncidents = 0;
          for (final s in stations) {
            if (s.reports.length > maxIncidents) {
              maxIncidents = s.reports.length;
              topStation = s;
            }
          }

          final lineCount = stations
              .map((s) => s.lineName)
              .toSet()
              .length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildStatsRow(
                  totalStations: totalStations,
                  totalIncidents: totalIncidents,
                  avgRating: avgRating,
                  lineCount: lineCount,
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Destaque'),
                const SizedBox(height: 8),
                topStation != null
                    ? _buildTopStationCard(topStation, maxIncidents)
                    : _buildEmptyCard('Sem incidentes registados ainda.'),
                const SizedBox(height: 20),
                _buildSectionTitle('Linhas'),
                const SizedBox(height: 8),
                _buildLinesCard(stations),

                const SizedBox(height: 20),

                _buildSectionTitle('Mapa da Rede'),
                const SizedBox(height: 8),
                _buildMetroMapCard(),

                const SizedBox(height: 20),

                _buildSectionTitle('Sabia que...'),
                const SizedBox(height: 8),

                _buildFactCard(),
                const SizedBox(height: 20),
                _buildSectionTitle('O que dizem os utilizadores'),
                const SizedBox(height: 8),
                _buildReviewsCard(),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetroMapCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.map_outlined,
                      color: Colors.blueGrey.shade700,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Mapa Oficial do Metro',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Explore todas as linhas e estações da rede metropolitana de Lisboa. Pode ampliar o mapa para uma visualização mais detalhada.',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Image.asset(
                'img.png',
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF8E0000),
            Color(0xFFC62828),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.train, color: Colors.white, size: 42),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Metro de Lisboa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Informação, estatísticas e monitorização da rede',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow({
    required int totalStations,
    required int totalIncidents,
    required double avgRating,
    required int lineCount,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            key: 'Estações',
            icon: Icons.location_on,
            value: '$totalStations',
            label: 'Estações',
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            key: 'Linhas',
            icon: Icons.linear_scale,
            value: '$lineCount',
            label: 'Linhas',
            color: Colors.green.shade700,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            key: 'Incidentes',
            icon: Icons.warning_amber_rounded,
            value: '$totalIncidents',
            label: 'Incidentes',
            color: Colors.orange.shade700,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            key: 'Média',
            icon: Icons.star,
            value: avgRating > 0 ? avgRating.toStringAsFixed(1) : '—',
            label: 'Média',
            color: Colors.purple.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String key,
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      key: Key('dashboard-indicator-$key'),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopStationCard(Station station, int incidentCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.emoji_events,
              color: Colors.orange.shade700,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mais incidentes registados',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  station.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Linha ${station.lineName}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.shade700,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$incidentCount',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinesCard(List<Station> stations) {
    final lines = <String, int>{};
    for (final s in stations) {
      lines[s.lineName] = (lines[s.lineName] ?? 0) + 1;
    }

    final lineColors = {
      'Azul': Colors.blue,
      'Amarela': Colors.amber,
      'Verde': Colors.green,
      'Vermelha': Colors.red,
      'Rosa': Colors.pink,
      'Castanha': Colors.brown,
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: lines.entries.map((entry) {
          final color = lineColors.entries
              .firstWhere(
                (e) => entry.key.toLowerCase().contains(e.key.toLowerCase()),
            orElse: () => const MapEntry('', Colors.blueGrey),
          )
              .value;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: color,
              radius: 12,
            ),
            title: Text('Linha ${entry.key}'),
            trailing: Text(
              '${entry.value} estações',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFactCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: const Color(0xFFB71C1C), size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'O Metro de Lisboa transporta mais de 170 milhões de passageiros por ano, sendo um dos mais modernos da Europa.',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsCard() {
    final reviews = [
      (
      icon: '🗣️',
      text: '"Linha Azul sempre pontual e muito organizada!"'
      ),
      (
      icon: '🗣️',
      text: '"Estação do Oriente muito bem sinalizada e acessível!"'
      ),
      (
      icon: '🗣️',
      text: '"Aplicação muito útil para reportar problemas rapidamente."'
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: reviews
            .map(
              (r) => ListTile(
            leading: Text(r.icon, style: const TextStyle(fontSize: 20)),
            title: Text(
              r.text,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 13,
              ),
            ),
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFB71C1C),
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: const TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildError() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'Não foi possível carregar os dados.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}