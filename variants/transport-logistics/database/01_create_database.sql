USE master;
GO
IF DB_ID(N'TransportLogisticsDemo') IS NULL
BEGIN
    CREATE DATABASE [TransportLogisticsDemo];
END;
GO
USE [TransportLogisticsDemo];
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

CREATE TABLE dbo.Manufacturers (
    ManufacturerId int IDENTITY(1,1) PRIMARY KEY,
    CompanyName nvarchar(200) NOT NULL UNIQUE,
    DirectorName nvarchar(200) NOT NULL,
    Email nvarchar(200) NULL,
    AddressLine nvarchar(300) NULL,
    Phone nvarchar(30) NULL
);

CREATE TABLE dbo.Consumers (
    ConsumerId int IDENTITY(1,1) PRIMARY KEY,
    CompanyName nvarchar(200) NOT NULL UNIQUE,
    DirectorName nvarchar(200) NOT NULL,
    Email nvarchar(200) NULL,
    AddressLine nvarchar(300) NULL,
    Phone nvarchar(30) NULL,
    IsCompany bit NOT NULL CONSTRAINT DF_Consumers_IsCompany DEFAULT (1)
);

CREATE TABLE dbo.Carriers (
    CarrierId int IDENTITY(1,1) PRIMARY KEY,
    CompanyName nvarchar(200) NOT NULL UNIQUE,
    DirectorName nvarchar(200) NOT NULL,
    Email nvarchar(200) NULL,
    AddressLine nvarchar(300) NULL,
    Phone nvarchar(30) NULL
);

CREATE TABLE dbo.Drivers (
    DriverId int IDENTITY(1,1) PRIMARY KEY,
    CarrierId int NOT NULL,
    FullName nvarchar(200) NOT NULL,
    Email nvarchar(200) NULL,
    Phone nvarchar(30) NULL,
    GenderName nvarchar(20) NULL,
    CONSTRAINT FK_Drivers_Carriers FOREIGN KEY (CarrierId) REFERENCES dbo.Carriers(CarrierId)
);

CREATE TABLE dbo.Orders (
    OrderId int IDENTITY(1,1) PRIMARY KEY,
    OrderNumber int NOT NULL UNIQUE,
    OrderDate date NOT NULL,
    DispatchDate date NULL,
    TransitDays int NOT NULL CONSTRAINT CK_Orders_TransitDays CHECK (TransitDays >= 0),
    ManufacturerId int NOT NULL,
    ConsumerId int NOT NULL,
    CarrierId int NULL,
    ManagerUserId int NULL,
    StatusName nvarchar(100) NOT NULL,
    CONSTRAINT FK_Orders_Manufacturers FOREIGN KEY (ManufacturerId) REFERENCES dbo.Manufacturers(ManufacturerId),
    CONSTRAINT FK_Orders_Consumers FOREIGN KEY (ConsumerId) REFERENCES dbo.Consumers(ConsumerId),
    CONSTRAINT FK_Orders_Carriers FOREIGN KEY (CarrierId) REFERENCES dbo.Carriers(CarrierId),
    CONSTRAINT FK_Orders_Managers FOREIGN KEY (ManagerUserId) REFERENCES dbo.AppUsers(UserId)
);

CREATE TABLE dbo.OrderDrivers (
    OrderDriverId int IDENTITY(1,1) PRIMARY KEY,
    OrderId int NOT NULL,
    DriverId int NOT NULL,
    DriverSlot tinyint NOT NULL CONSTRAINT CK_OrderDrivers_DriverSlot CHECK (DriverSlot IN (1, 2)),
    CONSTRAINT UQ_OrderDrivers UNIQUE (OrderId, DriverSlot),
    CONSTRAINT FK_OrderDrivers_Orders FOREIGN KEY (OrderId) REFERENCES dbo.Orders(OrderId) ON DELETE CASCADE,
    CONSTRAINT FK_OrderDrivers_Drivers FOREIGN KEY (DriverId) REFERENCES dbo.Drivers(DriverId)
);

CREATE VIEW dbo.v_MainRecords AS
SELECT
    o.OrderId AS RecordId,
    CONCAT(N'Заказ №', o.OrderNumber) AS Title,
    c.CompanyName AS Subtitle,
    CONCAT(m.CompanyName, N' -> ', ISNULL(cr.CompanyName, N'не назначен')) AS Description,
    o.StatusName AS StatusText,
    CONVERT(nvarchar(10), o.OrderDate, 104) AS DateText,
    CAST(o.TransitDays AS decimal(18,2)) AS NumericValue
FROM dbo.Orders o
INNER JOIN dbo.Manufacturers m ON m.ManufacturerId = o.ManufacturerId
INNER JOIN dbo.Consumers c ON c.ConsumerId = o.ConsumerId
LEFT JOIN dbo.Carriers cr ON cr.CarrierId = o.CarrierId;
GO
