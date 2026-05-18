USE [TransportLogisticsDemo];
GO

-- Количество заказов по перевозчикам
SELECT * FROM dbo.v_MainRecords;

-- Среднее число дней в пути
SELECT StatusText, COUNT(*) AS TotalCount, AVG(NumericValue) AS AverageValue FROM dbo.v_MainRecords GROUP BY StatusText;

-- Количество заказов по производителям
SELECT TOP (10) Title, NumericValue FROM dbo.v_MainRecords ORDER BY NumericValue DESC;
GO
