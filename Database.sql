USE master;
GO

IF DB_ID('SchoolSystemDB') IS NOT NULL
-- Create the Database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'SchoolSystemDB')
BEGIN
    ALTER DATABASE SchoolSystemDB 
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE SchoolSystemDB;
END
GO

-- Create the Database
CREATE DATABASE [SchoolSystemDB];
GO
use [SchoolSystemDB];
GO

-- Create the Database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'SchoolSystemDB')
BEGIN
    CREATE DATABASE [SchoolSystemDB];
END
GO

-- 1. Table: Admin (HoP)
IF OBJECT_ID('[Admin (HoP)]', 'U') IS NOT NULL DROP TABLE [Admin (HoP)];
CREATE TABLE [Admin (HoP)] (
  [admin_id] INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
  [admin_name] NVARCHAR(45) NOT NULL,
  [admin_email] NVARCHAR(45) NOT NULL,
  [admin_pw] NVARCHAR(45) NOT NULL,
  [admin_isactive] BIT NULL,
  [admin_bio] NVARCHAR(MAX) NULL,     -- New Bio Field
  [admin_img] VARBINARY(MAX) NULL    -- New Image Field
);

-- 2. Table: Lecturer
IF OBJECT_ID('[Lecturer]', 'U') IS NOT NULL DROP TABLE [Lecturer];
CREATE TABLE [Lecturer] (
  [lecturer_id] INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
  [lecturer_name] NVARCHAR(45) NOT NULL,
  [lecturer_pw] NVARCHAR(45) NOT NULL,
  [lecturer_email] NVARCHAR(45) NOT NULL,
  [lecturer_contact] NVARCHAR(45) NOT NULL,
  [lecturer_address] NVARCHAR(45) NOT NULL,
  [date_of_birth] NVARCHAR(100) NOT NULL,
  [program_specialisation] NVARCHAR(100) NOT NULL,
  [teacher_isactive] NVARCHAR(45) NOT NULL,
  [lecturer_bio] NVARCHAR(MAX) NULL,   -- New Bio Field
  [lecturer_img] VARBINARY(MAX) NULL,  -- New Image Field
  [Admin_admin_id] INT NOT NULL,
  CONSTRAINT [fk_Lecturer_Admin] FOREIGN KEY ([Admin_admin_id]) REFERENCES [Admin (HoP)] ([admin_id])
);


-- 3. Table: Program
IF OBJECT_ID('[Program]', 'U') IS NOT NULL DROP TABLE [Program];
CREATE TABLE [Program] (
  [program_id] INT NOT NULL IDENTITY(1,1),
  [program_name] NVARCHAR(100) NOT NULL,
  [program_desc] NVARCHAR(MAX) NOT NULL,
  [program_fee] NVARCHAR(45) NOT NULL,
  [program_semester] INT NULL,
  [program_credits] INT NULL,
  [program_isactive] BIT NOT NULL,
  [Lecturer_id] INT NOT NULL,
  [Admin_admin_id] INT NOT NULL,
  PRIMARY KEY ([program_id]),
  CONSTRAINT [fk_Program_Admin] FOREIGN KEY ([Admin_admin_id]) REFERENCES [Admin (HoP)] ([admin_id]),
  CONSTRAINT [fk_Program_Lecturer] FOREIGN KEY ([Lecturer_id]) REFERENCES [Lecturer] ([lecturer_id])
);

-- 4. Table: Student
IF OBJECT_ID('[Student]', 'U') IS NOT NULL DROP TABLE [Student];
CREATE TABLE [Student] (
  [student_id] INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
  [student_name] NVARCHAR(45) NOT NULL,
  [student_pw] NVARCHAR(45) NOT NULL,
  [student_email] NVARCHAR(45) NOT NULL,
  [student_contact] NVARCHAR(45) NOT NULL,
  [student_address] NVARCHAR(45) NOT NULL,
  [date_of_birth] DATETIME NOT NULL,
  [student_sem] INT NULL,
  [enrollment_date] DATETIME DEFAULT GETDATE(),
  [student_isactive] NVARCHAR(45) NOT NULL,
  [student_bio] NVARCHAR(MAX) NULL,    -- New Bio Field
  [student_img] VARBINARY(MAX) NULL,   -- New Image Field
  [Admin_admin_id] INT NOT NULL,
  [Program_id] INT NOT NULL,
  CONSTRAINT [fk_Student_Admin] FOREIGN KEY ([Admin_admin_id]) REFERENCES [Admin (HoP)] ([admin_id]),
  CONSTRAINT [fk_Student_Program] FOREIGN KEY ([Program_id]) REFERENCES [Program] ([program_id])
);

