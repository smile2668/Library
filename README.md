# Self Study Library Manager (Flutter + Supabase)

A production-ready Flutter mobile application for managing self-study libraries.
Supports **Admin**, **Staff**, and **Student** roles with full CRUD, real-time features,
QR-code attendance, fees management, analytics, and more.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (latest stable) |
| Backend | Supabase (PostgreSQL, Auth, Storage, Realtime) |
| State Mgmt | Provider |
| Charts | fl_chart |
| QR Scanning | mobile_scanner |
| QR Generation | qr_flutter |
| Notifications | flutter_local_notifications |
| UI | Material 3 (Light + Dark themes) |

---

## Features

### Three Roles
- **Admin** – Full library management, dashboard, reports, settings
- **Staff** – Manage students/attendance/fees/books/announcements (limited permissions)
- **Student** – Personal dashboard, QR attendance, book requests, study timer, messages

### Admin Dashboard (14 tabs)
| Tab | Description |
|-----|-------------|
| Dashboard | Live metrics: total/free seats, students, monthly revenue |
| Students | Add/edit/delete students with full profile (photo, Aadhar, etc.) |
| Seats | Colour-coded seat map (green = free, red = occupied) |
| Attendance | Daily attendance records and analytics |
| Fees | Fees management with due-date reminders |
| Books | Approve/reject student book requests |
| Expenses | Track electricity, rent, internet, etc. with profit calculation |
| Staff | Add/manage staff members |
| Notes | Upload PDF/image documents for students |
| Messages | Broadcast to all students or DM individuals |
| Announcements | Priority-based announcements with push notifications |
| Reports | Charts: daily attendance, monthly revenue, expense breakdown |
| Settings | Library profile, logo, images, QR code |
| QR Code | Generate and print the library's unique QR code |

### Student Dashboard (5 tabs)
- **Home** – Announcement carousel, study timer, fee status
- **Attendance** – QR scanner to mark attendance, history
- **Books** – Request books, track request status
- **Messages** – Chat with admin/staff
- **Profile** – Seat info, fee history, study hours stats

### Other Features
- Phone OTP authentication via Supabase Auth
- Library setup wizard (first-time admin)
- Study session timer with daily/weekly/monthly tracking
- Seat map with tap-to-view student details
- Dark mode / Light mode

---

## Project Structure

```
lib/
├── core/
│   └── supabase_config.dart        ← Supabase initialisation
├── models/
│   ├── announcement_model.dart
│   ├── attendance_model.dart
│   ├── book_request_model.dart
│   ├── expense_model.dart
│   ├── fee_model.dart
│   ├── library_model.dart
│   ├── message_model.dart
│   ├── note_model.dart
│   ├── seat_model.dart
│   ├── staff_model.dart
│   ├── student_model.dart
│   └── study_session_model.dart
├── providers/
│   ├── app_providers.dart           ← Service singletons
│   ├── auth_provider.dart
│   ├── library_provider.dart
│   └── student_provider.dart
├── screens/
│   ├── auth/
│   │   ├── login_selection_screen.dart
│   │   ├── admin_login_screen.dart
│   │   ├── staff_login_screen.dart
│   │   └── student_login_screen.dart
│   ├── setup/
│   │   └── library_setup_screen.dart
│   ├── admin/
│   │   ├── admin_dashboard_screen.dart
│   │   └── tabs/
│   │       ├── admin_announcements_tab.dart
│   │       ├── admin_attendance_tab.dart
│   │       ├── admin_books_tab.dart
│   │       ├── admin_expenses_tab.dart
│   │       ├── admin_fees_tab.dart
│   │       ├── admin_messages_tab.dart
│   │       ├── admin_notes_tab.dart
│   │       ├── admin_qr_tab.dart
│   │       ├── admin_reports_tab.dart
│   │       ├── admin_seats_tab.dart
│   │       ├── admin_settings_tab.dart
│   │       ├── admin_staff_tab.dart
│   │       └── admin_students_tab.dart
│   └── student/
│       ├── student_dashboard_screen.dart
│       ├── qr_scanner_screen.dart
│       └── tabs/
│           ├── student_attendance_tab.dart
│           ├── student_books_tab.dart
│           ├── student_home_tab.dart
│           ├── student_messages_tab.dart
│           └── student_profile_tab.dart
├── services/
│   ├── supabase_auth_service.dart
│   ├── supabase_db_service.dart
│   ├── supabase_storage_service.dart
│   └── notification_service.dart
├── utils/
│   ├── constants.dart               ← Supabase URL/keys, table names, bucket names
│   └── theme.dart                   ← Light/Dark Material 3 themes
├── widgets/
│   ├── announcement_banner.dart
│   ├── metric_card.dart
│   ├── seat_grid.dart
│   └── study_timer_widget.dart
├── app.dart
└── main.dart

supabase_schema.sql                  ← Full PostgreSQL schema + RLS policies
```

