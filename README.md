# Self Study Library Manager (Flutter + Firebase)

A production-focused starter app for Android/iOS to manage self-study libraries with **Admin** and **Student** roles.

## Features Included
- Role-based login entry: Admin / Student
- Admin phone OTP flow (Firebase Auth)
- Student login screen with library search and selection
- Admin dashboard with tabs:
  - Students
  - Seats (green/red seat grid)
  - Attendance
  - Fees
  - Books
  - Settings
- Student dashboard:
  - Seat details
  - Attendance
  - Fees status
  - Book requests
- Firebase services abstraction for:
  - Authentication
  - Firestore
  - Storage
  - FCM notifications
- Clean structure: `models`, `services`, `providers`, `screens`, `widgets`

## Project Structure

```txt
lib/
  core/
    firebase_options.dart
  models/
    attendance_model.dart
    book_request_model.dart
    fee_model.dart
    library_model.dart
    seat_model.dart
    student_model.dart
  providers/
    app_providers.dart
    auth_provider.dart
  screens/
    auth/
      admin_login_screen.dart
      login_selection_screen.dart
      student_login_screen.dart
    admin/
      admin_dashboard_screen.dart
      tabs/
        admin_attendance_tab.dart
        admin_books_tab.dart
        admin_fees_tab.dart
        admin_seats_tab.dart
        admin_settings_tab.dart
        admin_students_tab.dart
    student/
      student_dashboard_screen.dart
  services/
    auth_service.dart
    firestore_service.dart
    notification_service.dart
    storage_service.dart
  widgets/
    metric_card.dart
    seat_grid.dart
  app.dart
  main.dart
```

## Firebase Setup
1. Create Firebase project.
2. Enable services:
   - Authentication -> Phone
   - Cloud Firestore
   - Storage
   - Cloud Messaging
3. Add Android/iOS apps in Firebase console.
4. Replace placeholders in `lib/core/firebase_options.dart`.
5. Add platform files:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
6. Android gradle setup:
   - Add Google services classpath in project `build.gradle`
   - Apply `com.google.gms.google-services` plugin in app `build.gradle`
7. iOS setup:
   - `pod install` in `ios/`
   - Enable push notification capability for FCM.

## Firestore Data Model
Collections:
- `libraries`
  - `name`, `logoUrl`, `totalSeats`, `freeSeats`, `adminId`
- `students`
  - `libraryId`, `name`, `mobile`, `joiningDate`, `seatNumber`, `seatType`, `studyTime`, `passwordSet`
- `seats`
  - `libraryId`, `number`, `occupied`, `studentId`
- `attendance`
  - `libraryId`, `studentId`, `timestamp`, `status` (Pending/Accepted/Rejected)
- `fees`
  - `libraryId`, `studentId`, `studentName`, `seatNumber`, `plan`, `dueDate`, `paymentMethod`, `paymentStatus`
- `books`
  - `libraryId`, `studentId`, `bookName`, `imageUrl`, `status`
- `admins`
  - `phone`, `libraryId`, `name`

## Run Instructions
```bash
flutter pub get
flutter run
```

## Recommended Next Production Steps
- Add repository/use-case layer per strict clean architecture
- Add robust role-based guards and server-side security rules
- Enforce library-scoped student login validation
- Integrate image picker + upload flows for logos/books
- Implement background FCM fee reminder scheduling (Cloud Functions)
- Add unit/widget/integration tests and CI
