import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:patientappointment/core/models/user_model.dart' as UserModelImport;
import 'package:patientappointment/core/providers/auth_provider.dart';
import 'package:patientappointment/data/repos/user_repository.dart';

// Import the generated mocks file
import 'auth_provider_test.mocks.dart'; // <<< CORRECTED IMPORT PATH

@GenerateMocks([UserRepository])
void main() {
  late AuthProvider authProvider;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();

    // Default stubbing for methods called in AuthProvider constructor or early on
    when(mockUserRepository.getCurrentUserId()).thenReturn(null); // Assume no user initially
    when(mockUserRepository.getUserById(any)).thenReturn(null); // Default for getUserById

    authProvider = AuthProvider(mockUserRepository);
  });

  // Helper to reset mocks and authProvider if needed, especially for _loadCurrentUser in constructor
  void resetAuthProvider({String? initialUserId, UserModelImport.User? initialUser}) {
    clearInteractions(mockUserRepository); // Clear previous interactions
    reset(mockUserRepository); // Reset the mock's stubbings and interactions

    when(mockUserRepository.getCurrentUserId()).thenReturn(initialUserId);
    if (initialUserId != null) {
      when(mockUserRepository.getUserById(initialUserId)).thenReturn(initialUser);
    } else {
      when(mockUserRepository.getUserById(any)).thenReturn(null);
    }
    authProvider = AuthProvider(mockUserRepository); // Re-instantiate to trigger _loadCurrentUser
  }


  final tUser = UserModelImport.User(id: '1', name: 'Test User', phone: '12345', isAdmin: false);

  group('AuthProvider Tests', () {
    test('initial values are correct (no persisted user)', () async {
      // AuthProvider constructor calls _loadCurrentUser
      // The mockUserRepository.getCurrentUserId() is stubbed to return null in global setUp
      // So _currentUser should be null and isLoading false after constructor.
      // Need to wait for _loadCurrentUser to complete.
      await Future.delayed(Duration.zero); // Allow microtasks to complete (like async operations in constructor)

      expect(authProvider.currentUser, null);
      expect(authProvider.isLoading, false); // isLoading becomes false after _loadCurrentUser
    });

    test('_loadCurrentUser loads user if currentUserId exists', () async {
      resetAuthProvider(initialUserId: tUser.id, initialUser: tUser);
      await Future.delayed(Duration.zero); // for async _loadCurrentUser

      verify(mockUserRepository.getCurrentUserId()).called(1);
      verify(mockUserRepository.getUserById(tUser.id)).called(1);
      expect(authProvider.currentUser, tUser);
      expect(authProvider.isLoading, false);
    });

    group('login', () {
      const testPhone = '1234567890';
      const testName = 'New User';

      test('should create new user if user does not exist and set as current user', () async {
        // Arrange
        when(mockUserRepository.getUserByPhone(testPhone)).thenReturn(null); // User doesn't exist
        when(mockUserRepository.addUser(any)).thenAnswer((_) async {}); // Mock addUser
        when(mockUserRepository.setCurrentUser(any)).thenAnswer((_) async {}); // Mock setCurrentUser

        // Act
        final result = await authProvider.login(testPhone, testName);

        // Assert
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
        // Arrange
        final existingUser = UserModelImport.User(id: 'existingId', name: 'Existing User', phone: testPhone, isAdmin: false);
        when(mockUserRepository.getUserByPhone(testPhone)).thenReturn(existingUser);
        // addUser should not be called
        when(mockUserRepository.setCurrentUser(any)).thenAnswer((_) async {});

        // Act
        final result = await authProvider.login(testPhone, 'Some Name'); // Name shouldn't matter if user exists

        // Assert
        expect(result, true);
        expect(authProvider.currentUser, existingUser);
        expect(authProvider.isLoading, false);

        verify(mockUserRepository.getUserByPhone(testPhone)).called(1);
        verifyNever(mockUserRepository.addUser(any)); // Should not add new user
        verify(mockUserRepository.setCurrentUser(existingUser.id)).called(1);
      });

      test('should return false and handle error if repository throws error', () async {
        // Arrange
        when(mockUserRepository.getUserByPhone(testPhone)).thenThrow(Exception('DB Error'));

        // Act
        final result = await authProvider.login(testPhone, testName);

        // Assert
        expect(result, false);
        expect(authProvider.currentUser, null); // Assuming it was null before
        expect(authProvider.isLoading, false);
      });
    });

    test('logout should clear current user and call repository logout', () async {
      // Arrange: first, simulate a logged-in user
      resetAuthProvider(initialUserId: tUser.id, initialUser: tUser);
      await Future.delayed(Duration.zero);
      expect(authProvider.currentUser, isNotNull); // Pre-condition

      when(mockUserRepository.logout()).thenAnswer((_) async {});

      // Act
      await authProvider.logout();

      // Assert
      expect(authProvider.currentUser, null);
      verify(mockUserRepository.logout()).called(1);
    });

    test('updateProfile should update current user and call repository', () async {
      // Arrange: simulate logged-in user
      resetAuthProvider(initialUserId: tUser.id, initialUser: tUser);
      await Future.delayed(Duration.zero);

      const newName = 'Updated Test User';
      when(mockUserRepository.addUser(any)).thenAnswer((_) async {}); // addUser is used for updates too

      // Act
      await authProvider.updateProfile(newName);

      // Assert
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser?.name, newName);
      expect(authProvider.currentUser?.id, tUser.id); // ID and phone should remain
      expect(authProvider.currentUser?.phone, tUser.phone);

      final capturedUser = verify(mockUserRepository.addUser(captureAny)).captured.single as UserModelImport.User;
      expect(capturedUser.name, newName);
      expect(capturedUser.id, tUser.id);
    });

    test('toggleAdminMode should update isAdmin status and call repository', () async {
      // Arrange: simulate logged-in non-admin user
      resetAuthProvider(initialUserId: tUser.id, initialUser: tUser); // tUser.isAdmin is false
      await Future.delayed(Duration.zero);
      expect(authProvider.currentUser?.isAdmin, false); // Pre-condition

      when(mockUserRepository.addUser(any)).thenAnswer((_) async {});

      // Act
      await authProvider.toggleAdminMode();

      // Assert
      expect(authProvider.currentUser?.isAdmin, true);
      final capturedUser1 = verify(mockUserRepository.addUser(captureAny)).captured.single as UserModelImport.User;
      expect(capturedUser1.isAdmin, true);

      // Act again to toggle back
      await authProvider.toggleAdminMode();
      expect(authProvider.currentUser?.isAdmin, false);
      final capturedUser2 = verify(mockUserRepository.addUser(captureAny)).captured.last as UserModelImport.User; // .last because addUser called twice
      expect(capturedUser2.isAdmin, false);
    });
  });
}
