 USE master;
GO

-- 1. Create the Database FIRST
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'SchoolSystemDB')
BEGIN
    CREATE DATABASE [SchoolSystemDB];
END
GO

-- 2. SWITCH to the Database BEFORE dropping or creating tables!
USE SchoolSystemDB;
GO

-- 3. Drop existing tables if they exist (ORDER MATTERS FOR FOREIGN KEYS)
IF OBJECT_ID('[LecturerCourseFavourite]', 'U') IS NOT NULL DROP TABLE [LecturerCourseFavourite]; 
IF OBJECT_ID('[AssignmentSubmission]', 'U') IS NOT NULL DROP TABLE [AssignmentSubmission];
IF OBJECT_ID('[CourseAssignment]', 'U') IS NOT NULL DROP TABLE [CourseAssignment];
IF OBJECT_ID('[ModuleFile]', 'U') IS NOT NULL DROP TABLE [ModuleFile];
IF OBJECT_ID('[CourseModule]', 'U') IS NOT NULL DROP TABLE [CourseModule];
IF OBJECT_ID('[CourseGrade]', 'U') IS NOT NULL DROP TABLE [CourseGrade];
IF OBJECT_ID('[Announcement]', 'U') IS NOT NULL DROP TABLE [Announcement];
IF OBJECT_ID('[Payment]', 'U') IS NOT NULL DROP TABLE [Payment];
IF OBJECT_ID('[Enrollment]', 'U') IS NOT NULL DROP TABLE [Enrollment];
IF OBJECT_ID('[Course]', 'U') IS NOT NULL DROP TABLE [Course];
IF OBJECT_ID('[Calendar]', 'U') IS NOT NULL DROP TABLE [Calendar];
IF OBJECT_ID('[LecturerCalendar]', 'U') IS NOT NULL DROP TABLE LecturerCalendar;
IF OBJECT_ID('[Grades]', 'U') IS NOT NULL DROP TABLE [Grades];
IF OBJECT_ID('[Student]', 'U') IS NOT NULL DROP TABLE [Student];
IF OBJECT_ID('[Program]', 'U') IS NOT NULL DROP TABLE [Program];
IF OBJECT_ID('[Lecturer]', 'U') IS NOT NULL DROP TABLE [Lecturer];
IF OBJECT_ID('[Admin (HoP)]', 'U') IS NOT NULL DROP TABLE [Admin (HoP)];
GO

-- ============================================================
-- 1. Table: Admin (HoP)
-- ============================================================
CREATE TABLE [Admin (HoP)] (
  [admin_id] INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
  [admin_name] NVARCHAR(45) NOT NULL,
  [admin_email] NVARCHAR(45) NOT NULL,
  [admin_pw] NVARCHAR(45) NOT NULL,
  [admin_isactive] BIT NULL,
  [admin_bio] NVARCHAR(MAX) NULL,     
  [admin_img] VARBINARY(MAX) NULL    
);

-- ============================================================
-- 2. Table: Lecturer
-- ============================================================
CREATE TABLE [Lecturer] (
    [lecturer_id]        INT            NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [lecturer_code]      NVARCHAR(10)   NULL,                       
    [lecturer_name]      NVARCHAR(45)   NOT NULL,
    [lecturer_pw]        NVARCHAR(45)   NOT NULL DEFAULT 'lec123',  
    [lecturer_email]     NVARCHAR(45)   NOT NULL,                   
    [lecturer_contact]   NVARCHAR(45)   NULL,                       
    [lecturer_address]   NVARCHAR(45)   NULL,                       
    [date_of_birth]      NVARCHAR(100)  NULL,                       
    [lecturer_department] NVARCHAR(100) NOT NULL,                   
    [teacher_isactive]   NVARCHAR(45)   NOT NULL,
    [lecturer_bio]       NVARCHAR(MAX)  NULL,
    [lecturer_img]       VARBINARY(MAX) NULL,
    [Admin_admin_id]     INT            NOT NULL,
    CONSTRAINT [fk_Lecturer_Admin] FOREIGN KEY ([Admin_admin_id])
        REFERENCES [Admin (HoP)] ([admin_id])
);

