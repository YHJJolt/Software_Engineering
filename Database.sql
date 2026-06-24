-- ===================================================================================
-- SIMS CENTRAL DATABASE SYSTEM
-- Consolidated Clean Architecture Initialization
-- ===================================================================================
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

-- ============================================================
-- CLEANUP SCRIPT: Drop Constraints, Triggers, and Tables Safely
-- ============================================================

-- 1. Drop Stored Procedures & Triggers
IF OBJECT_ID('sp_ProcessGraduations', 'P') IS NOT NULL DROP PROCEDURE sp_ProcessGraduations;
IF OBJECT_ID('sp_AdvanceToNewSession', 'P') IS NOT NULL DROP PROCEDURE sp_AdvanceToNewSession;
IF OBJECT_ID('trg_GeneratePayment', 'TR') IS NOT NULL DROP TRIGGER trg_GeneratePayment;
IF OBJECT_ID('trg_Payment_SetInactive', 'TR') IS NOT NULL DROP TRIGGER trg_Payment_SetInactive;
IF OBJECT_ID('trg_Payment_SetActive', 'TR') IS NOT NULL DROP TRIGGER trg_Payment_SetActive;
IF OBJECT_ID('trg_Payment_DeleteReactivate', 'TR') IS NOT NULL DROP TRIGGER trg_Payment_DeleteReactivate;
IF OBJECT_ID('trg_CalculateGradesAndGPA', 'TR') IS NOT NULL DROP TRIGGER trg_CalculateGradesAndGPA;
GO

-- 2. BREAK FOREIGN KEY CONSTRAINTS 
-- (Only dropping the one that might cause circular student/program locks, others are handled by drop order)
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fk_Student_Program' AND parent_object_id = OBJECT_ID('Student'))
    ALTER TABLE [Student] DROP CONSTRAINT [fk_Student_Program];
GO

-- 3. Drop Deepest Child Tables & Junctions
IF OBJECT_ID('dbo.AssignmentSubmission', 'U') IS NOT NULL DROP TABLE [AssignmentSubmission];
IF OBJECT_ID('dbo.CourseGrade', 'U') IS NOT NULL DROP TABLE [CourseGrade];
IF OBJECT_ID('dbo.AttendanceRecord', 'U') IS NOT NULL DROP TABLE [AttendanceRecord];
IF OBJECT_ID('dbo.PaymentDetail', 'U') IS NOT NULL DROP TABLE [PaymentDetail];
IF OBJECT_ID('dbo.ModuleFile', 'U') IS NOT NULL DROP TABLE [ModuleFile];
IF OBJECT_ID('dbo.CourseAssignment', 'U') IS NOT NULL DROP TABLE [CourseAssignment];
IF OBJECT_ID('dbo.LecturerCourseFavourite', 'U') IS NOT NULL DROP TABLE [LecturerCourseFavourite];
IF OBJECT_ID('dbo.StudentCourseFavourite', 'U') IS NOT NULL DROP TABLE [StudentCourseFavourite];
IF OBJECT_ID('dbo.CourseAssignment_Session', 'U') IS NOT NULL DROP TABLE [CourseAssignment_Session];
IF OBJECT_ID('dbo.CourseProgram', 'U') IS NOT NULL DROP TABLE [CourseProgram];
GO

-- 4. Drop Mid-Level Dynamic Tables
IF OBJECT_ID('dbo.Enrollment', 'U') IS NOT NULL DROP TABLE [Enrollment];
IF OBJECT_ID('dbo.Payment', 'U') IS NOT NULL DROP TABLE [Payment];
IF OBJECT_ID('dbo.Grades', 'U') IS NOT NULL DROP TABLE [Grades];
IF OBJECT_ID('dbo.CourseModule', 'U') IS NOT NULL DROP TABLE [CourseModule];
IF OBJECT_ID('dbo.LecturerCalendar', 'U') IS NOT NULL DROP TABLE [LecturerCalendar];
IF OBJECT_ID('dbo.StudentCalendar', 'U') IS NOT NULL DROP TABLE [StudentCalendar];
IF OBJECT_ID('dbo.StudentNotifRead', 'U') IS NOT NULL DROP TABLE [StudentNotifRead];
GO

-- 5. Drop Major Entities
IF OBJECT_ID('dbo.Course', 'U') IS NOT NULL DROP TABLE [Course];
IF OBJECT_ID('dbo.Announcement', 'U') IS NOT NULL DROP TABLE [Announcement];
IF OBJECT_ID('dbo.Student', 'U') IS NOT NULL DROP TABLE [Student];
IF OBJECT_ID('dbo.Program', 'U') IS NOT NULL DROP TABLE [Program];
GO

-- 6. Drop Core Base Tables & Calendars
IF OBJECT_ID('dbo.Calendar', 'U') IS NOT NULL DROP TABLE [Calendar];
IF OBJECT_ID('dbo.LecturerNotifRead', 'U') IS NOT NULL DROP TABLE [LecturerNotifRead];
IF OBJECT_ID('dbo.AdminNotifRead', 'U') IS NOT NULL DROP TABLE [AdminNotifRead];
IF OBJECT_ID('dbo.SystemSettings', 'U') IS NOT NULL DROP TABLE [SystemSettings];
IF OBJECT_ID('dbo.Lecturer', 'U') IS NOT NULL DROP TABLE [Lecturer];
IF OBJECT_ID('dbo.Admin (HoP)', 'U') IS NOT NULL DROP TABLE [Admin (HoP)];
GO

-- ===================================================================================
-- 1. Table: Admin (HoP)
-- ===================================================================================
CREATE TABLE [Admin (HoP)] (
  [admin_id] INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
  [admin_name] NVARCHAR(45) NOT NULL,
  [admin_email] NVARCHAR(45) NOT NULL,
  [admin_pw] NVARCHAR(64) NOT NULL,
  [admin_contact] NVARCHAR(45) NULL,
  [admin_isactive] BIT NULL,
  [admin_bio] NVARCHAR(MAX) NULL,     
  [admin_img] VARBINARY(MAX) NULL    
);

