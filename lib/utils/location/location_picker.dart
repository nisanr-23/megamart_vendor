import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:megamart_vendor/utils/custom_text_fields.dart';
import '/utils/location/location_models.dart';
import '/utils/location/location_service.dart';

class LocationPicker extends StatefulWidget {
  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final LocationService locationService = LocationService();

  List<Division> divisions = [];
  List<District> districts = [];
  List<Upazila> upazilas = [];

  List<District> filteredDistricts = [];
  List<Upazila> filteredUpazilas = [];

  String? selectedDivision;
  String? selectedDistrict;
  String? selectedUpazila;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    divisions = await locationService.loadDivisions();
    districts = await locationService.loadDistricts();
    upazilas = await locationService.loadUpazilas();
    setState(() {});
  }

  void onDivisionChanged(String? value) {
    setState(() {
      selectedDivision = value;
      selectedDistrict = null;
      selectedUpazila = null;
      filteredDistricts = districts.where((district) => district.divisionId == value).toList();
      filteredUpazilas = [];
    });
  }

  void onDistrictChanged(String? value) {
    setState(() {
      selectedDistrict = value;
      selectedUpazila = null;
      filteredUpazilas = upazilas.where((upazila) => upazila.districtId == value).toList();
    });
  }

  void onUpazilaChanged(String? value) {
    setState(() {
      selectedUpazila = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          label: 'Select Division',
          value: selectedDivision,
          items: divisions.map<DropdownMenuItem<String>>((division) {
            return DropdownMenuItem<String>(
              value: division.id,
              child: Text(division.name),
            );
          }).toList(),
          onChanged: onDivisionChanged,
        ),
        SizedBox(height: 16),
        _buildDropdown(
          label: 'Select District',
          value: selectedDistrict,
          items: filteredDistricts.map<DropdownMenuItem<String>>((district) {
            return DropdownMenuItem<String>(
              value: district.id,
              child: Text(district.name),
            );
          }).toList(),
          onChanged: onDistrictChanged,
        ),
        SizedBox(height: 16),
        _buildDropdown(
          label: 'Select Upazila',
          value: selectedUpazila,
          items: filteredUpazilas.map<DropdownMenuItem<String>>((upazila) {
            return DropdownMenuItem<String>(
              value: upazila.id,
              child: Text(upazila.name),
            );
          }).toList(),
          onChanged: onUpazilaChanged,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              fillColor: Colors.blue[50],filled: true,
              label: Text(label,style: TextStyle(color: Colors.black),),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            isDense: true,
            isExpanded: true,
            value: value,
            onChanged: onChanged,
            items: items,
          ),
        ),
      ],
    );
  }
}