-- ============================================================
-- 3. Table: Program
-- ============================================================
CREATE TABLE [Program] (
    [program_id]       INT            NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[program_code]     NVARCHAR(20)   NOT NULL,
    [program_name]     NVARCHAR(100)  NOT NULL,
    [program_level]    NVARCHAR(50)   NOT NULL,
    [program_fee]      DECIMAL(10,2)   NOT NULL,
    [program_semester] INT            NULL,
    [program_credits]  INT            NULL,
    [program_isactive] BIT            NOT NULL DEFAULT 1,
    [Lecturer_id]      INT            NOT NULL,
    [Admin_admin_id]   INT            NOT NULL,
    CONSTRAINT [fk_Program_Admin]    FOREIGN KEY ([Admin_admin_id])
        REFERENCES [Admin (HoP)] ([admin_id]),
    CONSTRAINT [fk_Program_Lecturer] FOREIGN KEY ([Lecturer_id])
        REFERENCES [Lecturer] ([lecturer_id])
);

-- ============================================================
-- 4. Table: Student
-- ============================================================
CREATE TABLE [Student] (
    [student_id]       INT            NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [student_code]     NVARCHAR(10)   NULL,                         
    [student_name]     NVARCHAR(45)   NOT NULL,
    [student_pw]       NVARCHAR(45)   NOT NULL DEFAULT 'stud123',
    [student_email]    NVARCHAR(45)   NOT NULL,                     
    [student_contact]  NVARCHAR(45)   NULL,                         
    [student_address]  NVARCHAR(45)   NULL,                         
    [date_of_birth]    DATETIME       NULL,                         
    [student_sem]      INT            NOT NULL,                     
    [student_isactive] NVARCHAR(45)   NOT NULL,
    [student_bio]      NVARCHAR(MAX)  NULL,
    [student_img]      VARBINARY(MAX) NULL,
    [Admin_admin_id]   INT            NOT NULL,
    [Program_id]       INT            NOT NULL,
    CONSTRAINT [fk_Student_Admin]   FOREIGN KEY ([Admin_admin_id])
        REFERENCES [Admin (HoP)] ([admin_id]),
    CONSTRAINT [fk_Student_Program] FOREIGN KEY ([Program_id])
        REFERENCES [Program] ([program_id])
);

-- ============================================================
-- 5. Table: Grades
-- ============================================================
CREATE TABLE [Grades] (
    [grades_id]   INT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [gpa]         DECIMAL(3,2) NULL,
    [cgpa]        DECIMAL(3,2) NULL,
    [grade_marks] DECIMAL(5,2) NULL,
    [Student_id]  INT          NOT NULL,
    CONSTRAINT [fk_Grades_Student] FOREIGN KEY ([Student_id])
        REFERENCES [Student] ([student_id])
);

-- ============================================================
-- 6. Table: Admin Calendar
-- ============================================================
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

-- ============================================================
-- 7. Table: Lecturer Calendar
-- ============================================================
CREATE TABLE LecturerCalendar (
    calendar_id   INT           IDENTITY(1,1) PRIMARY KEY,
    event_title   NVARCHAR(200) NOT NULL,
    event_desc    NVARCHAR(MAX) NULL,
    start_date    DATE          NOT NULL,
    end_date      DATE          NULL,
    event_type    NVARCHAR(50)  NOT NULL DEFAULT 'Class',
        -- Allowed values: 'Class', 'Assignment', 'Meeting', 'Personal'
    visibility    NVARCHAR(50)  NOT NULL DEFAULT 'Private',
    lecturer_id   INT           NOT NULL,
    created_at    DATETIME      NOT NULL DEFAULT GETDATE(),
 
    CONSTRAINT FK_LecCalendar_Lecturer
        FOREIGN KEY (lecturer_id) REFERENCES Lecturer(lecturer_id)
        ON DELETE CASCADE
);