-- ===================================================================================
-- 2. Table: Lecturer
-- ===================================================================================
CREATE TABLE [Lecturer] (
    [lecturer_id]        INT            NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [lecturer_code]      NVARCHAR(10)   NULL,                       
    [lecturer_name]      NVARCHAR(45)   NOT NULL,
    [lecturer_pw]        NVARCHAR(64)   NOT NULL DEFAULT 'lec123',  
    [lecturer_email]     NVARCHAR(45)   NOT NULL,                   
    [lecturer_contact]   NVARCHAR(45)   NULL,                       
    [lecturer_address]   NVARCHAR(45)   NULL,                       
    [date_of_birth]      NVARCHAR(100)  NULL,                       
    [lecturer_department] NVARCHAR(100) NOT NULL,                   
    [teacher_isactive]   NVARCHAR(45)   NOT NULL,
    [lecturer_bio]       NVARCHAR(MAX)  NULL,
    [lecturer_img]       VARBINARY(MAX) NULL,
    [Admin_admin_id]     INT            NOT NULL,
    CONSTRAINT [fk_Lecturer_Admin] FOREIGN KEY ([Admin_admin_id]) REFERENCES [Admin (HoP)] ([admin_id])
);

-- ===================================================================================
-- 3. Table: Program
-- ===================================================================================
CREATE TABLE [Program] (
    [program_id]       INT            NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [program_code]     NVARCHAR(20)   NOT NULL,
    [program_name]     NVARCHAR(100)  NOT NULL,
    [program_level]    NVARCHAR(50)   NOT NULL,
    [program_fee]      DECIMAL(10,2)  NOT NULL,
    [program_semester] INT            NULL,
    [program_credits]  INT            NULL,
    [program_isactive] BIT            NOT NULL DEFAULT 1,
    [Lecturer_id]      INT            NOT NULL,
    [Admin_admin_id]   INT            NOT NULL,
    CONSTRAINT [fk_Program_Admin]    FOREIGN KEY ([Admin_admin_id]) REFERENCES [Admin (HoP)] ([admin_id]),
    CONSTRAINT [fk_Program_Lecturer] FOREIGN KEY ([Lecturer_id]) REFERENCES [Lecturer] ([lecturer_id])
);

-- ===================================================================================
-- 4. Table: Student
-- ===================================================================================
CREATE TABLE [Student] (
    [student_id]       INT            NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [student_code]     NVARCHAR(10)   NULL,                         
    [student_name]     NVARCHAR(45)   NOT NULL,
    [student_pw]       NVARCHAR(64)   NOT NULL DEFAULT 'stud123',
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
    CONSTRAINT [fk_Student_Admin]   FOREIGN KEY ([Admin_admin_id]) REFERENCES [Admin (HoP)] ([admin_id]),
    CONSTRAINT [fk_Student_Program] FOREIGN KEY ([Program_id]) REFERENCES [Program] ([program_id])
);

-- ===================================================================================
-- 5. Table: Grades
-- ===================================================================================
CREATE TABLE [Grades] (
    [grades_id]   INT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [semester]    INT          NOT NULL DEFAULT 1,
    [gpa]         DECIMAL(3,2) NULL,
    [cgpa]        DECIMAL(3,2) NULL,
    [Student_id]  INT          NOT NULL,
    CONSTRAINT [fk_Grades_Student] FOREIGN KEY ([Student_id]) REFERENCES [Student] ([student_id]),
    CONSTRAINT [UQ_Student_Semester] UNIQUE ([Student_id], [semester])
);

-- ===================================================================================
-- 6. Table: Admin Calendar
-- ===================================================================================
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

-- ===================================================================================
-- 7. Table: Lecturer Calendar
-- ===================================================================================
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

-- ===================================================================================
-- 7B. Table: StudentCalendar
-- ===================================================================================
CREATE TABLE StudentCalendar (
    calendar_id   INT           IDENTITY(1,1) PRIMARY KEY,
    event_title   NVARCHAR(200) NOT NULL,
    event_desc    NVARCHAR(MAX) NULL,
    start_date    DATE          NOT NULL,
    end_date      DATE          NULL,
    event_type    NVARCHAR(50)  NOT NULL DEFAULT 'Personal',
    visibility    NVARCHAR(50)  NOT NULL DEFAULT 'Private',
    student_id    INT           NOT NULL,
    created_at    DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_StudCalendar_Student FOREIGN KEY (student_id) REFERENCES Student(student_id) ON DELETE CASCADE
);

-- ===================================================================================
-- 8. Table: Course (Clean Model: Program_id and Lecturer_id completely dropped)
-- ===================================================================================
CREATE TABLE [Course] (
  [course_id] INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
  [course_code] NVARCHAR(20) NULL, 
  [course_name] NVARCHAR(100) NULL,
  [credit_hours] INT NULL,
  [course_fee] NVARCHAR(45) NOT NULL, 
  [course_img] VARBINARY(MAX) NULL,
  [Calendar_id] INT NOT NULL,
  CONSTRAINT [fk_Course_Calendar] FOREIGN KEY ([Calendar_id]) REFERENCES [Calendar] ([calendar_id])
);
GO

-- ===================================================================================
-- 8B. Table: CourseProgram (Junction Table for Multi-Program Capability) [cite: 15]
-- ===================================================================================
CREATE TABLE [CourseProgram] (
    [course_program_id] INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [course_id]  INT NOT NULL,
    [program_id] INT NOT NULL,
    CONSTRAINT [UQ_CourseProgram] UNIQUE ([course_id], [program_id]),
    CONSTRAINT [fk_CourseProgram_Course]  FOREIGN KEY ([course_id])  REFERENCES [Course]  ([course_id])  ON DELETE CASCADE,
    CONSTRAINT [fk_CourseProgram_Program] FOREIGN KEY ([program_id]) REFERENCES [Program] ([program_id]) ON DELETE CASCADE
);
GO

-- ===================================================================================
-- 9. Table: Enrollment (Isolated via session key tracking) [cite: 1, 3]
-- ===================================================================================
CREATE TABLE [Enrollment] (
    [enrollment_id] INT IDENTITY(1,1) PRIMARY KEY,
    [student_id] INT NOT NULL,
    [course_id] INT NOT NULL,
    [enrolled_semester] INT NOT NULL,
    [academic_session] NVARCHAR(20) NOT NULL, -- Fully built-in [cite: 5]
    [enrollment_date] DATETIME DEFAULT GETDATE(),
    [status] VARCHAR(20) DEFAULT 'Pending',
    [status_updated_at] DATETIME NULL,
    CONSTRAINT [FK_Enrollment_Student] FOREIGN KEY ([student_id]) REFERENCES [Student]([student_id]),
    CONSTRAINT [FK_Enrollment_Course] FOREIGN KEY ([course_id]) REFERENCES [Course]([course_id])
);

