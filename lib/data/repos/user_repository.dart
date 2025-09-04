import 'package:patientappointment/core/models/user_model.dart';
import 'package:patientappointment/core/services/local_storage_service.dart';

class UserRepository {
  UserRepository();

  Future<void> addUser(User user) async {
    await LocalStorageService.usersBox.put(user.id, user);
  }

  User? getUserById(String id) {
    return LocalStorageService.usersBox.get(id);
  }

  User? getUserByPhone(String phone) {
    try {
      return LocalStorageService.usersBox.values.firstWhere(
            (user) => user.phone == phone,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> setCurrentUser(String userId) async {
    await LocalStorageService.sessionBox.put('current_user_id', userId);
  }

  String? getCurrentUserId() {
    return LocalStorageService.sessionBox.get('current_user_id');
  }

  Future<void> logout() async {
    await LocalStorageService.sessionBox.delete('current_user_id');
  }
}