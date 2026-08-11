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
        [RowHash] VARBINARY(32) NULL
    )
END;
GO

SET IDENTITY_INSERT MRT.DIM_Person ON;

INSERT INTO MRT.DIM_Person
    (
    PersonSK,
    PersonNK,
    ValidFrom,
    Valid,
    RowHash
    )
VALUES
    (
        -1,
        -1,
        '1900-01-01',
        1,
        HASHBYTES('SHA2_256', CONCAT_WS('|',-1,-1,'1900-01-01',1)));

SET IDENTITY_INSERT MRT.DIM_Person OFF;
GO

IF OBJECT_ID (N'MRT.Dim_Person_Address', N'U') IS NULL 
BEGIN
    CREATE TABLE MRT.DIM_Person_Address
    (
        --Identity
        [PersonAddressSK] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [PersonAddressCNK] VARCHAR(50) NOT NULL,
        [PersonNK] INT NOT NULL,
        [PersonAddressNK] INT NOT NULL,
        [PersonAddressTypeNK] INT NOT NULL,
        [CountryRegionNK] NVARCHAR(3) NOT NULL,
        [StateProvinceNK] INT NOT NULL,
        --INT_PersonAddressFields
        [AddressLine1] NVARCHAR(60) NULL,
        [AddressLine2] NVARCHAR(60) NULL,
        [City] NVARCHAR(30) NULL,
        [PostalCode] NVARCHAR(15) NULL,
        [SpatialLocation] GEOGRAPHY NULL,
        --INT_PersonAddressTypeFields
        [AddressTypeName] NVARCHAR(50) NOT NULL,
        --INT_PersonCountryRegion
        [CountryRegionName] NVARCHAR(50) NULL,
        --INT_PersonStateProvince
        [StateProvinceCode] nchar(3) NOT NULL,
        [StateProvinceName] NVARCHAR(50) NULL,
        [IsOnlyStateProvinceFlag] BIT NULL,
        [IsOnlyStateProvinceDescription] VARCHAR(3) NULL,
        --SCD T2 Tracking
        [ValidFrom] DATETIME2(7) NOT NULL,
        [ValidTo] DATETIME2(7) NULL,
        [Valid] BIT NOT NULL DEFAULT 1,
        [RowHash] VARBINARY(32) NULL
    )
END;
GO

SET IDENTITY_INSERT MRT.DIM_Person_Address ON;

INSERT INTO MRT.DIM_Person_Address
    (
    PersonAddressSK,
    PersonAddressCNK,
    PersonNK,
    PersonAddressNK,
    PersonAddressTypeNK,
    CountryRegionNK,
    StateProvinceNK,
    AddressTypeName,
    StateProvinceCode,
    ValidFrom,
    Valid,
    RowHash
    )
VALUES
    (
        -1,
        '-1|-1|-1',
        -1,
        -1,
        -1,
        'NA',
        -1,
        'NA',
        'NA',
        '1900-01-01',
        1,
        HASHBYTES('SHA2_256', CONCAT_WS('|', -1, -1, '1900-01-01', 1))
);

SET IDENTITY_INSERT MRT.DIM_Person_Address OFF;
GO

IF OBJECT_ID (N'MRT.Dim_Product', N'U') IS NULL 
BEGIN
    CREATE TABLE MRT.Dim_Product(
        ProductSK INT IDENTITY(1,1) PRIMARY KEY,
        ProductNK INT NOT NULL,
        ProductName NVARCHAR(50) NULL,
        ProductNumber NVARCHAR(25) NULL,
        MakeFlag BIT NULL,
        MakeFlagDescription NVARCHAR(50) NULL,
        FinishedGoodsFlag BIT NULL,
        FinishedGoodsDescription NVARCHAR(50) NULL,
        Color NVARCHAR(15) NULL,
        SafetyStockLevel SMALLINT NULL,
        ReorderPoint SMALLINT NULL,
        StandardCost MONEY NULL,
        ListPrice MONEY NULL,
        Size NVARCHAR(5) NULL,
        SizeUnitMeasureCodeNK NVARCHAR(3) NULL,
        WeightUnitMeasureCodeNK NVARCHAR(3) NULL,
        Weight DECIMAL(8,2) NULL,
        DaysToManufacture INT NULL,
        ProductLine NVARCHAR(2) NULL,
        Class NVARCHAR(2) NULL,
        Style NVARCHAR(2) NULL,
        ProductCategoryNK INT NULL,
        ProductCategoryName NVARCHAR(50) NULL,
        ProductSubcategoryNK INT NULL,
        ProductSubCategoryName NVARCHAR(50) NULL,
        ProductModelNK INT NULL,
        ProductModelName NVARCHAR(50) NULL,
        SellStartDate DATETIME2 NULL,
        SellEndDate DATETIME2 NULL,
        DiscontinuedDate DATETIME2 NULL,
        ModifiedDate DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL,
        ValidFrom DATETIME2 NOT NULL,
        ValidTo DATETIME2 NULL,
        Valid BIT DEFAULT 1
    )
END;
GO

SET IDENTITY_INSERT MRT.Dim_Product ON;
    INSERT INTO MRT.Dim_Product
    (
        ProductSK,
        ProductNK,
        ProductName,
        ProductNumber,
        MakeFlag,
        MakeFlagDescription,
        FinishedGoodsFlag,
        FinishedGoodsDescription,
        Color,
        SafetyStockLevel,
        ReorderPoint,
        StandardCost,
        ListPrice,
        Size,
        SizeUnitMeasureCodeNK,
        WeightUnitMeasureCodeNK,
        Weight,
        DaysToManufacture,
        ProductLine,
        Class,
        Style,
        ProductCategoryNK,
        ProductCategoryName,
        ProductSubcategoryNK,
        ProductSubCategoryName,
        ProductModelNK,
        ProductModelName,
        SellStartDate,
        SellEndDate,
        DiscontinuedDate,
        ModifiedDate,
        ExtractDatetime,
        RowHash,
        ValidFrom,
        ValidTo,
        Valid
    )
    VALUES
    (
        -1,
        -1,
        'NA',
        'NA',
        NULL,
        'NA',
        NULL,
        'NA',
        'NA',
        NULL,
        NULL,
        NULL,
        NULL,
        'NA',
        'NA',
        'NA',
        NULL,
        NULL,
        'NA',
        'NA',
        'NA',
        -1,
        'NA',
        -1,
        'NA',
        -1,
        'NA',
        '1900-01-01',
        NULL,
        NULL,
        NULL,
        '1900-01-01',
        HASHBYTES('SHA2_256', CONCAT_WS('|', -1, -1, '1900-01-01', 1)),
        '1900-01-01',
        NULL,
        1
    )

SET IDENTITY_INSERT MRT.Dim_Product OFF;
GO
