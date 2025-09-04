import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:patientappointment/core/models/doctor_model.dart';
import 'package:patientappointment/presentation/widgets/confirm_booking_dialog.dart';

void main() { // <<<< ENSURE THIS main() FUNCTION IS PRESENT AND WRAPS EVERYTHING
  final tDoctor = Doctor(
    id: 'doc123',
    name: 'Dr. Emily Carter',
    specialty: 'Cardiology',
    avatarUrl: 'assets/images/doc1.png', // Ensure this asset path is valid or use a network URL if applicable
    workDays: [],
  );
  final tDateTime = DateTime(2023, 10, 26, 14, 30);
  const tPatientName = 'John Doe';
  const tPatientPhone = '555-1234';

  testWidgets('ConfirmBookingDialog displays correct information', (WidgetTester tester) async {
    // Arrange
    final dialog = ConfirmBookingDialog(
      doctor: tDoctor,
      dateTime: tDateTime,
      patientName: tPatientName,
      patientPhone: tPatientPhone,
    );

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: dialog)));

    // Assert
    // Corrected and more specific finder for the title
    final alertDialogWidget = tester.widget<AlertDialog>(find.byType(AlertDialog));
    expect(alertDialogWidget.title, isA<Text>(), reason: "Dialog title should be a Text widget");
    expect((alertDialogWidget.title as Text).data, 'Confirm Booking', reason: "Dialog title text does not match");

    expect(find.text('Doctor: ${tDoctor.name}'), findsOneWidget);
    expect(find.text('Specialty: ${tDoctor.specialty}'), findsOneWidget);
    expect(find.text('Date: ${DateFormat.yMMMMd().format(tDateTime)}'), findsOneWidget);
    expect(find.text('Time: ${DateFormat.jm().format(tDateTime)}'), findsOneWidget);
    expect(find.text('Patient: $tPatientName'), findsOneWidget);
    expect(find.text('Phone: $tPatientPhone'), findsOneWidget);

    expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Confirm Booking'), findsOneWidget);
  });

  testWidgets('ConfirmBookingDialog pops with false when Cancel is tapped', (WidgetTester tester) async {
    dynamic result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return Center(
                child: ElevatedButton(
                  child: const Text('Show Dialog'),
                  onPressed: () async {
                    result = await showDialog<bool>(
                      context: context,
                      builder: (_) => ConfirmBookingDialog(
                        doctor: tDoctor,
                        dateTime: tDateTime,
                        patientName: tPatientName,
                        patientPhone: tPatientPhone,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle(); // ensure dialog is shown

    expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle(); // ensure dialog is dismissed

    expect(result, isFalse);
  });

  testWidgets('ConfirmBookingDialog pops with true when "Confirm Booking" is tapped', (WidgetTester tester) async {
    dynamic result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return Center(
                child: ElevatedButton(
                  child: const Text('Show Dialog'),
                  onPressed: () async {
                    result = await showDialog<bool>(
                      context: context,
                      builder: (_) => ConfirmBookingDialog(
                        doctor: tDoctor,
                        dateTime: tDateTime,
                        patientName: tPatientName,
                        patientPhone: tPatientPhone,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle(); // ensure dialog is shown

    expect(find.widgetWithText(ElevatedButton, 'Confirm Booking'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm Booking'));
    await tester.pumpAndSettle(); // ensure dialog is dismissed

    expect(result, isTrue);
  });
}
