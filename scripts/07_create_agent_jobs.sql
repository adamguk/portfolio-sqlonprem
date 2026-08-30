USE msdb;


GO
IF EXISTS (SELECT job_id
           FROM   msdb.dbo.sysjobs
           WHERE  name = N'Populate_Marts')
    BEGIN
        EXECUTE dbo.sp_delete_job @job_name = N'Populate_Marts';
    END
GO

EXECUTE dbo.sp_add_job @job_name = N'Populate_Marts';
GO

------------------------
-------DIMENSIONS-------
------------------------
EXECUTE sp_add_jobstep @job_name = N'Populate_Marts', @database_name = N'DWH_ONPREM', @step_name = N'Populate MRT.DIM_Person', @subsystem = N'TSQL', @command = N'EXEC MRT.USP_LOAD_DIM_PERSON', @retry_attempts = 3, @retry_interval = 5, @on_success_action = 3, @on_fail_action = 2, @flags = 6;


GO
EXECUTE sp_add_jobstep @job_name = N'Populate_Marts', @database_name = N'DWH_ONPREM', @step_name = N'Populate MRT.DIM_Person_Address', @subsystem = N'TSQL', @command = N'EXEC MRT.USP_LOAD_DIM_PERSON_ADDRESS', @retry_attempts = 3, @retry_interval = 5, @on_success_action = 3, @on_fail_action = 2, @flags = 6;


GO
EXECUTE sp_add_jobstep @job_name = N'Populate_Marts', @database_name = N'DWH_ONPREM', @step_name = N'Populate MRT.DIM_Product', @subsystem = N'TSQL', @command = N'EXEC MRT.USP_LOAD_DIM_PRODUCT', @retry_attempts = 3, @retry_interval = 5, @on_success_action = 3, @on_fail_action = 2, @flags = 6;


GO
EXECUTE sp_add_jobstep @job_name = N'Populate_Marts', @database_name = N'DWH_ONPREM', @step_name = N'Populate MRT.DIM_SalesPerson', @subsystem = N'TSQL', @command = N'EXEC MRT.USP_LOAD_DIM_SALESPERSON', @retry_attempts = 3, @retry_interval = 5, @on_success_action = 3, @on_fail_action = 2, @flags = 6;


GO
EXECUTE sp_add_jobstep @job_name = N'Populate_Marts', @database_name = N'DWH_ONPREM', @step_name = N'Populate MRT.DIM_Store', @subsystem = N'TSQL', @command = N'EXEC MRT.USP_LOAD_DIM_STORE', @retry_attempts = 3, @retry_interval = 5, @on_success_action = 3, @on_fail_action = 2, @flags = 6;


GO
EXECUTE sp_add_jobstep @job_name = N'Populate_Marts', @database_name = N'DWH_ONPREM', @step_name = N'Populate MRT.DIM_Territory', @subsystem = N'TSQL', @command = N'EXEC MRT.USP_LOAD_DIM_TERRITORY', @retry_attempts = 3, @retry_interval = 5, @on_success_action = 3, @on_fail_action = 2, @flags = 6;


GO
EXECUTE sp_add_jobstep @job_name = N'Populate_Marts', @database_name = N'DWH_ONPREM', @step_name = N'Populate MRT.DIM_Customer', @subsystem = N'TSQL', @command = N'EXEC MRT.USP_LOAD_DIM_CUSTOMER', @retry_attempts = 3, @retry_interval = 5, @on_success_action = 3, @on_fail_action = 2, @flags = 6;


GO
EXECUTE sp_add_jobstep @job_name = N'Populate_Marts', @database_name = N'DWH_ONPREM', @step_name = N'Populate MRT.DIM_SpecialOffer', @subsystem = N'TSQL', @command = N'EXEC MRT.USP_LOAD_DIM_SPECIALOFFER', @retry_attempts = 3, @retry_interval = 5, @on_success_action = 3, @on_fail_action = 2, @flags = 6;


GO
EXECUTE sp_add_jobstep @job_name = N'Populate_Marts', @database_name = N'DWH_ONPREM', @step_name = N'Populate MRT.DIM_CreditCard', @subsystem = N'TSQL', @command = N'EXEC MRT.USP_LOAD_DIM_CREDITCARD', @retry_attempts = 3, @retry_interval = 5, @on_success_action = 3, @on_fail_action = 2, @flags = 6;


GO
EXECUTE sp_add_jobstep @job_name = N'Populate_Marts', @database_name = N'DWH_ONPREM', @step_name = N'Populate MRT.DIM_ShipMethod', @subsystem = N'TSQL', @command = N'EXEC MRT.USP_LOAD_DIM_SHIPMETHOD', @retry_attempts = 3, @retry_interval = 5, @on_success_action = 3, @on_fail_action = 2, @flags = 6;


GO
EXECUTE sp_add_jobstep @job_name = N'Populate_Marts', @database_name = N'DWH_ONPREM', @step_name = N'Populate MRT.DIM_Address', @subsystem = N'TSQL', @command = N'EXEC MRT.USP_LOAD_DIM_ADDRESS', @retry_attempts = 3, @retry_interval = 5, @on_success_action = 3, @on_fail_action = 2, @flags = 6;


GO
EXECUTE sp_add_jobstep @job_name = N'Populate_Marts', @database_name = N'DWH_ONPREM', @step_name = N'Populate MRT.DIM_CurrencyRate', @subsystem = N'TSQL', @command = N'EXEC MRT.USP_LOAD_DIM_CURRENCYRATE', @retry_attempts = 3, @retry_interval = 5, @on_success_action = 3, @on_fail_action = 2, @flags = 6;


GO
------------------------
---------FACTS----------
------------------------
EXECUTE sp_add_jobstep @job_name = N'Populate_Marts', @database_name = N'DWH_ONPREM', @step_name = N'Populate MRT.FCT_Sales', @subsystem = N'TSQL', @command = N'EXEC MRT.USP_LOAD_FACT_SALES', @retry_attempts = 3, @retry_interval = 5, @on_success_action = 3, @on_fail_action = 2, @flags = 6;


GO
EXECUTE dbo.sp_add_schedule @schedule_name = N'RunDaily', @freq_type = 4, @freq_interval = 1, @active_start_time = 233000;


GO
EXECUTE sp_attach_schedule @job_name = N'Populate_Marts', @schedule_name = N'RunDaily';


GO
EXECUTE dbo.sp_add_jobserver @job_name = N'Populate_Marts';