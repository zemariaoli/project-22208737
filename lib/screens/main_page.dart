import 'package:flutter/material.dart';
import 'package:cmproject/screens/dashboard_screen.dart';
import 'package:cmproject/screens/list_screen.dart';
import 'package:cmproject/screens/map_screen.dart';
import 'package:cmproject/screens/incident_screen.dart';

/// Ecrã principal da aplicação com navegação por bottom bar.
/// Gere a troca entre os 4 ecrãs: Dashboard, Lista, Mapa e Incidentes.
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainPage> {
  // ─── Estado ───────────────────────────────────────────────────────────────

  /// Índice do ecrã atualmente selecionado na bottom bar.
  int selectedIndex = 0;

  // ─── Lógica de navegação ──────────────────────────────────────────────────

  /// Atualiza o ecrã visível ao clicar num item da bottom bar.
  void onItemTapped(int index) {
    setState(() => selectedIndex = index);
  }

  /// Devolve o widget correspondente ao índice selecionado.
  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const ListScreen();
      case 2:
        return MapScreen();
      case 3:
        return const IncidentsScreen();
      default:
        return const DashboardScreen();
    }
  }

  // ─── Build principal ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Ecrã ativo consoante o índice selecionado
      body: _buildScreen(selectedIndex),

      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 8,

        // Cor do indicador do item selecionado
        indicatorColor: const Color(0xFFB71C1C),

        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: selectedIndex,
        onDestinationSelected: onItemTapped,

        destinations: const [
          // ── Dashboard ────────────────────────────────────────────────────
          NavigationDestination(
            key: Key('dashboard-bottom-bar-item'),
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: Colors.white),
            label: 'Dashboard',
          ),

          // ── Lista de estações ─────────────────────────────────────────────
          NavigationDestination(
            key: Key('list-bottom-bar-item'),
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt, color: Colors.white),
            label: 'Lista',
          ),

          // ── Mapa interativo ───────────────────────────────────────────────
          NavigationDestination(
            key: Key('map-bottom-bar-item'),
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map, color: Colors.white),
            label: 'Mapa',
          ),

          // ── Reporte de incidentes ─────────────────────────────────────────
          NavigationDestination(
            key: Key('incidents-report-bottom-bar-item'),
            icon: Icon(Icons.report_outlined),
            selectedIcon: Icon(Icons.report, color: Colors.white),
            label: 'Incidentes',
          ),
        ],
      ),
    );
  }
}