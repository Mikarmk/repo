USE [FurnitureProducts2025Demo];
GO

INSERT INTO dbo.Roles (Code, Name) VALUES (N'MANAGER', N'Менеджер'), (N'TECHNOLOGIST', N'Технолог');
INSERT INTO dbo.AppUsers (Login, PasswordHash, FullName, Phone, Email, RoleId)
SELECT N'manager', N'manager', N'Менеджер мебели', N'+7 905 000-00-01', N'managerf@demo.local', RoleId FROM dbo.Roles WHERE Code = N'MANAGER'
UNION ALL
SELECT N'tech', N'tech', N'Технолог мебели', N'+7 905 000-00-02', N'techf@demo.local', RoleId FROM dbo.Roles WHERE Code = N'TECHNOLOGIST';
INSERT INTO dbo.ProductTypes (TypeName, TypeCoefficient) VALUES (N'Кухонная мебель', 1.50), (N'Шкафы', 1.20);
INSERT INTO dbo.Materials (MaterialName, LossPercent) VALUES (N'Массив дуба', 0.03), (N'ЛДСП', 0.05);
INSERT INTO dbo.Products (ArticleNumber, ProductTypeId, ProductName, PartnerMinPrice, MainMaterialId)
SELECT TOP (1) N'ART-001', pt.ProductTypeId, N'Шкаф Классик', 25000.00, m.MaterialId FROM dbo.ProductTypes pt CROSS JOIN dbo.Materials m WHERE pt.TypeName = N'Шкафы' AND m.MaterialName = N'ЛДСП';
INSERT INTO dbo.Workshops (WorkshopName, EmployeesCount) VALUES (N'Распиловочный', 4), (N'Сборочный', 6);
INSERT INTO dbo.ProductWorkshops (ProductId, WorkshopId, ProductionMinutes)
SELECT TOP (1) p.ProductId, w.WorkshopId, 120 FROM dbo.Products p CROSS JOIN dbo.Workshops w WHERE w.WorkshopName = N'Распиловочный';
GO
