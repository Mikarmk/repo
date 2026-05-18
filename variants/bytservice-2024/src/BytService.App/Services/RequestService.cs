using BytService.App.Models;
using System.Data.SqlClient;

namespace BytService.App.Services;

public sealed class RequestService
{
    private readonly DatabaseContext _databaseContext;

    public RequestService(ApplicationSettings settings)
    {
        _databaseContext = new DatabaseContext(settings);
    }

    public async Task<List<RepairRequest>> GetRequestsAsync(AppUser currentUser, string? searchText)
    {
        var requests = new List<RepairRequest>();
        var sql = """
            SELECT
                rr.RequestId,
                rr.RequestNumber,
                rr.CreatedAt,
                rr.ApplianceType,
                rr.ApplianceModel,
                rr.ProblemDescription,
                rs.Code AS StatusCode,
                rs.Name AS StatusName,
                rr.ClientId,
                clientUser.FullName AS ClientName,
                rr.AssignedMasterId,
                masterUser.FullName AS AssignedMasterName,
                rr.PlannedCompletionDate,
                rr.ExtendedUntil,
                rr.ExtensionApprovedByClient,
                rr.CompletionDate,
                rr.RepairPartsUsed,
                rr.QualityManagerId,
                qualityUser.FullName AS QualityManagerName,
                assistant.MasterId AS AssistantMasterId,
                assistantUser.FullName AS AssistantMasterName,
                ISNULL(lastComment.CommentText, N'') AS LatestComment
            FROM dbo.RepairRequests rr
            INNER JOIN dbo.RequestStatuses rs ON rs.StatusId = rr.StatusId
            INNER JOIN dbo.Users clientUser ON clientUser.UserId = rr.ClientId
            LEFT JOIN dbo.Users masterUser ON masterUser.UserId = rr.AssignedMasterId
            LEFT JOIN dbo.Users qualityUser ON qualityUser.UserId = rr.QualityManagerId
            LEFT JOIN (
                SELECT requestAssistant.RequestId, MAX(requestAssistant.MasterId) AS MasterId
                FROM dbo.RequestAssistantMasters requestAssistant
                GROUP BY requestAssistant.RequestId
            ) assistant ON assistant.RequestId = rr.RequestId
            LEFT JOIN dbo.Users assistantUser ON assistantUser.UserId = assistant.MasterId
            OUTER APPLY (
                SELECT TOP (1) rc.CommentText
                FROM dbo.RequestComments rc
                WHERE rc.RequestId = rr.RequestId
                ORDER BY rc.CreatedAt DESC, rc.CommentId DESC
            ) lastComment
            WHERE (
                    @searchText = N''
                    OR rr.RequestNumber LIKE N'%' + @searchText + N'%'
                    OR rr.ApplianceType LIKE N'%' + @searchText + N'%'
                    OR rr.ApplianceModel LIKE N'%' + @searchText + N'%'
                    OR rr.ProblemDescription LIKE N'%' + @searchText + N'%'
                    OR clientUser.FullName LIKE N'%' + @searchText + N'%'
                  )
              AND (
                    @roleCode IN (N'OPERATOR', N'QUALITY_MANAGER')
                    OR (@roleCode = N'MASTER' AND (rr.AssignedMasterId = @userId OR assistant.MasterId = @userId))
                    OR (@roleCode = N'CLIENT' AND rr.ClientId = @userId)
                  )
            ORDER BY rr.CreatedAt DESC, rr.RequestId DESC;
            """;

        await using var connection = _databaseContext.CreateConnection();
        await connection.OpenAsync();

        await using var command = new SqlCommand(sql, connection);
        command.Parameters.AddWithValue("@searchText", searchText?.Trim() ?? string.Empty);
        command.Parameters.AddWithValue("@roleCode", currentUser.RoleCode);
        command.Parameters.AddWithValue("@userId", currentUser.UserId);

        await using var reader = await command.ExecuteReaderAsync();
        while (await reader.ReadAsync())
        {
            requests.Add(new RepairRequest
            {
                RequestId = reader.GetInt32(reader.GetOrdinal("RequestId")),
                RequestNumber = reader.GetString(reader.GetOrdinal("RequestNumber")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt")),
                ApplianceType = reader.GetString(reader.GetOrdinal("ApplianceType")),
                ApplianceModel = reader.GetString(reader.GetOrdinal("ApplianceModel")),
                ProblemDescription = reader.GetString(reader.GetOrdinal("ProblemDescription")),
                StatusCode = reader.GetString(reader.GetOrdinal("StatusCode")),
                StatusName = reader.GetString(reader.GetOrdinal("StatusName")),
                ClientId = reader.GetInt32(reader.GetOrdinal("ClientId")),
                ClientName = reader.GetString(reader.GetOrdinal("ClientName")),
                AssignedMasterId = reader.IsDBNull(reader.GetOrdinal("AssignedMasterId")) ? null : reader.GetInt32(reader.GetOrdinal("AssignedMasterId")),
                AssignedMasterName = reader.IsDBNull(reader.GetOrdinal("AssignedMasterName")) ? string.Empty : reader.GetString(reader.GetOrdinal("AssignedMasterName")),
                PlannedCompletionDate = reader.IsDBNull(reader.GetOrdinal("PlannedCompletionDate")) ? null : reader.GetDateTime(reader.GetOrdinal("PlannedCompletionDate")),
                ExtendedUntil = reader.IsDBNull(reader.GetOrdinal("ExtendedUntil")) ? null : reader.GetDateTime(reader.GetOrdinal("ExtendedUntil")),
                ExtensionApprovedByClient = !reader.IsDBNull(reader.GetOrdinal("ExtensionApprovedByClient")) && reader.GetBoolean(reader.GetOrdinal("ExtensionApprovedByClient")),
                CompletionDate = reader.IsDBNull(reader.GetOrdinal("CompletionDate")) ? null : reader.GetDateTime(reader.GetOrdinal("CompletionDate")),
                RepairPartsUsed = reader.IsDBNull(reader.GetOrdinal("RepairPartsUsed")) ? string.Empty : reader.GetString(reader.GetOrdinal("RepairPartsUsed")),
                LatestComment = reader.GetString(reader.GetOrdinal("LatestComment")),
                QualityManagerId = reader.IsDBNull(reader.GetOrdinal("QualityManagerId")) ? null : reader.GetInt32(reader.GetOrdinal("QualityManagerId")),
                QualityManagerName = reader.IsDBNull(reader.GetOrdinal("QualityManagerName")) ? string.Empty : reader.GetString(reader.GetOrdinal("QualityManagerName")),
                AssistantMasterId = reader.IsDBNull(reader.GetOrdinal("AssistantMasterId")) ? null : reader.GetInt32(reader.GetOrdinal("AssistantMasterId")),
                AssistantMasterName = reader.IsDBNull(reader.GetOrdinal("AssistantMasterName")) ? string.Empty : reader.GetString(reader.GetOrdinal("AssistantMasterName"))
            });
        }

        return requests;
    }

    public async Task<List<AppUser>> GetUsersByRoleAsync(string roleCode)
    {
        var users = new List<AppUser>();
        const string sql = """
            SELECT
                u.UserId,
                u.FullName,
                u.Phone,
                u.Login,
                u.IsActive,
                r.Code AS RoleCode,
                r.Name AS RoleName
            FROM dbo.Users u
            INNER JOIN dbo.Roles r ON r.RoleId = u.RoleId
            WHERE r.Code = @roleCode
            ORDER BY u.FullName;
            """;

        await using var connection = _databaseContext.CreateConnection();
        await connection.OpenAsync();
        await using var command = new SqlCommand(sql, connection);
        command.Parameters.AddWithValue("@roleCode", roleCode);

        await using var reader = await command.ExecuteReaderAsync();
        while (await reader.ReadAsync())
        {
            users.Add(new AppUser
            {
                UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
                FullName = reader.GetString(reader.GetOrdinal("FullName")),
                Phone = reader.GetString(reader.GetOrdinal("Phone")),
                Login = reader.GetString(reader.GetOrdinal("Login")),
                IsActive = reader.GetBoolean(reader.GetOrdinal("IsActive")),
                RoleCode = reader.GetString(reader.GetOrdinal("RoleCode")),
                RoleName = reader.GetString(reader.GetOrdinal("RoleName"))
            });
        }

        return users;
    }

    public async Task<List<AppUser>> GetAllUsersAsync()
    {
        const string sql = """
            SELECT
                u.UserId,
                u.FullName,
                u.Phone,
                u.Login,
                u.IsActive,
                r.Code AS RoleCode,
                r.Name AS RoleName
            FROM dbo.Users u
            INNER JOIN dbo.Roles r ON r.RoleId = u.RoleId
            ORDER BY r.Name, u.FullName;
            """;

        var users = new List<AppUser>();
        await using var connection = _databaseContext.CreateConnection();
        await connection.OpenAsync();
        await using var command = new SqlCommand(sql, connection);

        await using var reader = await command.ExecuteReaderAsync();
        while (await reader.ReadAsync())
        {
            users.Add(new AppUser
            {
                UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
                FullName = reader.GetString(reader.GetOrdinal("FullName")),
                Phone = reader.GetString(reader.GetOrdinal("Phone")),
                Login = reader.GetString(reader.GetOrdinal("Login")),
                IsActive = reader.GetBoolean(reader.GetOrdinal("IsActive")),
                RoleCode = reader.GetString(reader.GetOrdinal("RoleCode")),
                RoleName = reader.GetString(reader.GetOrdinal("RoleName"))
            });
        }

        return users;
    }

    public async Task<List<KeyValuePair<int, string>>> GetStatusesAsync()
    {
        var statuses = new List<KeyValuePair<int, string>>();
        const string sql = "SELECT StatusId, Name FROM dbo.RequestStatuses ORDER BY StatusId;";

        await using var connection = _databaseContext.CreateConnection();
        await connection.OpenAsync();
        await using var command = new SqlCommand(sql, connection);
        await using var reader = await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            statuses.Add(new KeyValuePair<int, string>(reader.GetInt32(0), reader.GetString(1)));
        }

        return statuses;
    }

