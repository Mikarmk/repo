USE [FurnitureProducts2025Demo];
GO

-- Staging tables for exam import. Replace this section with BULK INSERT / OPENROWSET on the exam workstation.
IF OBJECT_ID(N'dbo.StagingProducts', N'U') IS NOT NULL DROP TABLE dbo.StagingProducts;
CREATE TABLE dbo.StagingProducts (RawLine nvarchar(max) NULL);
IF OBJECT_ID(N'dbo.StagingTypes', N'U') IS NOT NULL DROP TABLE dbo.StagingTypes;
CREATE TABLE dbo.StagingTypes (RawLine nvarchar(max) NULL);
IF OBJECT_ID(N'dbo.StagingWorkshops', N'U') IS NOT NULL DROP TABLE dbo.StagingWorkshops;
CREATE TABLE dbo.StagingWorkshops (RawLine nvarchar(max) NULL);

GO
