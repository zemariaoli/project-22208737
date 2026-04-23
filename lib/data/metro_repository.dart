import 'package:cmproject/models/incident_report.dart';
import 'package:cmproject/models/station.dart';

class MetroRepository {

  List<Station> getAllStations() {
    return getStations();
  }

  void attachIncident(String id, IncidentReport report)  {
    throw UnimplementedError("attachIncident");
  }

  void insertStation(Station station)  {
    //throw UnimplementedError("insertStation");
  }

  Station getStationDetail(String id) {
    throw UnimplementedError("getStationDetail");
  }

  List<Station> getStationsByName(String name)  {
    throw UnimplementedError("getStationsByName");
  }


  List<Station> getStations(){
    return[
      Station(
          id: "1",
          name: "Oriente",
          latitude: 38.7678,
          longitude: -9.0988,
          lineName: "Linha Vermelha"
      ),
      Station(
          id: "2",
          name: "Marquês de Pombal",
          latitude: 100.084,
          longitude: -9.0988,
          lineName: "Linha Azul"
      ),
      //Station(id: "3",name: "Station 3",latitude: 38.7678,longitude: -9.0988,lineName: "Line 3"),

    ];
  }

  Station? getStation(String id) {
    for (final station in getStations()) {
      if (station.id == id) {
        return station;
      }
    }
    return null;
  }
}