-- 5. Table: Grades
IF OBJECT_ID('[Grades]', 'U') IS NOT NULL DROP TABLE [Grades];
CREATE TABLE [Grades] (
  [grades_id] INT NOT NULL IDENTITY(1,1),
  [gpa] DECIMAL(3,2) NULL,
  [cgpa] DECIMAL(3,2) NULL,
  [grade_marks] DECIMAL(5,2) NULL,
  [Student_id] INT NOT NULL,
  PRIMARY KEY ([grades_id]),
  CONSTRAINT [fk_Grades_Student] FOREIGN KEY ([Student_id]) REFERENCES [Student] ([student_id])
);

-- 6. Table: Calendar
IF OBJECT_ID('[Calendar]', 'U') IS NOT NULL DROP TABLE [Calendar];
CREATE TABLE [Calendar] (
    [calendar_id] INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [event_title] NVARCHAR(100) NOT NULL,
    [event_desc] NVARCHAR(MAX) NULL,
    [start_date] DATETIME NOT NULL,
    [end_date] DATETIME NULL,
    [event_type] NVARCHAR(50) DEFAULT 'General',
    [Admin_id] INT NOT NULL,
    CONSTRAINT [fk_Calendar_Admin] FOREIGN KEY ([Admin_id]) REFERENCES [Admin (HoP)] ([admin_id])
);

-- 7. Table: Course
IF OBJECT_ID('[Course]', 'U') IS NOT NULL DROP TABLE [Course];
CREATE TABLE [Course] (
  [course_id] INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
  [course_name] NVARCHAR(100) NULL, -- Added this so you can name the courses (e.g. 'Math')
  [course_assignment] DECIMAL(5,2) NULL,
  [course_exam] DECIMAL(5,2) NULL,
  [course_attendance] BIT NULL,
  [Student_id] INT NOT NULL,
  [Lecturer_id] INT NOT NULL,
  [Calendar_id] INT NOT NULL,
  CONSTRAINT [fk_Course_Student] FOREIGN KEY ([Student_id]) REFERENCES [Student] ([student_id]),
  CONSTRAINT [fk_Course_Lecturer] FOREIGN KEY ([Lecturer_id]) REFERENCES [Lecturer] ([lecturer_id]),
  CONSTRAINT [fk_Course_Calendar] FOREIGN KEY ([Calendar_id]) REFERENCES [Calendar] ([calendar_id])
);

-- 8. Table: Payment
IF OBJECT_ID('[Payment]', 'U') IS NOT NULL DROP TABLE [Payment];
CREATE TABLE [Payment] (
  [payment_id] INT NOT NULL IDENTITY(1,1),
  [payment_amount] DECIMAL(10,2) NULL,
  [payment_duedate] DATETIME NULL,
  [payment_paydate] DATETIME NULL,
  [payment_method] NVARCHAR(45) NULL,
  [Student_id] INT NOT NULL,
  PRIMARY KEY ([payment_id]),
  CONSTRAINT [fk_Payment_Student] FOREIGN KEY ([Student_id]) REFERENCES [Student] ([student_id])
);

-- 9. Table: Announcement
IF OBJECT_ID('[Announcement]', 'U') IS NOT NULL DROP TABLE [Announcement];
CREATE TABLE [Announcement] (
    [announcement_id] INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [title] NVARCHAR(100) NOT NULL,
    [content] NVARCHAR(MAX) NOT NULL,
    [category] NVARCHAR(45) DEFAULT 'General',
    [created_at] DATETIME DEFAULT GETDATE(),
    [Admin_id] INT NULL,
    [Lecturer_id] INT NULL,
    [Course_id] INT NULL,
    CONSTRAINT [fk_Rule_Admin] FOREIGN KEY ([Admin_id]) REFERENCES [Admin (HoP)] ([admin_id]),
    CONSTRAINT [fk_Rule_Lecturer] FOREIGN KEY ([Lecturer_id]) REFERENCES [Lecturer] ([lecturer_id]),
    CONSTRAINT [fk_Rule_Course] FOREIGN KEY ([Course_id]) REFERENCES [Course] ([course_id])
);