-- ============================================================
-- 8. Table: Course
-- ============================================================
CREATE TABLE [Course] (
  [course_code] NVARCHAR(20) NULL, 
  [course_id] INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
  [course_name] NVARCHAR(100) NULL,
  [credit_hours] INT NULL,
  [course_fee] NVARCHAR(45) NOT NULL, 
  [course_status] NVARCHAR(20) DEFAULT 'Open', 
  [course_img] VARBINARY(MAX) NULL,
  [Lecturer_id] INT NOT NULL,
  [Calendar_id] INT NOT NULL,
  [Program_id] INT NOT NULL DEFAULT 1,
  
  CONSTRAINT [fk_Course_Lecturer] FOREIGN KEY ([Lecturer_id]) REFERENCES [Lecturer] ([lecturer_id]),
  CONSTRAINT [fk_Course_Calendar] FOREIGN KEY ([Calendar_id]) REFERENCES [Calendar] ([calendar_id]),
  CONSTRAINT [fk_Course_Program] FOREIGN KEY ([Program_id]) REFERENCES [Program] ([program_id])
);
GO

-- ============================================================
-- 9. Table: Enrolment
-- ============================================================
CREATE TABLE [Enrollment] (
    [enrollment_id] INT IDENTITY(1,1) PRIMARY KEY,
    [student_id] INT NOT NULL,
    [course_id] INT NOT NULL,
    [enrollment_date] DATETIME DEFAULT GETDATE(),
    [status] VARCHAR(20) DEFAULT 'Pending',
    CONSTRAINT [FK_Enrollment_Student]
        FOREIGN KEY ([student_id])
        REFERENCES [Student]([student_id]),
    CONSTRAINT [FK_Enrollment_Course]
        FOREIGN KEY ([course_id])
        REFERENCES [Course]([course_id])
);

-- ============================================================
-- 10. Table: Payment
-- ============================================================
CREATE TABLE [Payment] (
    [payment_id]      INT            NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [payment_amount]  DECIMAL(10,2)  NULL,
    [payment_duedate] DATETIME       NULL,
    [payment_paydate] DATETIME       NULL,
    [payment_method]  NVARCHAR(45)   NULL,
    [Student_id]      INT            NOT NULL,
    CONSTRAINT [fk_Payment_Student] FOREIGN KEY ([Student_id])
        REFERENCES [Student] ([student_id])
);

-- ============================================================
-- 11. Table: Announcement
-- ============================================================
CREATE TABLE [Announcement] (
    [announcement_id] INT            NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [title]           NVARCHAR(100)  NOT NULL,
    [content]         NVARCHAR(MAX)  NOT NULL,
    [category]        NVARCHAR(45)   DEFAULT 'General',
    [created_at]      DATETIME       DEFAULT GETDATE(),
    [Admin_id]        INT            NULL,
    [Lecturer_id]     INT            NULL,
    [Course_id]       INT            NULL,
    CONSTRAINT [fk_Rule_Admin]    FOREIGN KEY ([Admin_id])
        REFERENCES [Admin (HoP)] ([admin_id]),
    CONSTRAINT [fk_Rule_Lecturer] FOREIGN KEY ([Lecturer_id])
        REFERENCES [Lecturer] ([lecturer_id]),
    CONSTRAINT [fk_Rule_Course]   FOREIGN KEY ([Course_id])
        REFERENCES [Course] ([course_id])
);
GO

