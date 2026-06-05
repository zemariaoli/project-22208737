import 'package:cmproject/data/metro_repository.dart';
import 'package:cmproject/models/station.dart';
import 'package:cmproject/screens/list_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Ecrã de listagem das estações do Metro de Lisboa.
/// Suporta pesquisa por nome e linha, e navega para o detalhe de cada estação.
class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  // ─── Estado ───────────────────────────────────────────────────────────────

  /// Texto de pesquisa introduzido pelo utilizador.
  String searchStation = '';

  /// Future para carregar as estações da API / base de dados.
  Future<List<Station>>? _stationsFuture;

  // ─── Ciclo de vida ────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // Carrega as estações uma única vez ao inicializar o ecrã
    _stationsFuture = context.read<MetroRepository>().getStations();
  }

  // ─── Lógica de linhas ─────────────────────────────────────────────────────

  /// Extrai os nomes das linhas a partir do campo lineName da estação.
  /// Suporta múltiplas linhas separadas por vírgula, ponto e vírgula, etc.
  List<String> _extractLineNames(String lineName) {
    var cleaned = lineName
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('"', '')
        .replaceAll("'", '')
        .trim();

    // Remove a palavra "Linha" para evitar duplicação
    cleaned = cleaned.replaceAll(
      RegExp(r'\bLinha\b', caseSensitive: false),
      '',
    );

    return cleaned
        .split(RegExp(r'\s*(?:,|;|/|\||\be\b)\s*', caseSensitive: false))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map(_capitalize)
        .toList();
  }

  /// Coloca a primeira letra de cada palavra em maiúscula.
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').where((w) => w.isNotEmpty).map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Formata o nome da linha para apresentação ao utilizador.
  /// Exemplos: "Verde" → "Linha Verde" | "Verde, Amarela" → "Linha Verde e Amarela"
  String formatLineName(String lineName) {
    final lines = _extractLineNames(lineName);

    if (lines.isEmpty) return 'Linha desconhecida';
    if (lines.length == 1) return 'Linha ${lines.first}';
    if (lines.length == 2) return 'Linha ${lines[0]} e ${lines[1]}';

    final firstLines = lines.sublist(0, lines.length - 1).join(', ');
    return 'Linha $firstLines e ${lines.last}';
  }

  // ─── Lógica de cores ──────────────────────────────────────────────────────

  /// Devolve a lista de cores correspondentes às linhas da estação.
  List<Color> _lineColors(String lineName) {
    final lines = _extractLineNames(lineName);
    if (lines.isEmpty) return [Colors.blueGrey];
    return lines.map(_colorFromLineName).toList();
  }

  /// Mapeia o nome de uma linha para a sua cor representativa.
  Color _colorFromLineName(String lineName) {
    switch (lineName.toLowerCase().trim()) {
      case 'azul':
        return Colors.blue;
      case 'amarela':
      case 'amarelo':
        return Colors.amber;
      case 'verde':
        return Colors.green;
      case 'vermelha':
      case 'vermelho':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  // ─── Lógica de filtragem ──────────────────────────────────────────────────

  /// Filtra as estações com base no texto introduzido na pesquisa.
  List<Station> _filterStations(List<Station> stations) {
    final query = searchStation.toLowerCase();
    return stations.where((station) {
      return station.name.toLowerCase().contains(query) ||
          formatLineName(station.lineName).toLowerCase().contains(query);
    }).toList();
  }

  // ─── Navegação ────────────────────────────────────────────────────────────

  /// Navega para o ecrã de detalhe da estação selecionada.
  void _navigateToDetail(BuildContext context, Station station) {
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
  }

  // ─── Widgets auxiliares ───────────────────────────────────────────────────

  /// Barra de pesquisa no topo da lista.
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        onChanged: (value) => setState(() => searchStation = value),
        decoration: InputDecoration(
          hintText: 'Pesquisar estação...',
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFB71C1C)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFB71C1C), width: 2),
          ),
        ),
      ),
    );
  }

  /// Card de cabeçalho com o título da rede metropolitana.
  Widget _buildNetworkHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8E0000), Color(0xFFC62828)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rede Metropolitana',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            SizedBox(height: 4),
            Text(
              'Estações do Metro de Lisboa',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Avatar circular com a cor da linha (ou metade/metade se forem duas linhas).
  Widget _buildLineAvatar(Station station) {
    final colors = _lineColors(station.lineName);

    // Uma só linha — avatar simples
    if (colors.length == 1) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: colors.first,
        child: _buildAvatarLetter(station),
      );
    }

    // Múltiplas linhas — avatar dividido horizontalmente
    return ClipOval(
      child: SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          children: [
            Row(
              children: colors
                  .map((color) => Expanded(child: Container(color: color)))
                  .toList(),
            ),
            Center(child: _buildAvatarLetter(station)),
          ],
        ),
      ),
    );
  }

  /// Letra inicial do nome da estação usada dentro do avatar.
  Widget _buildAvatarLetter(Station station) {
    return Text(
      station.name.isNotEmpty ? station.name[0].toUpperCase() : '?',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  /// Card individual de cada estação na lista.
  Widget _buildStationTile(BuildContext context, Station station) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: Color(0xFFB71C1C), width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: _buildLineAvatar(station),
          title: Text(
            station.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          subtitle: Text(
            formatLineName(station.lineName),
            style: TextStyle(color: Colors.grey.shade600),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Color(0xFFB71C1C),
          ),
          onTap: () => _navigateToDetail(context, station),
        ),
      ),
    );
  }

  /// Lista de estações filtradas.
  Widget _buildList(List<Station> filteredStations) {
    return ListView.separated(
      key: const Key('list-view'),
      itemCount: filteredStations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 2),
      itemBuilder: (context, index) =>
          _buildStationTile(context, filteredStations[index]),
    );
  }

  /// Mensagem de erro mostrada quando não há estações disponíveis
  /// (modo offline sem dados locais ou falha de rede).
  Widget _buildErrorMessage() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Não foi possível obter as estações de metro. Verifique a conectividade e volte a tentar',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Build principal ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('list-screen'),
      appBar: AppBar(
        title: const Text(
          'Estações',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
      ),
      body: Container(
        // Fundo com gradiente suave de vermelho claro para branco
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFEBEE), Color(0xFFF8F8F8)],
          ),
        ),
        child: Column(
          children: [
            _buildSearchBar(),
            _buildNetworkHeader(),
            Expanded(
              child: FutureBuilder<List<Station>>(
                future: _stationsFuture,
                builder: (context, snapshot) {
                  // A carregar
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFB71C1C),
                      ),
                    );
                  }

                  // Erro de rede ou API
                  if (snapshot.hasError) return _buildErrorMessage();

                  final stations = snapshot.data ?? [];

                  // Sem estações (offline sem cache)
                  if (stations.isEmpty) return _buildErrorMessage();

                  final filteredStations = _filterStations(stations);

                  // Pesquisa sem resultados
                  if (filteredStations.isEmpty) {
                    return const Center(
                      child: Text('Sem estações disponíveis.'),
                    );
                  }

                  return _buildList(filteredStations);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}