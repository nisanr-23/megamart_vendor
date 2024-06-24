import 'dart:convert';
import 'package:flutter/services.dart';
import 'location_models.dart';

class LocationService {
  Future<List<Division>> loadDivisions() async {
    final String response = await rootBundle.loadString('assets/location/divisions.json');
    final data = json.decode(response)['data'] as List;
    return data.map((json) => Division.fromJson(json)).toList();
  }

  Future<List<District>> loadDistricts() async {
    final String response = await rootBundle.loadString('assets/location/districts.json');
    final data = json.decode(response)['data'] as List;
    return data.map((json) => District.fromJson(json)).toList();
  }

  Future<List<Upazila>> loadUpazilas() async {
    final String response = await rootBundle.loadString('assets/location/upazilas.json');
    final data = json.decode(response)['data'] as List;
    return data.map((json) => Upazila.fromJson(json)).toList();
  }
}
