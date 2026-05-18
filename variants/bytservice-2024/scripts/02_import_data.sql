USE BytServiceDemo;
GO

SET NOCOUNT ON;
GO

DELETE FROM dbo.RequestStatusHistory;
DELETE FROM dbo.RequestAssistantMasters;
DELETE FROM dbo.RequestComments;
DELETE FROM dbo.RepairRequests;
DELETE FROM dbo.Users;
GO

SET IDENTITY_INSERT dbo.Users ON;
INSERT INTO dbo.Users (UserId, FullName, Phone, Login, PasswordHash, RoleId, IsActive)
SELECT 1, N'Трубин Никита Юрьевич', N'89210563128', N'kasoo', CONVERT(varchar(64), HASHBYTES('SHA2_256', N'root'), 2), RoleId, 1 FROM dbo.Roles WHERE Code = N'QUALITY_MANAGER'
UNION ALL
SELECT 2, N'Мурашов Андрей Юрьевич', N'89535078985', N'murashov123', CONVERT(varchar(64), HASHBYTES('SHA2_256', N'qwerty'), 2), RoleId, 1 FROM dbo.Roles WHERE Code = N'MASTER'
UNION ALL
SELECT 3, N'Степанов Андрей Викторович', N'89210673849', N'test1', CONVERT(varchar(64), HASHBYTES('SHA2_256', N'test1'), 2), RoleId, 1 FROM dbo.Roles WHERE Code = N'MASTER'
UNION ALL
SELECT 4, N'Перина Анастасия Денисовна', N'89990563748', N'perinaAD', CONVERT(varchar(64), HASHBYTES('SHA2_256', N'250519'), 2), RoleId, 1 FROM dbo.Roles WHERE Code = N'OPERATOR'
UNION ALL
SELECT 5, N'Мажитова Ксения Сергеевна', N'89994563847', N'krutiha1234567', CONVERT(varchar(64), HASHBYTES('SHA2_256', N'1234567890'), 2), RoleId, 1 FROM dbo.Roles WHERE Code = N'OPERATOR'
UNION ALL
SELECT 6, N'Семенова Ясмина Марковна', N'89994563847', N'login1', CONVERT(varchar(64), HASHBYTES('SHA2_256', N'pass1'), 2), RoleId, 1 FROM dbo.Roles WHERE Code = N'MASTER'
UNION ALL
SELECT 7, N'Баранова Эмилия Марковна', N'89994563841', N'login2', CONVERT(varchar(64), HASHBYTES('SHA2_256', N'pass2'), 2), RoleId, 1 FROM dbo.Roles WHERE Code = N'CLIENT'
UNION ALL
SELECT 8, N'Егорова Алиса Платоновна', N'89994563842', N'login3', CONVERT(varchar(64), HASHBYTES('SHA2_256', N'pass3'), 2), RoleId, 1 FROM dbo.Roles WHERE Code = N'CLIENT'
UNION ALL
SELECT 9, N'Титов Максим Иванович', N'89994563843', N'login4', CONVERT(varchar(64), HASHBYTES('SHA2_256', N'pass4'), 2), RoleId, 1 FROM dbo.Roles WHERE Code = N'CLIENT'
UNION ALL
SELECT 10, N'Иванов Марк Максимович', N'89994563844', N'login5', CONVERT(varchar(64), HASHBYTES('SHA2_256', N'pass5'), 2), RoleId, 1 FROM dbo.Roles WHERE Code = N'MASTER'
UNION ALL
SELECT 11, N'Демидова Ольга Сергеевна', N'89990000001', N'quality.demo', CONVERT(varchar(64), HASHBYTES('SHA2_256', N'Quality2024!'), 2), RoleId, 1 FROM dbo.Roles WHERE Code = N'QUALITY_MANAGER';
SET IDENTITY_INSERT dbo.Users OFF;
GO

SET IDENTITY_INSERT dbo.RepairRequests ON;
INSERT INTO dbo.RepairRequests
(
    RequestId,
    RequestNumber,
    CreatedAt,
    ApplianceType,
    ApplianceModel,
    ProblemDescription,
    StatusId,
    ClientId,
    AssignedMasterId,
    PlannedCompletionDate,
    ExtendedUntil,
    ExtensionApprovedByClient,
    CompletionDate,
    RepairPartsUsed,
    CreatedByUserId,
    QualityManagerId
)
SELECT
    1,
    N'REQ-2023-0001',
    '2023-06-06',
    N'Фен',
    N'Ладомир ТА112 белый',
    N'Перестал работать',
    statusLookup.StatusId,
    7,
    2,
    '2023-06-11',
    NULL,
    0,
    NULL,
    NULL,
    4,
    1
