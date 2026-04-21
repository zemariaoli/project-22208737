import 'package:cmproject/models/station.dart';

class StationsRepository {

  List<Station> getStations(){
    return[
      Station(id: "1", name: "Oriente", latitude: 38.7678,longitude: -9.0988, lineName: "Linha Vermelha"),
      Station(id: "2", name: "Marquês de Pombal", latitude: 38.7678,longitude: -9.0988, lineName: "Linha Azul"),
      Station(id: "3", name: "Baixa-Chiado", latitude: 38.7678,longitude: -9.0988, lineName: "Linha Verde"),

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