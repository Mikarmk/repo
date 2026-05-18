USE [FurnitureProducts2025Demo];
GO

-- Суммарное время производства продукта
SELECT * FROM dbo.v_MainRecords;

-- Список цехов по продукту
SELECT StatusText, COUNT(*) AS TotalCount, AVG(NumericValue) AS AverageValue FROM dbo.v_MainRecords GROUP BY StatusText;
GO
