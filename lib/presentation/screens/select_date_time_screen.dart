
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:patientappointment/core/models/doctor_model.dart';
import 'package:patientappointment/core/models/appointment_model.dart';
import 'package:patientappointment/core/providers/appointment_provider.dart';
import 'package:patientappointment/core/providers/auth_provider.dart';
import 'package:patientappointment/presentation/widgets/confirm_booking_dialog.dart';

class SelectDateTimeScreen extends StatefulWidget {
  final Doctor doctor;
  final Appointment? existingAppointment;

  const SelectDateTimeScreen({
    super.key,
    required this.doctor,
    this.existingAppointment,
  });

  @override
  State<SelectDateTimeScreen> createState() => _SelectDateTimeScreenState();
}

class _SelectDateTimeScreenState extends State<SelectDateTimeScreen> {
  DateTime? _selectedDate;
  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.existingAppointment != null) {
      _selectedDate = widget.existingAppointment!.dateTime;
      _selectedTime = DateFormat('HH:mm').format(widget.existingAppointment!.dateTime);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null;
      });
    }
  }

  List<String> _getAvailableSlots(Doctor doctor, DateTime? selectedDate) {
    if (selectedDate == null) return [];

    final weekday = selectedDate.weekday;
    final workDay = doctor.workDays.firstWhere(
          (wd) => wd.weekday == weekday,
      orElse: () => WorkDay(weekday: 0, slots: []),
    );

    final now = DateTime.now();
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);

    return workDay.slots.where((slot) {
      final slotDateTime = _combineDateAndTime(selectedDate, slot);
      bool isPastSlot = selectedDate.year == now.year &&
          selectedDate.month == now.month &&
          selectedDate.day == now.day &&
          slotDateTime.isBefore(now);
      return !isPastSlot && appointmentProvider.isDoctorAvailable(doctor.id, slotDateTime);
    }).toList();
  }

  DateTime _combineDateAndTime(DateTime date, String time) {
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    final List<String> availableSlots = _getAvailableSlots(widget.doctor, _selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingAppointment != null ? 'Reschedule Appointment' : 'Select Date & Time'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Doctor: ${widget.doctor.name}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'Specialty: ${widget.doctor.specialty}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              const Text(
                'Select Date:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: () => _selectDate(context),
                child: Text(_selectedDate == null
                    ? 'Choose Date'
                    : 'Selected: ${DateFormat.yMMMMd().format(_selectedDate!)}'),
              ),
              const SizedBox(height: 24),
              if (_selectedDate != null) ...[
                const Text(
                  'Select Available Time:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (availableSlots.isEmpty)
                  const Center(child: Text('No available slots for the selected date.'))
                else
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: availableSlots.map((slot) {
                      final bool isSelected = _selectedTime == slot;
                      return ChoiceChip(
                        label: Text(slot, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
                        selected: isSelected,
                        selectedColor: Theme.of(context).primaryColor,
                        backgroundColor: Colors.grey[200],
                        onSelected: (selected) {
                          setState(() {
                            _selectedTime = selected ? slot : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: (_selectedDate != null && _selectedTime != null && currentUser != null)
          ? FloatingActionButton.extended(
        onPressed: () async {
          final DateTime combinedDateTime = _combineDateAndTime(_selectedDate!, _selectedTime!);

          if (widget.existingAppointment != null) {
            final bool? confirmReschedule = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Confirm Reschedule'),
                content: Text('Reschedule appointment with ${widget.doctor.name} to ${DateFormat.yMMMMd().add_jm().format(combinedDateTime)}?'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                  ),
                  TextButton(
                    child: const Text('Confirm'),
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                  ),
                ],
              ),
            );

            if (confirmReschedule == true) {
              try {
                await appointmentProvider.rescheduleAppointment(
                  widget.existingAppointment!.id,
                  combinedDateTime,
                );
                if (mounted) {
                  Navigator.of(context).pop();


                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Appointment rescheduled successfully!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error rescheduling: ${e.toString()}')),
                  );
                }
              }
            }
          } else {
            final bool? confirmBooking = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => ConfirmBookingDialog(
                doctor: widget.doctor,
                dateTime: combinedDateTime,
                patientName: currentUser.name,
                patientPhone: currentUser.phone,
              ),
            );

            if (confirmBooking == true) {
              try {
                await appointmentProvider.addAppointment(
                  doctorId: widget.doctor.id,
                  dateTime: combinedDateTime,
                );
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Appointment booked successfully!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error booking appointment: ${e.toString()}')),
                  );
                }
              }
            }
          }
        },
        label: Text(widget.existingAppointment != null ? 'Reschedule' : 'Book Now'),
        icon: const Icon(Icons.check_circle_outline),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
