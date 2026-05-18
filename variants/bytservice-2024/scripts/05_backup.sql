USE master;
GO

BACKUP DATABASE BytServiceDemo
TO DISK = N'C:\Backup\BytServiceDemo.bak'
WITH INIT,
     COMPRESSION,
     STATS = 10,
     NAME = N'BytServiceDemo-FullBackup';
GO