-- Insert Initial Admin
INSERT INTO [Admin (HoP)] (admin_email, admin_name, admin_pw, admin_isactive, admin_bio)
VALUES ('admin@school.com', 'Tan Kai En', 'admin123', 1, 'Senior Head of Program at School of Computing.');
GO


INSERT INTO [Calendar] (event_title, start_date, Admin_id) VALUES ('Semester 1 Starts', '2026-05-01', 1);
INSERT INTO [Announcement] (title, content, Admin_id) VALUES ('Welcome to the New System', 'The portal is now live.', 1);
GO


-- 1. Add some Lecturers (Needed for Programs and Courses)
INSERT INTO [Lecturer] (lecturer_name, lecturer_pw, lecturer_email, lecturer_contact, lecturer_address, date_of_birth, program_specialisation, teacher_isactive, Admin_admin_id)
VALUES 
('Alan Turing', 'pass123', 'alan@school.com', '012-3456789', '123 Computing Way', '1990-01-01', 'Computer Science', 'Active', 1),
('Ada Lovelace', 'pass123', 'ada@school.com', '012-9876543', '456 Algorithm Lane', '1992-05-15', 'Software Engineering', 'Active', 1),
('Warren Buffett', 'pass123', 'warren@school.com', '011-1112222', '789 Finance St', '1985-10-10', 'Business Management', 'Active', 1);

-- 2. Add Programs (This will drive your Pie Chart)
INSERT INTO [Program] (program_name, program_desc, program_fee, program_semester, program_credits, program_isactive, Lecturer_id, Admin_admin_id)
VALUES 
('School of Computing', 'Deep dive into coding and AI', '15000', 6, 120, 1, 1, 1),
('School of Business', 'Management and Economics', '12000', 6, 100, 1, 3, 1),
('School of Design', 'UI/UX and Graphic Arts', '13000', 6, 110, 1, 2, 1);

-- 3. Add Students (Distributed across programs for the chart)
-- Computing (4 students)
INSERT INTO [Student] (student_name, student_pw, student_email, student_contact, student_address, date_of_birth, student_sem, student_isactive, Admin_admin_id, Program_id)
VALUES 
('John Doe', 'stud123', 'john@stud.com', '017-1111', 'KL', '2004-01-01', 1, 'Active', 1, 1),
('Jane Smith', 'stud123', 'jane@stud.com', '017-2222', 'PJ', '2004-02-01', 1, 'Active', 1, 1),
('Bob Wilson', 'stud123', 'bob@stud.com', '017-3333', 'Subang', '2004-03-01', 2, 'Active', 1, 1),
('Alice Wong', 'stud123', 'alice@stud.com', '017-4444', 'Cheras', '2004-04-01', 1, 'Active', 1, 1);

-- Business (2 students)
INSERT INTO [Student] (student_name, student_pw, student_email, student_contact, student_address, date_of_birth, student_sem, student_isactive, Admin_admin_id, Program_id)
VALUES 
('Charlie Brown', 'stud123', 'charlie@stud.com', '017-5555', 'KL', '2003-05-01', 3, 'Active', 1, 2),
('David Miller', 'stud123', 'david@stud.com', '017-6666', 'PJ', '2003-06-01', 3, 'Active', 1, 2);

-- Design (1 student)
INSERT INTO [Student] (student_name, student_pw, student_email, student_contact, student_address, date_of_birth, student_sem, student_isactive, Admin_admin_id, Program_id)
VALUES 
('Eve Adams', 'stud123', 'eve@stud.com', '017-7777', 'Shah Alam', '2004-07-01', 1, 'Active', 1, 3);

-- 4. Add Calendar Events (Driving your "Upcoming Schedule")
INSERT INTO [Calendar] (event_title, event_desc, start_date, end_date, event_type, Admin_id)
VALUES 
('Final Exam Week', 'All levels', '2026-06-15', '2026-06-30', 'Exam', 1),
('Semester Break', 'Summer holiday', '2026-07-01', '2026-08-31', 'Holiday', 1),
('Course Registration', 'New Semester', '2026-08-20', '2026-08-25', 'Enrollment', 1),
('System Maintenance', 'Portal Offline', '2026-05-10', '2026-05-11', 'General', 1);

-- 5. Add Courses (To test the "Total Courses" count)
INSERT INTO [Course] (course_name, course_assignment, course_exam, course_attendance, Student_id, Lecturer_id, Calendar_id)
VALUES 
('C# Development', 85.0, 90.0, 1, 1, 1, 1),
('Database Systems', 70.0, 75.0, 1, 2, 2, 1),
('Business Ethics', 95.0, 88.0, 1, 5, 3, 1);

