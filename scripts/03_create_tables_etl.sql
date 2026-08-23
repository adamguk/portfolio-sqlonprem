IF OBJECT_ID (N'ETL.LoadAudit',N'U') IS NULL
BEGIN
    CREATE TABLE ETL.LoadAudit
    (
        LoadAuditID INT IDENTITY(1,1) PRIMARY KEY,
        TableName NVARCHAR(128) NOT NULL,
        LoadPattern NVARCHAR(50) NOT NULL,  -- 'Truncate & Replace', 'Watermark', 'Merge', etc.
        RowsAffected INT NULL,
        LoadStartDatetime DATETIME2 NOT NULL,
        LoadEndDatetime DATETIME2 NOT NULL,
        Status NVARCHAR(20) NOT NULL  -- 'Success', 'Failed'
    )
END;
GO