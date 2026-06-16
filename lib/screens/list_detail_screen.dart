import 'package:flutter/material.dart';
import 'package:cmproject/data/metro_repository.dart';
import 'package:cmproject/models/incident_report.dart';
import 'package:cmproject/models/station.dart';
import 'package:cmproject/location_module.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Ecrã de detalhe de uma estação do Metro de Lisboa.
/// Apresenta informações da estação, tempos de espera dos comboios
/// e incidentes reportados.
class StationDetailPage extends StatefulWidget {
  final String stationId;
  final String stationName;
  final String lineName;
  final double latitude;
  final double longitude;
  final String origem;


  const StationDetailPage({
    super.key,
    required this.stationId,
    required this.stationName,
    required this.lineName,
    required this.latitude,
    required this.longitude,
    required this.origem,
  });

  @override
  State<StationDetailPage> createState() => _StationDetailPageState();
}

class _StationDetailPageState extends State<StationDetailPage> {
  // ─── Futures para carregamento assíncrono ─────────────────────────────────

  /// Future para carregar os dados da estação.
  Future<Station?> _stationFuture = Future.value(null);

  /// Future para carregar os tempos de espera dos comboios.
  Future<List<Map<String, dynamic>>> _waitTimesFuture = Future.value([]);

  // ─── Estado local ─────────────────────────────────────────────────────────

  /// Distância em metros entre o utilizador e a estação.
  double? _distanceMeters;

  /// Hora da última atualização dos tempos de espera (formato HH:mm).
  String? _lastUpdateTime;



  // ─── Ciclo de vida ────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final repository = context.read<MetroRepository>();

    // Carrega os dados da estação
    _stationFuture = repository.getStation(widget.stationId);

    // Carrega os tempos de espera e regista a hora quando chegarem
    _waitTimesFuture = repository.getWaitTimes(widget.stationId).then((data) {
      if (mounted && data.isNotEmpty) {
        setState(() {
          _lastUpdateTime = DateFormat('HH:mm').format(DateTime.now());
        });
      }
      return data;
    });