-- ============================================================
-- 12. Table: CourseGrade
-- ============================================================
CREATE TABLE [CourseGrade] (
    [cg_id]          INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [letter_grade]   NVARCHAR(5) NULL,
<<<<<<< HEAD
    [grade_point]    DECIMAL(3,2) NOT NULL,
=======
    [grade_point]    DECIMAL(3,2) NULL,
>>>>>>> b2b300e3b44176f94a8f1ceef0bdaae7ee425601
    [total_hours]    INT NOT NULL DEFAULT 0,
    [attended_hours] INT NOT NULL DEFAULT 0,
    [Enrollment_id]  INT NOT NULL,
    CONSTRAINT [fk_CG_Enrollment] FOREIGN KEY ([Enrollment_id]) REFERENCES [Enrollment]([enrollment_id])
);
GO


-- ============================================================
-- 13. Table: CourseModule 
-- ============================================================
CREATE TABLE [CourseModule] (
    [module_id]          INT IDENTITY(1,1) PRIMARY KEY,
    [course_id]          INT NOT NULL, 
    [module_name]        NVARCHAR(255) NOT NULL,
    [module_description] NVARCHAR(MAX) NULL, 
    [lock_until_date]    DATETIME NULL, 
    [created_at]         DATETIME DEFAULT GETDATE(),
    CONSTRAINT [fk_CourseModule_Course] FOREIGN KEY ([course_id]) REFERENCES [Course]([course_id])
);
GO

-- ============================================================
-- 14. Table: ModuleFile 
-- ============================================================
CREATE TABLE [ModuleFile] (
    [file_id]          INT IDENTITY(1,1) PRIMARY KEY,
    [module_id]        INT NOT NULL, 
    [file_title]       NVARCHAR(255) NOT NULL, 
    [file_description] NVARCHAR(MAX) NULL, 
    [file_name]        NVARCHAR(255) NOT NULL, 
    [file_path]        NVARCHAR(MAX) NOT NULL, 
    [upload_date]      DATETIME DEFAULT GETDATE(),
    CONSTRAINT [fk_ModuleFile_Module] FOREIGN KEY ([module_id]) REFERENCES [CourseModule]([module_id])
);
GO

-- ============================================================
-- 15. Table: CourseAssignment 
-- ============================================================
CREATE TABLE [CourseAssignment] (
    [assignment_id]   INT IDENTITY(1,1) PRIMARY KEY,
    [course_id]       INT NOT NULL,  
    [title]           NVARCHAR(255) NOT NULL,
    [description]     NVARCHAR(MAX) NULL,
    [assignment_type] NVARCHAR(50) NOT NULL, 
    [due_date]        DATETIME NOT NULL,
    [max_marks]       INT NOT NULL DEFAULT 100, 
    [attachment_path] NVARCHAR(MAX) NULL, 
    [created_at]      DATETIME DEFAULT GETDATE(),
    CONSTRAINT [fk_CourseAssignment_Course] FOREIGN KEY ([course_id]) REFERENCES [Course]([course_id])
);
GO

-- ============================================================
-- 16. Table: AssignmentSubmission
-- ============================================================
CREATE TABLE [AssignmentSubmission] (
    [submission_id]   INT IDENTITY(1,1) PRIMARY KEY,
    [assignment_id]   INT NOT NULL,
    [student_id]      INT NOT NULL,  
    
    -- === THE STUDENT'S HALF ===
    [submission_file] NVARCHAR(MAX) NULL,   -- The file the student uploaded
    [submitted_at]    DATETIME NULL,        -- To calculate On-Time vs. Late
    
    -- === THE LECTURER'S HALF ===
    [marks_awarded]   DECIMAL(5,2) NULL,        
    [is_published]    BIT NOT NULL DEFAULT 0,   
    [feedback]        NVARCHAR(MAX) NULL,       
    [graded_date]     DATETIME NULL,

    CONSTRAINT [fk_Sub_Assignment] FOREIGN KEY ([assignment_id]) REFERENCES [CourseAssignment]([assignment_id]),
    CONSTRAINT [fk_Sub_Student] FOREIGN KEY ([student_id]) REFERENCES [Student]([student_id])
);
GO

