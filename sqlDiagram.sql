PRAGMA foreign_keys = ON;
--------------------------------------------------
-- 1) إنشاء الجداول الأساسية
--------------------------------------------------

---------------------
-- جدول الطلاب
---------------------
CREATE TABLE students (
    student_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name    TEXT NOT NULL,
    email        TEXT NOT NULL UNIQUE,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP
);

---------------------
-- جدول التوتورز (بشري أو AI)
---------------------
CREATE TABLE tutors (
    tutor_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name      TEXT NOT NULL,
    specialization TEXT,
    is_ai          INTEGER NOT NULL DEFAULT 0  -- 0 = بشرى, 1 = AI
);

---------------------
-- جدول الكورسات
---------------------
CREATE TABLE courses (
    course_id            INTEGER PRIMARY KEY AUTOINCREMENT,
    title                TEXT NOT NULL,
    level                TEXT,
    description          TEXT,
    created_by_tutor_id  INTEGER,
    created_at           DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by_tutor_id) REFERENCES tutors(tutor_id)
);

---------------------
-- اشتراك الطلاب في الكورسات
---------------------
CREATE TABLE enrollments (
    enrollment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id    INTEGER NOT NULL,
    course_id     INTEGER NOT NULL,
    enrolled_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    UNIQUE (student_id, course_id)
);

---------------------
-- الدروس داخل الكورس
---------------------
CREATE TABLE lessons (
    lesson_id        INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id        INTEGER NOT NULL,
    title            TEXT NOT NULL,
    content_summary  TEXT,
    order_index      INTEGER,
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

---------------------
-- جلسات التوتورينج (شات / كويز)
---------------------
CREATE TABLE sessions (
    session_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id    INTEGER NOT NULL,
    tutor_id      INTEGER NOT NULL,
    course_id     INTEGER,
    session_type  TEXT NOT NULL, -- 'chat' أو 'quiz'
    started_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    ended_at      DATETIME,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (tutor_id)   REFERENCES tutors(tutor_id),
    FOREIGN KEY (course_id)  REFERENCES courses(course_id)
);

---------------------
-- رسائل الشات داخل الجلسة
---------------------
CREATE TABLE messages (
    message_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id   INTEGER NOT NULL,
    sender_type  TEXT NOT NULL, -- 'student' أو 'tutor'
    content      TEXT NOT NULL,
    sent_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES sessions(session_id)
);

---------------------
-- أسئلة الكويز على الدروس
---------------------
CREATE TABLE quiz_questions (
    question_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    lesson_id      INTEGER NOT NULL,
    question_text  TEXT NOT NULL,
    difficulty     TEXT, -- 'easy', 'medium', 'hard'
    FOREIGN KEY (lesson_id) REFERENCES lessons(lesson_id)
);

---------------------
-- محاولات الطلاب في الكويز
---------------------
CREATE TABLE quiz_attempts (
    attempt_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id      INTEGER NOT NULL,
    question_id     INTEGER NOT NULL,
    student_answer  TEXT NOT NULL,
    is_correct      INTEGER NOT NULL, -- 0 أو 1
    attempted_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (question_id) REFERENCES quiz_questions(question_id)
);

---------------------
-- جدول حسابات الدخول (User Login)
---------------------
CREATE TABLE user_logins (
    user_login_id  INTEGER PRIMARY KEY AUTOINCREMENT,
    username       TEXT NOT NULL UNIQUE,     -- ده اللي اليوزر بيكتبه في شاشة اللوجين
    password_hash  TEXT NOT NULL,           -- خزّن الـ hash مش الباسوورد الخام
    role           TEXT NOT NULL,           -- 'student', 'tutor', 'admin' ...
    student_id     INTEGER,                 -- لو الأكاونت لطالب
    tutor_id       INTEGER,                 -- لو الأكاونت لتيوتور
    is_active      INTEGER NOT NULL DEFAULT 1,  -- 1 فعال، 0 موقوف
    last_login     DATETIME,
    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (tutor_id)   REFERENCES tutors(tutor_id)
);

--------------------------------------------------
-- 2) إدخال بيانات تجريبية
--------------------------------------------------

-- طلاب
INSERT INTO students (full_name, email) VALUES
('Ahmed Ali',   'ahmed@example.com'),
('Sara Mohamed','sara@example.com'),
('Omar Hassan', 'omar@example.com');

