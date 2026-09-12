
IF NOT EXISTS (SELECT 1
               FROM   SSISDB.catalog.environments
               WHERE  name = N'Production')
    BEGIN
        EXECUTE SSISDB.catalog.create_environment @folder_name = N'DWH_OnPrem', @environment_name = N'Production';
    END


GO
IF NOT EXISTS (SELECT 1
               FROM   SSISDB.catalog.environment_variables
               WHERE  name = N'AdventureWorksPassword')
    BEGIN
        EXECUTE SSISDB.catalog.create_environment_variable @folder_name = N'DWH_OnPrem', @environment_name = N'Production', @variable_name = N'AdventureWorksPassword', @data_type = N'String', @sensitive = 1, @value = N'$(AdventureWorksPassword)', @description = N'AdventureWorks source connection password';
    END


GO
IF NOT EXISTS (SELECT 1
               FROM   SSISDB.catalog.environment_variables
               WHERE  name = N'DwhPassword')
    BEGIN
        EXECUTE SSISDB.catalog.create_environment_variable @folder_name = N'DWH_OnPrem', @environment_name = N'Production', @variable_name = N'DwhPassword', @data_type = N'String', @sensitive = 1, @value = N'$(DwhPassword)', @description = N'DWH destination connection password';
    END


GO
EXECUTE SSISDB.catalog.set_environment_variable_value @folder_name = N'DWH_OnPrem', @environment_name = N'Production', @variable_name = N'AdventureWorksPassword', @value = N'$(AdventureWorksPassword)';


GO
EXECUTE SSISDB.catalog.set_environment_variable_value @folder_name = N'DWH_OnPrem', @environment_name = N'Production', @variable_name = N'DwhPassword', @value = N'$(DwhPassword)';


GO
IF NOT EXISTS (SELECT 1
               FROM   SSISDB.catalog.environment_references
               WHERE  environment_name = N'Production')
    BEGIN
        DECLARE @ReferenceID AS BIGINT;
        EXECUTE SSISDB.catalog.create_environment_reference @folder_name = N'DWH_OnPrem', @project_name = N'SSIS_DWHONPREM', @environment_name = N'Production', @reference_type = N'R', @reference_id = @ReferenceID OUTPUT;
    END


GO
DECLARE @Packages TABLE (
    PackageName NVARCHAR (260));

INSERT  INTO @Packages
VALUES (N'Load_Reference_Tables.dtsx'),
(N'Load_Append_Tables.dtsx'),
(N'Load_Fact_Tables.dtsx');

DECLARE @PackageName AS NVARCHAR (260);

DECLARE PackageCursor CURSOR
    FOR SELECT PackageName
        FROM   @Packages;

OPEN PackageCursor;

FETCH NEXT FROM PackageCursor INTO @PackageName;

WHILE @@FETCH_STATUS = 0
    BEGIN
        EXECUTE SSISDB.catalog.set_object_parameter_value @object_type = 30, @folder_name = N'DWH_OnPrem', @project_name = N'SSIS_DWHONPREM', @parameter_name = N'CM.AdventureWorks.Password', @parameter_value = N'AdventureWorksPassword', @object_name = @PackageName, @value_type = N'R';
        EXECUTE SSISDB.catalog.set_object_parameter_value @object_type = 30, @folder_name = N'DWH_OnPrem', @project_name = N'SSIS_DWHONPREM', @parameter_name = N'CM.Destination_DWHONPREM.Password', @parameter_value = N'DwhPassword', @object_name = @PackageName, @value_type = N'R';
        FETCH NEXT FROM PackageCursor INTO @PackageName;
    END

CLOSE PackageCursor;

DEALLOCATE PackageCursor;