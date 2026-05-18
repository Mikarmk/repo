USE master;
GO

BACKUP DATABASE [PartnerOrdersDemo]
TO DISK = N'C:\Backup\PartnerOrdersDemo.bak'
WITH INIT, FORMAT, NAME = N'PartnerOrdersDemo full backup';
GO