    public async Task SaveRequestAsync(RepairRequest request, AppUser actor)
    {
        await using var connection = _databaseContext.CreateConnection();
        await connection.OpenAsync();
        await using var transaction = connection.BeginTransaction();

        var statusId = await GetStatusIdByNameAsync(request.StatusName, connection, transaction);

        if (request.RequestId == 0)
        {
            var nextNumber = await GenerateRequestNumberAsync(connection, transaction);
            const string insertSql = """
                INSERT INTO dbo.RepairRequests
                (
                    RequestNumber,
                    CreatedAt,
                    ApplianceType,
                    ApplianceModel,
                    ProblemDescription,
                    StatusId,
                    ClientId,
                    AssignedMasterId,
                    PlannedCompletionDate,
                    CompletionDate,
                    RepairPartsUsed,
                    CreatedByUserId,
                    QualityManagerId,
                    ExtendedUntil,
                    ExtensionApprovedByClient
                )
                VALUES
                (
                    @requestNumber,
                    @createdAt,
                    @applianceType,
                    @applianceModel,
                    @problemDescription,
                    @statusId,
                    @clientId,
                    @assignedMasterId,
                    @plannedCompletionDate,
                    @completionDate,
                    @repairPartsUsed,
                    @createdByUserId,
                    @qualityManagerId,
                    @extendedUntil,
                    @extensionApprovedByClient
                );
                SELECT CAST(SCOPE_IDENTITY() AS int);
                """;

            await using var insertCommand = new SqlCommand(insertSql, connection, transaction);
            insertCommand.Parameters.AddWithValue("@requestNumber", nextNumber);
            insertCommand.Parameters.AddWithValue("@createdAt", request.CreatedAt);
            insertCommand.Parameters.AddWithValue("@applianceType", request.ApplianceType.Trim());
            insertCommand.Parameters.AddWithValue("@applianceModel", request.ApplianceModel.Trim());
            insertCommand.Parameters.AddWithValue("@problemDescription", request.ProblemDescription.Trim());
            insertCommand.Parameters.AddWithValue("@statusId", statusId);
            insertCommand.Parameters.AddWithValue("@clientId", request.ClientId);
            insertCommand.Parameters.AddWithValue("@assignedMasterId", (object?)request.AssignedMasterId ?? DBNull.Value);
            insertCommand.Parameters.AddWithValue("@plannedCompletionDate", (object?)request.PlannedCompletionDate ?? DBNull.Value);
            insertCommand.Parameters.AddWithValue("@completionDate", (object?)request.CompletionDate ?? DBNull.Value);
            insertCommand.Parameters.AddWithValue("@repairPartsUsed", string.IsNullOrWhiteSpace(request.RepairPartsUsed) ? DBNull.Value : request.RepairPartsUsed.Trim());
            insertCommand.Parameters.AddWithValue("@createdByUserId", actor.UserId);
            insertCommand.Parameters.AddWithValue("@qualityManagerId", (object?)request.QualityManagerId ?? DBNull.Value);
            insertCommand.Parameters.AddWithValue("@extendedUntil", (object?)request.ExtendedUntil ?? DBNull.Value);
            insertCommand.Parameters.AddWithValue("@extensionApprovedByClient", request.ExtensionApprovedByClient);

            request.RequestId = (int)(await insertCommand.ExecuteScalarAsync() ?? 0);
            request.RequestNumber = nextNumber;
        }
        else
        {
            const string updateSql = """
                UPDATE dbo.RepairRequests
                SET ApplianceType = @applianceType,
                    ApplianceModel = @applianceModel,
                    ProblemDescription = @problemDescription,
                    StatusId = @statusId,
                    ClientId = @clientId,
                    AssignedMasterId = @assignedMasterId,
                    PlannedCompletionDate = @plannedCompletionDate,
                    CompletionDate = @completionDate,
                    RepairPartsUsed = @repairPartsUsed,
                    QualityManagerId = @qualityManagerId,
                    ExtendedUntil = @extendedUntil,
                    ExtensionApprovedByClient = @extensionApprovedByClient
                WHERE RequestId = @requestId;
                """;

            await using var updateCommand = new SqlCommand(updateSql, connection, transaction);
            updateCommand.Parameters.AddWithValue("@requestId", request.RequestId);
            updateCommand.Parameters.AddWithValue("@applianceType", request.ApplianceType.Trim());
            updateCommand.Parameters.AddWithValue("@applianceModel", request.ApplianceModel.Trim());
            updateCommand.Parameters.AddWithValue("@problemDescription", request.ProblemDescription.Trim());
            updateCommand.Parameters.AddWithValue("@statusId", statusId);
            updateCommand.Parameters.AddWithValue("@clientId", request.ClientId);
            updateCommand.Parameters.AddWithValue("@assignedMasterId", (object?)request.AssignedMasterId ?? DBNull.Value);
            updateCommand.Parameters.AddWithValue("@plannedCompletionDate", (object?)request.PlannedCompletionDate ?? DBNull.Value);
            updateCommand.Parameters.AddWithValue("@completionDate", (object?)request.CompletionDate ?? DBNull.Value);
            updateCommand.Parameters.AddWithValue("@repairPartsUsed", string.IsNullOrWhiteSpace(request.RepairPartsUsed) ? DBNull.Value : request.RepairPartsUsed.Trim());
            updateCommand.Parameters.AddWithValue("@qualityManagerId", (object?)request.QualityManagerId ?? DBNull.Value);
            updateCommand.Parameters.AddWithValue("@extendedUntil", (object?)request.ExtendedUntil ?? DBNull.Value);
            updateCommand.Parameters.AddWithValue("@extensionApprovedByClient", request.ExtensionApprovedByClient);
            await updateCommand.ExecuteNonQueryAsync();
        }

        await UpsertAssistantMasterAsync(request, actor, connection, transaction);
        await InsertStatusHistoryAsync(request.RequestId, statusId, actor.UserId, connection, transaction);
        await transaction.CommitAsync();
    }

