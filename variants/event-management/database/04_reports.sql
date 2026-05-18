USE [EventManagementDemo];
GO

-- Средний рейтинг услуг
SELECT * FROM dbo.v_MainRecords;

-- Количество заявок по статусам
SELECT StatusText, COUNT(*) AS TotalCount, AVG(NumericValue) AS AverageValue FROM dbo.v_MainRecords GROUP BY StatusText;

-- Выручка по типам мероприятий
SELECT TOP (10) Title, NumericValue FROM dbo.v_MainRecords ORDER BY NumericValue DESC;
GO
