USE BytServiceDemo;
GO

SELECT
    COUNT(*) AS CompletedRequestsCount
FROM dbo.RepairRequests rr
INNER JOIN dbo.RequestStatuses rs ON rs.StatusId = rr.StatusId
WHERE rs.Code = N'READY';
GO

SELECT
    CAST(AVG(DATEDIFF(DAY, rr.CreatedAt, rr.CompletionDate) * 1.0) AS decimal(10,2)) AS AverageRepairDays
FROM dbo.RepairRequests rr
WHERE rr.CompletionDate IS NOT NULL;
GO

SELECT
    rr.ApplianceType,
    COUNT(*) AS RequestsCount
FROM dbo.RepairRequests rr
GROUP BY rr.ApplianceType
ORDER BY RequestsCount DESC, rr.ApplianceType;
GO

SELECT
    rr.RequestNumber,
    clientUser.FullName AS ClientName,
    rs.Name AS StatusName,
    rr.PlannedCompletionDate,
    rr.ExtendedUntil
FROM dbo.RepairRequests rr
INNER JOIN dbo.Users clientUser ON clientUser.UserId = rr.ClientId
INNER JOIN dbo.RequestStatuses rs ON rs.StatusId = rr.StatusId
WHERE COALESCE(rr.ExtendedUntil, rr.PlannedCompletionDate) < CAST(SYSDATETIME() AS date)
  AND rs.Code <> N'READY'
ORDER BY COALESCE(rr.ExtendedUntil, rr.PlannedCompletionDate);
GO

SELECT
    masterUser.FullName AS MasterName,
    COUNT(*) AS ActiveRequestsCount
FROM dbo.RepairRequests rr
INNER JOIN dbo.Users masterUser ON masterUser.UserId = rr.AssignedMasterId
INNER JOIN dbo.RequestStatuses rs ON rs.StatusId = rr.StatusId
WHERE rs.Code IN (N'IN_PROGRESS', N'WAIT_PARTS')
GROUP BY masterUser.FullName
ORDER BY ActiveRequestsCount DESC, masterUser.FullName;
GO

