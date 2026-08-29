IF NOT EXISTS (SELECT 1
               FROM   sys.configurations
               WHERE  name = 'clr enabled'
                      AND value_in_use = 1)
    BEGIN
        EXECUTE sp_configure 'clr enabled', 1;
        RECONFIGURE;
    END


GO
IF NOT EXISTS (SELECT 1
               FROM   sys.databases
               WHERE  name = 'SSISDB')
    BEGIN
        EXECUTE catalog.create_catalog @password = N'YourStrongMasterKeyPasswordHere';
    END


GO
IF NOT EXISTS (SELECT 1
               FROM   SSISDB.catalog.folders
               WHERE  name = 'DWH_OnPrem')
    BEGIN
        EXECUTE SSISDB.catalog.create_folder @folder_name = N'DWH_OnPrem';
    END