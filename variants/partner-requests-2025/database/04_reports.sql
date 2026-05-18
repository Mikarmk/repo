USE [PartnerRequests2025Demo];
GO

-- Стоимость заявки
SELECT * FROM dbo.v_MainRecords;

-- Список продукции по заявке
SELECT StatusText, COUNT(*) AS TotalCount, AVG(NumericValue) AS AverageValue FROM dbo.v_MainRecords GROUP BY StatusText;
GO
