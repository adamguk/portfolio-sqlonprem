IF OBJECT_ID(N'ETL.LoadAudit', N'U') IS NULL
    BEGIN
        CREATE TABLE ETL.LoadAudit (
            [LoadAuditID]         INT            IDENTITY (1, 1) PRIMARY KEY,
            [TableName]           NVARCHAR (128) NOT NULL,
            [LoadPattern]         NVARCHAR (50)  NOT NULL, -- 'Truncate & Replace', 'Watermark Append', 'Watermark Merge', etc.
            [RowsAffected]        INT            NULL,
            [ExecutionID]         BIGINT         NULL,
            [LoggedAtUTC]         DATETIME2 (7)  DEFAULT GETUTCDATE() NOT NULL,
            [Status]              NVARCHAR (20)  NOT NULL, -- 'Success', 'Failure'
            [MaxModifiedDateSeen] DATETIME2      DEFAULT '1900-01-01' NOT NULL
        );
    END