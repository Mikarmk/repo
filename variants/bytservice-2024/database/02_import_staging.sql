USE BytServiceDemo;
GO

IF OBJECT_ID(N'dbo.StagingUsers', N'U') IS NOT NULL DROP TABLE dbo.StagingUsers;
IF OBJECT_ID(N'dbo.StagingRequests', N'U') IS NOT NULL DROP TABLE dbo.StagingRequests;
IF OBJECT_ID(N'dbo.StagingComments', N'U') IS NOT NULL DROP TABLE dbo.StagingComments;
GO

CREATE TABLE dbo.StagingUsers
(
    RawLine nvarchar(max) NULL
);
GO

CREATE TABLE dbo.StagingRequests
(
    RawLine nvarchar(max) NULL
);
GO

CREATE TABLE dbo.StagingComments
(
    RawLine nvarchar(max) NULL
);
GO

-- На экзамене можно заменить эти staging-таблицы на BULK INSERT / OPENROWSET
-- из assets/raw/Приложение... и assets/import.
