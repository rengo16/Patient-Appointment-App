# Patient appointment app (offline)
<img width="364" height="787" alt="image" src="https://github.com/user-attachments/assets/3dc5474d-711b-47c7-bdef-15fbb2553c82" />

This is a flutter based application for managing patient appointments with doctors. It works offline-first using hive for local storage and there are features like booking, rescheduling and cancelling the appointment. It also has admin or doctor view to manage the appointments and accept/reject them.

## Patient features

= User authentication: phone number and OTP verification
<img width="360" height="267" alt="image" src="https://github.com/user-attachments/assets/2bda036f-3b5e-4f80-81e8-374877a6cad8" />

- Doctor search: Browse doctors with search and filter
- <img width="366" height="433" alt="image" src="https://github.com/user-attachments/assets/79886119-8fe7-477a-9238-4e88572f33cf" />

- Appointment management: Book, reschedule, and cancel appointments
- Appointment history: View upcoming, completed, and missed appointments
- <img width="354" height="753" alt="image" src="https://github.com/user-attachments/assets/70f140fc-7087-4f7b-b615-5aab8a1538a8" />

- Notifications: Local reminders for upcoming appointments

## Admin or doctor features
<img width="372" height="566" alt="image" src="https://github.com/user-attachments/assets/7a711bea-49e1-44f6-bcf8-4c6afbac58a4" />

- Appointment dashboard to view todays schedule
- Managing appointments (accepting or rejecting)
- Toggle between user and admin view

## Tools

- Flutter
- Hive, for local database
- flutter local notifications
- intl for data formatting and localizing
- uuid for unique IDs generation

# How to use

## Requirements
- Flutter SDK
- Android Studio with android SDK
- Java JDK 17

## Installation
- Clone the repo with git clone
- Install the dependancies with flutter pub get
- Ensure that android SDK 35 is installed and java 17 is set in enviroment variables
- Run the application
