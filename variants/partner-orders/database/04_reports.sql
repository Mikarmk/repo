USE [PartnerOrdersDemo];
GO

-- Общая стоимость партнерских заявок
SELECT * FROM dbo.v_MainRecords;

-- Список партнеров по рейтингу
SELECT StatusText, COUNT(*) AS TotalCount, AVG(NumericValue) AS AverageValue FROM dbo.v_MainRecords GROUP BY StatusText;

-- Топ продукции в заявках
SELECT TOP (10) Title, NumericValue FROM dbo.v_MainRecords ORDER BY NumericValue DESC;
GO
