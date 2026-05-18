USE master;
GO

BACKUP DATABASE [FurnitureProducts2025Demo]
TO DISK = N'C:\Backup\FurnitureProducts2025Demo.bak'
WITH INIT, FORMAT, NAME = N'FurnitureProducts2025Demo full backup';
GO