-- ============================================================
-- 17. Table: LecturerCourseFavourite
-- ============================================================
CREATE TABLE [LecturerCourseFavourite] (
    [fav_id]      INT      NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [lecturer_id] INT      NOT NULL,
    [course_id]   INT      NOT NULL,
    [created_at]  DATETIME DEFAULT GETDATE(),
    CONSTRAINT [UQ_LecFav]          UNIQUE      ([lecturer_id], [course_id]),
    CONSTRAINT [FK_LecFav_Lecturer] FOREIGN KEY ([lecturer_id])
        REFERENCES [Lecturer] ([lecturer_id]),
    CONSTRAINT [FK_LecFav_Course]   FOREIGN KEY ([course_id])
        REFERENCES [Course]   ([course_id])
);
GO

-- ===================================================================================
-- 18. Trigger: Auto Generate Payment (This must run seperately when creating table)
-- ===================================================================================
CREATE TRIGGER trg_GeneratePayment
ON [Enrollment]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM inserted WHERE status = 'Approved')
    BEGIN
        MERGE INTO [Payment] AS target
        USING (
            SELECT 
                e.student_id,
                SUM(CAST(c.course_fee AS DECIMAL(18,2))) AS TotalFee,
                DATEADD(day, 14, MIN(e.enrollment_date)) AS DueDate
            FROM [Enrollment] e
            INNER JOIN [Course] c ON e.course_id = c.course_id
            WHERE e.status = 'Approved'
              AND e.student_id IN (SELECT student_id FROM inserted WHERE status = 'Approved')
            GROUP BY e.student_id
        ) AS source
        ON target.student_id = source.student_id
        
        WHEN MATCHED THEN
            UPDATE SET payment_amount = source.TotalFee
            
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (student_id, payment_amount, payment_duedate)
            VALUES (source.student_id, source.TotalFee, source.DueDate);
    END
END
GO


-- ============
-- INSERT DATA
-- ============

-- ============================================================
-- Admin Account
-- ============================================================
INSERT INTO [Admin (HoP)] (admin_email, admin_name, admin_pw, admin_isactive, admin_bio)
VALUES ('admin@school.com', 'Justin Tan Hao Ren', 'admin123', 1, 'Senior Head of Program');

-- ============================================================
-- Lecturers
-- ============================================================
INSERT INTO [Lecturer]
    (lecturer_name, lecturer_pw, lecturer_email,
     lecturer_contact, lecturer_address, date_of_birth,
     lecturer_department, teacher_isactive, Admin_admin_id)
VALUES
('Alan Turing',    'lect123', 'alanturing0001@lect.com',    NULL, NULL, NULL, 'School of Computing', 'Active', 1),
('Ada Lovelace',   'lect123', 'adalovelace0002@lect.com',   NULL, NULL, NULL, 'School of Design', 'Active', 1),
('Warren Buffett', 'lect123', 'warrenbuffett0003@lect.com', NULL, NULL, NULL, 'School of Business',  'Active', 1);

UPDATE [Lecturer]
SET lecturer_code = 'L' + RIGHT('0000' + CAST(lecturer_id AS NVARCHAR(4)), 4);
GO

-- ============================================================
-- Programs
-- ============================================================
INSERT INTO [Program]
	(program_code, program_name, program_level, program_fee,
	 program_semester, program_credits, Lecturer_id, Admin_admin_id)
VALUES
('BSE', 'Software Engineering', 'Degree', 86000, 6, 120, 1, 1),
('BUS', 'Business Management','Degree', 85400, 6, 120, 3, 1),
('DCS', 'Computer Science','Diploma', 44000, 6, 90, 2, 1);
GO

-- ============================================================
-- Students
-- ============================================================
INSERT INTO [Student]
    (student_name, student_pw, student_email,
     student_contact, student_address, date_of_birth,
     student_sem, student_isactive, Admin_admin_id, Program_id)