-- ===================================================================================
-- 10. Table: Payment
-- ===================================================================================
CREATE TABLE [Payment] (
    [payment_id]      INT            NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [payment_amount]  DECIMAL(10,2)  NULL,
    [payment_duedate] DATETIME       NULL,
    [payment_paydate] DATETIME       NULL,
    [payment_method]  NVARCHAR(45)   NULL,
    [Student_id]      INT            NOT NULL,
    CONSTRAINT [fk_Payment_Student] FOREIGN KEY ([Student_id]) REFERENCES [Student] ([student_id])
);

-- ===================================================================================
-- 10B. Table: PaymentDetail
-- ===================================================================================
CREATE TABLE [PaymentDetail] (
    [detail_id] INT IDENTITY(1,1) PRIMARY KEY,
    [payment_id] INT NOT NULL,
    [enrollment_id] INT NOT NULL,
    [course_fee] DECIMAL(10,2) NOT NULL,
    CONSTRAINT [fk_PD_Payment] FOREIGN KEY ([payment_id]) REFERENCES [Payment]([payment_id]),
    CONSTRAINT [fk_PD_Enrollment] FOREIGN KEY ([enrollment_id]) REFERENCES [Enrollment]([enrollment_id])
);
GO

-- ===================================================================================
-- 11. Table: Announcement (Isolated via session tracking rules) [cite: 1, 6]
-- ===================================================================================
CREATE TABLE [Announcement] (
    [announcement_id] INT            NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [title]           NVARCHAR(100)  NOT NULL,
    [content]         NVARCHAR(MAX)  NOT NULL,
    [category]        NVARCHAR(45)   DEFAULT 'General',
    [academic_session] NVARCHAR(20)  NULL, -- Embedded matching standard [cite: 6]
    [created_at]      DATETIME       DEFAULT GETDATE(),
    [Admin_id]        INT            NULL,
    [Lecturer_id]     INT            NULL,
    [Course_id]       INT            NULL,
    CONSTRAINT [fk_Rule_Admin]    FOREIGN KEY ([Admin_id]) REFERENCES [Admin (HoP)] ([admin_id]),
    CONSTRAINT [fk_Rule_Lecturer] FOREIGN KEY ([Lecturer_id]) REFERENCES [Lecturer] ([lecturer_id]),
    CONSTRAINT [fk_Rule_Course]   FOREIGN KEY ([Course_id]) REFERENCES [Course] ([course_id])
);
GO

-- ===================================================================================
-- 12. Table: CourseGrade
-- ===================================================================================
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

-- ===================================================================================
-- 12B. Table: AttendanceRecord
-- ===================================================================================
CREATE TABLE [AttendanceRecord] (
    [attendance_id]   INT IDENTITY(1,1) PRIMARY KEY,
    [enrollment_id]   INT NOT NULL,
    [attendance_date] DATE NOT NULL,
    [status]          NVARCHAR(10) NOT NULL,
    CONSTRAINT [fk_AR_Enrollment] FOREIGN KEY ([enrollment_id]) REFERENCES [Enrollment]([enrollment_id]),
    CONSTRAINT [uq_AR_EnrollDate] UNIQUE ([enrollment_id], [attendance_date])
);
GO

-- ===================================================================================
-- 13. Table: CourseModule (Isolated via integrated session constraint tracking) [cite: 1, 8]
-- ===================================================================================
CREATE TABLE [CourseModule] (
    [module_id]          INT IDENTITY(1,1) PRIMARY KEY,
    [course_id]          INT NOT NULL, 
    [module_name]        NVARCHAR(255) NOT NULL,
    [module_description] NVARCHAR(MAX) NULL, 
    [academic_session]   NVARCHAR(20) NOT NULL, -- Integrated built-in key tracking [cite: 8]
    [lock_until_date]    DATETIME NULL, 
    [created_at]         DATETIME DEFAULT GETDATE(),
    CONSTRAINT [fk_CourseModule_Course] FOREIGN KEY ([course_id]) REFERENCES [Course]([course_id])
);
GO

-- ===================================================================================
-- 14. Table: ModuleFile
-- ===================================================================================
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

-- ===================================================================================
-- 15. Table: CourseAssignment (Isolated via internal session identity parsing) [cite: 1, 10]
-- ===================================================================================
CREATE TABLE [CourseAssignment] (
    [assignment_id]   INT IDENTITY(1,1) PRIMARY KEY,
    [course_id]       INT NOT NULL,  
    [title]           NVARCHAR(255) NOT NULL,
    [description]     NVARCHAR(MAX) NULL,
    [assignment_type] NVARCHAR(50) NOT NULL, 
    [academic_session] NVARCHAR(20) NOT NULL, -- Configured matching structural design [cite: 10]
    [due_date]        DATETIME NOT NULL,
    [max_marks]       INT NOT NULL DEFAULT 100, 
    [attachment_path] NVARCHAR(MAX) NULL, 
    [created_at]      DATETIME DEFAULT GETDATE(),
    CONSTRAINT [fk_CourseAssignment_Course] FOREIGN KEY ([course_id]) REFERENCES [Course]([course_id])
);
GO

-- ===================================================================================
-- 16. Table: AssignmentSubmission
-- ===================================================================================
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

-- ===================================================================================
-- 17. Table: LecturerCourseFavourite
-- ===================================================================================
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
-- 18. Table: StudentCourseFavourite Table
-- ===================================================================================
CREATE TABLE [StudentCourseFavourite] (
    [fav_id]      INT      NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [student_id]  INT      NOT NULL,
    [course_id]   INT      NOT NULL,
    [created_at]  DATETIME DEFAULT GETDATE(),
    CONSTRAINT [UQ_StudFav]          UNIQUE      ([student_id], [course_id]),
    CONSTRAINT [FK_StudFav_Student]  FOREIGN KEY ([student_id]) REFERENCES [Student]  ([student_id]),
    CONSTRAINT [FK_StudFav_Course]   FOREIGN KEY ([course_id])  REFERENCES [Course]   ([course_id])
);
GO

