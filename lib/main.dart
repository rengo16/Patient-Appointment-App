
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patientappointment/core/providers/appointment_provider.dart';
import 'package:patientappointment/core/providers/auth_provider.dart';
import 'package:patientappointment/core/providers/doctor_provider.dart';
import 'package:patientappointment/core/services/local_storage_service.dart';
import 'package:patientappointment/core/services/notification_service.dart';
import 'package:patientappointment/data/repos/appointment_repository.dart';
import 'package:patientappointment/data/repos/doctor_repository.dart';
import 'package:patientappointment/data/repos/user_repository.dart';
import 'package:patientappointment/presentation/screens/splash_screen.dart';
import 'package:patientappointment/presentation/screens/sign_in_phone_screen.dart';
import 'package:patientappointment/presentation/screens/home_tabs_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  await NotificationService().init();

  runApp(
    MultiProvider(
      providers: [
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