    public async Task DeleteRequestAsync(int requestId)
    {
        const string sql = "DELETE FROM dbo.RepairRequests WHERE RequestId = @requestId;";
        await using var connection = _databaseContext.CreateConnection();
        await connection.OpenAsync();
        await using var command = new SqlCommand(sql, connection);
        command.Parameters.AddWithValue("@requestId", requestId);
        await command.ExecuteNonQueryAsync();
    }

    public async Task<List<RequestComment>> GetCommentsAsync(int requestId)
    {
        var comments = new List<RequestComment>();
        const string sql = """
            SELECT
                rc.CommentId,
                rc.RequestId,
                rc.MasterId,
                u.FullName AS MasterName,
                rc.CommentText,
                rc.CreatedAt
            FROM dbo.RequestComments rc
            INNER JOIN dbo.Users u ON u.UserId = rc.MasterId
            WHERE rc.RequestId = @requestId
            ORDER BY rc.CreatedAt DESC, rc.CommentId DESC;
            """;

        await using var connection = _databaseContext.CreateConnection();
        await connection.OpenAsync();
        await using var command = new SqlCommand(sql, connection);
        command.Parameters.AddWithValue("@requestId", requestId);
        await using var reader = await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            comments.Add(new RequestComment
            {
                CommentId = reader.GetInt32(reader.GetOrdinal("CommentId")),
                RequestId = reader.GetInt32(reader.GetOrdinal("RequestId")),
                MasterId = reader.GetInt32(reader.GetOrdinal("MasterId")),
                MasterName = reader.GetString(reader.GetOrdinal("MasterName")),
                CommentText = reader.GetString(reader.GetOrdinal("CommentText")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt"))
            });
        }

        return comments;
    }

