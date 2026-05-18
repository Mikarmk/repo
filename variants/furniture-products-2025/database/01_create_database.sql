USE master;
GO
IF DB_ID(N'FurnitureProducts2025Demo') IS NULL
BEGIN
    CREATE DATABASE [FurnitureProducts2025Demo];
END;
GO
USE [FurnitureProducts2025Demo];
GO

IF OBJECT_ID(N'dbo.v_MainRecords', N'V') IS NOT NULL DROP VIEW dbo.v_MainRecords;
GO
CREATE TABLE dbo.Roles (
    RoleId int IDENTITY(1,1) PRIMARY KEY,
    Code nvarchar(50) NOT NULL UNIQUE,
    Name nvarchar(100) NOT NULL UNIQUE
);

CREATE TABLE dbo.AppUsers (
    UserId int IDENTITY(1,1) PRIMARY KEY,
    Login nvarchar(100) NOT NULL UNIQUE,
    PasswordHash nvarchar(100) NOT NULL,
    FullName nvarchar(200) NOT NULL,
    Phone nvarchar(30) NULL,
    Email nvarchar(200) NULL,
    RoleId int NOT NULL,
    IsActive bit NOT NULL CONSTRAINT DF_AppUsers_IsActive DEFAULT (1),
    CONSTRAINT FK_AppUsers_Roles FOREIGN KEY (RoleId) REFERENCES dbo.Roles(RoleId)
);

CREATE TABLE dbo.ProductTypes (
    ProductTypeId int IDENTITY(1,1) PRIMARY KEY,
    TypeName nvarchar(100) NOT NULL UNIQUE,
    TypeCoefficient decimal(18,4) NOT NULL CONSTRAINT CK_ProductTypes_TypeCoefficient CHECK (TypeCoefficient > 0)
);

CREATE TABLE dbo.Materials (
    MaterialId int IDENTITY(1,1) PRIMARY KEY,
    MaterialName nvarchar(200) NOT NULL UNIQUE,
    LossPercent decimal(18,4) NOT NULL CONSTRAINT CK_Materials_LossPercent CHECK (LossPercent >= 0)
);

CREATE TABLE dbo.Products (
    ProductId int IDENTITY(1,1) PRIMARY KEY,
    ArticleNumber nvarchar(50) NOT NULL,
    ProductTypeId int NOT NULL,
    ProductName nvarchar(200) NOT NULL,
    PartnerMinPrice decimal(18,2) NOT NULL CONSTRAINT CK_Products_PartnerMinPrice CHECK (PartnerMinPrice >= 0),
    MainMaterialId int NULL,
    CONSTRAINT FK_Products_ProductTypes FOREIGN KEY (ProductTypeId) REFERENCES dbo.ProductTypes(ProductTypeId),
    CONSTRAINT FK_Products_Materials FOREIGN KEY (MainMaterialId) REFERENCES dbo.Materials(MaterialId)
);

CREATE TABLE dbo.Workshops (
    WorkshopId int IDENTITY(1,1) PRIMARY KEY,
    WorkshopName nvarchar(200) NOT NULL UNIQUE,
    EmployeesCount int NOT NULL CONSTRAINT CK_Workshops_EmployeesCount CHECK (EmployeesCount >= 0)
);

CREATE TABLE dbo.ProductWorkshops (
    ProductWorkshopId int IDENTITY(1,1) PRIMARY KEY,
    ProductId int NOT NULL,
    WorkshopId int NOT NULL,
    ProductionMinutes int NOT NULL CONSTRAINT CK_ProductWorkshops_ProductionMinutes CHECK (ProductionMinutes >= 0),
    CONSTRAINT FK_ProductWorkshops_Products FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId) ON DELETE CASCADE,
    CONSTRAINT FK_ProductWorkshops_Workshops FOREIGN KEY (WorkshopId) REFERENCES dbo.Workshops(WorkshopId)
);

CREATE VIEW dbo.v_MainRecords AS
SELECT
    p.ProductId AS RecordId,
    p.ProductName AS Title,
    pt.TypeName AS Subtitle,
    ISNULL(m.MaterialName, N'Не указан') AS Description,
    N'Активен' AS StatusText,
    N'' AS DateText,
    CAST(p.PartnerMinPrice AS decimal(18,2)) AS NumericValue
FROM dbo.Products p
INNER JOIN dbo.ProductTypes pt ON pt.ProductTypeId = p.ProductTypeId
LEFT JOIN dbo.Materials m ON m.MaterialId = p.MainMaterialId;
GO
