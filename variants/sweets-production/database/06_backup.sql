USE master;
GO

BACKUP DATABASE [SweetsProductionDemo]
TO DISK = N'C:\Backup\SweetsProductionDemo.bak'
WITH INIT, FORMAT, NAME = N'SweetsProductionDemo full backup';
GO
