import 'package:cmproject/models/incident_report.dart';
import 'package:cmproject/models/station.dart';

class MetroRepository {

  List<Station> getAllStations() {
    throw UnimplementedError("getAllStations");
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
          name: "Station 1",
          latitude: 38.7678,
          longitude: -9.0988,
          lineName: "Linha Rosa"
      ),
      Station(
          id: "2",
          name: "Station 2",
          latitude: 38.7678,
          longitude: -9.0988,
          lineName: "Linha Castanha"
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
