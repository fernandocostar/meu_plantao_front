import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class StateCityProvider {
  late List<State> _states;
  late List<City> _cities;

  Future<void> loadStateAndCityData() async {
    final String stateJsonString =
        await rootBundle.loadString('assets/data/states.json');
    final String cityJsonString =
        await rootBundle.loadString('assets/data/cities.json');

    final List<dynamic> stateJsonData = json.decode(stateJsonString);
    final List<dynamic> cityJsonData = json.decode(cityJsonString);

    _states = stateJsonData.map((item) => State.fromJson(item)).toList();
    _cities = cityJsonData.map((item) => City.fromJson(item)).toList();
  }

  // Get the list of state names
  List<String> getStateNames() {
    return _states.map((state) => state.sigla).toList();
  }

  // Get the list of cities by state name
  List<String> getCitiesByState(String stateAcronym) {
    final state = _states.firstWhere((state) => state.sigla == stateAcronym);
    final filteredCities =
        _cities.where((city) => city.estadoId == state.id).toList();
    return filteredCities.map((city) => city.nome).toList();
  }
}

class State {
  final String id;
  final String sigla;
  final String nome;

  State({required this.id, required this.sigla, required this.nome});

  factory State.fromJson(Map<String, dynamic> json) {
    return State(
      id: json['ID'],
      sigla: json['Sigla'],
      nome: json['Nome'],
    );
  }
}

class City {
  final String id;
  final String nome;
  final String estadoId;

  City({required this.id, required this.nome, required this.estadoId});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['ID'],
      nome: json['Nome'],
      estadoId: json['Estado'],
    );
  }
}
