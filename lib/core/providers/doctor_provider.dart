import 'package:flutter/material.dart';
import 'package:patientappointment/core/models/doctor_model.dart';
import 'package:patientappointment/data/repos/doctor_repository.dart';

class DoctorProvider with ChangeNotifier {
  final DoctorRepository _doctorRepository;
  List<Doctor> _doctors = [];
  List<Doctor> _filteredDoctors = [];
  String _searchQuery = '';
  String? _selectedSpecialty;

  DoctorProvider(this._doctorRepository) {
    loadDoctors();
  }

  List<Doctor> get doctors => _filteredDoctors;
  List<String> get specialties => _doctorRepository.getSpecialties();
  String get searchQuery => _searchQuery;
  String? get selectedSpecialty => _selectedSpecialty;

  Future<void> loadDoctors() async {
    await _doctorRepository.loadSeedData();
    _doctors = _doctorRepository.getAllDoctors();
    _filteredDoctors = _doctors;
    notifyListeners();
  }

  void searchDoctors(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterBySpecialty(String? specialty) {
    _selectedSpecialty = specialty;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedSpecialty = null;
    _filteredDoctors = _doctors;
    notifyListeners();
  }

  void _applyFilters() {
    _filteredDoctors = _doctorRepository.searchDoctors(
      _searchQuery,
      specialty: _selectedSpecialty,
    );
    notifyListeners();
  }

  Doctor? getDoctorById(String id) {
    return _doctorRepository.getDoctorById(id);
  }
}