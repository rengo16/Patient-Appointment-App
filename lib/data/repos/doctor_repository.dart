import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:patientappointment/core/models/doctor_model.dart';
import 'package:patientappointment/core/services/local_storage_service.dart';

class DoctorRepository {
  DoctorRepository();

  Future<void> loadSeedData() async {
    final doctorsBox = LocalStorageService.doctorsBox;
    if (doctorsBox.isEmpty) {
      final String response = await rootBundle.loadString('assets/seed/seed_doctors.json');
      final data = await json.decode(response);
      List<Doctor> doctors = (data['doctors'] as List).map((doc) => Doctor.fromJson(doc)).toList();
      for (var doctor in doctors) {
        await doctorsBox.put(doctor.id, doctor);
      }
    }
  }

  List<Doctor> getAllDoctors() {
    return LocalStorageService.doctorsBox.values.toList();
  }

  Doctor? getDoctorById(String id) {
    return LocalStorageService.doctorsBox.get(id);
  }

  List<Doctor> searchDoctors(String query, {String? specialty}) {
    var doctors = getAllDoctors();
    if (query.isNotEmpty) {
      doctors = doctors.where((doctor) =>
      doctor.name.toLowerCase().contains(query.toLowerCase()) ||
          doctor.specialty.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    if (specialty != null && specialty.isNotEmpty) {
      doctors = doctors.where((doctor) => doctor.specialty == specialty).toList();
    }
    return doctors;
  }

  List<String> getSpecialties() {
    var doctors = getAllDoctors();
    return doctors.map((doc) => doc.specialty).toSet().toList();
  }
}