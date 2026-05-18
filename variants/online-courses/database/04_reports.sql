USE [OnlineCoursesDemo];
GO

-- Количество записей по курсам
SELECT * FROM dbo.v_MainRecords;

-- Нагрузка преподавателей по расписанию
SELECT StatusText, COUNT(*) AS TotalCount, AVG(NumericValue) AS AverageValue FROM dbo.v_MainRecords GROUP BY StatusText;

-- Среднее число занятий по курсу
SELECT TOP (10) Title, NumericValue FROM dbo.v_MainRecords ORDER BY NumericValue DESC;
GO
