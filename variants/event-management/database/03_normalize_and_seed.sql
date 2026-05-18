USE [EventManagementDemo];
GO

INSERT INTO dbo.Roles (Code, Name) VALUES
(N'DIRECTOR', N'Директор'),
(N'MANAGER', N'Менеджер'),
(N'CLIENT', N'Клиент'),
(N'GUEST', N'Гость');

INSERT INTO dbo.AppUsers (Login, PasswordHash, FullName, Phone, Email, RoleId)
SELECT N'director', N'director', N'Директор Демонстрационный', N'+7 901 000-00-01', N'director@demo.local', RoleId FROM dbo.Roles WHERE Code = N'DIRECTOR'
UNION ALL
SELECT N'manager', N'manager', N'Менеджер Демонстрационный', N'+7 901 000-00-02', N'manager@demo.local', RoleId FROM dbo.Roles WHERE Code = N'MANAGER'
UNION ALL
SELECT N'client', N'client', N'Клиент Демонстрационный', N'+7 901 000-00-03', N'client@demo.local', RoleId FROM dbo.Roles WHERE Code = N'CLIENT';

INSERT INTO dbo.Services (ServiceName, BasePrice, DescriptionText)
VALUES (N'Свадьба', 150000, N'Организация свадебного мероприятия'), (N'Юбилей', 85000, N'Праздничное мероприятие'), (N'День рождения', 50000, N'Семейный праздник');

INSERT INTO dbo.EventOrders (ClientUserId, ServiceId, EventTypeName, OrderDate, EventDate, StatusName, TotalPrice, ManagerUserId)
SELECT c.UserId, s.ServiceId, N'Юбилей', '2024-05-01', '2024-06-15', N'Согласование', 85000, m.UserId
FROM dbo.AppUsers c CROSS JOIN dbo.Services s CROSS JOIN dbo.AppUsers m
WHERE c.Login = N'client' AND s.ServiceName = N'Юбилей' AND m.Login = N'manager';

INSERT INTO dbo.Reviews (EventOrderId, ClientUserId, RatingValue, ReviewText)
SELECT e.EventOrderId, c.UserId, 5, N'Все прошло отлично.'
FROM dbo.EventOrders e CROSS JOIN dbo.AppUsers c WHERE c.Login = N'client';
GO
