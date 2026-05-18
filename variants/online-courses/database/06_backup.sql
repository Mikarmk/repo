USE master;
GO

BACKUP DATABASE [OnlineCoursesDemo]
TO DISK = N'C:\Backup\OnlineCoursesDemo.bak'
WITH INIT, FORMAT, NAME = N'OnlineCoursesDemo full backup';
GO
