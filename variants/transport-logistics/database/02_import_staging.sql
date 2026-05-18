USE [TransportLogisticsDemo];
GO

-- Staging tables for exam import. Replace this section with BULK INSERT / OPENROWSET on the exam workstation.
IF OBJECT_ID(N'dbo.StagingManagers', N'U') IS NOT NULL DROP TABLE dbo.StagingManagers;
CREATE TABLE dbo.StagingManagers (RawLine nvarchar(max) NULL);
IF OBJECT_ID(N'dbo.StagingManufacturers', N'U') IS NOT NULL DROP TABLE dbo.StagingManufacturers;
CREATE TABLE dbo.StagingManufacturers (RawLine nvarchar(max) NULL);
IF OBJECT_ID(N'dbo.StagingConsumers', N'U') IS NOT NULL DROP TABLE dbo.StagingConsumers;
CREATE TABLE dbo.StagingConsumers (RawLine nvarchar(max) NULL);
IF OBJECT_ID(N'dbo.StagingCarriers', N'U') IS NOT NULL DROP TABLE dbo.StagingCarriers;
CREATE TABLE dbo.StagingCarriers (RawLine nvarchar(max) NULL);
IF OBJECT_ID(N'dbo.StagingDrivers', N'U') IS NOT NULL DROP TABLE dbo.StagingDrivers;
CREATE TABLE dbo.StagingDrivers (RawLine nvarchar(max) NULL);
IF OBJECT_ID(N'dbo.StagingOrders', N'U') IS NOT NULL DROP TABLE dbo.StagingOrders;
CREATE TABLE dbo.StagingOrders (RawLine nvarchar(max) NULL);

GO