-- توتورز (AI + بشرية)
INSERT INTO tutors (full_name, specialization, is_ai) VALUES
('AI Tutor v1',      'General AI Tutoring', 1),
('Dr. Mona Hassan',  'Mathematics',         0);

-- كورسات
INSERT INTO courses (title, level, description, created_by_tutor_id) VALUES
('Intro to AI',  'Beginner', 'Basic concepts of AI and ML.', 1),
('Algebra 101',  'Beginner', 'Linear equations and inequalities.', 2);

-- اشتراكات الطلاب في الكورسات
INSERT INTO enrollments (student_id, course_id) VALUES
(1, 1), -- Ahmed في Intro to AI
(1, 2), -- Ahmed في Algebra
(2, 1), -- Sara في Intro to AI
(3, 2); -- Omar في Algebra

-- دروس Intro to AI
INSERT INTO lessons (course_id, title, content_summary, order_index) VALUES
(1, 'What is AI?', 'Definition, history, and applications of AI.', 1),
(1, 'Machine Learning Basics', 'Supervised vs unsupervised learning.', 2);

-- دروس Algebra 101
INSERT INTO lessons (course_id, title, content_summary, order_index) VALUES
(2, 'Linear Equations', 'Solve single-variable linear equations.', 1),
(2, 'Systems of Equations', 'Solve systems of linear equations.', 2);

-- جلسات توتورينج (شات)
INSERT INTO sessions (student_id, tutor_id, course_id, session_type, started_at, ended_at) VALUES
(1, 1, 1, 'chat', '2025-11-20 10:00:00', '2025-11-20 10:30:00'), -- Ahmed مع AI Tutor
(2, 2, 2, 'chat', '2025-11-21 15:00:00', '2025-11-21 15:45:00'); -- Sara مع Dr. Mona

-- رسائل في الجلسة الأولى
INSERT INTO messages (session_id, sender_type, content, sent_at) VALUES
(1, 'student', 'What is artificial intelligence?', '2025-11-20 10:01:00'),
(1, 'tutor',   'Artificial intelligence is the field of building smart machines.', '2025-11-20 10:01:10'),
(1, 'student', 'Can you give me real-world examples?', '2025-11-20 10:02:00'),
(1, 'tutor',   'Sure: recommendation systems, self-driving cars, and chatbots.', '2025-11-20 10:02:20');

-- رسائل في الجلسة الثانية
INSERT INTO messages (session_id, sender_type, content, sent_at) VALUES
(2, 'student', 'I do not understand how to solve 2x + 3 = 7.', '2025-11-21 15:05:00'),
(2, 'tutor',   'First subtract 3 from both sides, then divide by 2.', '2025-11-21 15:05:20');

-- أسئلة كويز على درس "What is AI?"
INSERT INTO quiz_questions (lesson_id, question_text, difficulty) VALUES
(1, 'What does AI stand for?', 'easy'),
(1, 'Mention one real-world application of AI.', 'easy');

-- أسئلة كويز على درس "Linear Equations"
INSERT INTO quiz_questions (lesson_id, question_text, difficulty) VALUES
(3, 'Solve the equation: 2x + 3 = 7', 'easy');

-- محاولات طلاب على أسئلة الكويز
INSERT INTO quiz_attempts (student_id, question_id, student_answer, is_correct, attempted_at) VALUES
(1, 1, 'Artificial Intelligence', 1, '2025-11-22 09:00:00'),
(1, 2, 'Self-driving cars',       1, '2025-11-22 09:02:00'),
(2, 3, 'x = 2',                   1, '2025-11-22 10:15:00'),
(3, 3, 'x = 1',                   0, '2025-11-22 11:00:00');

-- حسابات اللوجين (لاحظ إن اللوجين بالـ username)
INSERT INTO user_logins (username, password_hash, role, student_id)
VALUES
('ahmed', 'hashed_ahmed123', 'student', 1),
('sara',  'hashed_sara123',  'student', 2),
('omar',  'hashed_omar123',  'student', 3);

INSERT INTO user_logins (username, password_hash, role, tutor_id)
VALUES
('dr_mona', 'hashed_mona123', 'tutor', 2);

INSERT INTO user_logins (username, password_hash, role)
VALUES
('admin', 'hashed_admin123', 'admin');


SELECT *
FROM user_logins
WHERE  username = :username
  AND    is_active = 1; 
  
