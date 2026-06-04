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
IF OBJECT_ID('sp_ProcessGraduations', 'P') IS NOT NULL DROP PROCEDURE sp_ProcessGraduations;
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
IF OBJECT_ID('LecturerCalendar', 'U') IS NOT NULL DROP TABLE LecturerCalendar;
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
-- 5. Table: Grades (UPDATED)
-- ============================================================
CREATE TABLE [Grades] (
    [grades_id]   INT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [semester]    INT          NOT NULL DEFAULT 1,
    [gpa]         DECIMAL(3,2) NULL,
    [cgpa]        DECIMAL(3,2) NULL,
    [Student_id]  INT          NOT NULL,
    CONSTRAINT [fk_Grades_Student] FOREIGN KEY ([Student_id])
        REFERENCES [Student] ([student_id]),
    CONSTRAINT [UQ_Student_Semester] UNIQUE ([Student_id], [semester])
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
    visibility    NVARCHAR(50)  NOT NULL DEFAULT 'Private',
    lecturer_id   INT           NOT NULL,
    created_at    DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_LecCalendar_Lecturer FOREIGN KEY (lecturer_id) REFERENCES Lecturer(lecturer_id) ON DELETE CASCADE
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
-- 9. Table: Enrollment (UPDATED WITH SEMESTER)
-- ============================================================
CREATE TABLE [Enrollment] (
    [enrollment_id] INT IDENTITY(1,1) PRIMARY KEY,
    [student_id] INT NOT NULL,
    [course_id] INT NOT NULL,
    [enrolled_semester] INT NOT NULL,
    [enrollment_date] DATETIME DEFAULT GETDATE(),
    [status] VARCHAR(20) DEFAULT 'Pending',
    CONSTRAINT [FK_Enrollment_Student] FOREIGN KEY ([student_id]) REFERENCES [Student]([student_id]),
    CONSTRAINT [FK_Enrollment_Course] FOREIGN KEY ([course_id]) REFERENCES [Course]([course_id])
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
    CONSTRAINT [fk_Payment_Student] FOREIGN KEY ([Student_id]) REFERENCES [Student] ([student_id])
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
    CONSTRAINT [fk_Rule_Admin]    FOREIGN KEY ([Admin_id]) REFERENCES [Admin (HoP)] ([admin_id]),
    CONSTRAINT [fk_Rule_Lecturer] FOREIGN KEY ([Lecturer_id]) REFERENCES [Lecturer] ([lecturer_id]),
    CONSTRAINT [fk_Rule_Course]   FOREIGN KEY ([Course_id]) REFERENCES [Course] ([course_id])
);
GO

-- ============================================================
-- 12. Table: CourseGrade
-- ============================================================
CREATE TABLE [CourseGrade] (
    [cg_id]          INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [letter_grade]   NVARCHAR(5) NULL,
    [grade_point]    DECIMAL(3,2) NULL,
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
    [submission_file] NVARCHAR(MAX) NULL,   
    [submitted_at]    DATETIME NULL,        
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
    CONSTRAINT [FK_LecFav_Lecturer] FOREIGN KEY ([lecturer_id]) REFERENCES [Lecturer] ([lecturer_id]),
    CONSTRAINT [FK_LecFav_Course]   FOREIGN KEY ([course_id]) REFERENCES [Course]   ([course_id])
);
GO

-- ===================================================================================
-- 18. STORED PROCEDURE: Process Graduations Only (Controlled from C#)
-- ===================================================================================
CREATE PROCEDURE sp_ProcessGraduations
AS
BEGIN
    SET NOCOUNT ON;

    -- Graduate students who have reached or exceeded their program's max semester
    UPDATE s
    SET s.student_isactive = 'Graduated'
    FROM Student s
    INNER JOIN Program p ON s.Program_id = p.program_id
    WHERE s.student_isactive = 'Active' 
      AND s.student_sem >= p.program_semester;
END
GO

-- ===================================================================================
-- 19. Trigger: Auto Generate Payment
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

-- ===================================================================================
-- 20. Trigger: Auto Calculate GPA & CGPA 
-- ===================================================================================
IF OBJECT_ID('trg_CalculateGradesAndGPA', 'TR') IS NOT NULL DROP TRIGGER trg_CalculateGradesAndGPA;
GO

CREATE TRIGGER trg_CalculateGradesAndGPA
ON [AssignmentSubmission]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(marks_awarded)
    BEGIN
        -- Phase 1: Find Affected Enrollments
        SELECT DISTINCT 
            i.student_id, 
            ca.course_id,
            e.enrollment_id
        INTO #AffectedEnrollments
        FROM inserted i
        INNER JOIN CourseAssignment ca ON i.assignment_id = ca.assignment_id
        INNER JOIN Enrollment e ON i.student_id = e.student_id AND ca.course_id = e.course_id;

        -- Phase 2: Calculate Course Grade Points (ONLY counting graded submissions)
        MERGE INTO CourseGrade AS target
        USING (
            SELECT 
                enrollment_id,
                CASE 
                    WHEN Pct >= 80 THEN 'A'
                    WHEN Pct >= 75 THEN 'A-'
                    WHEN Pct >= 70 THEN 'B+'
                    WHEN Pct >= 65 THEN 'B'
                    WHEN Pct >= 60 THEN 'B-'
                    WHEN Pct >= 55 THEN 'C+'
                    WHEN Pct >= 50 THEN 'C'
                    ELSE 'F'
                END AS LetterGrade,
                CASE 
                    WHEN Pct >= 80 THEN 4.00
                    WHEN Pct >= 75 THEN 3.70
                    WHEN Pct >= 70 THEN 3.30
                    WHEN Pct >= 65 THEN 3.00
                    WHEN Pct >= 60 THEN 2.70
                    WHEN Pct >= 55 THEN 2.30
                    WHEN Pct >= 50 THEN 2.00
                    ELSE 0.00
                END AS GradePoint
            FROM (
                SELECT 
                    ae.enrollment_id,
                    -- Only sum max_marks if marks_awarded is NOT NULL
                    (SUM(sub.marks_awarded) / NULLIF(SUM(CASE WHEN sub.marks_awarded IS NOT NULL THEN ca.max_marks ELSE 0 END), 0)) * 100 AS Pct
                FROM #AffectedEnrollments ae
                INNER JOIN CourseAssignment ca ON ae.course_id = ca.course_id
                LEFT JOIN AssignmentSubmission sub ON ca.assignment_id = sub.assignment_id AND sub.student_id = ae.student_id
                GROUP BY ae.enrollment_id
            ) AS Calc
        ) AS source
        ON target.Enrollment_id = source.enrollment_id
        
        WHEN MATCHED THEN
            UPDATE SET letter_grade = source.LetterGrade, grade_point = source.GradePoint
            
        WHEN NOT MATCHED THEN
            INSERT (Enrollment_id, letter_grade, grade_point, total_hours, attended_hours)
            VALUES (source.enrollment_id, source.LetterGrade, source.GradePoint, 0, 0);

        -- Phase 3A: Calculate the GPA based on the Enrolled Semester
        MERGE INTO Grades AS target
        USING (
            SELECT 
                s.student_id,
                e.enrolled_semester AS semester,
                SUM(cg.grade_point * c.credit_hours) / NULLIF(SUM(c.credit_hours), 0) AS CalculatedGPA
            FROM (SELECT DISTINCT student_id FROM #AffectedEnrollments) af
            INNER JOIN Student s ON af.student_id = s.student_id
            INNER JOIN Enrollment e ON s.student_id = e.student_id
            INNER JOIN Course c ON e.course_id = c.course_id
            INNER JOIN CourseGrade cg ON e.enrollment_id = cg.Enrollment_id
            GROUP BY s.student_id, e.enrolled_semester
        ) AS source
        ON target.Student_id = source.student_id AND target.semester = source.semester
        
        WHEN MATCHED THEN
            UPDATE SET gpa = source.CalculatedGPA
            
        WHEN NOT MATCHED THEN
            INSERT (Student_id, semester, gpa)
            VALUES (source.student_id, source.semester, source.CalculatedGPA);

        -- Phase 3B: Calculate the Cumulative GPA (CGPA)
        UPDATE g
        SET cgpa = cgpaCalc.CumulativeGPA
        FROM Grades g
        INNER JOIN (
            SELECT Student_id, AVG(gpa) as CumulativeGPA
            FROM Grades
            GROUP BY Student_id
        ) cgpaCalc ON g.Student_id = cgpaCalc.Student_id
        WHERE g.Student_id IN (SELECT DISTINCT student_id FROM #AffectedEnrollments);
        
        DROP TABLE #AffectedEnrollments;
    END
END
GO

-- ============================================================
-- ALIGNED INSERT DATA
-- ============================================================

-- 1. ADMIN
INSERT INTO [Admin (HoP)] (admin_email, admin_name, admin_pw, admin_isactive, admin_bio)
VALUES ('admin@school.com', 'Justin Tan Hao Ren', 'admin123', 1, 'Senior Head of Program');

-- 2. LECTURERS
INSERT INTO [Lecturer]
    (lecturer_name, lecturer_pw, lecturer_email, lecturer_department, teacher_isactive, Admin_admin_id)
VALUES
('Alan Turing',    'lect123', 'alanturing0001@lect.com',  'School of Computing', 'Active', 1),
('Ada Lovelace',   'lect123', 'adalovelace0002@lect.com', 'School of Computing', 'Active', 1),
('Warren Buffett', 'lect123', 'warrenbuffett0003@lect.com', 'School of Business',  'Active', 1);

UPDATE [Lecturer] SET lecturer_code = 'L' + RIGHT('0000' + CAST(lecturer_id AS NVARCHAR(4)), 4);
GO

-- 3. PROGRAMS (ID 1: Software Eng, ID 2: Business, ID 3: CompSci)
INSERT INTO [Program]
	(program_code, program_name, program_level, program_fee, program_semester, program_credits, Lecturer_id, Admin_admin_id)
VALUES
('BSE', 'Software Engineering', 'Degree', 86000, 6, 120, 1, 1),
('BUS', 'Business Management','Degree', 85400, 6, 120, 3, 1),
('DCS', 'Computer Science','Diploma', 44000, 6, 90, 2, 1);
GO

-- 4. STUDENTS 
-- Charlie (ID 1) & David (ID 2) -> Program 1 (BSE), Semester 3
-- Eve (ID 3) -> Program 2 (BUS), Semester 1
INSERT INTO [Student]
    (student_name, student_pw, student_email, student_sem, student_isactive, Admin_admin_id, Program_id)
VALUES
('Charlie Brown', 'stud123', 'charliebrown0001@stud.com', 3, 'Active', 1, 1),
('David Miller',  'stud123', 'davidmiller0002@stud.com',   3, 'Active', 1, 1),
('Eve Adams',     'stud123', 'eveadams0003@stud.com',     1, 'Active', 1, 2);

UPDATE [Student] SET student_code = 'S' + RIGHT('0000' + CAST(student_id AS NVARCHAR(4)), 4);
GO

-- 5. CALENDAR (Base events needed for Course creation)
INSERT INTO [Calendar] (event_title, event_desc, start_date, end_date, event_type, Admin_id)
VALUES
('Spring Semester 2026', 'Main Academic Calendar', '2026-01-10', '2026-06-15', 'General', 1);

-- 6. COURSES (Aligned to Programs)
-- IDs 1, 2, 3, 4 belong to Program 1 (BSE). ID 5 belongs to Program 2 (BUS)
INSERT INTO [Course] 
	(course_code, course_name, Lecturer_id, Calendar_id, credit_hours, course_fee, Program_id)
VALUES 
    ('CS101',  'C# Development',    1, 1, 3, '1500', 1),
    ('DB202',  'Database Systems',  2, 1, 4, '1200', 1),
    ('WEB105', 'Web Development',   1, 1, 3, '2300', 1),
    ('DS204',  'Data Structures',   2, 1, 4, '2500', 1),
    ('BUS301', 'Business Ethics',   3, 1, 3, '4300', 2);
GO

-- 7. ENROLLMENTS (Students take courses strictly in their Sem & Program)
-- Charlie (ID 1) & David (ID 2) taking Sem 3 courses
INSERT INTO [Enrollment] (student_id, course_id, enrolled_semester, enrollment_date, [status])
VALUES 
	(1, 2, 3, GETDATE(), 'Approved'), -- Charlie in DB202
	(1, 3, 3, GETDATE(), 'Approved'), -- Charlie in WEB105
	(1, 4, 3, GETDATE(), 'Approved'), -- Charlie in DS204
	(2, 2, 3, GETDATE(), 'Approved'), -- David in DB202
	(2, 4, 3, GETDATE(), 'Approved'), -- David in DS204
	(3, 5, 1, GETDATE(), 'Approved'); -- Eve in BUS301 (Sem 1)
GO

-- 8. ANNOUNCEMENTS
INSERT INTO [Announcement] (title, content, category, Admin_id)
VALUES ('Welcome to the New System', 'The portal is now live.', 'General', 1);
GO

-- 9. COURSE MODULES & FILES
INSERT INTO [CourseModule] (course_id, module_name, module_description)
VALUES (2, 'Week 1 - Intro to Databases', 'Fundamentals of relational databases.');

INSERT INTO [ModuleFile] (module_id, file_title, file_description, file_name, file_path)
VALUES (1, 'Chapter 1 Slides', 'Read pages 15-30.', 'Chapter1.pdf', '~/Uploads/Chapter1.pdf');
GO

-- 10. ASSIGNMENTS 
-- ID 1 & 2 for DB202, ID 3 for WEB105, ID 4 for BUS301
INSERT INTO [CourseAssignment] (course_id, title, description, assignment_type, due_date, max_marks)
VALUES 
(2, 'Week 1 Quiz: Intro to DB', 'SQL fundamentals.', 'Quiz', '2026-05-10 12:00:00', 20),
(2, 'Midterm Examination', 'Covers chapters 1 to 5.', 'Exam', '2026-07-01 10:00:00', 50),
(3, 'Frontend Web Project', 'Design a responsive site.', 'Project', '2026-06-15 10:00:00', 100),
(5, 'Corporate Ethics Essay', '1000 word essay.', 'Essay', '2026-06-20 10:00:00', 100);
GO

-- 11. SUBMISSIONS (This will automatically fire your Trigger to calculate Grades & CGPA)
-- Note: DS204 is left with NO submissions, so it will show up on the dashboard but not affect the GPA.
INSERT INTO [AssignmentSubmission] (assignment_id, student_id, submission_file, submitted_at, marks_awarded, is_published)
VALUES 
(1, 1, '~/Uploads/Charlie_Quiz1.docx', GETDATE(), 18, 1), -- Charlie gets 18/20 in DB202 (A)
(3, 1, '~/Uploads/Charlie_Web.zip', GETDATE(), 72, 1),    -- Charlie gets 72/100 in WEB105 (B+)
(1, 2, '~/Uploads/David_Quiz1.docx', GETDATE(), 15, 1),   -- David gets 15/20 in DB202 (A-)
(4, 3, '~/Uploads/Eve_Essay.docx', GETDATE(), 90, 1);     -- Eve gets 90/100 in BUS301 (A)
GO
 
-- ============================================================
-- VERIFICATION SELECTS
-- ============================================================
SELECT * FROM Course;
SELECT * FROM Enrollment;
SELECT * FROM Lecturer;
SELECT * FROM Student;
SELECT * FROM CourseGrade;
SELECT * FROM Announcement;
SELECT * FROM CourseModule;
SELECT * FROM ModuleFile;
SELECT * FROM CourseAssignment;
SELECT * FROM AssignmentSubmission;