import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patientappointment/core/providers/appointment_provider.dart';
import 'package:patientappointment/core/providers/auth_provider.dart';
import 'package:patientappointment/core/providers/doctor_provider.dart';
import 'package:patientappointment/core/services/local_storage_service.dart';
import 'package:patientappointment/core/services/notification_service.dart'; // Ensure this is imported
import 'package:patientappointment/data/repos/appointment_repository.dart';
import 'package:patientappointment/data/repos/doctor_repository.dart';
import 'package:patientappointment/data/repos/user_repository.dart';
import 'package:patientappointment/presentation/screens/splash_screen.dart';
import 'package:patientappointment/presentation/screens/sign_in_phone_screen.dart';
import 'package:patientappointment/presentation/screens/home_tabs_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  final notificationService = NotificationService(); // Get the instance
  await notificationService.init();                 // Initialize it

  runApp(
    MultiProvider(
      providers: [
        // You can also provide NotificationService itself if other providers might need it,
        // though in this case, only AppointmentProvider needs it directly.
        // Provider(create: (_) => notificationService), // Optional: provide NotificationService globally

        Provider(create: (_) => UserRepository()),
        Provider(create: (_) => DoctorRepository()),
        Provider(create: (_) => AppointmentRepository()),

        ChangeNotifierProvider(
          create: (context) => AuthProvider(context.read<UserRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => DoctorProvider(context.read<DoctorRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => AppointmentProvider(
            context.read<AppointmentRepository>(),
            context.read<AuthProvider>(),
            notificationService, // <<< PASS THE NOTIFICATION SERVICE INSTANCE HERE
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patient Appointment App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const SignInPhoneScreen(),
        '/home_tabs': (context) => const HomeTabsScreen(),
      },
    );
  }
}
