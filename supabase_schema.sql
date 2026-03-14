-- ============================================================
-- SELF STUDY LIBRARY MANAGER — Supabase PostgreSQL Schema
-- ============================================================
-- Run this entire file in the Supabase SQL Editor at:
-- https://supabase.com/dashboard → SQL Editor → New Query
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ──────────────────────────────────────────────────────────────
-- 1. LIBRARIES
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS libraries (
  id            TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  name          TEXT NOT NULL,
  logo_url      TEXT DEFAULT '',
  total_seats   INT  NOT NULL DEFAULT 0,
  free_seats    INT  NOT NULL DEFAULT 0,
  admin_id      TEXT NOT NULL,
  address       TEXT DEFAULT '',
  maps_link     TEXT DEFAULT '',
  website_link  TEXT DEFAULT '',
  seat_price    NUMERIC(10,2) DEFAULT 0.00,
  image_urls    TEXT[] DEFAULT '{}',
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ──────────────────────────────────────────────────────────────
-- 2. ADMINS
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS admins (
  id           TEXT PRIMARY KEY,   -- matches Supabase auth.users.id
  library_id   TEXT REFERENCES libraries(id) ON DELETE SET NULL,
  name         TEXT DEFAULT '',
  phone        TEXT DEFAULT '',
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- ──────────────────────────────────────────────────────────────
-- 3. STAFF
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS staff (
  id            TEXT PRIMARY KEY,  -- matches Supabase auth.users.id
  library_id    TEXT NOT NULL REFERENCES libraries(id) ON DELETE CASCADE,
  name          TEXT NOT NULL DEFAULT '',
  phone         TEXT NOT NULL DEFAULT '',
  photo_url     TEXT DEFAULT '',
  role          TEXT NOT NULL DEFAULT 'staff',
  password_set  BOOLEAN NOT NULL DEFAULT FALSE,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ──────────────────────────────────────────────────────────────
-- 4. STUDENTS
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS students (
  id               TEXT PRIMARY KEY,  -- matches Supabase auth.users.id
  library_id       TEXT NOT NULL REFERENCES libraries(id) ON DELETE CASCADE,
  name             TEXT NOT NULL DEFAULT '',
  mobile           TEXT NOT NULL DEFAULT '',
  joining_date     DATE NOT NULL DEFAULT CURRENT_DATE,
  seat_number      INT  NOT NULL DEFAULT 0,
  seat_type        TEXT NOT NULL DEFAULT 'Free Seat',
  study_time       TEXT NOT NULL DEFAULT 'Full Day',
  role             TEXT NOT NULL DEFAULT 'student',
  password_set     BOOLEAN NOT NULL DEFAULT FALSE,
  photo_url        TEXT DEFAULT '',
  aadhar_number    TEXT DEFAULT '',
  aadhar_image_url TEXT DEFAULT '',
  birthday         DATE,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

-- ──────────────────────────────────────────────────────────────
-- 5. SEATS
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS seats (
  id          TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  library_id  TEXT NOT NULL REFERENCES libraries(id) ON DELETE CASCADE,
  number      INT  NOT NULL,
  occupied    BOOLEAN NOT NULL DEFAULT FALSE,
  student_id  TEXT REFERENCES students(id) ON DELETE SET NULL,
  UNIQUE (library_id, number)
);

-- ──────────────────────────────────────────────────────────────
-- 6. ATTENDANCE
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS attendance (
  id          TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  library_id  TEXT NOT NULL REFERENCES libraries(id) ON DELETE CASCADE,
  student_id  TEXT NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  seat_number INT DEFAULT 0,
  timestamp   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  date        DATE GENERATED ALWAYS AS (timestamp::DATE) STORED,
  status      TEXT NOT NULL DEFAULT 'Present',
  UNIQUE (library_id, student_id, date)   -- once per day
);

-- ──────────────────────────────────────────────────────────────
-- 7. FEES
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS fees (
  id              TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  library_id      TEXT NOT NULL REFERENCES libraries(id) ON DELETE CASCADE,
  student_id      TEXT NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  student_name    TEXT DEFAULT '',
  seat_number     INT  DEFAULT 0,
  plan            TEXT NOT NULL DEFAULT '1 Month',
  due_date        DATE NOT NULL,
  payment_method  TEXT NOT NULL DEFAULT 'Pay to counter',
  payment_status  TEXT NOT NULL DEFAULT 'Pending',
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ──────────────────────────────────────────────────────────────
-- 8. BOOKS (requests)
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS books (
  id          TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  library_id  TEXT NOT NULL REFERENCES libraries(id) ON DELETE CASCADE,
  student_id  TEXT NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  book_name   TEXT NOT NULL DEFAULT '',
  image_url   TEXT DEFAULT '',
  status      TEXT NOT NULL DEFAULT 'Pending',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ──────────────────────────────────────────────────────────────
-- 9. EXPENSES
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS expenses (
  id          TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  library_id  TEXT NOT NULL REFERENCES libraries(id) ON DELETE CASCADE,
  name        TEXT NOT NULL DEFAULT '',
  amount      NUMERIC(10,2) NOT NULL DEFAULT 0.00,
  date        DATE NOT NULL DEFAULT CURRENT_DATE,
  notes       TEXT DEFAULT '',
  category    TEXT NOT NULL DEFAULT 'Other',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ──────────────────────────────────────────────────────────────
-- 10. ANNOUNCEMENTS
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS announcements (
  id          TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  library_id  TEXT NOT NULL REFERENCES libraries(id) ON DELETE CASCADE,
  title       TEXT NOT NULL DEFAULT '',
  message     TEXT NOT NULL DEFAULT '',
  image_url   TEXT DEFAULT '',
  priority    TEXT NOT NULL DEFAULT 'medium',
  created_by  TEXT DEFAULT '',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ──────────────────────────────────────────────────────────────
-- 11. MESSAGES
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS messages (
  id           TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  library_id   TEXT NOT NULL REFERENCES libraries(id) ON DELETE CASCADE,
  sender_id    TEXT NOT NULL DEFAULT '',
  receiver_id  TEXT,   -- NULL means broadcast to all students
  content      TEXT NOT NULL DEFAULT '',
  is_read      BOOLEAN NOT NULL DEFAULT FALSE,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- ──────────────────────────────────────────────────────────────
-- 12. NOTES
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS notes (
  id           TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  library_id   TEXT NOT NULL REFERENCES libraries(id) ON DELETE CASCADE,
  title        TEXT NOT NULL DEFAULT '',
  file_url     TEXT NOT NULL DEFAULT '',
  file_type    TEXT NOT NULL DEFAULT 'pdf',
  uploaded_by  TEXT DEFAULT '',
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- ──────────────────────────────────────────────────────────────
-- 13. STUDY SESSIONS
-- ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS study_sessions (
  id                TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  student_id        TEXT NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  library_id        TEXT NOT NULL REFERENCES libraries(id) ON DELETE CASCADE,
  start_time        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  end_time          TIMESTAMPTZ,
  duration_minutes  INT
);

-- ============================================================
-- STORAGE BUCKETS
-- ============================================================
-- Run these in the Supabase Dashboard → Storage → New Bucket
-- OR use the SQL below (requires pg_storage extension).
--
-- Buckets to create (all public):
--   library_images
--   student_photos
--   staff_photos
--   aadhar_images
--   book_images
--   notes_files
--
-- In Dashboard: Storage → New Bucket → name → Public → Create

-- ============================================================
-- ROW-LEVEL SECURITY (RLS)
-- ============================================================
-- Enable RLS on all tables
ALTER TABLE libraries        ENABLE ROW LEVEL SECURITY;
ALTER TABLE admins           ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff            ENABLE ROW LEVEL SECURITY;
ALTER TABLE students         ENABLE ROW LEVEL SECURITY;
ALTER TABLE seats            ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance       ENABLE ROW LEVEL SECURITY;
ALTER TABLE fees             ENABLE ROW LEVEL SECURITY;
ALTER TABLE books            ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses         ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements    ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages         ENABLE ROW LEVEL SECURITY;
ALTER TABLE notes            ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_sessions   ENABLE ROW LEVEL SECURITY;

-- ── Helper function: get library_id for current user ────────
CREATE OR REPLACE FUNCTION get_my_library_id()
RETURNS TEXT LANGUAGE sql STABLE AS $$
  SELECT COALESCE(
    (SELECT library_id FROM admins  WHERE id = auth.uid()::TEXT LIMIT 1),
    (SELECT library_id FROM staff   WHERE id = auth.uid()::TEXT LIMIT 1),
    (SELECT library_id FROM students WHERE id = auth.uid()::TEXT LIMIT 1)
  );
$$;

-- ── Libraries ───────────────────────────────────────────────
CREATE POLICY "Admins can manage their library"
  ON libraries FOR ALL USING (admin_id = auth.uid()::TEXT);

CREATE POLICY "Staff/Students can read their library"
  ON libraries FOR SELECT USING (id = get_my_library_id());

-- ── Admins ──────────────────────────────────────────────────
CREATE POLICY "Admins can read own record"
  ON admins FOR SELECT USING (id = auth.uid()::TEXT);

CREATE POLICY "Admins can update own record"
  ON admins FOR UPDATE USING (id = auth.uid()::TEXT);

CREATE POLICY "Admins can insert own record"
  ON admins FOR INSERT WITH CHECK (id = auth.uid()::TEXT);

-- ── Staff ───────────────────────────────────────────────────
CREATE POLICY "Admins can manage staff"
  ON staff FOR ALL
  USING (library_id IN (SELECT id FROM libraries WHERE admin_id = auth.uid()::TEXT));

CREATE POLICY "Staff can read own record"
  ON staff FOR SELECT USING (id = auth.uid()::TEXT);

-- ── Students ────────────────────────────────────────────────
CREATE POLICY "Admins and staff can manage students"
  ON students FOR ALL
  USING (library_id = get_my_library_id());

CREATE POLICY "Students can read own record"
  ON students FOR SELECT USING (id = auth.uid()::TEXT);

-- ── Seats ───────────────────────────────────────────────────
CREATE POLICY "Library members can read seats"
  ON seats FOR SELECT USING (library_id = get_my_library_id());

CREATE POLICY "Admins and staff can manage seats"
  ON seats FOR ALL
  USING (library_id IN (
    SELECT id FROM libraries WHERE admin_id = auth.uid()::TEXT
    UNION
    SELECT library_id FROM staff WHERE id = auth.uid()::TEXT
  ));

-- ── Attendance ──────────────────────────────────────────────
CREATE POLICY "Library members can read attendance"
  ON attendance FOR SELECT USING (library_id = get_my_library_id());

CREATE POLICY "Students can insert own attendance"
  ON attendance FOR INSERT WITH CHECK (student_id = auth.uid()::TEXT);

CREATE POLICY "Admins and staff can manage attendance"
  ON attendance FOR ALL
  USING (library_id IN (
    SELECT id FROM libraries WHERE admin_id = auth.uid()::TEXT
    UNION
    SELECT library_id FROM staff WHERE id = auth.uid()::TEXT
  ));

-- ── Fees ────────────────────────────────────────────────────
CREATE POLICY "Admins and staff can manage fees"
  ON fees FOR ALL
  USING (library_id IN (
    SELECT id FROM libraries WHERE admin_id = auth.uid()::TEXT
    UNION
    SELECT library_id FROM staff WHERE id = auth.uid()::TEXT
  ));

CREATE POLICY "Students can read own fees"
  ON fees FOR SELECT USING (student_id = auth.uid()::TEXT);

-- ── Books ───────────────────────────────────────────────────
CREATE POLICY "Library members can read books"
  ON books FOR SELECT USING (library_id = get_my_library_id());

CREATE POLICY "Students can insert book requests"
  ON books FOR INSERT WITH CHECK (student_id = auth.uid()::TEXT);

CREATE POLICY "Admins and staff can manage books"
  ON books FOR ALL
  USING (library_id IN (
    SELECT id FROM libraries WHERE admin_id = auth.uid()::TEXT
    UNION
    SELECT library_id FROM staff WHERE id = auth.uid()::TEXT
  ));

-- ── Expenses ────────────────────────────────────────────────
CREATE POLICY "Admins can manage expenses"
  ON expenses FOR ALL
  USING (library_id IN (SELECT id FROM libraries WHERE admin_id = auth.uid()::TEXT));

CREATE POLICY "Staff can read expenses"
  ON expenses FOR SELECT
  USING (library_id IN (SELECT library_id FROM staff WHERE id = auth.uid()::TEXT));

-- ── Announcements ───────────────────────────────────────────
CREATE POLICY "Library members can read announcements"
  ON announcements FOR SELECT USING (library_id = get_my_library_id());

CREATE POLICY "Admins and staff can manage announcements"
  ON announcements FOR ALL
  USING (library_id IN (
    SELECT id FROM libraries WHERE admin_id = auth.uid()::TEXT
    UNION
    SELECT library_id FROM staff WHERE id = auth.uid()::TEXT
  ));

-- ── Messages ────────────────────────────────────────────────
CREATE POLICY "Library members can read messages"
  ON messages FOR SELECT
  USING (
    library_id = get_my_library_id() AND
    (receiver_id IS NULL OR receiver_id = auth.uid()::TEXT OR sender_id = auth.uid()::TEXT)
  );

CREATE POLICY "Authenticated users can send messages"
  ON messages FOR INSERT WITH CHECK (sender_id = auth.uid()::TEXT);

-- ── Notes ───────────────────────────────────────────────────
CREATE POLICY "Library members can read notes"
  ON notes FOR SELECT USING (library_id = get_my_library_id());

CREATE POLICY "Admins and staff can manage notes"
  ON notes FOR ALL
  USING (library_id IN (
    SELECT id FROM libraries WHERE admin_id = auth.uid()::TEXT
    UNION
    SELECT library_id FROM staff WHERE id = auth.uid()::TEXT
  ));

-- ── Study Sessions ──────────────────────────────────────────
CREATE POLICY "Students can manage own study sessions"
  ON study_sessions FOR ALL USING (student_id = auth.uid()::TEXT);

CREATE POLICY "Admins and staff can read study sessions"
  ON study_sessions FOR SELECT
  USING (library_id IN (
    SELECT id FROM libraries WHERE admin_id = auth.uid()::TEXT
    UNION
    SELECT library_id FROM staff WHERE id = auth.uid()::TEXT
  ));

-- ============================================================
-- USEFUL INDEXES
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_students_library     ON students(library_id);
CREATE INDEX IF NOT EXISTS idx_staff_library        ON staff(library_id);
CREATE INDEX IF NOT EXISTS idx_seats_library        ON seats(library_id);
CREATE INDEX IF NOT EXISTS idx_attendance_library   ON attendance(library_id);
CREATE INDEX IF NOT EXISTS idx_attendance_student   ON attendance(student_id);
CREATE INDEX IF NOT EXISTS idx_attendance_date      ON attendance(date);
CREATE INDEX IF NOT EXISTS idx_fees_library         ON fees(library_id);
CREATE INDEX IF NOT EXISTS idx_fees_student         ON fees(student_id);
CREATE INDEX IF NOT EXISTS idx_books_library        ON books(library_id);
CREATE INDEX IF NOT EXISTS idx_expenses_library     ON expenses(library_id);
CREATE INDEX IF NOT EXISTS idx_announcements_lib    ON announcements(library_id);
CREATE INDEX IF NOT EXISTS idx_messages_library     ON messages(library_id);
CREATE INDEX IF NOT EXISTS idx_notes_library        ON notes(library_id);
CREATE INDEX IF NOT EXISTS idx_study_sessions_std   ON study_sessions(student_id);