    public async Task AddCommentAsync(int requestId, int masterId, string commentText)
    {
        const string sql = """
            INSERT INTO dbo.RequestComments (RequestId, MasterId, CommentText, CreatedAt)
            VALUES (@requestId, @masterId, @commentText, SYSDATETIME());
            """;

        await using var connection = _databaseContext.CreateConnection();
        await connection.OpenAsync();
        await using var command = new SqlCommand(sql, connection);
        command.Parameters.AddWithValue("@requestId", requestId);
        command.Parameters.AddWithValue("@masterId", masterId);
        command.Parameters.AddWithValue("@commentText", commentText.Trim());
        await command.ExecuteNonQueryAsync();
    }

    public async Task<RepairStatistics> GetStatisticsAsync()
    {
        var statistics = new RepairStatistics();
        await using var connection = _databaseContext.CreateConnection();
        await connection.OpenAsync();

        const string summarySql = """
            SELECT
                SUM(CASE WHEN statusLookup.Code = N'READY' THEN 1 ELSE 0 END) AS CompletedRequestsCount,
                AVG(CASE WHEN rr.CompletionDate IS NOT NULL THEN DATEDIFF(DAY, rr.CreatedAt, rr.CompletionDate) * 1.0 END) AS AverageRepairDays,
                SUM(CASE WHEN COALESCE(rr.ExtendedUntil, rr.PlannedCompletionDate) < CAST(SYSDATETIME() AS date) AND statusLookup.Code <> N'READY' THEN 1 ELSE 0 END) AS OverdueRequestsCount
            FROM dbo.RepairRequests rr
            INNER JOIN dbo.RequestStatuses statusLookup ON statusLookup.StatusId = rr.StatusId;
            """;

        await using var summaryCommand = new SqlCommand(summarySql, connection);
        await using var summaryReader = await summaryCommand.ExecuteReaderAsync();
        if (await summaryReader.ReadAsync())
        {
            statistics.CompletedRequestsCount = summaryReader.IsDBNull(0) ? 0 : summaryReader.GetInt32(0);
            statistics.AverageRepairDays = summaryReader.IsDBNull(1) ? 0 : Math.Round(summaryReader.GetDouble(1), 2);
            statistics.OverdueRequestsCount = summaryReader.IsDBNull(2) ? 0 : summaryReader.GetInt32(2);
        }

        await summaryReader.CloseAsync();

        const string detailsSql = """
            SELECT rr.ApplianceType, COUNT(*) AS RequestsCount
            FROM dbo.RepairRequests rr
            GROUP BY rr.ApplianceType
            ORDER BY COUNT(*) DESC, rr.ApplianceType;
            """;

        await using var detailsCommand = new SqlCommand(detailsSql, connection);
        await using var detailsReader = await detailsCommand.ExecuteReaderAsync();
        while (await detailsReader.ReadAsync())
        {
            statistics.ProblemTypes.Add(new ProblemTypeStatistics
            {
                ApplianceType = detailsReader.GetString(0),
                RequestsCount = detailsReader.GetInt32(1)
            });
        }

        return statistics;
    }

