import 'package:flutter/material.dart';
import 'package:cmproject/screens/dashboard_screen.dart';
import 'package:cmproject/screens/list_screen.dart';
import 'package:cmproject/screens/map_screen.dart';
import 'package:cmproject/screens/incident_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainPage> {
  int selectedIndex = 0;

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildScreen(selectedIndex),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onItemTapped,
        destinations: const [
          NavigationDestination(
            key: Key('dashboard-bottom-bar-item'),
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            key: Key('list-bottom-bar-item'),
            icon: Icon(Icons.list),
            label: 'List',
          ),
          NavigationDestination(
            key: Key('map-bottom-bar-item'),
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            key: Key('incidents-report-bottom-bar-item'),
            icon: Icon(Icons.report),
            label: 'Incidents',
          ),
        ],
      ),
    );
  }
}