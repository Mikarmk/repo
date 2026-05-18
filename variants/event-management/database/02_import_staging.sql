USE [EventManagementDemo];
GO

-- Staging tables for exam import. Replace this section with BULK INSERT / OPENROWSET on the exam workstation.
IF OBJECT_ID(N'dbo.StagingManagers', N'U') IS NOT NULL DROP TABLE dbo.StagingManagers;
CREATE TABLE dbo.StagingManagers (RawLine nvarchar(max) NULL);
IF OBJECT_ID(N'dbo.StagingClients', N'U') IS NOT NULL DROP TABLE dbo.StagingClients;
CREATE TABLE dbo.StagingClients (RawLine nvarchar(max) NULL);

GO
