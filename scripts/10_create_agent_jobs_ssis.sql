USE msdb;
GO

IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = N'Run_SSIS_Packages')
BEGIN
    EXEC dbo.sp_delete_job @job_name = N'Run_SSIS_Packages';
END
GO

EXECUTE dbo.sp_add_job @job_name = N'Run_SSIS_Packages';
GO

EXECUTE sp_add_jobstep
    @job_name = N'Run_SSIS_Packages',
    @step_name = N'Run Load_Reference_Tables',
    @subsystem = N'TSQL',
    @command = N'EXEC ETL.USP_RUN_SSIS_PACKAGE @PackageName = N''Load_Reference_Tables.dtsx'';',
    @retry_attempts = 1,
    @retry_interval = 5,
    @on_success_action = 3,
    @on_fail_action = 2,
    @flags = 6;
GO

EXECUTE sp_add_jobstep
    @job_name = N'Run_SSIS_Packages',
    @step_name = N'Run Load_Append_Tables',
    @subsystem = N'TSQL',
    @command = N'EXEC ETL.USP_RUN_SSIS_PACKAGE @PackageName = N''Load_Append_Tables.dtsx'';',
    @retry_attempts = 1,
    @retry_interval = 5,
    @on_success_action = 3,
    @on_fail_action = 2,
    @flags = 6;
GO

EXECUTE sp_add_jobstep
    @job_name = N'Run_SSIS_Packages',
    @step_name = N'Run Load_Fact_Tables',
    @subsystem = N'TSQL',
    @command = N'EXEC ETL.USP_RUN_SSIS_PACKAGE @PackageName = N''Load_Fact_Tables.dtsx'';',
    @retry_attempts = 1,
    @retry_interval = 5,
    @on_success_action = 3,
    @on_fail_action = 2,
    @flags = 6;
GO

EXECUTE dbo.sp_add_schedule
    @schedule_name = N'RunDailyEarly',
    @freq_type = 4,
    @freq_interval = 1,
    @active_start_time = 223000;  -- one hour before Populate_Marts at 23:30
GO

EXECUTE sp_attach_schedule
    @job_name = N'Run_SSIS_Packages',
    @schedule_name = N'RunDailyEarly';
GO

EXECUTE dbo.sp_add_jobserver @job_name = N'Run_SSIS_Packages';
GO