    public async Task CreateUserAsync(string fullName, string phone, string login, string password, string roleCode)
    {
        const string sql = """
            INSERT INTO dbo.Users (FullName, Phone, Login, PasswordHash, RoleId, IsActive)
            SELECT
                @fullName,
                @phone,
                @login,
                @passwordHash,
                r.RoleId,
                1
            FROM dbo.Roles r
            WHERE r.Code = @roleCode;
            """;

        await using var connection = _databaseContext.CreateConnection();
        await connection.OpenAsync();
        await using var command = new SqlCommand(sql, connection);
        command.Parameters.AddWithValue("@fullName", fullName.Trim());
        command.Parameters.AddWithValue("@phone", phone.Trim());
        command.Parameters.AddWithValue("@login", login.Trim());
        command.Parameters.AddWithValue("@passwordHash", PasswordHasher.ComputeHash(password));
        command.Parameters.AddWithValue("@roleCode", roleCode);
        await command.ExecuteNonQueryAsync();
    }

    private static async Task InsertStatusHistoryAsync(int requestId, int newStatusId, int changedByUserId, SqlConnection connection, SqlTransaction transaction)
    {
        const string sql = """
            INSERT INTO dbo.RequestStatusHistory (RequestId, OldStatusId, NewStatusId, ChangedByUserId, ChangedAt, ChangeComment)
            SELECT
                @requestId,
                (
                    SELECT TOP (1) history.NewStatusId
                    FROM dbo.RequestStatusHistory history
                    WHERE history.RequestId = @requestId
                    ORDER BY history.ChangedAt DESC, history.StatusHistoryId DESC
                ),
                @newStatusId,
                @changedByUserId,
                SYSDATETIME(),
                N'Статус обновлен из приложения';
            """;

        await using var command = new SqlCommand(sql, connection, transaction);
        command.Parameters.AddWithValue("@requestId", requestId);
        command.Parameters.AddWithValue("@newStatusId", newStatusId);
        command.Parameters.AddWithValue("@changedByUserId", changedByUserId);
        await command.ExecuteNonQueryAsync();
    }

