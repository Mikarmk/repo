USE master;
GO

BACKUP DATABASE [TransportLogisticsDemo]
TO DISK = N'C:\Backup\TransportLogisticsDemo.bak'
WITH INIT, FORMAT, NAME = N'TransportLogisticsDemo full backup';
GO
