IF NOT EXISTS (SELECT 1
               FROM   SSISDB.catalog.folders
               WHERE  name = N'DWH_OnPrem')
    EXECUTE SSISDB.catalog.create_folder @folder_name = N'DWH_OnPrem';


GO
DECLARE @ProjectBinary AS VARBINARY (MAX) = (SELECT BulkColumn
                                             FROM   OPENROWSET (BULK N'C:\Temp\SSIS_DWHONPREM.ispac', SINGLE_BLOB) AS x);

EXECUTE SSISDB.catalog.deploy_project @folder_name = N'DWH_OnPrem', @project_name = N'SSIS_DWHONPREM', @project_stream = @ProjectBinary;