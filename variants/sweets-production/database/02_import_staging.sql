USE [SweetsProductionDemo];
GO

-- Staging tables for exam import. Replace this section with BULK INSERT / OPENROWSET on the exam workstation.
IF OBJECT_ID(N'dbo.StagingManagers', N'U') IS NOT NULL DROP TABLE dbo.StagingManagers;
CREATE TABLE dbo.StagingManagers (RawLine nvarchar(max) NULL);
IF OBJECT_ID(N'dbo.StagingStorekeepers', N'U') IS NOT NULL DROP TABLE dbo.StagingStorekeepers;
CREATE TABLE dbo.StagingStorekeepers (RawLine nvarchar(max) NULL);
IF OBJECT_ID(N'dbo.StagingRetailBuyers', N'U') IS NOT NULL DROP TABLE dbo.StagingRetailBuyers;
CREATE TABLE dbo.StagingRetailBuyers (RawLine nvarchar(max) NULL);
IF OBJECT_ID(N'dbo.StagingCompanyBuyers', N'U') IS NOT NULL DROP TABLE dbo.StagingCompanyBuyers;
CREATE TABLE dbo.StagingCompanyBuyers (RawLine nvarchar(max) NULL);
IF OBJECT_ID(N'dbo.StagingOrders', N'U') IS NOT NULL DROP TABLE dbo.StagingOrders;
CREATE TABLE dbo.StagingOrders (RawLine nvarchar(max) NULL);

GO
