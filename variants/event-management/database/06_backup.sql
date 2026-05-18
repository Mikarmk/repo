USE master;
GO

BACKUP DATABASE [EventManagementDemo]
TO DISK = N'C:\Backup\EventManagementDemo.bak'
WITH INIT, FORMAT, NAME = N'EventManagementDemo full backup';
GO