-- 6. Add Announcements (Driving your "Latest Announcements" list)
INSERT INTO [Announcement] (title, content, category, Admin_id)
VALUES 
('Exam Venue Update', 'Check your portal for the new hall numbers.', 'Academic', 1),
('Library Closing Early', 'Closing at 6 PM this Friday for renovations.', 'General', 1),
('Scholarship Open', 'Apply now for the 2026 intake.', 'Finance', 1),
('Club Recruitment', 'Join the Robotics club today!', 'Co-curriculum', 1);


--AML added
USE [SchoolSystemDB];
GO

-- Drop tables with dependencies first
IF OBJECT_ID('[Announcement]', 'U') IS NOT NULL DROP TABLE [Announcement];
IF OBJECT_ID('[Enrollment]', 'U') IS NOT NULL DROP TABLE [Enrollment];
IF OBJECT_ID('[Course]', 'U') IS NOT NULL DROP TABLE [Course];
GO

CREATE TABLE [Course] (
  [course_code] NVARCHAR(20) NULL, -- Added Course Code
  [course_id] INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
  [course_name] NVARCHAR(100) NULL,
  [credit_hours] INT NULL,
  [course_status] NVARCHAR(20) DEFAULT 'Open', 
  [Lecturer_id] INT NOT NULL,
  [Calendar_id] INT NOT NULL,
  [Program_id] INT NOT NULL DEFAULT 1,
  
  CONSTRAINT [fk_Course_Lecturer] FOREIGN KEY ([Lecturer_id]) REFERENCES [Lecturer] ([lecturer_id]),
  CONSTRAINT [fk_Course_Calendar] FOREIGN KEY ([Calendar_id]) REFERENCES [Calendar] ([calendar_id]),
  CONSTRAINT [fk_Course_Program] FOREIGN KEY ([Program_id]) REFERENCES [Program] ([program_id])
);
GO

CREATE TABLE [Announcement] (
    [announcement_id] INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [title] NVARCHAR(100) NOT NULL,
    [content] NVARCHAR(MAX) NOT NULL,
    [category] NVARCHAR(45) DEFAULT 'General',
    [created_at] DATETIME DEFAULT GETDATE(),
    [Admin_id] INT NULL,
    [Lecturer_id] INT NULL,
    [Course_id] INT NULL,
    CONSTRAINT [fk_Rule_Admin] FOREIGN KEY ([Admin_id]) REFERENCES [Admin (HoP)] ([admin_id]),
    CONSTRAINT [fk_Rule_Lecturer] FOREIGN KEY ([Lecturer_id]) REFERENCES [Lecturer] ([lecturer_id]),
    CONSTRAINT [fk_Rule_Course] FOREIGN KEY ([Course_id]) REFERENCES [Course] ([course_id])
);
GO

-- Insert Courses with the new [course_code] column
INSERT INTO Course (course_code, course_name, Lecturer_id, Calendar_id, credit_hours, course_status, Program_id)
VALUES 
    ('CS101', 'C# Development', 1, 1, 3, 'Open', 1),
    ('DB202', 'Database Systems', 2, 1, 4, 'Ongoing', 1),
    ('BUS301', 'Business Ethics', 3, 1, 3, 'Open', 1),
    ('WEB105', 'Web Development', 1, 1, 3, 'Open', 1),
    ('DS204', 'Data Structures', 2, 1, 4, 'Ongoing', 1);
GO




-- HJ Added Enrollment Table, CourseGrade, Dummy Data
IF OBJECT_ID('[CourseGrade]', 'U') IS NOT NULL DROP TABLE [CourseGrade];
IF OBJECT_ID('[Enrollment]', 'U') IS NOT NULL DROP TABLE [Enrollment];
GO

CREATE TABLE [Enrollment] (
    [enrollment_id] INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [semester]      INT NOT NULL,
    [Student_id]    INT NOT NULL,
    [Course_id]     INT NOT NULL,
    CONSTRAINT [fk_Enrollment_Student] FOREIGN KEY ([Student_id]) REFERENCES [Student]([student_id]),
    CONSTRAINT [fk_Enrollment_Course]  FOREIGN KEY ([Course_id])  REFERENCES [Course]([course_id])
);

