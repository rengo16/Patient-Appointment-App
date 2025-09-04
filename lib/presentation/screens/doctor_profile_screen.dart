
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patientappointment/core/models/doctor_model.dart';
import 'package:patientappointment/core/providers/auth_provider.dart';
import 'package:patientappointment/presentation/screens/select_date_time_screen.dart';

class DoctorProfileScreen extends StatelessWidget {
  final Doctor doctor;

  const DoctorProfileScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(doctor.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,



                backgroundImage: doctor.avatarUrl.startsWith('assets/')
                    ? AssetImage(doctor.avatarUrl)
                    : NetworkImage(doctor.avatarUrl) as ImageProvider,
                onBackgroundImageError: (exception, stackTrace) {
                  print('Error loading image: ${doctor.avatarUrl}, $exception');
                },
                child: doctor.avatarUrl.isEmpty || doctor.avatarUrl == "assets/images/doc_placeholder.png"
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                doctor.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                doctor.specialty,
                style: const TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Availability',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (doctor.workDays.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: Text('No availability information provided for this doctor.')),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: doctor.workDays.length,
                itemBuilder: (context, index) {
                  final workDay = doctor.workDays[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              _getWeekday(workDay.weekday),
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              workDay.slots.isNotEmpty
                                  ? workDay.slots.join(', ')
                                  : 'No slots available on this day.',
                              style: TextStyle(
                                color: workDay.slots.isNotEmpty ? Colors.black87 : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: currentUser != null && !currentUser.isAdmin
          ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SelectDateTimeScreen(doctor: doctor),
            ),
          );
        },
        icon: const Icon(Icons.calendar_today_outlined),
        label: const Text("Book Appointment"),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Unknown';
    }
  }
}
