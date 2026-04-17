import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cmproject/screens/dashboard_screen.dart';
import 'package:cmproject/screens/list_screen.dart';
import 'package:cmproject/screens/map_screen.dart';
import 'package:cmproject/screens/incident_screen.dart';

class MainPage extends StatefulWidget {
  @override
  MainScreenState createState() => MainScreenState();
}



class MainScreenState extends State<MainPage> {

  int selectedIndex = 0;


  final List<Widget> screens = [
    DashboardScreen(),
    ListScreen(),
    MapScreen(),
    IncidentsScreen(),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
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
            key: Key('incidente-report-bottom-bar-item'),
            icon: Icon(Icons.report),
            label: 'Incidents',
          ),
        ]
      )
    );
  }
}
