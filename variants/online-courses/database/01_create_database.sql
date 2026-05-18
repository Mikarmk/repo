USE master;
GO
IF DB_ID(N'OnlineCoursesDemo') IS NULL
BEGIN
    CREATE DATABASE [OnlineCoursesDemo];
END;
GO
USE [OnlineCoursesDemo];
GO

IF OBJECT_ID(N'dbo.v_MainRecords', N'V') IS NOT NULL DROP VIEW dbo.v_MainRecords;
GO
CREATE TABLE dbo.Roles (
    RoleId int IDENTITY(1,1) PRIMARY KEY,
    Code nvarchar(50) NOT NULL UNIQUE,
    Name nvarchar(100) NOT NULL UNIQUE
);

CREATE TABLE dbo.AppUsers (
    UserId int IDENTITY(1,1) PRIMARY KEY,
    Login nvarchar(100) NOT NULL UNIQUE,
    PasswordHash nvarchar(100) NOT NULL,
    FullName nvarchar(200) NOT NULL,
    Phone nvarchar(30) NULL,
    Email nvarchar(200) NULL,
    RoleId int NOT NULL,
    IsActive bit NOT NULL CONSTRAINT DF_AppUsers_IsActive DEFAULT (1),
    CONSTRAINT FK_AppUsers_Roles FOREIGN KEY (RoleId) REFERENCES dbo.Roles(RoleId)
);

CREATE TABLE dbo.Parents (
    ParentId int IDENTITY(1,1) PRIMARY KEY,
    UserId int NOT NULL UNIQUE,
    CONSTRAINT FK_Parents_AppUsers FOREIGN KEY (UserId) REFERENCES dbo.AppUsers(UserId)
);

CREATE TABLE dbo.Teachers (
    TeacherId int IDENTITY(1,1) PRIMARY KEY,
    UserId int NOT NULL UNIQUE,
    Qualification nvarchar(200) NULL,
    CONSTRAINT FK_Teachers_AppUsers FOREIGN KEY (UserId) REFERENCES dbo.AppUsers(UserId)
);

CREATE TABLE dbo.Students (
    StudentId int IDENTITY(1,1) PRIMARY KEY,
    UserId int NOT NULL UNIQUE,
    ParentId int NULL,
    StartDate date NULL,
    CONSTRAINT FK_Students_AppUsers FOREIGN KEY (UserId) REFERENCES dbo.AppUsers(UserId),
    CONSTRAINT FK_Students_Parents FOREIGN KEY (ParentId) REFERENCES dbo.Parents(ParentId)
);

CREATE TABLE dbo.Courses (
    CourseId int IDENTITY(1,1) PRIMARY KEY,
    CourseName nvarchar(200) NOT NULL UNIQUE,
    BaseLessonCount int NOT NULL CONSTRAINT CK_Courses_BaseLessonCount CHECK (BaseLessonCount > 0),
    PriceAmount decimal(18,2) NOT NULL CONSTRAINT CK_Courses_PriceAmount CHECK (PriceAmount >= 0)
);

CREATE TABLE dbo.Enrollments (
    EnrollmentId int IDENTITY(1,1) PRIMARY KEY,
    StudentId int NOT NULL,
    CourseId int NOT NULL,
    PurchaseDate date NOT NULL,
    LessonCount int NOT NULL CONSTRAINT CK_Enrollments_LessonCount CHECK (LessonCount > 0),
    PaymentStatus nvarchar(50) NOT NULL,
    CONSTRAINT FK_Enrollments_Students FOREIGN KEY (StudentId) REFERENCES dbo.Students(StudentId),
    CONSTRAINT FK_Enrollments_Courses FOREIGN KEY (CourseId) REFERENCES dbo.Courses(CourseId)
);

CREATE TABLE dbo.ScheduleEntries (
    ScheduleEntryId int IDENTITY(1,1) PRIMARY KEY,
    CourseId int NOT NULL,
    TeacherId int NOT NULL,
    LessonDate datetime NOT NULL,
    RoomName nvarchar(50) NULL,
    CONSTRAINT FK_ScheduleEntries_Courses FOREIGN KEY (CourseId) REFERENCES dbo.Courses(CourseId),
    CONSTRAINT FK_ScheduleEntries_Teachers FOREIGN KEY (TeacherId) REFERENCES dbo.Teachers(TeacherId)
);

CREATE VIEW dbo.v_MainRecords AS
SELECT
    e.EnrollmentId AS RecordId,
    sUser.FullName AS Title,
    c.CourseName AS Subtitle,
    CONCAT(N'Родитель: ', ISNULL(pUser.FullName, N'не указан')) AS Description,
    e.PaymentStatus AS StatusText,
    CONVERT(nvarchar(10), e.PurchaseDate, 104) AS DateText,
    CAST(e.LessonCount AS decimal(18,2)) AS NumericValue
FROM dbo.Enrollments e
INNER JOIN dbo.Students s ON s.StudentId = e.StudentId
INNER JOIN dbo.AppUsers sUser ON sUser.UserId = s.UserId
LEFT JOIN dbo.Parents p ON p.ParentId = s.ParentId
LEFT JOIN dbo.AppUsers pUser ON pUser.UserId = p.UserId
INNER JOIN dbo.Courses c ON c.CourseId = e.CourseId;
GO
