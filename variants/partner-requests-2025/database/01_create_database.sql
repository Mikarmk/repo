USE master;
GO
IF DB_ID(N'PartnerRequests2025Demo') IS NULL
BEGIN
    CREATE DATABASE [PartnerRequests2025Demo];
END;
GO
USE [PartnerRequests2025Demo];
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

CREATE TABLE dbo.PartnerTypes (
    PartnerTypeId int IDENTITY(1,1) PRIMARY KEY,
    TypeName nvarchar(100) NOT NULL UNIQUE
);

CREATE TABLE dbo.Partners (
    PartnerId int IDENTITY(1,1) PRIMARY KEY,
    PartnerTypeId int NOT NULL,
    PartnerName nvarchar(200) NOT NULL,
    DirectorName nvarchar(200) NOT NULL,
    AddressLine nvarchar(300) NULL,
    RatingValue int NOT NULL CONSTRAINT CK_Partners_RatingValue CHECK (RatingValue >= 0),
    Phone nvarchar(30) NULL,
    Email nvarchar(200) NULL,
    CONSTRAINT FK_Partners_Types FOREIGN KEY (PartnerTypeId) REFERENCES dbo.PartnerTypes(PartnerTypeId)
);

CREATE TABLE dbo.Products (
    ProductId int IDENTITY(1,1) PRIMARY KEY,
    ProductName nvarchar(200) NOT NULL UNIQUE,
    PartnerMinPrice decimal(18,2) NOT NULL CONSTRAINT CK_Products_PartnerMinPrice CHECK (PartnerMinPrice >= 0)
);

CREATE TABLE dbo.PartnerRequests (
    PartnerRequestId int IDENTITY(1,1) PRIMARY KEY,
    PartnerId int NOT NULL,
    CreatedAt date NOT NULL,
    StatusName nvarchar(100) NOT NULL,
    CONSTRAINT FK_PartnerRequests_Partners FOREIGN KEY (PartnerId) REFERENCES dbo.Partners(PartnerId)
);

CREATE TABLE dbo.PartnerRequestItems (
    PartnerRequestItemId int IDENTITY(1,1) PRIMARY KEY,
    PartnerRequestId int NOT NULL,
    ProductId int NOT NULL,
    Quantity int NOT NULL CONSTRAINT CK_PartnerRequestItems_Quantity CHECK (Quantity > 0),
    CONSTRAINT FK_PartnerRequestItems_Requests FOREIGN KEY (PartnerRequestId) REFERENCES dbo.PartnerRequests(PartnerRequestId) ON DELETE CASCADE,
    CONSTRAINT FK_PartnerRequestItems_Products FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId)
);

CREATE VIEW dbo.v_MainRecords AS
SELECT
    r.PartnerRequestId AS RecordId,
    p.PartnerName AS Title,
    p.DirectorName AS Subtitle,
    CONCAT(N'Продукция: ', COUNT(i.PartnerRequestItemId)) AS Description,
    r.StatusName AS StatusText,
    CONVERT(nvarchar(10), r.CreatedAt, 104) AS DateText,
    CAST(SUM(pr.PartnerMinPrice * i.Quantity) AS decimal(18,2)) AS NumericValue
FROM dbo.PartnerRequests r
INNER JOIN dbo.Partners p ON p.PartnerId = r.PartnerId
INNER JOIN dbo.PartnerRequestItems i ON i.PartnerRequestId = r.PartnerRequestId
INNER JOIN dbo.Products pr ON pr.ProductId = i.ProductId
GROUP BY r.PartnerRequestId, p.PartnerName, p.DirectorName, r.StatusName, r.CreatedAt;
GO