VALUES
('Charlie Brown', 'stud123', 'charliebrown0001@stud.com', NULL, NULL, NULL, 3, 'Active', 1, 2),
('David Miller',  'stud123', 'davidmiller0002@stud.com',  NULL, NULL, NULL, 3, 'Active', 1, 2);

INSERT INTO [Student]
    (student_name, student_pw, student_email,
     student_contact, student_address, date_of_birth,
     student_sem, student_isactive, Admin_admin_id, Program_id)
VALUES
('Eve Adams', 'stud123', 'eveadams0003@stud.com', NULL, NULL, NULL, 1, 'Active', 1, 3);

UPDATE [Student]
SET student_code = 'S' + RIGHT('0000' + CAST(student_id AS NVARCHAR(4)), 4);
GO

-- ============================================================
-- Calendar
-- ============================================================
INSERT INTO [Calendar] (event_title, event_desc, start_date, end_date, event_type, Admin_id)
VALUES
-- Multiple Events on May 20th (Testing Sidebar & Badges)
('Java Workshop', 'Intro to Spring Boot', '2026-05-20', '2026-05-20', 'General', 1),
('Midterm Consultation', 'Room 302', '2026-05-20', '2026-05-20', 'Exam', 1),
('Club Recruitment', 'Main Hall', '2026-05-20', '2026-05-20', 'Enrollment', 1),
('Guest Lecturer Visit', 'Dr. Alan Turing', '2026-05-20', '2026-05-20', 'General', 1),
('Library Book Return', 'Final Deadline', '2026-05-20', '2026-05-20', 'Holiday', 1),

-- Additional Spread Out Events
('Database Lab Exam', 'Practical Assessment', '2026-05-28', '2026-05-28', 'Exam', 1),
('Sports Day', 'Stadium Complex', '2026-06-05', '2026-06-05', 'General', 1),
('Convocation Ceremony', 'Class of 2026', '2026-07-15', '2026-07-15', 'General', 1),

--Existing Events
('Final Exam Week', 'All levels', '2026-06-15', '2026-06-30', 'Exam', 1),
('Semester Break', 'Summer holiday', '2026-07-01', '2026-08-31', 'Holiday', 1),
('Course Registration', 'New Semester', '2026-08-20', '2026-08-25', 'Enrollment', 1),
('System Maintenance', 'Portal Offline', '2026-05-10', '2026-05-11', 'General', 1);

-- ============================================================
-- Courses 
-- ============================================================
INSERT INTO [Course] 
	(course_code, course_name, Lecturer_id, Calendar_id, credit_hours, course_fee, course_status, Program_id)
VALUES 
    ('CS101', 'C# Development', 1, 1, 3, '1500', 'Open', 3),
    ('DB202', 'Database Systems', 2, 1, 4, '1234', 'Ongoing', 1),
    ('BUS301', 'Business Ethics', 3, 1, 3, '4321', 'Open', 2),
    ('WEB105', 'Web Development', 1, 1, 3, '2341', 'Open', 1),
    ('DS204', 'Data Structures', 2, 1, 4, '2567', 'Ongoing', 3);
GO

-- ============================================================
-- Announcements 
-- ============================================================
INSERT INTO [Announcement] (title, content, category, Admin_id)
VALUES
('Welcome to the New System', 'The portal is now live.',                       'General',       1),
('Exam Venue Update',         'Check your portal for the new hall numbers.',  'Academic',      1),
('Library Closing Early',     'Closing at 6 PM this Friday for renovations.', 'General',       1),
('Scholarship Open',          'Apply now for the 2026 intake.',               'Finance',       1),
('Club Recruitment',          'Join the Robotics club today!',                'Co-curriculum', 1);
GO

-- ============================================================
-- Enrollment 
-- ============================================================
INSERT INTO [Enrollment] 
	(student_id, course_id, enrollment_date, [status])