    private static async Task<int> GetStatusIdByNameAsync(string statusName, SqlConnection connection, SqlTransaction transaction)
    {
        const string sql = "SELECT StatusId FROM dbo.RequestStatuses WHERE Name = @statusName;";
        await using var command = new SqlCommand(sql, connection, transaction);
        command.Parameters.AddWithValue("@statusName", statusName);
        var result = await command.ExecuteScalarAsync();
        if (result is int statusId)
        {
            return statusId;
        }

        throw new InvalidOperationException($"Статус '{statusName}' не найден в справочнике.");
    }

    private static async Task<string> GenerateRequestNumberAsync(SqlConnection connection, SqlTransaction transaction)
    {
        const string sql = "SELECT ISNULL(MAX(RequestId), 0) + 1 FROM dbo.RepairRequests;";
        await using var command = new SqlCommand(sql, connection, transaction);
        var nextId = (int)(await command.ExecuteScalarAsync() ?? 1);
        return $"REQ-{DateTime.Now:yyyy}-{nextId:0000}";
    }

    private static async Task UpsertAssistantMasterAsync(RepairRequest request, AppUser actor, SqlConnection connection, SqlTransaction transaction)
    {
        if (request.AssistantMasterId is null)
        {
            const string deleteSql = "DELETE FROM dbo.RequestAssistantMasters WHERE RequestId = @requestId;";
            await using var deleteCommand = new SqlCommand(deleteSql, connection, transaction);
            deleteCommand.Parameters.AddWithValue("@requestId", request.RequestId);
            await deleteCommand.ExecuteNonQueryAsync();
            return;
        }

        const string sql = """
            MERGE dbo.RequestAssistantMasters AS target
            USING (SELECT @requestId AS RequestId) AS source
            ON target.RequestId = source.RequestId
            WHEN MATCHED THEN
                UPDATE SET
                    MasterId = @masterId,
                    AssignedByQualityManagerId = @managerId,
                    AssignedAt = SYSDATETIME()
            WHEN NOT MATCHED THEN
                INSERT (RequestId, MasterId, AssignedByQualityManagerId, AssignedAt)
                VALUES (@requestId, @masterId, @managerId, SYSDATETIME());
            """;

        await using var command = new SqlCommand(sql, connection, transaction);
        command.Parameters.AddWithValue("@requestId", request.RequestId);
        command.Parameters.AddWithValue("@masterId", request.AssistantMasterId.Value);
        command.Parameters.AddWithValue("@managerId", actor.IsQualityManager ? actor.UserId : (object?)request.QualityManagerId ?? DBNull.Value);
        await command.ExecuteNonQueryAsync();
    }
}
