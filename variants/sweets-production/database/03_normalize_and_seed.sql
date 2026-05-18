USE [SweetsProductionDemo];
GO

INSERT INTO dbo.Roles (Code, Name) VALUES
(N'DIRECTOR', N'Директор'),
(N'MANAGER', N'Менеджер'),
(N'BUYER', N'Покупатель'),
(N'STOREKEEPER', N'Кладовщик');

INSERT INTO dbo.AppUsers (Login, PasswordHash, FullName, Phone, Email, RoleId)
SELECT N'director', N'director', N'Директор Демонстрационный', N'+7 902 000-00-01', N'director@demo.local', RoleId FROM dbo.Roles WHERE Code = N'DIRECTOR'
UNION ALL
SELECT N'manager', N'manager', N'Менеджер Демонстрационный', N'+7 902 000-00-02', N'manager@demo.local', RoleId FROM dbo.Roles WHERE Code = N'MANAGER'
UNION ALL
SELECT N'storekeeper', N'storekeeper', N'Кладовщик Демонстрационный', N'+7 902 000-00-03', N'storekeeper@demo.local', RoleId FROM dbo.Roles WHERE Code = N'STOREKEEPER'
UNION ALL
SELECT N'buyer', N'buyer', N'Покупатель Демонстрационный', N'+7 902 000-00-04', N'buyer@demo.local', RoleId FROM dbo.Roles WHERE Code = N'BUYER';

INSERT INTO dbo.Buyers (UserId, BuyerName, CompanyName, IsWholesale)
SELECT UserId, N'Покупатель Демонстрационный', NULL, 0 FROM dbo.AppUsers WHERE Login = N'buyer';

INSERT INTO dbo.Products (ProductName, ProductType, UnitPrice, StockQuantity)
VALUES (N'Шоколадный батончик', N'Сладость', 120.00, 1000), (N'Карамель', N'Конфета', 60.00, 5000);

INSERT INTO dbo.RawMaterials (MaterialName, UnitName, StockQuantity)
VALUES (N'Сахар', N'кг', 300.00), (N'Какао', N'кг', 120.00);

INSERT INTO dbo.ProductMaterials (ProductId, RawMaterialId, QuantityPerUnit)
SELECT p.ProductId, m.RawMaterialId, 0.100 FROM dbo.Products p CROSS JOIN dbo.RawMaterials m WHERE p.ProductName = N'Шоколадный батончик' AND m.MaterialName = N'Сахар';

INSERT INTO dbo.Orders (OrderNumber, OrderDate, ShipDate, BuyerId, ManagerUserId, StorekeeperUserId, StatusName)
SELECT 1, '2024-05-01', '2024-05-02', b.BuyerId, m.UserId, s.UserId, N'Новый'
FROM dbo.Buyers b CROSS JOIN dbo.AppUsers m CROSS JOIN dbo.AppUsers s
WHERE b.BuyerName = N'Покупатель Демонстрационный' AND m.Login = N'manager' AND s.Login = N'storekeeper';

INSERT INTO dbo.OrderItems (OrderId, ProductId, Quantity, UnitPrice)
SELECT o.OrderId, p.ProductId, 10, p.UnitPrice FROM dbo.Orders o CROSS JOIN dbo.Products p WHERE o.OrderNumber = 1 AND p.ProductName = N'Шоколадный батончик';
GO