-- ===================================================================================
-- 19. Table: CourseAssignment_Session (Term Scheduling Control Workspace)
-- ===================================================================================
CREATE TABLE [CourseAssignment_Session] (
    [assign_id]        INT            NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [course_id]        INT            NOT NULL,
    [lecturer_id]      INT            NOT NULL,
    [academic_session] NVARCHAR(20)   NOT NULL,   
    [assign_status]    NVARCHAR(20)   NOT NULL DEFAULT 'Active', -- Standard dynamic parameter value
    [created_at]       DATETIME       NOT NULL DEFAULT GETDATE(),
    CONSTRAINT [uq_Course_Session] UNIQUE ([course_id], [academic_session]),
    CONSTRAINT [fk_CAS_Course]    FOREIGN KEY ([course_id])   REFERENCES [Course]   ([course_id]) ON DELETE CASCADE,
    CONSTRAINT [fk_CAS_Lecturer]  FOREIGN KEY ([lecturer_id]) REFERENCES [Lecturer] ([lecturer_id])
);
GO

-- ===================================================================================
-- 20. Table: SystemSettings Table
-- ===================================================================================
CREATE TABLE [SystemSettings] (
    [setting_key]   NVARCHAR(100) NOT NULL PRIMARY KEY,
    [setting_value] NVARCHAR(200) NOT NULL
);
GO

-- ===================================================================================
-- 21. Table: Student notifications read
-- ===================================================================================
CREATE TABLE [StudentNotifRead] (
    [student_id]   INT      NOT NULL PRIMARY KEY,
    [last_read_at] DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT [fk_SNR_Student] FOREIGN KEY ([student_id]) REFERENCES [Student]([student_id]) ON DELETE CASCADE
);
GO

-- ===================================================================================
-- 22. Table: Lecturer notifications read
-- ===================================================================================
CREATE TABLE LecturerNotifRead (
    lecturer_id INT PRIMARY KEY,
    last_read_at DATETIME NOT NULL
);
GO

-- ===================================================================================
-- 23. Table: Admin notifications read
-- ===================================================================================
CREATE TABLE AdminNotifRead (
    admin_id INT PRIMARY KEY,
    last_read_at DATETIME NOT NULL
);
GO


-- ===================================================================================
-- PROCEDURES, TRIGGERS & BUSINESS LOGIC ENGINES
-- ===================================================================================

-- 1. STORED PROCEDURE: Process Graduations Only
CREATE PROCEDURE sp_ProcessGraduations
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE s
    SET s.student_isactive = 'Graduated'
    FROM Student s
    INNER JOIN Program p ON s.Program_id = p.program_id
    WHERE s.student_isactive = 'Active' 
      AND s.student_sem >= p.program_semester;
END
GO

-- 2. STORED PROCEDURE: Advance To New Session
CREATE PROCEDURE sp_AdvanceToNewSession
    @NewSessionName NVARCHAR(20) -- e.g., 'APR2026'
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Update the global current session in System Settings
    UPDATE [SystemSettings]
    SET setting_value = @NewSessionName
    WHERE setting_key = 'current_session';

    -- 2. Advance the semester counter (+1) for all currently active students
    UPDATE [Student]
    SET student_sem = student_sem + 1
    WHERE student_isactive = 'Active';

    -- 3. Run the graduation check (graduates students who just hit their max semester)
    EXEC sp_ProcessGraduations;
END
GO

-- 3. TRIGGER: Auto Generate Payment
CREATE TRIGGER trg_GeneratePayment
ON [Enrollment]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted WHERE status = 'Approved')
    BEGIN
        DECLARE @StudentId INT;
        DECLARE student_cursor CURSOR FOR SELECT DISTINCT student_id FROM inserted WHERE status = 'Approved';
        OPEN student_cursor;
        FETCH NEXT FROM student_cursor INTO @StudentId;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            DECLARE @NewFeeAmount DECIMAL(18,2) = 0;
            SELECT @NewFeeAmount = ISNULL(SUM(CAST(c.course_fee AS DECIMAL(18,2))), 0)
            FROM [Enrollment] e
            INNER JOIN [Course] c ON e.course_id = c.course_id
            WHERE e.student_id = @StudentId AND e.status = 'Approved'
              AND NOT EXISTS (SELECT 1 FROM [PaymentDetail] pd WHERE pd.enrollment_id = e.enrollment_id);

            IF @NewFeeAmount > 0
            BEGIN
                DECLARE @PaymentId INT = NULL;
                SELECT TOP 1 @PaymentId = payment_id FROM [Payment] WHERE Student_id = @StudentId AND payment_paydate IS NULL ORDER BY payment_id DESC;
                IF @PaymentId IS NOT NULL
                    UPDATE [Payment] SET payment_amount = payment_amount + @NewFeeAmount WHERE payment_id = @PaymentId;
                ELSE
                BEGIN
                    INSERT INTO [Payment] (Student_id, payment_amount, payment_duedate) VALUES (@StudentId, @NewFeeAmount, DATEADD(day, 14, GETDATE()));
                    SET @PaymentId = SCOPE_IDENTITY();
                END
                INSERT INTO [PaymentDetail] (payment_id, enrollment_id, course_fee)
                SELECT @PaymentId, e.enrollment_id, c.course_fee
                FROM [Enrollment] e
                INNER JOIN [Course] c ON e.course_id = c.course_id
                WHERE e.student_id = @StudentId AND e.status = 'Approved'
                  AND NOT EXISTS (SELECT 1 FROM [PaymentDetail] pd WHERE pd.enrollment_id = e.enrollment_id);
            END
            FETCH NEXT FROM student_cursor INTO @StudentId;
        END
        CLOSE student_cursor; DEALLOCATE student_cursor;
    END
END
GO

-- 4. TRIGGER: Set student to 'Inactive' when payment is overdue
CREATE TRIGGER trg_Payment_SetInactive
ON [Payment]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE s
    SET s.[student_isactive] = 'Inactive'
    FROM [Student] s
    INNER JOIN inserted i ON s.[student_id] = i.[Student_id]
    WHERE i.[payment_duedate] < GETDATE() AND i.[payment_paydate] IS NULL AND s.[student_isactive] NOT IN ('Inactive', 'Graduated');
