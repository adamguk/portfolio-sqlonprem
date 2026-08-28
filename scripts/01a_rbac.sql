USE DWH_ONPREM;


GO
IF NOT EXISTS (SELECT *
               FROM   sys.database_principals
               WHERE  name = N'etl_serviceaccount'
                      AND type = 'R')
    CREATE ROLE etl_serviceaccount;


GO
IF NOT EXISTS (SELECT *
               FROM   sys.database_principals
               WHERE  name = N'principal_dataengineer'
                      AND type = 'R')
    CREATE ROLE principal_dataengineer;


GO
IF NOT EXISTS (SELECT *
               FROM   sys.database_principals
               WHERE  name = N'dataengineer'
                      AND type = 'R')
    CREATE ROLE dataengineer;


GO
IF NOT EXISTS (SELECT *
               FROM   sys.database_principals
               WHERE  name = N'junior_dataengineer'
                      AND type = 'R')
    CREATE ROLE junior_dataengineer;


GO
IF NOT EXISTS (SELECT *
               FROM   sys.database_principals
               WHERE  name = N'bianalyst'
                      AND type = 'R')
    CREATE ROLE bianalyst;


GO
--Service account used to run SSIS, Agents, USPs
GRANT EXECUTE
    ON SCHEMA::MRT TO etl_serviceaccount;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON SCHEMA::STG TO etl_serviceaccount;

GRANT SELECT
    ON SCHEMA::INT TO etl_serviceaccount;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON SCHEMA::MRT TO etl_serviceaccount;


GO
--Princple Data Engineer role owns database and authorises new users
ALTER ROLE db_securityadmin ADD MEMBER principal_dataengineer;

ALTER ROLE db_accessadmin ADD MEMBER principal_dataengineer;

ALTER ROLE db_owner ADD MEMBER principal_dataengineer;


GO
--Data Engineer role to manage db excluding administration and drops
ALTER ROLE db_ddladmin ADD MEMBER dataengineer;

ALTER ROLE db_datawriter ADD MEMBER dataengineer;

ALTER ROLE db_datareader ADD MEMBER dataengineer;

GRANT EXECUTE
    ON SCHEMA::MRT TO dataengineer;


GO
--Junior data engineer still learning the ropes
ALTER ROLE db_datareader ADD MEMBER junior_dataengineer;

GRANT CREATE VIEW TO junior_dataengineer;

GRANT ALTER
    ON SCHEMA::INT TO junior_dataengineer;


GO
--Analysts just access to marts
GRANT SELECT
    ON SCHEMA::MRT TO bianalyst;