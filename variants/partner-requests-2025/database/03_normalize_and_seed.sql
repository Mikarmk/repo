USE [PartnerRequests2025Demo];
GO

INSERT INTO dbo.Roles (Code, Name) VALUES (N'MANAGER', N'Менеджер'), (N'PARTNER', N'Партнер');
INSERT INTO dbo.AppUsers (Login, PasswordHash, FullName, Phone, Email, RoleId)
SELECT N'manager', N'manager', N'Менеджер 2025', N'+7 904 000-00-01', N'manager2025@demo.local', RoleId FROM dbo.Roles WHERE Code = N'MANAGER'
UNION ALL
SELECT N'partner', N'partner', N'Партнер 2025', N'+7 904 000-00-02', N'partner2025@demo.local', RoleId FROM dbo.Roles WHERE Code = N'PARTNER';
INSERT INTO dbo.PartnerTypes (TypeName) VALUES (N'ООО');
INSERT INTO dbo.Partners (PartnerTypeId, PartnerName, DirectorName, AddressLine, RatingValue, Phone, Email)
SELECT PartnerTypeId, N'Партнер 2025', N'Директор 2025', N'Адрес 2025', 3, N'+7 904 111-11-11', N'p2025@demo.local' FROM dbo.PartnerTypes;
INSERT INTO dbo.Products (ProductName, PartnerMinPrice) VALUES (N'Тестовая продукция', 1000.00);
INSERT INTO dbo.PartnerRequests (PartnerId, CreatedAt, StatusName) SELECT PartnerId, '2025-05-01', N'Создана' FROM dbo.Partners;
INSERT INTO dbo.PartnerRequestItems (PartnerRequestId, ProductId, Quantity) SELECT TOP (1) r.PartnerRequestId, p.ProductId, 5 FROM dbo.PartnerRequests r CROSS JOIN dbo.Products p;
GO
