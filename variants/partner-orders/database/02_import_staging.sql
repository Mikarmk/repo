USE [PartnerOrdersDemo];
GO

-- Staging tables for exam import. Replace this section with BULK INSERT / OPENROWSET on the exam workstation.
IF OBJECT_ID(N'dbo.StagingPartners', N'U') IS NOT NULL DROP TABLE dbo.StagingPartners;
CREATE TABLE dbo.StagingPartners (RawLine nvarchar(max) NULL);
IF OBJECT_ID(N'dbo.StagingProductTypes', N'U') IS NOT NULL DROP TABLE dbo.StagingProductTypes;
CREATE TABLE dbo.StagingProductTypes (RawLine nvarchar(max) NULL);
IF OBJECT_ID(N'dbo.StagingProducts', N'U') IS NOT NULL DROP TABLE dbo.StagingProducts;
CREATE TABLE dbo.StagingProducts (RawLine nvarchar(max) NULL);
IF OBJECT_ID(N'dbo.StagingMaterialTypes', N'U') IS NOT NULL DROP TABLE dbo.StagingMaterialTypes;
CREATE TABLE dbo.StagingMaterialTypes (RawLine nvarchar(max) NULL);
IF OBJECT_ID(N'dbo.StagingPartnerRequestItems', N'U') IS NOT NULL DROP TABLE dbo.StagingPartnerRequestItems;
CREATE TABLE dbo.StagingPartnerRequestItems (RawLine nvarchar(max) NULL);

GO