END
GO

-- 5. TRIGGER: Restore student to 'Active' when payment is made
CREATE TRIGGER trg_Payment_SetActive
ON [Payment]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT UPDATE([payment_paydate]) RETURN;
    UPDATE s
    SET s.[student_isactive] = 'Active'
    FROM [Student] s
    INNER JOIN inserted i  ON s.[student_id] = i.[Student_id]
    INNER JOIN deleted  d  ON i.[payment_id] = d.[payment_id]
    WHERE i.[payment_paydate] IS NOT NULL AND d.[payment_paydate] IS NULL AND s.[student_isactive] = 'Inactive'
      AND NOT EXISTS (SELECT 1 FROM [Payment] p WHERE p.[Student_id] = s.[student_id] AND p.[payment_id] <> i.[payment_id] AND p.[payment_duedate] < GETDATE() AND p.[payment_paydate] IS NULL);
END
GO

-- 6. TRIGGER: Restore student to 'Active' when overdue unpaid record is deleted
CREATE TRIGGER trg_Payment_DeleteReactivate
ON [Payment]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE s
    SET s.[student_isactive] = 'Active'
    FROM [Student] s
    INNER JOIN deleted d ON s.[student_id] = d.[Student_id]
    WHERE d.[payment_duedate] < GETDATE() AND d.[payment_paydate] IS NULL AND s.[student_isactive] = 'Inactive'
      AND NOT EXISTS (SELECT 1 FROM [Payment] p WHERE p.[Student_id] = s.[student_id] AND p.[payment_duedate] < GETDATE() AND p.[payment_paydate] IS NULL);
END
GO

