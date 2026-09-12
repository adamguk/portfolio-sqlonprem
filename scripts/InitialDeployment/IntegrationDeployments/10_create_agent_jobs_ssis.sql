USE msdb;


GO
IF EXISTS (SELECT job_id
           FROM   msdb.dbo.sysjobs
           WHERE  name = N'Run_SSIS_Packages')
    BEGIN
        EXECUTE dbo.sp_delete_job @job_name = N'Run_SSIS_Packages';
    END


GO
EXECUTE dbo.sp_add_job @job_name = N'Run_SSIS_Packages';


GO
EXECUTE sp_add_jobstep @job_name = N'Run_SSIS_Packages', @step_name = N'Run Load_Reference_Tables', @subsystem = N'SSIS', @command = N'/ISSERVER "\"\SSISDB\DWH_OnPrem\SSIS_DWHONPREM\Load_Reference_Tables.dtsx\"" /SERVER "\"DESKTOP-8Q39CF7\SQLDEV2025\"" /ENVREFERENCE 1 /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', @database_name = N'master', @retry_attempts = 1, @retry_interval = 5, @on_success_action = 3, @on_fail_action = 2, @flags = 0;


GO
EXECUTE sp_add_jobstep @job_name = N'Run_SSIS_Packages', @step_name = N'Run Load_Append_Tables', @subsystem = N'SSIS', @command = N'/ISSERVER "\"\SSISDB\DWH_OnPrem\SSIS_DWHONPREM\Load_Append_Tables.dtsx\"" /SERVER "\"DESKTOP-8Q39CF7\SQLDEV2025\"" /ENVREFERENCE 1 /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', @database_name = N'master', @retry_attempts = 1, @retry_interval = 5, @on_success_action = 3, @on_fail_action = 2, @flags = 0;


GO
EXECUTE sp_add_jobstep @job_name = N'Run_SSIS_Packages', @step_name = N'Run Load_Fact_Tables', @subsystem = N'SSIS', @command = N'/ISSERVER "\"\SSISDB\DWH_OnPrem\SSIS_DWHONPREM\Load_Fact_Tables.dtsx\"" /SERVER "\"DESKTOP-8Q39CF7\SQLDEV2025\"" /ENVREFERENCE 1 /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', @database_name = N'master', @retry_attempts = 1, @retry_interval = 5, @on_success_action = 1, @on_fail_action = 2, @flags = 0;


GO
EXECUTE dbo.sp_add_schedule @schedule_name = N'RunDailyEarly', @freq_type = 4, @freq_interval = 1, @active_start_time = 223000; -- one hour before Populate_Marts at 23:30


GO
EXECUTE sp_attach_schedule @job_name = N'Run_SSIS_Packages', @schedule_name = N'RunDailyEarly';


GO
EXECUTE dbo.sp_add_jobserver @job_name = N'Run_SSIS_Packages';