---

## Supabase Setup

### 1. Create a Supabase project
Go to [https://supabase.com](https://supabase.com) and create a project.

### 2. Run the database schema
Open **SQL Editor** in the Supabase Dashboard and paste the contents of
`supabase_schema.sql`, then click **Run**.

This creates all 13 tables, RLS policies, and indexes.

### 3. Create Storage Buckets
Go to **Storage** → **New Bucket** and create each bucket as **Public**:

| Bucket | Purpose |
|--------|---------|
| `library_images` | Library logo and photo gallery |
| `student_photos` | Student profile photos |
| `staff_photos` | Staff profile photos |
| `aadhar_images` | Student Aadhar card images |
| `book_images` | Book request cover images |
| `notes_files` | PDFs and documents uploaded by admin/staff |

### 4. Configure Authentication
Go to **Authentication** → **Providers** → Enable **Phone** with your SMS provider (Twilio, MessageBird, etc.).

### 5. Add your credentials
The app already contains the credentials for the provided Supabase project in
`lib/utils/constants.dart`. Update them if you use a different project:

```dart
static const supabaseUrl  = 'https://YOUR_PROJECT.supabase.co';
static const supabaseAnonKey = 'YOUR_ANON_KEY';
```

### 6. First Admin Registration
- In the Supabase dashboard, manually insert a row into the `admins` table with the
  phone number you will use to log in:
  ```sql
  INSERT INTO admins (id, name, phone) VALUES ('YOUR_AUTH_UID', 'Admin Name', '+91XXXXXXXXXX');
  ```
- After registering via OTP in the app, the admin will be redirected to the
  Library Setup wizard to create the library profile.

---

## Run the App

```bash
# Install dependencies
flutter pub get

# Run on connected device / emulator
flutter run

# Build release APK (Android)
flutter build apk --release

# Build release IPA (iOS)
flutter build ipa --release
```

### Android extras
- Add `<uses-permission android:name="android.permission.CAMERA"/>` to
  `android/app/src/main/AndroidManifest.xml` for QR scanning.
- For push notifications, add the `flutter_local_notifications` Android
  configuration (notification icon, etc.).

### iOS extras
- Add `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` to
  `ios/Runner/Info.plist`.

---

## Supabase Database Tables

| Table | Description |
|-------|-------------|
| `libraries` | Library profile with seats, pricing, images |
| `admins` | Library admin records linked to auth users |
| `staff` | Staff members with roles and permissions |
| `students` | Student registrations with full profile |
| `seats` | Seat availability and student assignment |
| `attendance` | Daily QR-scanned attendance records |
| `fees` | Fee plans, due dates, and payment status |
| `books` | Student book requests |
| `expenses` | Library expense tracking |
| `announcements` | Priority announcements for students |
| `messages` | Direct / broadcast messages |
| `notes` | PDF/image notes uploaded by admin/staff |
| `study_sessions` | Student study timer sessions |

---

## Security Notes

- The Supabase **anon key** is the public client key — it is safe to embed in
  Flutter apps (similar to a Firebase config). Actual data access is governed by
  **Row-Level Security (RLS)** policies defined in `supabase_schema.sql`.
- All tables have RLS enabled. Each role (admin/staff/student) can only access
  data that belongs to their library.
- Never store the Supabase `service_role` key in client-side code.

