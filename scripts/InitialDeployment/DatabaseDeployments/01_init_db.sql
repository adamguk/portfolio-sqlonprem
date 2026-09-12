USE master;
GO

IF NOT EXISTS (
    SELECT name
FROM sys.databases
WHERE name = N'DWH_ONPREM'
)  
BEGIN
    CREATE DATABASE DWH_ONPREM;
END
GO

ALTER DATABASE DWH_ONPREM SET RECOVERY SIMPLE; --small logging given etl can be redeployed
ALTER DATABASE DWH_ONPREM SET AUTO_CLOSE OFF; --stop server closing the DB when idle (performance protection)
ALTER DATABASE DWH_ONPREM SET AUTO_SHRINK OFF; --stop server auto shrinking files (performance protection)
ALTER DATABASE DWH_ONPREM SET AUTO_UPDATE_STATISTICS ON; --keep stats current with regular load ops (accurate run planning)
ALTER DATABASE DWH_ONPREM SET AUTO_CREATE_STATISTICS ON; --keep stats current with regular load ops (accurate run planning)
ALTER DATABASE DWH_ONPREM SET READ_COMMITTED_SNAPSHOT ON; --prevent analyst/bi-tool queries blocking ETL/write scripts (performance protection)
ALTER DATABASE DWH_ONPREM SET PAGE_VERIFY CHECKSUM; --ensure quality checking against corrupted data
ALTER DATABASE DWH_ONPREM SET ANSI_NULLS ON; --predictable NULL operators
ALTER DATABASE DWH_ONPREM SET QUOTED_IDENTIFIER ON; --predictable column referencing
GO

USE DWH_ONPREM;
GO

IF NOT EXISTS (
    SELECT *
FROM sys.schemas
WHERE name = N'ETL'
)
EXEC('CREATE SCHEMA ETL');
GO

IF NOT EXISTS (
    SELECT *
FROM sys.schemas
WHERE name = N'STG'
)
EXEC('CREATE SCHEMA STG');
GO

IF NOT EXISTS (
    SELECT *
FROM sys.schemas
WHERE name = N'INT'
)
EXEC('CREATE SCHEMA INT');
GO

IF NOT EXISTS (
    SELECT *
FROM sys.schemas
WHERE name = N'MRT'
)
EXEC('CREATE SCHEMA MRT');
GO

