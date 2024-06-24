class Division {
  final String id;
  final String name;

  Division({required this.id, required this.name});

  factory Division.fromJson(Map<String, dynamic> json) {
    return Division(
      id: json['id'].toString(),
      name: json['name'],
    );
  }
}

class District {
  final String id;
  final String divisionId;
  final String name;

  District({required this.id, required this.divisionId, required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'].toString(),
      divisionId: json['division_id'].toString(),
      name: json['name'],
    );
  }
}

class Upazila {
  final String id;
  final String districtId;
  final String name;

  Upazila({required this.id, required this.districtId, required this.name});

  factory Upazila.fromJson(Map<String, dynamic> json) {
    return Upazila(
      id: json['id'].toString(),
      districtId: json['district_id'].toString(),
      name: json['name'],
    );
  }
}
