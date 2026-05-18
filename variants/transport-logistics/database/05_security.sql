USE [TransportLogisticsDemo];
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'app_reader')
BEGIN
    CREATE ROLE app_reader;
END;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'app_writer')
BEGIN
    CREATE ROLE app_writer;
END;

GRANT SELECT ON dbo.v_MainRecords TO app_reader;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.AppUsers TO app_writer;
GO
