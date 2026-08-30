IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'ETL')
    EXEC('CREATE SCHEMA ETL');
GO

CREATE OR ALTER PROCEDURE ETL.USP_RUN_SSIS_PACKAGE
    @PackageName NVARCHAR(260),
    @ProjectName NVARCHAR(128) = 'SSIS_DWHONPREM',
    @FolderName NVARCHAR(128) = 'DWH_OnPrem'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ExecutionID BIGINT;
    DECLARE @Status INT;
    DECLARE @MaxWaitSeconds INT = 1800;
    DECLARE @WaitedSeconds INT = 0;

    EXEC SSISDB.catalog.create_execution
        @folder_name = @FolderName,
        @project_name = @ProjectName,
        @package_name = @PackageName,
        @use32bitruntime = 0,
        @reference_id = NULL,
        @execution_id = @ExecutionID OUTPUT;

    EXEC SSISDB.catalog.start_execution @execution_id = @ExecutionID;

    WHILE 1 = 1
    BEGIN
        SELECT @Status = status
        FROM SSISDB.catalog.executions
        WHERE execution_id = @ExecutionID;

        IF @Status <> 2  -- no longer "running"
            BREAK;

        IF @WaitedSeconds >= @MaxWaitSeconds
        BEGIN
            RAISERROR('SSIS package %s timed out after %d seconds', 16, 1, @PackageName, @MaxWaitSeconds);
            RETURN;
        END;

        WAITFOR DELAY '00:00:05';
        SET @WaitedSeconds = @WaitedSeconds + 5;
    END;

    IF @Status <> 7  -- not "succeeded"
    BEGIN
        RAISERROR('SSIS package %s did not succeed. Final status code: %d. Check SSISDB.catalog.executions for details.', 16, 1, @PackageName, @Status);
        RETURN;
    END;

    PRINT 'SSIS package ' + @PackageName + ' completed successfully.';
END;
GO