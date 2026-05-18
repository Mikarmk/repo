USE master;
GO
IF DB_ID(N'SweetsProductionDemo') IS NULL
BEGIN
    CREATE DATABASE [SweetsProductionDemo];
END;
GO
USE [SweetsProductionDemo];
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

CREATE TABLE dbo.Buyers (
    BuyerId int IDENTITY(1,1) PRIMARY KEY,
    UserId int NULL,
    BuyerName nvarchar(200) NOT NULL,
    CompanyName nvarchar(200) NULL,
    IsWholesale bit NOT NULL,
    CONSTRAINT FK_Buyers_AppUsers FOREIGN KEY (UserId) REFERENCES dbo.AppUsers(UserId)
);

CREATE TABLE dbo.Products (
    ProductId int IDENTITY(1,1) PRIMARY KEY,
    ProductName nvarchar(200) NOT NULL UNIQUE,
    ProductType nvarchar(100) NOT NULL,
    UnitPrice decimal(18,2) NOT NULL CONSTRAINT CK_Products_UnitPrice CHECK (UnitPrice >= 0),
    StockQuantity int NOT NULL CONSTRAINT CK_Products_StockQuantity CHECK (StockQuantity >= 0)
);

CREATE TABLE dbo.RawMaterials (
    RawMaterialId int IDENTITY(1,1) PRIMARY KEY,
    MaterialName nvarchar(200) NOT NULL UNIQUE,
    UnitName nvarchar(50) NOT NULL,
    StockQuantity decimal(18,2) NOT NULL CONSTRAINT CK_RawMaterials_StockQuantity CHECK (StockQuantity >= 0)
);

CREATE TABLE dbo.ProductMaterials (
    ProductMaterialId int IDENTITY(1,1) PRIMARY KEY,
    ProductId int NOT NULL,
    RawMaterialId int NOT NULL,
    QuantityPerUnit decimal(18,3) NOT NULL CONSTRAINT CK_ProductMaterials_QuantityPerUnit CHECK (QuantityPerUnit > 0),
    CONSTRAINT UQ_ProductMaterials UNIQUE (ProductId, RawMaterialId),
    CONSTRAINT FK_ProductMaterials_Products FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId),
    CONSTRAINT FK_ProductMaterials_RawMaterials FOREIGN KEY (RawMaterialId) REFERENCES dbo.RawMaterials(RawMaterialId)
);

CREATE TABLE dbo.Orders (
    OrderId int IDENTITY(1,1) PRIMARY KEY,
    OrderNumber int NOT NULL UNIQUE,
    OrderDate date NOT NULL,
    ShipDate date NULL,
    BuyerId int NOT NULL,
    ManagerUserId int NULL,
    StorekeeperUserId int NULL,
    StatusName nvarchar(100) NOT NULL,
    CONSTRAINT FK_Orders_Buyers FOREIGN KEY (BuyerId) REFERENCES dbo.Buyers(BuyerId),
    CONSTRAINT FK_Orders_Managers FOREIGN KEY (ManagerUserId) REFERENCES dbo.AppUsers(UserId),
    CONSTRAINT FK_Orders_Storekeepers FOREIGN KEY (StorekeeperUserId) REFERENCES dbo.AppUsers(UserId)
);

CREATE TABLE dbo.OrderItems (
    OrderItemId int IDENTITY(1,1) PRIMARY KEY,
    OrderId int NOT NULL,
    ProductId int NOT NULL,
    Quantity int NOT NULL CONSTRAINT CK_OrderItems_Quantity CHECK (Quantity > 0),
    UnitPrice decimal(18,2) NOT NULL CONSTRAINT CK_OrderItems_UnitPrice CHECK (UnitPrice >= 0),
    CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (OrderId) REFERENCES dbo.Orders(OrderId) ON DELETE CASCADE,
    CONSTRAINT FK_OrderItems_Products FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId)
);

CREATE VIEW dbo.v_MainRecords AS
SELECT
    o.OrderId AS RecordId,
    CONCAT(N'Заказ №', o.OrderNumber) AS Title,
    b.BuyerName AS Subtitle,
    ISNULL(b.CompanyName, N'Розничный покупатель') AS Description,
    o.StatusName AS StatusText,
    CONVERT(nvarchar(10), o.OrderDate, 104) AS DateText,
    CAST(SUM(oi.Quantity * oi.UnitPrice) AS decimal(18,2)) AS NumericValue
FROM dbo.Orders o
INNER JOIN dbo.Buyers b ON b.BuyerId = o.BuyerId
INNER JOIN dbo.OrderItems oi ON oi.OrderId = o.OrderId
GROUP BY o.OrderId, o.OrderNumber, b.BuyerName, b.CompanyName, o.StatusName, o.OrderDate;
GO