VALUES 
	(1, 2, GETDATE(), 'Pending'),
	(2, 2, GETDATE(), 'Pending'), 
	(3, 4, GETDATE(), 'Pending'),
	(1, 4, GETDATE(), 'Pending'),
	(2, 1, GETDATE(), 'Pending'),
	(3, 1, GETDATE(), 'Pending'),
	(2, 5, GETDATE(), 'Pending'),
	(1, 5, GETDATE(), 'Pending');
    UPDATE Enrollment SET status = 'Approved' WHERE course_id = 2;
GO


-- ============================================================
-- CourseGrade 
-- ============================================================
INSERT INTO [CourseGrade] (letter_grade, grade_point, total_hours, attended_hours, Enrollment_id) VALUES
('A',  4.00, 42, 38, 1), 
('B+', 3.50, 48, 44, 2), 
('A-', 3.70, 36, 32, 3), 
('F',  0.00, 36, 5,  4), 
('C-', 1.70, 48, 20, 5); 
GO

<<<<<<< HEAD
=======
-- ============================================================
-- NEW DUMMY DATA FOR PROTOTYPING
-- ============================================================

-- Insert Dummy Module
INSERT INTO [CourseModule] (course_id, module_name, module_description)
VALUES (2, 'Week 1 - Introduction to Databases', 'This week we will cover the fundamentals of relational databases. Please ensure you have SQL Server installed.');
GO

-- Insert Dummy File
INSERT INTO [ModuleFile] (module_id, file_title, file_description, file_name, file_path)
VALUES (1, 'Chapter 1 Slides', 'Read pages 15-30 before our next lecture.', 'Chapter1.pdf', '~/Uploads/Modules/Chapter1.pdf');
GO

-- Insert Dummy Assignments
-- 1. Create ACTIVE Assignments (Due Dates in June/July 2026)
INSERT INTO [CourseAssignment] (course_id, title, description, assignment_type, due_date, max_marks, attachment_path)
VALUES 
(2, 'Database Design Project', 'Design an ERD for a library management system.', 'Coursework', '2026-06-15 23:59:00', 100, NULL),
(2, 'Midterm Examination', 'Covers chapters 1 to 5. Download the guidelines attached.', 'Midterm', '2026-07-01 10:00:00', 50, '~/Uploads/Assignments/Midterm_Instructions.pdf');

-- 2. Create a PAST Assignment (Due Date in May 2026)
INSERT INTO [CourseAssignment] (course_id, title, description, assignment_type, due_date, max_marks)
VALUES 
(2, 'Week 1 Quiz: Intro to DB', 'Initial assessment on SQL fundamentals.', 'Coursework', '2026-05-10 12:00:00', 20);

-- Grab the ID of the Past Assignment we just created
DECLARE @PastAssignId INT = SCOPE_IDENTITY();

-- 3. Inject Past Submissions for Charlie and David (using .docx directly)
INSERT INTO [AssignmentSubmission] (assignment_id, student_id, submission_file, submitted_at, marks_awarded, is_published)
VALUES 
(@PastAssignId, 1, '~/Uploads/Submissions/Charlie_Quiz1.docx', '2026-05-09 15:00:00', 18, 1),
(@PastAssignId, 2, '~/Uploads/Submissions/David_Quiz1.docx', '2026-05-10 11:30:00', 15, 1);
GO

>>>>>>> b2b300e3b44176f94a8f1ceef0bdaae7ee425601

-- ============================================================
-- VERIFICATION SELECTS
-- ============================================================
SELECT * FROM Course;
SELECT * FROM Enrollment;
SELECT * FROM Lecturer;
SELECT * FROM CourseGrade;
<<<<<<< HEAD
SELECT * FROM Announcement;
=======
SELECT * FROM CourseModule;
SELECT * FROM ModuleFile;
SELECT * FROM CourseAssignment;
SELECT * FROM AssignmentSubmission;

>>>>>>> b2b300e3b44176f94a8f1ceef0bdaae7ee425601
