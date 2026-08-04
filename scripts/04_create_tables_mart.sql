USE DWH_ONPREM;
GO

IF OBJECT_ID (N'MRT.Dim_Person', N'U') IS NULL 
BEGIN
    CREATE TABLE MRT.DIM_Person
    (
        --Identity
        [PersonSK] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [PersonNK] INT NOT NULL,

        --Attributes
        [PersonTypeDescription] NVARCHAR(50),
        [PersonTypeGroup] NVARCHAR(20),
        [PersonType] NCHAR(2) NULL,
        [Title] NVARCHAR(8) NULL,
        [FirstName] NVARCHAR(50) NULL,
        [MiddleName] NVARCHAR(50) NULL,
        [LastName] NVARCHAR(50) NULL,
        [Suffix] NVARCHAR(10) NULL,
        [FullName] NVARCHAR(180) NULL,
        [EmailAddress] NVARCHAR(50) NULL,
        [EmailPromotionSignUpFlag] INT NULL,
        [EmailPromotionSignUp] VARCHAR(3),
        [ModifiedDate] DATETIME2(7) NULL,
        ExtractDatetime DATETIME2(7) NULL DEFAULT GETDATE(),

        --SCD T2 Tracking
        [ValidFrom] DATETIME2(7) NOT NULL,
        [ValidTo] DATETIME2(7) NULL,
        [Valid] BIT NOT NULL DEFAULT 1,
        [RowHash] CHAR(64) NULL
    )
END;
GO