    // Calcula a distância à estação em segundo plano
    _loadDistance();
  }

  // logica se é perigosa a estacao

  bool _verificaPerigo(Station station) {

    final reports = station.reports;

    bool haperigo = false;

    for (IncidentReport i in reports) {
      if (i.danger == true){
        haperigo = true;
      }
    }

    return haperigo;
  }





  // ─── Lógica de localização ────────────────────────────────────────────────

  /// Obtém a posição atual do utilizador e calcula a distância à estação.
  Future<void> _loadDistance() async {
    final locationModule = context.read<LocationModule>();
    final position = await locationModule.getCurrentPosition();
    if (position == null) return;

    final distance = locationModule.distanceTo(
      fromLat: position.latitude,
      fromLon: position.longitude,
      toLat: widget.latitude,
      toLon: widget.longitude,
    );

    setState(() => _distanceMeters = distance);
  }

  // ─── Utilitários ──────────────────────────────────────────────────────────

  /// Garante que o nome da linha começa sempre com "Linha ".
  String formatLineName(String lineName) {
    if (lineName.startsWith('Linha ')) return lineName;
    return 'Linha $lineName';
  }

  /// Devolve a cor do badge do tempo de espera consoante a urgência:
  /// verde (<= 60s), laranja (<= 180s) ou vermelho (> 180s).
  Color _waitTimeColor(dynamic time) {
    final seconds = int.tryParse(time.toString()) ?? 0;
    if (seconds <= 60) return Colors.green.shade600;
    if (seconds <= 180) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  // ─── Widgets auxiliares ───────────────────────────────────────────────────

  ///Texto com o meio de navegacao ate aqui
  Widget _buildMeiodeNavegacao() {
    return Text(widget.origem);
  }



  /// Título de secção com barra vermelha lateral e sufixo opcional.
  Widget _buildSectionTitle(String title, {String? suffix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Barra vermelha decorativa
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFFB71C1C),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB71C1C),
            ),
          ),
          // Sufixo opcional (ex: hora de atualização)
          if (suffix != null) ...[
            const SizedBox(width: 6),
            Text(
              suffix,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

 Future<void> estacaofavorita(MetroRepository repository, String id) async {

   Station? station = await repository.getStation(id);

   IncidentType? type = IncidentType.Other;
   int? rating = 5;
   DateTime dateTime = DateTime.now();
   String? notes = 'Avaliação automática';
   bool perigo = false;

   final report = IncidentReport(
       timestamp: dateTime,
       rate: rating,
       notes: notes,
       type: type,
       danger: perigo
   );

   await repository.attachIncident(station!.id, report);

   setState(() {});

 }


  /// Card com as informações principais da estação (nome, linha, distância, média).
  Widget _buildStationCard(Station station, double? avgRating) {

    final repository = context.read<MetroRepository>();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Nome e linha da estação
            Row(
              children: [
                const Icon(Icons.train, color: Colors.blueGrey, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatLineName(station.lineName),
                        style: TextStyle(color: Colors.grey.shade600),
                      ),

                      ElevatedButton(
                        onPressed:() async => await estacaofavorita(repository, station.id),
                        child: Text('Máxima Avaliação')
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Chips de distância e média de incidentes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoChip(
                  Icons.location_on,
                  _distanceMeters != null
                      ? '${_distanceMeters!.toStringAsFixed(0)} m'
                      : '...',
                  'Distância',
                ),
                _buildInfoChip(
                  Icons.star,
                  avgRating != null ? avgRating.toStringAsFixed(1) : 'N/A',
                  'Média',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Chip de informação com ícone, valor e label.
  Widget _buildInfoChip(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueGrey),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }


  Widget _buildHaPerigo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.dangerous, color: Colors.grey),
          SizedBox(width: 8),
          Text(
            'ESTAÇÃO PERIGOSA',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );

  }


  /// Secção de tempos de espera, agrupada por cais.
  /// Cada cais tem um header com cor e os comboios listados por baixo.
  Widget _buildWaitTimesSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _waitTimesFuture,
      builder: (context, snapshot) {
        // A carregar
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final waitTimes = snapshot.data ?? [];

        // Sem dados disponíveis
        if (waitTimes.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Sem tempos de espera disponíveis.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Agrupa os comboios por cais
        // Cada entrada da API pode ter até 3 comboios (comboio, comboio2, comboio3)
        final Map<String, List<Map<String, dynamic>>> byCais = {};
        for (final wt in waitTimes) {
          final cais = wt['cais'] ?? 'Desconhecido';
          byCais.putIfAbsent(cais, () => []);

          if (wt['comboio'] != null && wt['tempoChegada1'] != null) {
            byCais[cais]!.add({
              'comboio': wt['comboio'],
              'tempo': wt['tempoChegada1'],
            });
          }
          if (wt['comboio2'] != null && wt['tempoChegada2'] != null) {
            byCais[cais]!.add({
              'comboio': wt['comboio2'],
              'tempo': wt['tempoChegada2'],
            });
          }
          if (wt['comboio3'] != null && wt['tempoChegada3'] != null) {
            byCais[cais]!.add({
              'comboio': wt['comboio3'],
              'tempo': wt['tempoChegada3'],
            });
          }

          // Ordena os comboios de cada cais por tempo de chegada crescente
          byCais[cais]!.sort((a, b) {
            final ta = int.tryParse(a['tempo'].toString()) ?? 0;
            final tb = int.tryParse(b['tempo'].toString()) ?? 0;
            return ta.compareTo(tb);
          });
        }

        // Renderiza um card por cais
        return Column(
          children: byCais.entries.map((entry) {
            final cais = entry.key;
            final trains = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
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
                  // Header do cais
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade800,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.train, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Cais $cais',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Lista de comboios do cais
                  ...trains.asMap().entries.map((trainEntry) {
                    final index = trainEntry.key;
                    final train = trainEntry.value;
                    final seconds =
                        int.tryParse(train['tempo'].toString()) ?? 0;
                    final minutes = seconds ~/ 60;
                    final secs = seconds % 60;

                    // Formata o tempo: "1m 37s" ou "45s"
                    final timeLabel =
                    minutes > 0 ? '${minutes}m ${secs}s' : '${secs}s';

                    return Column(
                      children: [
                        if (index > 0) const Divider(height: 1),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.directions_subway,
                              color: Colors.blueGrey,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            'Comboio ${train['comboio']}',
                            style:
                            const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          // Badge colorido com o tempo de espera
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _waitTimeColor(seconds),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              timeLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// Card individual de um incidente reportado.
  Widget _buildIncidentTile(IncidentReport report) {
    final formattedDate =
    DateFormat('dd/MM/yyyy HH:mm').format(report.timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
        title: Row(
          children: [
            Text(formattedDate),
            const SizedBox(width: 8),
            // Badge com o tipo de incidente
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                report.type.name.toUpperCase(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
        // Notas do incidente (se existirem)
        subtitle: report.notes != null && report.notes!.isNotEmpty
            ? Text(report.notes!)
            : null,
      ),
    );
  }

  /// Lista de incidentes da estação.
  /// Usa shrinkWrap para funcionar dentro de um SingleChildScrollView.
  Widget _buildIncidentsSection(List<IncidentReport> reports) {
    return ListView.builder(
      key: const Key('detail-screen-incidents-list'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reports.length,
      itemBuilder: (context, index) => _buildIncidentTile(reports[index]),
    );
  }

  // ─── Build principal ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // context.watch deteta o notifyListeners do repositório
    // (ex: quando um novo incidente é adicionado)
    final repository = context.watch<MetroRepository>();

    return Scaffold(
      key: const Key('detail-screen'),
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text(widget.stationName),
        elevation: 0,
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Station?>(
        future: _stationFuture,
        builder: (context, snapshot) {
          // A carregar
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Estação não encontrada
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Estação não encontrada'));
          }

          final station = snapshot.data!;

          // Combina incidentes do datasource com os adicionados na sessão atual
          final reportsFromStation = station.reports;
          final reportsFromSession =
          repository.getIncidents(widget.stationId);
          final reports = [
            ...reportsFromStation,
            ...reportsFromSession
                .where((r) => !reportsFromStation.contains(r)),
          ];

          // Calcula a média de avaliação dos incidentes
          final avgRating = reports.isEmpty
              ? null
              : reports.map((r) => r.rate).reduce((a, b) => a + b) /
              reports.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card com os dados da estação
                _buildStationCard(station, avgRating),
                const SizedBox(height: 24),

                _buildMeiodeNavegacao(),
                const SizedBox(height: 40),

                if (_verificaPerigo(station) == true) _buildHaPerigo(),
                const SizedBox(height: 40),

                // Tempos de espera (com hora de atualização se disponível)
                _buildSectionTitle(
                  'Tempos de espera',
                  suffix: _lastUpdateTime != null
                      ? '(última atualização: $_lastUpdateTime)'
                      : null,
                ),
                _buildWaitTimesSection(),
                const SizedBox(height: 24),

                // Incidentes reportados
                _buildSectionTitle('Incidentes'),
                _buildIncidentsSection(reports),
              ],
            ),
          );
        },
      ),
    );
  }
}