USE master;
GO

IF DB_ID(N'BytServiceDemo') IS NULL
BEGIN
    CREATE DATABASE BytServiceDemo;
END;
GO

USE BytServiceDemo;
GO

IF OBJECT_ID(N'dbo.RequestStatusHistory', N'U') IS NOT NULL DROP TABLE dbo.RequestStatusHistory;
IF OBJECT_ID(N'dbo.RequestAssistantMasters', N'U') IS NOT NULL DROP TABLE dbo.RequestAssistantMasters;
IF OBJECT_ID(N'dbo.RequestComments', N'U') IS NOT NULL DROP TABLE dbo.RequestComments;
IF OBJECT_ID(N'dbo.RepairRequests', N'U') IS NOT NULL DROP TABLE dbo.RepairRequests;
IF OBJECT_ID(N'dbo.Users', N'U') IS NOT NULL DROP TABLE dbo.Users;
IF OBJECT_ID(N'dbo.RequestStatuses', N'U') IS NOT NULL DROP TABLE dbo.RequestStatuses;
IF OBJECT_ID(N'dbo.Roles', N'U') IS NOT NULL DROP TABLE dbo.Roles;
GO

CREATE TABLE dbo.Roles
(
    RoleId int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Code nvarchar(50) NOT NULL UNIQUE,
    Name nvarchar(100) NOT NULL UNIQUE
);
GO

CREATE TABLE dbo.Users
(
    UserId int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    FullName nvarchar(200) NOT NULL,
    Phone nvarchar(20) NOT NULL,
    Login nvarchar(100) NOT NULL UNIQUE,
    PasswordHash varchar(64) NOT NULL,
    RoleId int NOT NULL,
    IsActive bit NOT NULL CONSTRAINT DF_Users_IsActive DEFAULT (1),
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleId) REFERENCES dbo.Roles (RoleId)
);
GO

CREATE TABLE dbo.RequestStatuses
(
    StatusId int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Code nvarchar(50) NOT NULL UNIQUE,
    Name nvarchar(100) NOT NULL UNIQUE
);
GO

CREATE TABLE dbo.RepairRequests
(
    RequestId int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    RequestNumber nvarchar(30) NOT NULL UNIQUE,
    CreatedAt date NOT NULL,
    ApplianceType nvarchar(100) NOT NULL,
    ApplianceModel nvarchar(200) NOT NULL,
    ProblemDescription nvarchar(1000) NOT NULL,
    StatusId int NOT NULL,
    ClientId int NOT NULL,
    AssignedMasterId int NULL,
    PlannedCompletionDate date NULL,
    ExtendedUntil date NULL,
    ExtensionApprovedByClient bit NOT NULL CONSTRAINT DF_RepairRequests_ExtensionApprovedByClient DEFAULT (0),
    CompletionDate date NULL,
    RepairPartsUsed nvarchar(1000) NULL,
    CreatedByUserId int NOT NULL,
    QualityManagerId int NULL,
    CONSTRAINT FK_RepairRequests_Statuses FOREIGN KEY (StatusId) REFERENCES dbo.RequestStatuses (StatusId),
    CONSTRAINT FK_RepairRequests_Clients FOREIGN KEY (ClientId) REFERENCES dbo.Users (UserId),
    CONSTRAINT FK_RepairRequests_Masters FOREIGN KEY (AssignedMasterId) REFERENCES dbo.Users (UserId),
    CONSTRAINT FK_RepairRequests_CreatedBy FOREIGN KEY (CreatedByUserId) REFERENCES dbo.Users (UserId),
    CONSTRAINT FK_RepairRequests_QualityManagers FOREIGN KEY (QualityManagerId) REFERENCES dbo.Users (UserId)
);
GO

CREATE TABLE dbo.RequestComments
(
    CommentId int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    RequestId int NOT NULL,
    MasterId int NOT NULL,
    CommentText nvarchar(1000) NOT NULL,
    CreatedAt datetime2(0) NOT NULL CONSTRAINT DF_RequestComments_CreatedAt DEFAULT (SYSDATETIME()),
    CONSTRAINT FK_RequestComments_Requests FOREIGN KEY (RequestId) REFERENCES dbo.RepairRequests (RequestId) ON DELETE CASCADE,
    CONSTRAINT FK_RequestComments_Masters FOREIGN KEY (MasterId) REFERENCES dbo.Users (UserId)
);
GO

CREATE TABLE dbo.RequestAssistantMasters
(
    RequestAssistantMasterId int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    RequestId int NOT NULL UNIQUE,
    MasterId int NOT NULL,
    AssignedByQualityManagerId int NOT NULL,
    AssignedAt datetime2(0) NOT NULL CONSTRAINT DF_RequestAssistantMasters_AssignedAt DEFAULT (SYSDATETIME()),
    CONSTRAINT FK_RequestAssistantMasters_Requests FOREIGN KEY (RequestId) REFERENCES dbo.RepairRequests (RequestId) ON DELETE CASCADE,
    CONSTRAINT FK_RequestAssistantMasters_Masters FOREIGN KEY (MasterId) REFERENCES dbo.Users (UserId),
    CONSTRAINT FK_RequestAssistantMasters_Managers FOREIGN KEY (AssignedByQualityManagerId) REFERENCES dbo.Users (UserId)
);
GO

CREATE TABLE dbo.RequestStatusHistory
(
    StatusHistoryId int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    RequestId int NOT NULL,
    OldStatusId int NULL,
    NewStatusId int NOT NULL,
    ChangedByUserId int NOT NULL,
    ChangedAt datetime2(0) NOT NULL CONSTRAINT DF_RequestStatusHistory_ChangedAt DEFAULT (SYSDATETIME()),
    ChangeComment nvarchar(300) NULL,
    CONSTRAINT FK_RequestStatusHistory_Requests FOREIGN KEY (RequestId) REFERENCES dbo.RepairRequests (RequestId) ON DELETE CASCADE,
    CONSTRAINT FK_RequestStatusHistory_OldStatuses FOREIGN KEY (OldStatusId) REFERENCES dbo.RequestStatuses (StatusId),
    CONSTRAINT FK_RequestStatusHistory_NewStatuses FOREIGN KEY (NewStatusId) REFERENCES dbo.RequestStatuses (StatusId),
    CONSTRAINT FK_RequestStatusHistory_Users FOREIGN KEY (ChangedByUserId) REFERENCES dbo.Users (UserId)
);
GO

CREATE INDEX IX_RepairRequests_ClientId ON dbo.RepairRequests (ClientId);
CREATE INDEX IX_RepairRequests_AssignedMasterId ON dbo.RepairRequests (AssignedMasterId);
CREATE INDEX IX_RepairRequests_StatusId ON dbo.RepairRequests (StatusId);
CREATE INDEX IX_RequestComments_RequestId ON dbo.RequestComments (RequestId);
GO

INSERT INTO dbo.Roles (Code, Name)
VALUES
    (N'OPERATOR', N'Оператор'),
    (N'MASTER', N'Мастер'),
    (N'CLIENT', N'Заказчик'),
    (N'QUALITY_MANAGER', N'Менеджер по качеству');
GO

INSERT INTO dbo.RequestStatuses (Code, Name)
VALUES
    (N'NEW', N'Новая заявка'),
    (N'IN_PROGRESS', N'В процессе ремонта'),
    (N'WAIT_PARTS', N'Ожидание запчастей'),
    (N'READY', N'Готова к выдаче');
GO

