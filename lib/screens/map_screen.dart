import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: Key("map-screen"),
      appBar: AppBar(
        title: const Text('Map'),
      ),


    );
  }



}

