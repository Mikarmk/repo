USE [PartnerOrdersDemo];
GO

INSERT INTO dbo.Roles (Code, Name) VALUES
(N'MANAGER', N'Менеджер'),
(N'ANALYST', N'Аналитик'),
(N'PARTNER', N'Партнер');

INSERT INTO dbo.AppUsers (Login, PasswordHash, FullName, Phone, Email, RoleId)
SELECT N'manager', N'manager', N'Менеджер Демонстрационный', N'+7 903 000-00-01', N'manager@demo.local', RoleId FROM dbo.Roles WHERE Code = N'MANAGER'
UNION ALL
SELECT N'analyst', N'analyst', N'Аналитик Демонстрационный', N'+7 903 000-00-02', N'analyst@demo.local', RoleId FROM dbo.Roles WHERE Code = N'ANALYST'
UNION ALL
SELECT N'partner', N'partner', N'Партнер Демонстрационный', N'+7 903 000-00-03', N'partner@demo.local', RoleId FROM dbo.Roles WHERE Code = N'PARTNER';

INSERT INTO dbo.PartnerTypes (TypeName) VALUES (N'ООО'), (N'ЗАО');
INSERT INTO dbo.ProductTypes (TypeName, TypeCoefficient) VALUES (N'Древесно-плитные материалы', 1.50), (N'Декоративные панели', 3.50), (N'Плитка', 5.25);
INSERT INTO dbo.MaterialTypes (TypeName, DefectPercent) VALUES (N'Тип материала 1', 0.002), (N'Тип материала 2', 0.005);
INSERT INTO dbo.Partners (PartnerTypeId, PartnerName, DirectorName, Email, Phone, LegalAddress, Inn, RatingValue)
SELECT TOP (1) pt.PartnerTypeId, N'Стройдвор', N'Андреева Ангелина Николаевна', N'angelina77@kart.ru', N'492 452 22 82', N'Московская область', N'9432455179', 5 FROM dbo.PartnerTypes pt WHERE pt.TypeName = N'ЗАО';
INSERT INTO dbo.Products (ProductTypeId, ProductName, ArticleNumber, PartnerMinPrice)
SELECT TOP (1) pt.ProductTypeId, N'Фанера ФСФ 1800х1200х27 мм бежевая береза', N'6549922', 5100 FROM dbo.ProductTypes pt WHERE pt.TypeName = N'Древесно-плитные материалы';
INSERT INTO dbo.PartnerRequests (PartnerId, CreatedAt, StatusName, RequestedByUserId)
SELECT p.PartnerId, '2024-05-01', N'Создана', u.UserId FROM dbo.Partners p CROSS JOIN dbo.AppUsers u WHERE p.PartnerName = N'Стройдвор' AND u.Login = N'manager';
INSERT INTO dbo.PartnerRequestItems (PartnerRequestId, ProductId, Quantity, UnitPrice)
SELECT r.PartnerRequestId, pr.ProductId, 1000, pr.PartnerMinPrice FROM dbo.PartnerRequests r CROSS JOIN dbo.Products pr;
GO
