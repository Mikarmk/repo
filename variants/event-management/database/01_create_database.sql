USE master;
GO
IF DB_ID(N'EventManagementDemo') IS NULL
BEGIN
    CREATE DATABASE [EventManagementDemo];
END;
GO
USE [EventManagementDemo];
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

CREATE TABLE dbo.Services (
    ServiceId int IDENTITY(1,1) PRIMARY KEY,
    ServiceName nvarchar(200) NOT NULL UNIQUE,
    BasePrice decimal(18,2) NOT NULL CONSTRAINT CK_Services_BasePrice CHECK (BasePrice >= 0),
    DescriptionText nvarchar(500) NULL
);

CREATE TABLE dbo.EventOrders (
    EventOrderId int IDENTITY(1,1) PRIMARY KEY,
    ClientUserId int NOT NULL,
    ServiceId int NOT NULL,
    EventTypeName nvarchar(100) NOT NULL,
    OrderDate date NOT NULL,
    EventDate date NOT NULL,
    StatusName nvarchar(100) NOT NULL,
    TotalPrice decimal(18,2) NOT NULL CONSTRAINT CK_EventOrders_TotalPrice CHECK (TotalPrice >= 0),
    ManagerUserId int NULL,
    CONSTRAINT FK_EventOrders_Clients FOREIGN KEY (ClientUserId) REFERENCES dbo.AppUsers(UserId),
    CONSTRAINT FK_EventOrders_Services FOREIGN KEY (ServiceId) REFERENCES dbo.Services(ServiceId),
    CONSTRAINT FK_EventOrders_Managers FOREIGN KEY (ManagerUserId) REFERENCES dbo.AppUsers(UserId)
);

CREATE TABLE dbo.Reviews (
    ReviewId int IDENTITY(1,1) PRIMARY KEY,
    EventOrderId int NOT NULL,
    ClientUserId int NOT NULL,
    RatingValue int NOT NULL CONSTRAINT CK_Reviews_RatingValue CHECK (RatingValue BETWEEN 1 AND 5),
    ReviewText nvarchar(1000) NULL,
    IsBlocked bit NOT NULL CONSTRAINT DF_Reviews_IsBlocked DEFAULT (0),
    CONSTRAINT FK_Reviews_EventOrders FOREIGN KEY (EventOrderId) REFERENCES dbo.EventOrders(EventOrderId) ON DELETE CASCADE,
    CONSTRAINT FK_Reviews_Clients FOREIGN KEY (ClientUserId) REFERENCES dbo.AppUsers(UserId)
);

CREATE VIEW dbo.v_MainRecords AS
SELECT
    e.EventOrderId AS RecordId,
    e.EventTypeName AS Title,
    c.FullName AS Subtitle,
    s.ServiceName AS Description,
    e.StatusName AS StatusText,
    CONVERT(nvarchar(10), e.EventDate, 104) AS DateText,
    e.TotalPrice AS NumericValue
FROM dbo.EventOrders e
INNER JOIN dbo.AppUsers c ON c.UserId = e.ClientUserId
INNER JOIN dbo.Services s ON s.ServiceId = e.ServiceId;
GO
