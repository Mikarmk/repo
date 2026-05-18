USE master;
GO

BACKUP DATABASE [PartnerRequests2025Demo]
TO DISK = N'C:\Backup\PartnerRequests2025Demo.bak'
WITH INIT, FORMAT, NAME = N'PartnerRequests2025Demo full backup';
GO
