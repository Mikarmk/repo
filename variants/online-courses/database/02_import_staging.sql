USE [OnlineCoursesDemo];
GO

-- Staging tables for exam import. Replace this section with BULK INSERT / OPENROWSET on the exam workstation.
IF OBJECT_ID(N'dbo.StagingImportStudents', N'U') IS NOT NULL DROP TABLE dbo.StagingImportStudents;
CREATE TABLE dbo.StagingImportStudents (RawLine nvarchar(max) NULL);

GO
