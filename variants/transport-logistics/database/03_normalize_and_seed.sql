USE [TransportLogisticsDemo];
GO

INSERT INTO dbo.Roles (Code, Name) VALUES
(N'DIRECTOR', N'Директор'),
(N'MANAGER', N'Менеджер'),
(N'PRODUCER', N'Производитель'),
(N'CONSUMER', N'Потребитель'),
(N'CARRIER', N'Перевозчик');

INSERT INTO dbo.AppUsers (Login, PasswordHash, FullName, Phone, Email, RoleId)
SELECT N'director', N'director', N'Директор Демонстрационный', N'+7 900 000-00-01', N'director@demo.local', RoleId FROM dbo.Roles WHERE Code = N'DIRECTOR'
UNION ALL
SELECT N'manager', N'manager', N'Менеджер Демонстрационный', N'+7 900 000-00-02', N'manager@demo.local', RoleId FROM dbo.Roles WHERE Code = N'MANAGER'
UNION ALL
SELECT N'carrier', N'carrier', N'Перевозчик Демонстрационный', N'+7 900 000-00-03', N'carrier@demo.local', RoleId FROM dbo.Roles WHERE Code = N'CARRIER';

INSERT INTO dbo.Manufacturers (CompanyName, DirectorName, Email, AddressLine, Phone)
VALUES (N'Дилегация', N'Миронов Арсений Романович', N'mironov@example.com', N'Москва', N'+7 900 111-11-11');

INSERT INTO dbo.Consumers (CompanyName, DirectorName, Email, AddressLine, Phone, IsCompany)
VALUES (N'ООО "Единый"', N'Орехова Николь Дмитриевна', N'consumer@example.com', N'Суровый', N'+7 900 222-22-22', 1);

INSERT INTO dbo.Carriers (CompanyName, DirectorName, Email, AddressLine, Phone)
VALUES (N'ИП Минутка', N'Яковлева Марина Всеволодовна', N'carrier@example.com', N'Казань', N'+7 900 333-33-33');

INSERT INTO dbo.Drivers (CarrierId, FullName, Email, Phone, GenderName)
SELECT CarrierId, N'Бобров Терентий Созонович', N'driver1@example.com', N'+7 900 444-44-44', N'м' FROM dbo.Carriers WHERE CompanyName = N'ИП Минутка';

INSERT INTO dbo.Orders (OrderNumber, OrderDate, DispatchDate, TransitDays, ManufacturerId, ConsumerId, CarrierId, ManagerUserId, StatusName)
SELECT 1, '2024-05-01', '2024-05-02', 2, m.ManufacturerId, c.ConsumerId, cr.CarrierId, u.UserId, N'Создан'
FROM dbo.Manufacturers m, dbo.Consumers c, dbo.Carriers cr, dbo.AppUsers u
WHERE m.CompanyName = N'Дилегация' AND c.CompanyName = N'ООО "Единый"' AND cr.CompanyName = N'ИП Минутка' AND u.Login = N'manager';

INSERT INTO dbo.OrderDrivers (OrderId, DriverId, DriverSlot)
SELECT o.OrderId, d.DriverId, 1 FROM dbo.Orders o CROSS JOIN dbo.Drivers d WHERE o.OrderNumber = 1;
GO
