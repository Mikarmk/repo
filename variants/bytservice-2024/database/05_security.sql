USE BytServiceDemo;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'app_operator')
BEGIN
    CREATE ROLE app_operator;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'app_master')
BEGIN
    CREATE ROLE app_master;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'app_client')
BEGIN
    CREATE ROLE app_client;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'app_quality_manager')
BEGIN
    CREATE ROLE app_quality_manager;
END;
GO

GRANT SELECT, INSERT, UPDATE ON dbo.RepairRequests TO app_operator;
GRANT SELECT ON dbo.Users TO app_operator;
GRANT SELECT ON dbo.RequestStatuses TO app_operator;
GRANT SELECT, INSERT ON dbo.RequestComments TO app_operator;

GRANT SELECT, UPDATE ON dbo.RepairRequests TO app_master;
GRANT SELECT, INSERT ON dbo.RequestComments TO app_master;
GRANT SELECT ON dbo.Users TO app_master;
GRANT SELECT ON dbo.RequestStatuses TO app_master;

GRANT SELECT, INSERT, UPDATE ON dbo.RepairRequests TO app_client;
GRANT SELECT ON dbo.RequestStatuses TO app_client;

GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.RepairRequests TO app_quality_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.RequestAssistantMasters TO app_quality_manager;
GRANT SELECT, INSERT, UPDATE ON dbo.RequestComments TO app_quality_manager;
GRANT SELECT, INSERT ON dbo.RequestStatusHistory TO app_quality_manager;
GRANT SELECT ON dbo.Users TO app_quality_manager;
GRANT SELECT ON dbo.RequestStatuses TO app_quality_manager;
GO

/*
Пример привязки существующего пользователя БД:

CREATE USER demo_operator WITHOUT LOGIN;
ALTER ROLE app_operator ADD MEMBER demo_operator;
*/

