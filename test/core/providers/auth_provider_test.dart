import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:patientappointment/core/models/user_model.dart' as UserModelImport;
import 'package:patientappointment/core/providers/auth_provider.dart';
import 'package:patientappointment/data/repos/user_repository.dart';
import 'auth_provider_test.mocks.dart';

@GenerateMocks([UserRepository])
void main() {
  late AuthProvider authProvider;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
    when(mockUserRepository.getCurrentUserId()).thenReturn(null);
    when(mockUserRepository.getUserById(any)).thenReturn(null);

    authProvider = AuthProvider(mockUserRepository);
  });
  void resetAuthProvider({String? initialUserId, UserModelImport.User? initialUser}) {
    clearInteractions(mockUserRepository);
    reset(mockUserRepository);

    when(mockUserRepository.getCurrentUserId()).thenReturn(initialUserId);
    if (initialUserId != null) {
      when(mockUserRepository.getUserById(initialUserId)).thenReturn(initialUser);
    } else {
      when(mockUserRepository.getUserById(any)).thenReturn(null);
    }
    authProvider = AuthProvider(mockUserRepository);
  }


  final tUser = UserModelImport.User(id: '1', name: 'Test User', phone: '12345', isAdmin: false);

  group('AuthProvider Tests', () {
    test('initial values are correct (no persisted user)', () async {



      await Future.delayed(Duration.zero);

      expect(authProvider.currentUser, null);
      expect(authProvider.isLoading, false);
    });

    test('_loadCurrentUser loads user if currentUserId exists', () async {
      resetAuthProvider(initialUserId: tUser.id, initialUser: tUser);
      await Future.delayed(Duration.zero);

      verify(mockUserRepository.getCurrentUserId()).called(1);
      verify(mockUserRepository.getUserById(tUser.id)).called(1);
      expect(authProvider.currentUser, tUser);
      expect(authProvider.isLoading, false);
    });

    group('login', () {
      const testPhone = '1234567890';
      const testName = 'New User';

      test('should create new user if user does not exist and set as current user', () async {
        when(mockUserRepository.getUserByPhone(testPhone)).thenReturn(null);
        when(mockUserRepository.addUser(any)).thenAnswer((_) async {});
        when(mockUserRepository.setCurrentUser(any)).thenAnswer((_) async {});

        final result = await authProvider.login(testPhone, testName);
        expect(result, true);
        expect(authProvider.currentUser, isNotNull);
        expect(authProvider.currentUser?.phone, testPhone);
        expect(authProvider.currentUser?.name, testName);
        expect(authProvider.isLoading, false);

        verify(mockUserRepository.getUserByPhone(testPhone)).called(1);
        final capturedUser = verify(mockUserRepository.addUser(captureAny)).captured.single as UserModelImport.User;
        expect(capturedUser.phone, testPhone);
        expect(capturedUser.name, testName);
        verify(mockUserRepository.setCurrentUser(capturedUser.id)).called(1);
      });

      test('should use existing user if user exists and set as current user', () async {
        final existingUser = UserModelImport.User(id: 'existingId', name: 'Existing User', phone: testPhone, isAdmin: false);
        when(mockUserRepository.getUserByPhone(testPhone)).thenReturn(existingUser);
        when(mockUserRepository.setCurrentUser(any)).thenAnswer((_) async {});
        final result = await authProvider.login(testPhone, 'Some Name');

        expect(result, true);
        expect(authProvider.currentUser, existingUser);
        expect(authProvider.isLoading, false);

        verify(mockUserRepository.getUserByPhone(testPhone)).called(1);
        verifyNever(mockUserRepository.addUser(any));
        verify(mockUserRepository.setCurrentUser(existingUser.id)).called(1);
      });

      test('should return false and handle error if repository throws error', () async {
        when(mockUserRepository.getUserByPhone(testPhone)).thenThrow(Exception('DB Error'));
        final result = await authProvider.login(testPhone, testName);
        expect(result, false);
        expect(authProvider.currentUser, null);
        expect(authProvider.isLoading, false);
      });
    });

    test('logout should clear current user and call repository logout', () async {
      resetAuthProvider(initialUserId: tUser.id, initialUser: tUser);
      await Future.delayed(Duration.zero);
      expect(authProvider.currentUser, isNotNull);

      when(mockUserRepository.logout()).thenAnswer((_) async {});
      await authProvider.logout();
      expect(authProvider.currentUser, null);
      verify(mockUserRepository.logout()).called(1);
    });

    test('updateProfile should update current user and call repository', () async {
      resetAuthProvider(initialUserId: tUser.id, initialUser: tUser);
      await Future.delayed(Duration.zero);

      const newName = 'Updated Test User';
      when(mockUserRepository.addUser(any)).thenAnswer((_) async {});

      await authProvider.updateProfile(newName);
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser?.name, newName);
      expect(authProvider.currentUser?.id, tUser.id);
      expect(authProvider.currentUser?.phone, tUser.phone);

      final capturedUser = verify(mockUserRepository.addUser(captureAny)).captured.single as UserModelImport.User;
      expect(capturedUser.name, newName);
      expect(capturedUser.id, tUser.id);
    });

    test('toggleAdminMode should update isAdmin status and call repository', () async {
      resetAuthProvider(initialUserId: tUser.id, initialUser: tUser);
      await Future.delayed(Duration.zero);
      expect(authProvider.currentUser?.isAdmin, false);

      when(mockUserRepository.addUser(any)).thenAnswer((_) async {});
      await authProvider.toggleAdminMode();
      expect(authProvider.currentUser?.isAdmin, true);
      final capturedUser1 = verify(mockUserRepository.addUser(captureAny)).captured.single as UserModelImport.User;
      expect(capturedUser1.isAdmin, true);
      await authProvider.toggleAdminMode();
      expect(authProvider.currentUser?.isAdmin, false);
      final capturedUser2 = verify(mockUserRepository.addUser(captureAny)).captured.last as UserModelImport.User;
      expect(capturedUser2.isAdmin, false);
    });
  });
}