FROM dbo.RequestStatuses statusLookup
WHERE statusLookup.Code = N'IN_PROGRESS'
UNION ALL
SELECT
    2, N'REQ-2023-0002', '2023-05-05', N'Тостер', N'Redmond RT-437 черный',
    N'Перестал работать', statusLookup.StatusId, 7, 3, '2023-05-10', NULL, 0, NULL, NULL, 4, 1
FROM dbo.RequestStatuses statusLookup WHERE statusLookup.Code = N'IN_PROGRESS'
UNION ALL
SELECT
    3, N'REQ-2022-0003', '2022-07-07', N'Холодильник', N'Indesit DS 316 W белый',
    N'Не морозит одна из камер холодильника', statusLookup.StatusId, 8, 2, '2022-07-12', NULL, 0, '2023-01-01', NULL, 5, 1
FROM dbo.RequestStatuses statusLookup WHERE statusLookup.Code = N'READY'
UNION ALL
SELECT
    4, N'REQ-2023-0004', '2023-08-02', N'Стиральная машина', N'DEXP WM-F610NTMA/WW белый',
    N'Перестали работать многие режимы стирки', statusLookup.StatusId, 8, NULL, '2023-08-07', NULL, 0, NULL, NULL, 5, NULL
FROM dbo.RequestStatuses statusLookup WHERE statusLookup.Code = N'NEW'
UNION ALL
SELECT
    5, N'REQ-2023-0005', '2023-08-02', N'Мультиварка', N'Redmond RMC-M95 черный',
    N'Перестала включаться', statusLookup.StatusId, 9, NULL, '2023-08-07', NULL, 0, NULL, NULL, 4, NULL
FROM dbo.RequestStatuses statusLookup WHERE statusLookup.Code = N'NEW'
UNION ALL
SELECT
    6, N'REQ-2023-0006', '2023-08-02', N'Фен', N'Ладомир ТА113 чёрный',
    N'Перестал работать', statusLookup.StatusId, 7, 2, '2023-08-07', NULL, 0, '2023-08-03', NULL, 4, 1
FROM dbo.RequestStatuses statusLookup WHERE statusLookup.Code = N'READY'
UNION ALL
SELECT
    7, N'REQ-2023-0007', '2023-07-09', N'Холодильник', N'Indesit DS 314 W серый',
    N'Гудит, но не замораживает', statusLookup.StatusId, 8, 2, '2023-07-14', '2023-08-03', 1, '2023-08-03',
    N'Мотор обдува морозильной камеры холодильника', 5, 11
FROM dbo.RequestStatuses statusLookup WHERE statusLookup.Code = N'READY';
SET IDENTITY_INSERT dbo.RepairRequests OFF;
GO

SET IDENTITY_INSERT dbo.RequestComments ON;
INSERT INTO dbo.RequestComments (CommentId, RequestId, MasterId, CommentText, CreatedAt)
VALUES
    (1, 1, 2, N'Интересная поломка', '2023-06-07T10:00:00'),
    (2, 2, 3, N'Очень странно, будем разбираться!', '2023-05-06T11:20:00'),
    (3, 7, 2, N'Скорее всего потребуется мотор обдува!', '2023-07-12T09:30:00'),
    (4, 1, 2, N'Интересная проблема', '2023-06-08T14:15:00'),
    (5, 6, 3, N'Очень странно, будем разбираться!', '2023-08-02T17:40:00');
SET IDENTITY_INSERT dbo.RequestComments OFF;
GO

INSERT INTO dbo.RequestAssistantMasters (RequestId, MasterId, AssignedByQualityManagerId)
VALUES (7, 10, 11);
GO

INSERT INTO dbo.RequestStatusHistory (RequestId, OldStatusId, NewStatusId, ChangedByUserId, ChangedAt, ChangeComment)
SELECT rr.RequestId, NULL, rr.StatusId, rr.CreatedByUserId, DATEADD(HOUR, 9, CAST(rr.CreatedAt AS datetime2(0))), N'Импорт стартового состояния'
FROM dbo.RepairRequests rr;
GO

