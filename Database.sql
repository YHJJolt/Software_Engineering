-- Create the Database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'SchoolSystemDB')
BEGIN
    CREATE DATABASE [SchoolSystemDB];
END
GO

-- 1. Table: Admin (HoP)
IF OBJECT_ID('[Admin (HoP)]', 'U') IS NOT NULL DROP TABLE [Admin (HoP)];
CREATE TABLE [Admin (HoP)] (
  [admin_id] INT NOT NULL IDENTITY(1,1),
  [admin_name] NVARCHAR(45) NOT NULL,
  [admin_email] NVARCHAR(45) NOT NULL,
  [admin_pw] NVARCHAR(45) NOT NULL,
  [admin_isactive] BIT NULL,
  PRIMARY KEY ([admin_id])
);

-- 2. Table: Lecturer
IF OBJECT_ID('[Lecturer]', 'U') IS NOT NULL DROP TABLE [Lecturer];
CREATE TABLE [Lecturer] (
  [lecturer_id] INT NOT NULL IDENTITY(1,1),
  [lecturer_name] NVARCHAR(45) NOT NULL,
  [lecturer_pw] NVARCHAR(45) NOT NULL,
  [lecturer_email] NVARCHAR(45) NOT NULL,
  [lecturer_contact] NVARCHAR(45) NOT NULL,
  [lecturer_address] NVARCHAR(45) NOT NULL,
  [date_of_birth] NVARCHAR(100) NOT NULL,
  [program_specialisation] NVARCHAR(100) NOT NULL,
  [teacher_isactive] NVARCHAR(45) NOT NULL,
  [Admin_admin_id] INT NOT NULL,
  PRIMARY KEY ([lecturer_id]),
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
  [student_id] INT NOT NULL IDENTITY(1,1),
  [student_name] NVARCHAR(45) NOT NULL,
  [student_pw] NVARCHAR(45) NOT NULL,
  [student_email] NVARCHAR(45) NOT NULL,
  [student_contact] NVARCHAR(45) NOT NULL,
  [student_address] NVARCHAR(45) NOT NULL,
  [date_of_birth] DATETIME NOT NULL,
  [student_sem] INT NULL,
  [enrollment_date] DATETIME DEFAULT GETDATE(),
  [student_isactive] NVARCHAR(45) NOT NULL,
  [created_time] DATETIME DEFAULT GETDATE(),
  [Admin_admin_id] INT NOT NULL,
  [Program_id] INT NOT NULL,
  PRIMARY KEY ([student_id]),
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

INSERT INTO [Admin (HoP)] (admin_email, admin_name, admin_pw, admin_isactive)
VALUES ('admin@school.com','Dr. Smith', 'admin123', 1);


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

GO