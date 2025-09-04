import 'package:flutter/material.dart';
import 'package:patientappointment/core/models/user_model.dart' as UserModelImport;
import 'package:patientappointment/data/repos/user_repository.dart';

class AuthProvider with ChangeNotifier {
  final UserRepository _userRepository;
  UserModelImport.User? _currentUser;
  bool _isLoading = false;

  AuthProvider(this._userRepository) {
    _loadCurrentUser();
  }

  UserModelImport.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<void> _loadCurrentUser() async {
    _isLoading = true;


    final userId = _userRepository.getCurrentUserId();
    if (userId != null) {
      _currentUser = _userRepository.getUserById(userId);
    } else {
      _currentUser = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String phone, String name) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));

    try {
      var user = _userRepository.getUserByPhone(phone);
      if (user == null) {
        user = UserModelImport.User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          phone: phone,
          name: name,
          isAdmin: false,
        );
        await _userRepository.addUser(user);
      }

      await _userRepository.setCurrentUser(user.id);
      _currentUser = user;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("AUTH_PROVIDER: Error during login: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  Future<void> logout() async {
    print("AUTH_PROVIDER: Logout called.");
    await _userRepository.logout();
    _currentUser = null;
    print("AUTH_PROVIDER: CurrentUser is now null. Notifying listeners.");
    notifyListeners();
    print("AUTH_PROVIDER: Listeners notified after logout.");
  }

  Future<void> updateProfile(String name) async {
    if (_currentUser != null) {
      final updatedUser = UserModelImport.User(
        id: _currentUser!.id,
        phone: _currentUser!.phone,
        name: name,
        isAdmin: _currentUser!.isAdmin,
      );
      await _userRepository.addUser(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
    }
  }

  Future<void> toggleAdminMode() async {
    if (_currentUser != null) {
      final updatedUser = _currentUser!.copyWith(isAdmin: !_currentUser!.isAdmin);







      await _userRepository.addUser(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
    }
  }
}