-- 7. TRIGGER: Auto Calculate GPA & CGPA
CREATE TRIGGER trg_CalculateGradesAndGPA
ON [AssignmentSubmission]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(marks_awarded)
    BEGIN
        SELECT DISTINCT i.student_id, ca.course_id, e.enrollment_id INTO #AffectedEnrollments FROM inserted i
        INNER JOIN CourseAssignment ca ON i.assignment_id = ca.assignment_id
        INNER JOIN Enrollment e ON i.student_id = e.student_id AND ca.course_id = e.course_id;

        MERGE INTO CourseGrade AS target
        USING (
            SELECT enrollment_id,
                CASE WHEN Pct >= 80 THEN 'A' WHEN Pct >= 75 THEN 'A-' WHEN Pct >= 70 THEN 'B+' WHEN Pct >= 65 THEN 'B' WHEN Pct >= 60 THEN 'B-' WHEN Pct >= 55 THEN 'C+' WHEN Pct >= 50 THEN 'C' ELSE 'F' END AS LetterGrade,
                CASE WHEN Pct >= 80 THEN 4.00 WHEN Pct >= 75 THEN 3.70 WHEN Pct >= 70 THEN 3.30 WHEN Pct >= 65 THEN 3.00 WHEN Pct >= 60 THEN 2.70 WHEN Pct >= 55 THEN 2.30 WHEN Pct >= 50 THEN 2.00 ELSE 0.00 END AS GradePoint
            FROM (SELECT ae.enrollment_id, (SUM(sub.marks_awarded) / NULLIF(SUM(CASE WHEN sub.marks_awarded IS NOT NULL THEN ca.max_marks ELSE 0 END), 0)) * 100 AS Pct
                FROM #AffectedEnrollments ae INNER JOIN CourseAssignment ca ON ae.course_id = ca.course_id
                LEFT JOIN AssignmentSubmission sub ON ca.assignment_id = sub.assignment_id AND sub.student_id = ae.student_id GROUP BY ae.enrollment_id) AS Calc
        ) AS source ON target.Enrollment_id = source.enrollment_id
        WHEN MATCHED THEN UPDATE SET letter_grade = source.LetterGrade, grade_point = source.GradePoint
        WHEN NOT MATCHED THEN INSERT (Enrollment_id, letter_grade, grade_point, total_hours, attended_hours) VALUES (source.enrollment_id, source.LetterGrade, source.GradePoint, 0, 0);

        MERGE INTO Grades AS target
        USING (
            SELECT s.student_id, e.enrolled_semester AS semester, SUM(cg.grade_point * c.credit_hours) / NULLIF(SUM(c.credit_hours), 0) AS CalculatedGPA
            FROM (SELECT DISTINCT student_id FROM #AffectedEnrollments) af INNER JOIN Student s ON af.student_id = s.student_id
            INNER JOIN Enrollment e ON s.student_id = e.student_id INNER JOIN Course c ON e.course_id = c.course_id INNER JOIN CourseGrade cg ON e.enrollment_id = cg.Enrollment_id GROUP BY s.student_id, e.enrolled_semester
        ) AS source ON target.Student_id = source.student_id AND target.semester = source.semester
        WHEN MATCHED THEN UPDATE SET gpa = source.CalculatedGPA
        WHEN NOT MATCHED THEN INSERT (Student_id, semester, gpa) VALUES (source.student_id, source.semester, source.CalculatedGPA);

        UPDATE g SET cgpa = cgpaCalc.CumulativeGPA FROM Grades g
        INNER JOIN (SELECT Student_id, AVG(gpa) as CumulativeGPA FROM Grades GROUP BY Student_id) cgpaCalc ON g.Student_id = cgpaCalc.Student_id
        WHERE g.Student_id IN (SELECT DISTINCT student_id FROM #AffectedEnrollments);

        DROP TABLE #AffectedEnrollments;
    END
END
GO


-- ===================================================================================
-- ALIGNED CORE DATA FACTORY INITIALIZATION
-- ===================================================================================

-- 1. SYSTEM CONTEXT SEED
INSERT INTO [SystemSettings] (setting_key, setting_value) VALUES ('current_session', 'JAN2026');
GO

-- 2. ADMINISTRATIVE ACCESS PROFILE
INSERT INTO [Admin (HoP)] (admin_email, admin_name, admin_pw, admin_contact, admin_isactive, admin_bio)
VALUES ('admin@school.com', 'Justin Tan Hao Ren', 'admin123', '012-3456789', 1, 'Senior Head of Program');
GO

-- 3. FACULTY WORKFORCE ROSTER
INSERT INTO [Lecturer] (lecturer_name, lecturer_pw, lecturer_email, lecturer_department, teacher_isactive, Admin_admin_id)
VALUES
('Alan Turing',    'lect123', 'alanturing0001@lect.com',  'School of Computing', 'Active', 1),
('Ada Lovelace',   'lect123', 'adalovelace0002@lect.com', 'School of Computing', 'Active', 1),
('Warren Buffett', 'lect123', 'warrenbuffett0003@lect.com', 'School of Business',  'Active', 1),
('Grace Hopper',   'lect123', 'gracehopper0004@lect.com', 'School of Computing', 'Active', 1),
('John Keynes',    'lect123', 'johnkeynes0005@lect.com',  'School of Business',  'Inactive', 1);  -- Inactive: hidden from Course Allocation dropdown

UPDATE [Lecturer] SET lecturer_code = 'L' + RIGHT('0000' + CAST(lecturer_id AS NVARCHAR(4)), 4);
GO

-- 4. ACADEMIC PROGRAMS
INSERT INTO [Program] (program_code, program_name, program_level, program_fee, program_semester, program_credits, Lecturer_id, Admin_admin_id)
VALUES
('BSE', 'Software Engineering', 'Degree', 86000, 6, 120, 1, 1),
('BUS', 'Business Management',  'Degree', 85400, 6, 120, 3, 1),
('DCS', 'Computer Science',     'Diploma', 44000, 6, 90,  2, 1);
GO

-- 5. STUDENT IDENTITIES
INSERT INTO [Student] (student_name, student_pw, student_email, student_sem, student_isactive, Admin_admin_id, Program_id)
VALUES
('Charlie Brown', 'stud123', 'charliebrown0001@stud.com', 5, 'Active', 1, 1),   -- BSE, sem 5: one Advance Session => graduates
('David Miller',  'stud123', 'davidmiller0002@stud.com',  3, 'Active', 1, 1),   -- BSE, sem 3
('Eve Adams',     'stud123', 'eveadams0003@stud.com',     3, 'Active', 1, 1),   -- BSE, sem 3 (same program + sem as David)
('Frank Castle',  'stud123', 'frankcastle0004@stud.com',  2, 'Active', 1, 1),   -- BSE, sem 2: gets locked out via overdue fee
('Hannah Lee',    'stud123', 'hannahlee0005@stud.com',    1, 'Active', 1, 2),   -- BUS, sem 1: pending-enrolment demo
('Ivy Chen',      'stud123', 'ivychen0006@stud.com',      4, 'Active', 1, 2);   -- BUS, sem 4: BUS grades / performance

UPDATE [Student] SET student_code = 'S' + RIGHT('0000' + CAST(student_id AS NVARCHAR(4)), 4);
GO

-- 6. GENERAL SCHEDULING CALENDAR
INSERT INTO [Calendar] (event_title, event_desc, start_date, end_date, event_type, Admin_id)
VALUES ('Spring Semester 2026', 'Main Academic Calendar', '2026-06-10', '2026-06-15', 'General', 1),
       ('Midterm Week',            'Midterm exams for all courses.',     '2026-07-13', '2026-07-17', 'Exam',      1),
       ('Faculty Town Hall',       'Open briefing for all students.',    '2026-07-13', '2026-07-13', 'General',   1),
       ('Mid-Semester Break',      'Campus break - no classes.',         '2026-07-20', '2026-07-26', 'Holiday',   1),
       ('APR2026 Enrolment Opens', 'Registration for the next session.', '2026-07-06', '2026-07-13', 'Enrolment', 1);
GO

-- 7. SYLLABUS ENTRIES (Decoupled base tracking layer)
INSERT INTO [Course] (course_code, course_name, Calendar_id, credit_hours, course_fee)
VALUES
    ('CS101',  'C# Development',       1, 3, '1500'),
    ('DB202',  'Database Systems',     1, 4, '1200'),
    ('WEB105', 'Web Development',      1, 3, '2300'),
    ('DS204',  'Data Structures',      1, 4, '2500'),
    ('BUS301', 'Business Ethics',      1, 3, '4300'),
    ('BUS210', 'Marketing Principles', 1, 3, '2000'),
    ('BUS305', 'Financial Accounting', 1, 4, '2200');
GO

-- 7B. MULTI-PROGRAM MAPPING SYSTEM ASSIGNMENTS [cite: 15]
INSERT INTO [CourseProgram] (course_id, program_id)
VALUES
    (1, 1), -- CS101 tied to BSE
    (2, 1), -- DB202 tied to BSE
    (3, 1), -- WEB105 tied to BSE
    (4, 1), -- DS204 tied to BSE
    (5, 2), -- BUS301 tied to BUS
    (6, 2), -- BUS210 tied to BUS
    (7, 2); -- BUS305 tied to BUS
GO

-- 8. SESSION RECOGNIZED COURSE ENROLLMENT TRACKING [cite: 3]
INSERT INTO [Enrollment] (student_id, course_id, enrolled_semester, academic_session, enrollment_date, [status])
VALUES
    (1, 2, 5, 'JAN2026', GETDATE(), 'Approved'),   -- Charlie  DB202
    (1, 3, 5, 'JAN2026', GETDATE(), 'Approved'),   -- Charlie  WEB105
    (1, 4, 5, 'JAN2026', GETDATE(), 'Approved'),   -- Charlie  DS204
    (2, 2, 3, 'JAN2026', GETDATE(), 'Approved'),   -- David    DB202
    (2, 4, 3, 'JAN2026', GETDATE(), 'Approved'),   -- David    DS204
    (3, 1, 3, 'JAN2026', GETDATE(), 'Approved'),   -- Eve      CS101
    (3, 3, 3, 'JAN2026', GETDATE(), 'Approved'),   -- Eve      WEB105
    (4, 2, 2, 'JAN2026', GETDATE(), 'Approved'),   -- Frank    DB202   (auto-invoice via trigger)
    (4, 3, 2, 'JAN2026', GETDATE(), 'Approved'),   -- Frank    WEB105  (auto-invoice via trigger)
    (4, 4, 2, 'JAN2026', GETDATE(), 'Pending'),    -- Frank    DS204   (pending request)
    (5, 5, 1, 'JAN2026', GETDATE(), 'Pending'),    -- Hannah   BUS301  (pending request)
    (6, 5, 4, 'JAN2026', GETDATE(), 'Approved'),   -- Ivy      BUS301
    (6, 6, 4, 'JAN2026', GETDATE(), 'Approved'),   -- Ivy      BUS210
    (6, 7, 4, 'JAN2026', GETDATE(), 'Approved');   -- Ivy      BUS305
GO

-- 9. NOTICES & BROADCASTING
INSERT INTO [Announcement] (title, content, category, academic_session, Admin_id)
VALUES ('Welcome to the New System', 'The portal is now live.', 'General', 'JAN2026', 1),
       ('Fee Payment Reminder', 'Outstanding fees are due by the end of the month.', 'Finance', 'JAN2026', 1),
       ('Exam Timetable Released', 'Check the calendar for your exam dates.', 'Academic', 'JAN2026', 1),
       ('Coding Club Recruitment', 'Sign-ups open this week in the student lounge.', 'Co-curriculum', 'JAN2026', 1);

-- Course-specific announcement authored by a lecturer (Ada -> DB202)
INSERT INTO [Announcement] (title, content, category, academic_session, Lecturer_id, Course_id)
VALUES ('DB202: Lab 1 Posted', 'Lab Exercise 1 has been posted to the module page.', 'Academic', 'JAN2026', 2, 2);
GO

-- 10. CONTENT MANIFEST SCHEDULING
INSERT INTO [CourseModule] (course_id, module_name, module_description, academic_session)
VALUES (2, 'Week 1 - Intro to Databases', 'Fundamentals of relational databases.', 'JAN2026'),
       (2, 'Week 2 - Normalization',      'From 1NF to BCNF.',                'JAN2026'),
       (3, 'Week 1 - HTML & CSS',         'Frontend foundations.',            'JAN2026'),
       (1, 'Week 1 - C# Basics',          'Variables, types, control flow.',  'JAN2026'),
       (6, 'Week 1 - Marketing Intro',    'The 4 Ps of marketing.',           'JAN2026');

INSERT INTO [ModuleFile] (module_id, file_title, file_description, file_name, file_path)
VALUES (1, 'Chapter 1 Slides', 'Read pages 15-30.', 'Chapter1.pdf', '~/Uploads/Chapter1.pdf');
GO

-- 11. ASSIGNMENTS REGISTRATION
INSERT INTO [CourseAssignment] (course_id, title, description, assignment_type, academic_session, due_date, max_marks)
VALUES 
(2, 'Week 1 Quiz: Intro to DB', 'SQL fundamentals.', 'Quiz', 'JAN2026', '2026-05-10 12:00:00', 20),
(2, 'Midterm Examination', 'Covers chapters 1 to 5.', 'Exam', 'JAN2026', '2026-07-01 10:00:00', 50),
(3, 'Frontend Web Project', 'Design a responsive site.', 'Project', 'JAN2026', '2026-06-15 10:00:00', 100),
(5, 'Corporate Ethics Essay', '1000 word essay.', 'Essay', 'JAN2026', '2026-06-20 10:00:00', 100),
(2, 'Lab Exercise 1', 'Normalization practice (1NF-BCNF).', 'Coursework', 'JAN2026', DATEADD(DAY,-5,GETDATE()), 50),  -- past due -> late-submission demo
(3, 'Final Web Portfolio', 'Build a responsive portfolio.', 'Project', 'JAN2026', DATEADD(DAY,10,GETDATE()), 100),    -- future due
(6, 'Marketing Plan', 'Draft a go-to-market plan.', 'Project', 'JAN2026', '2026-06-18 10:00:00', 100),
(1, 'C# Basics Quiz', 'Variables and loops.', 'Quiz', 'JAN2026', '2026-05-20 12:00:00', 30);
GO

-- ===================================================================================
-- 12. EVALUATED GRADEBOOK ARTIFACTS (Triggers automatic computation workflow)
-- Marks are tuned so trg_CalculateGradesAndGPA produces a clear performance spread:
--   Charlie -> Good      (B+ / ~3.30)
--   David   -> Average   (C+ / ~2.30)
--   Eve     -> Fail      (F  /  0.00)
--   Frank   -> Excellent (A  /  4.00)
--   Ivy     -> Average   (C  /  2.00)
-- Assignment id -> course / max marks reference:
--   a1 DB202/20  a2 DB202/50  a3 WEB105/100  a4 BUS301/100
--   a5 DB202/50 (past due)    a6 WEB105/100 (future)  a7 BUS210/100  a8 CS101/30
-- ===================================================================================

-- CHARLIE (student 1) -> Good (~72% across DB202 + WEB105)
INSERT INTO [AssignmentSubmission] (assignment_id, student_id, submission_file, submitted_at, marks_awarded, is_published) VALUES
(1, 1, '~/Uploads/Charlie_Quiz1.docx', GETDATE(), 14, 1),   -- DB202 quiz   14/20
(2, 1, '~/Uploads/Charlie_Mid.docx',   GETDATE(), 36, 1),   -- DB202 midterm 36/50
(5, 1, '~/Uploads/Charlie_Lab1.pdf',   GETDATE(), 36, 1),   -- DB202 lab    36/50  (now graded)
(3, 1, '~/Uploads/Charlie_Web.zip',    GETDATE(), 72, 1),   -- WEB105 proj  72/100
(6, 1, '~/Uploads/Charlie_Folio.zip',  GETDATE(), 72, 1);   -- WEB105 folio 72/100

-- DAVID (student 2) -> Average (~57% in DB202)
INSERT INTO [AssignmentSubmission] (assignment_id, student_id, submission_file, submitted_at, marks_awarded, is_published) VALUES
(1, 2, '~/Uploads/David_Quiz1.docx', GETDATE(), 11, 1),     -- DB202 quiz    11/20
(2, 2, '~/Uploads/David_Mid.docx',   GETDATE(), 29, 1),     -- DB202 midterm 29/50
(5, 2, '~/Uploads/David_Lab1.pdf',   GETDATE(), 28, 1);     -- DB202 lab     28/50  (now graded)

-- EVE (student 3) -> Fail (~40% in CS101 + WEB105)
INSERT INTO [AssignmentSubmission] (assignment_id, student_id, submission_file, submitted_at, marks_awarded, is_published) VALUES
(8, 3, '~/Uploads/Eve_CS101.docx', GETDATE(), 12, 1),       -- CS101 quiz   12/30
(3, 3, '~/Uploads/Eve_Web.zip',    GETDATE(), 40, 1),       -- WEB105 proj  40/100
(6, 3, '~/Uploads/Eve_Folio.zip',  GETDATE(), 40, 1);       -- WEB105 folio 40/100

-- FRANK (student 4) -> Excellent (~85% in DB202 + WEB105)
INSERT INTO [AssignmentSubmission] (assignment_id, student_id, submission_file, submitted_at, marks_awarded, is_published) VALUES
(1, 4, '~/Uploads/Frank_Quiz1.docx', GETDATE(), 17, 1),     -- DB202 quiz    17/20
(2, 4, '~/Uploads/Frank_Mid.docx',   GETDATE(), 43, 1),     -- DB202 midterm 43/50
(5, 4, '~/Uploads/Frank_Lab1.pdf',   GETDATE(), 43, 1),     -- DB202 lab     43/50
(3, 4, '~/Uploads/Frank_Web.zip',    GETDATE(), 85, 1),     -- WEB105 proj   85/100
(6, 4, '~/Uploads/Frank_Folio.zip',  GETDATE(), 86, 1);     -- WEB105 folio  86/100

-- IVY (student 6) -> Average (~51% in BUS301 + BUS210)
INSERT INTO [AssignmentSubmission] (assignment_id, student_id, submission_file, submitted_at, marks_awarded, is_published) VALUES
(4, 6, '~/Uploads/Ivy_Essay.docx',     GETDATE(), 52, 1),   -- BUS301 essay     52/100
(7, 6, '~/Uploads/Ivy_Marketing.docx', GETDATE(), 50, 1);   -- BUS210 marketing 50/100
GO

-- ===================================================================================
-- 12B. PAST-DUE LATE SUBMISSION DEMO (ungraded, still visible to lecturer/student)
-- Frank has a late, ungraded Lab1 to populate the lecturer's "to grade" queue
-- without affecting the graded students above.
-- ===================================================================================
INSERT INTO [AssignmentSubmission] (assignment_id, student_id, submission_file, submitted_at, is_published)
VALUES
(5, 4, '~/Uploads/Frank_Lab1_late.pdf', GETDATE(), 0);      -- Frank Lab1 (late, ungraded)
GO

-- 13. SEMESTER DISPATCH SCHEDULER ALLOCATIONS
INSERT INTO [CourseAssignment_Session] (course_id, lecturer_id, academic_session, assign_status)
VALUES
(1, 1, 'JAN2026', 'Active'),
(2, 2, 'JAN2026', 'Active'),
(3, 4, 'JAN2026', 'Active'),   -- WEB105 -> Grace
(4, 1, 'JAN2026', 'Active'),   -- DS204  -> Alan
(5, 3, 'JAN2026', 'Active'),   -- BUS301 -> Warren
(6, 3, 'JAN2026', 'Active'),   -- BUS210 -> Warren
(7, 3, 'JAN2026', 'Active');   -- BUS305 -> Warren
GO

-- ===================================================================================
-- 14. HISTORICAL GRADE RECORDS (PAST SEMESTERS)
-- trg_CalculateGradesAndGPA only writes the CURRENT enrolled semester, so prior-sem
-- GPA rows are seeded directly here. Counts vary per student. The UQ_Student_Semester
-- constraint keeps one row per (student, semester); none of these collide with the
-- current-semester rows the trigger created in Section 12.
--   Charlie (now sem5): 4 past sems   David (now sem3): 2 past sems
--   Eve     (now sem3): 2 past sems   Frank (now sem2): 1 past sem
--   Ivy     (now sem4): 3 past sems
-- Each student's history trends toward their current performance band.
-- ===================================================================================

-- Charlie -> Good: steady B+ history
INSERT INTO [Grades] (Student_id, semester, gpa) VALUES
(1, 1, 3.10), (1, 2, 3.25), (1, 3, 3.40), (1, 4, 3.20);

-- David -> Average: C+/B- history
INSERT INTO [Grades] (Student_id, semester, gpa) VALUES
(2, 1, 2.50), (2, 2, 2.40);

-- Eve -> Fail: weak, declining history
INSERT INTO [Grades] (Student_id, semester, gpa) VALUES
(3, 1, 1.80), (3, 2, 1.50);

-- Frank -> Excellent: strong prior sem
INSERT INTO [Grades] (Student_id, semester, gpa) VALUES
(4, 1, 3.85);

-- Ivy -> Average: flat C history
INSERT INTO [Grades] (Student_id, semester, gpa) VALUES
(6, 1, 2.10), (6, 2, 2.30), (6, 3, 2.00);
GO

-- Recompute CGPA across ALL semesters (mirrors the trigger's averaging logic so the
-- cumulative figure accounts for both the seeded history and the current-sem rows).
UPDATE g
SET cgpa = c.CumulativeGPA
FROM [Grades] g
INNER JOIN (SELECT Student_id, AVG(gpa) AS CumulativeGPA FROM [Grades] GROUP BY Student_id) c
  ON g.Student_id = c.Student_id;
GO

-- ===================================================================================
-- 15. VERIFICATION: performance spread + semester history
-- ===================================================================================
SELECT s.student_name, g.semester, g.gpa, g.cgpa
FROM [Grades] g INNER JOIN [Student] s ON g.Student_id = s.student_id
ORDER BY s.student_name, g.semester;
GO

-- ===================================================================================
-- DATA INTEGRITY VERIFICATION CHECK WINDOW
-- ===================================================================================
SELECT * FROM [SystemSettings];
SELECT * FROM [Program];
SELECT * FROM [CourseProgram];
SELECT * FROM [Lecturer];
SELECT * FROM [Student];

SELECT * FROM [Enrollment];

SELECT * FROM [Course];
SELECT * FROM [Announcement];
SELECT * FROM [CourseGrade];
SELECT * FROM [Grades];
SELECT * FROM [CourseAssignment_Session];


USE SchoolSystemDB;
GO

