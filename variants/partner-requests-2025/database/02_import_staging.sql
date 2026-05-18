USE [PartnerRequests2025Demo];
GO

-- Staging tables for exam import. Replace this section with BULK INSERT / OPENROWSET on the exam workstation.
IF OBJECT_ID(N'dbo.StagingPartners', N'U') IS NOT NULL DROP TABLE dbo.StagingPartners;
CREATE TABLE dbo.StagingPartners (RawLine nvarchar(max) NULL);
IF OBJECT_ID(N'dbo.StagingProducts', N'U') IS NOT NULL DROP TABLE dbo.StagingProducts;
CREATE TABLE dbo.StagingProducts (RawLine nvarchar(max) NULL);
IF OBJECT_ID(N'dbo.StagingRequests', N'U') IS NOT NULL DROP TABLE dbo.StagingRequests;
CREATE TABLE dbo.StagingRequests (RawLine nvarchar(max) NULL);

GO
