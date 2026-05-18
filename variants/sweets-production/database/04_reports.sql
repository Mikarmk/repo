USE [SweetsProductionDemo];
GO

-- Выручка по заказам
SELECT * FROM dbo.v_MainRecords;

-- Остатки сырья
SELECT StatusText, COUNT(*) AS TotalCount, AVG(NumericValue) AS AverageValue FROM dbo.v_MainRecords GROUP BY StatusText;

-- Популярные продукты
SELECT TOP (10) Title, NumericValue FROM dbo.v_MainRecords ORDER BY NumericValue DESC;
GO
