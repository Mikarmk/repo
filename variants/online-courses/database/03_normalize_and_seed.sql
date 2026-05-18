USE [OnlineCoursesDemo];
GO

INSERT INTO dbo.Roles (Code, Name) VALUES
(N'ADMIN', N'Администратор'),
(N'TEACHER', N'Преподаватель'),
(N'PARENT', N'Родитель'),
(N'STUDENT', N'Ученик');

INSERT INTO dbo.AppUsers (Login, PasswordHash, FullName, Phone, Email, RoleId)
SELECT N'admin', N'admin', N'Администратор Демонстрационный', N'+7 900 100-00-01', N'admin@demo.local', RoleId FROM dbo.Roles WHERE Code = N'ADMIN'
UNION ALL
SELECT N'teacher', N'teacher', N'Преподаватель Демонстрационный', N'+7 900 100-00-02', N'teacher@demo.local', RoleId FROM dbo.Roles WHERE Code = N'TEACHER'
UNION ALL
SELECT N'parent', N'parent', N'Родитель Демонстрационный', N'+7 900 100-00-03', N'parent@demo.local', RoleId FROM dbo.Roles WHERE Code = N'PARENT'
UNION ALL
SELECT N'student', N'student', N'Ученик Демонстрационный', N'+7 900 100-00-04', N'student@demo.local', RoleId FROM dbo.Roles WHERE Code = N'STUDENT';

INSERT INTO dbo.Parents (UserId) SELECT UserId FROM dbo.AppUsers WHERE Login = N'parent';
INSERT INTO dbo.Teachers (UserId, Qualification) SELECT UserId, N'Математика' FROM dbo.AppUsers WHERE Login = N'teacher';
INSERT INTO dbo.Students (UserId, ParentId, StartDate)
SELECT s.UserId, p.ParentId, '2024-04-01' FROM dbo.AppUsers s CROSS JOIN dbo.Parents p WHERE s.Login = N'student';
INSERT INTO dbo.Courses (CourseName, BaseLessonCount, PriceAmount) VALUES (N'Математика', 15, 12000.00), (N'Русский язык', 15, 11000.00), (N'Программирование C#', 20, 18000.00);
INSERT INTO dbo.Enrollments (StudentId, CourseId, PurchaseDate, LessonCount, PaymentStatus)
SELECT TOP (1) s.StudentId, c.CourseId, '2024-05-01', 15, N'Оплачено'
FROM dbo.Students s CROSS JOIN dbo.Courses c WHERE c.CourseName = N'Математика';
INSERT INTO dbo.ScheduleEntries (CourseId, TeacherId, LessonDate, RoomName)
SELECT TOP (1) c.CourseId, t.TeacherId, '2024-05-20T18:00:00', N'Кабинет 101'
FROM dbo.Courses c CROSS JOIN dbo.Teachers t WHERE c.CourseName = N'Математика';
GO