CREATE TABLE [CourseGrade] (
    [cg_id]          INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [letter_grade]   NVARCHAR(5) NOT NULL,
    [grade_point]    DECIMAL(3,2) NOT NULL,
    [total_hours]    INT NOT NULL DEFAULT 0,
    [attended_hours] INT NOT NULL DEFAULT 0,
    [Enrollment_id]  INT NOT NULL,
    CONSTRAINT [fk_CG_Enrollment] FOREIGN KEY ([Enrollment_id]) REFERENCES [Enrollment]([enrollment_id])
);

-- =============================================
-- DATA FOR STUDENT 1 (John Doe)
-- =============================================
-- Semester 1: CS101, DB202, WEB105
INSERT INTO [Enrollment] (semester, Student_id, Course_id) VALUES(1, 1, 1),(1, 1, 2),(1, 1, 4);
-- Semester 2: DS204, BUS301
INSERT INTO [Enrollment] (semester, Student_id, Course_id) VALUES(2, 1, 5),(2, 1, 3);

-- CourseGrades (Enrollment IDs: 1, 2, 3, 4, 5)
INSERT INTO [CourseGrade] (letter_grade, grade_point, total_hours, attended_hours, Enrollment_id) VALUES
('A',  4.00, 42, 38, 1),
('B+', 3.50, 48, 44, 2),
('A-', 3.70, 36, 32, 3),
('A',  4.00, 48, 45, 4),
('B',  3.00, 42, 36, 5);


-- =============================================
-- DATA FOR STUDENT 2 (Jane Smith) - CRITICAL CASE
-- =============================================
-- Low attendance and failing/borderline grades
INSERT INTO [Enrollment] (semester, Student_id, Course_id) VALUES(1, 2, 1),(1, 2, 2);
INSERT INTO [Enrollment] (semester, Student_id, Course_id) VALUES(2, 2, 4),(2, 2, 5);

-- CourseGrades (Enrollment IDs: 6, 7, 8, 9)
INSERT INTO [CourseGrade] (letter_grade, grade_point, total_hours, attended_hours, Enrollment_id) VALUES
('F',  0.00, 42, 10, 6), -- Failed, very low attendance
('D',  1.00, 48, 15, 7), -- Barely passed, low attendance
('F',  0.00, 36, 5,  8), -- Failed, almost never attended
('C-', 1.70, 48, 20, 9); -- Poor grade, low attendance


-- =============================================
-- DATA FOR STUDENT 3 (Bob Wilson) - 1 Exc, 1 Good, 1 Avg, 1 Poor
-- =============================================
INSERT INTO [Enrollment] (semester, Student_id, Course_id) VALUES(1, 3, 1),(1, 3, 2);
INSERT INTO [Enrollment] (semester, Student_id, Course_id) VALUES(2, 3, 4),(2, 3, 5);

-- CourseGrades (check your actual enrollment_ids after re-run)
INSERT INTO [CourseGrade] (letter_grade, grade_point, total_hours, attended_hours, Enrollment_id) VALUES
('A',  4.00, 42, 40, (SELECT enrollment_id FROM [Enrollment] WHERE Student_id = 3 AND Course_id = 1)),
('B',  3.00, 48, 44, (SELECT enrollment_id FROM [Enrollment] WHERE Student_id = 3 AND Course_id = 2)),
('C+', 2.30, 36, 30, (SELECT enrollment_id FROM [Enrollment] WHERE Student_id = 3 AND Course_id = 4)),
('D',  1.00, 42, 28, (SELECT enrollment_id FROM [Enrollment] WHERE Student_id = 3 AND Course_id = 5));


-- =============================================
-- DATA FOR STUDENT 4 (Alice Wong) - WARNING CASE
-- =============================================
-- Attendance hovering in the 70-79% warning zone
INSERT INTO [Enrollment] (semester, Student_id, Course_id) VALUES(1, 4, 1),(1, 4, 4);
INSERT INTO [Enrollment] (semester, Student_id, Course_id) VALUES(2, 4, 2),(2, 4, 3);

-- CourseGrades (Enrollment IDs: 14, 15, 16, 17)
INSERT INTO [CourseGrade] (letter_grade, grade_point, total_hours, attended_hours, Enrollment_id) VALUES
('B-', 2.70, 42, 31, 14), -- 73.8% attendance - warning zone
('C+', 2.30, 36, 26, 15), -- 72.2% attendance - warning zone
('B',  3.00, 48, 35, 16), -- 72.9% attendance - warning zone
('C',  2.00, 42, 30, 17); -- 71.4% attendance - warning zone

GO

--NEWEST


