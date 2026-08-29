USE DWH_ONPREM;


GO
--------------------
-----DIMENSIONS-----
--------------------
IF OBJECT_ID(N'MRT.DIM_Person', N'U') IS NULL
    BEGIN
        CREATE TABLE MRT.DIM_Person (
            --Identity
            [PersonSK]                 INT            IDENTITY (1, 1) NOT NULL PRIMARY KEY,
            [PersonNK]                 INT            NOT NULL,
            --Attributes
            [PersonTypeDescription]    NVARCHAR (50) ,
            [PersonTypeGroup]          NVARCHAR (20) ,
            [PersonType]               NCHAR (2)      NULL,
            [Title]                    NVARCHAR (8)   NULL,
            [FirstName]                NVARCHAR (50)  NULL,
            [MiddleName]               NVARCHAR (50)  NULL,
            [LastName]                 NVARCHAR (50)  NULL,
            [Suffix]                   NVARCHAR (10)  NULL,
            [FullName]                 NVARCHAR (180) NULL,
            [EmailAddress]             NVARCHAR (50)  NULL,
            [EmailPromotionSignUpFlag] INT            NULL,
            [EmailPromotionSignUp]     VARCHAR (3)    NULL,
            [ModifiedDate]             DATETIME2 (7)  NULL,
            ExtractDatetime            DATETIME2 (7)  NOT NULL,
            --SCD T2 Tracking
            [ValidFrom]                DATETIME2 (7)  NOT NULL,
            [ValidTo]                  DATETIME2 (7)  NULL,
            [Valid]                    BIT            DEFAULT 1 NOT NULL,
            [RowHash]                  VARBINARY (32) NULL
        );
        --Index fields used for time-agnostic joins
        CREATE NONCLUSTERED INDEX IX_DIM_Person_PersonNK_Valid
            ON MRT.DIM_Person(PersonNK, Valid);
        --Index fields used for time-based joins
        CREATE NONCLUSTERED INDEX IX_DIM_Person_PersonNK_ValidFrom_ValidTo
            ON MRT.DIM_Person(PersonNK, ValidFrom, ValidTo);
    END


GO
IF NOT EXISTS (SELECT 1
               FROM   MRT.DIM_Person
               WHERE  PersonSK = -1)
    BEGIN
        SET IDENTITY_INSERT MRT.DIM_Person ON;
        INSERT  INTO MRT.DIM_Person (
            PersonSK,
            PersonNK,
            ValidFrom,
            Valid,
            RowHash
        )
        VALUES                     (-1, -1, '1900-01-01', 1, HASHBYTES('SHA2_256', 'FallbackEntityRow'));
        SET IDENTITY_INSERT MRT.DIM_Person OFF;
    END


GO
IF OBJECT_ID(N'MRT.DIM_Person_Address', N'U') IS NULL
    BEGIN
        CREATE TABLE MRT.DIM_Person_Address (
            --Identity
            [PersonAddressSK]                INT            IDENTITY (1, 1) NOT NULL PRIMARY KEY,
            [PersonAddressCNK]               VARCHAR (50)   NOT NULL,
            [PersonNK]                       INT            NOT NULL,
            [PersonAddressNK]                INT            NOT NULL,
            [PersonAddressTypeNK]            INT            NOT NULL,
            [CountryRegionNK]                NVARCHAR (3)   NOT NULL,
            [StateProvinceNK]                INT            NOT NULL,
            --INT_PersonAddressFields
            [AddressLine1]                   NVARCHAR (60)  NULL,
            [AddressLine2]                   NVARCHAR (60)  NULL,
            [City]                           NVARCHAR (30)  NULL,
            [PostalCode]                     NVARCHAR (15)  NULL,
            [SpatialLocation]                GEOGRAPHY      NULL,
            --INT_PersonAddressTypeFields
            [AddressTypeName]                NVARCHAR (50)  NOT NULL,
            --INT_PersonCountryRegion
            [CountryRegionName]              NVARCHAR (50)  NULL,
            --INT_PersonStateProvince
            [StateProvinceCode]              NCHAR (3)      NOT NULL,
            [StateProvinceName]              NVARCHAR (50)  NULL,
            [IsOnlyStateProvinceFlag]        BIT            NULL,
            [IsOnlyStateProvinceDescription] VARCHAR (3)    NULL,
            --SCD T2 Tracking
            [ValidFrom]                      DATETIME2 (7)  NOT NULL,
            [ValidTo]                        DATETIME2 (7)  NULL,
            [Valid]                          BIT            DEFAULT 1 NOT NULL,
            [RowHash]                        VARBINARY (32) NULL
        );
        --Index fields used for time-agnostic joins
        CREATE NONCLUSTERED INDEX IX_DIM_PersonAddress_PersonAddressCNK_Valid
            ON MRT.DIM_Person_Address(PersonAddressCNK, Valid);
    END


GO
IF NOT EXISTS (SELECT 1
               FROM   MRT.DIM_Person_Address
               WHERE  PersonAddressSK = -1)
    BEGIN
        SET IDENTITY_INSERT MRT.DIM_Person_Address ON;
        INSERT  INTO MRT.DIM_Person_Address (
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
        VALUES                             (-1, '-1|-1|-1', -1, -1, -1, 'NA', -1, 'NA', 'NA', '1900-01-01', 1, HASHBYTES('SHA2_256', 'FallbackEntityRow'));
        SET IDENTITY_INSERT MRT.DIM_Person_Address OFF;
    END


GO
IF OBJECT_ID(N'MRT.DIM_Product', N'U') IS NULL
    BEGIN
        CREATE TABLE MRT.DIM_Product (
            ProductSK                INT            IDENTITY (1, 1) PRIMARY KEY,
            ProductNK                INT            NOT NULL,
            ProductName              NVARCHAR (50)  NULL,
            ProductNumber            NVARCHAR (25)  NULL,
            MakeFlag                 BIT            NULL,
            MakeFlagDescription      NVARCHAR (50)  NULL,
            FinishedGoodsFlag        BIT            NULL,
            FinishedGoodsDescription NVARCHAR (50)  NULL,
            Color                    NVARCHAR (15)  NULL,
            SafetyStockLevel         SMALLINT       NULL,
            ReorderPoint             SMALLINT       NULL,
            StandardCost             MONEY          NULL,
            ListPrice                MONEY          NULL,
            Size                     NVARCHAR (5)   NULL,
            SizeUnitMeasureCodeNK    NVARCHAR (3)   NULL,
            WeightUnitMeasureCodeNK  NVARCHAR (3)   NULL,
            Weight                   DECIMAL (8, 2) NULL,
            DaysToManufacture        INT            NULL,
            ProductLine              NVARCHAR (2)   NULL,
            Class                    NVARCHAR (2)   NULL,
            Style                    NVARCHAR (2)   NULL,
            ProductCategoryNK        INT            NULL,
            ProductCategoryName      NVARCHAR (50)  NULL,
            ProductSubcategoryNK     INT            NULL,
            ProductSubCategoryName   NVARCHAR (50)  NULL,
            ProductModelNK           INT            NULL,
            ProductModelName         NVARCHAR (50)  NULL,
            SellStartDate            DATETIME2      NULL,
            SellEndDate              DATETIME2      NULL,
            DiscontinuedDate         DATETIME2      NULL,
            ModifiedDate             DATETIME2      NULL,
            ExtractDatetime          DATETIME2      NOT NULL,
            RowHash                  VARBINARY (32) NULL,
            ValidFrom                DATETIME2      NOT NULL,
            ValidTo                  DATETIME2      NULL,
            Valid                    BIT            DEFAULT 1
        );
        --Index fields used for time-agnostic joins
        CREATE NONCLUSTERED INDEX IX_DIM_Product_ProductNK_Valid
            ON MRT.DIM_Product(ProductNK, Valid);
        --Index fields used for time-based joins
        CREATE NONCLUSTERED INDEX IX_DIM_Product_ProductNK_ValidFrom_ValidTo
            ON MRT.DIM_Product(ProductNK, ValidFrom, ValidTo);
    END


GO
IF OBJECT_ID(N'MRT.DIM_Address', N'U') IS NULL
    BEGIN
        CREATE TABLE MRT.DIM_Address (
            --Keys
            [AddressSK]         INT            IDENTITY (1, 1) PRIMARY KEY,
            [AddressNK]         INT            NOT NULL,
            --SCD-T1
            [AddressLine1]      NVARCHAR (60)  NULL,
            [AddressLine2]      NVARCHAR (60)  NULL,
            [City]              NVARCHAR (30)  NULL,
            [PostalCode]        NVARCHAR (15)  NULL,
            [SpatialLocation]   GEOGRAPHY      NULL,
            [StateProvinceNK]   INT            NULL,
            [StateProvinceCode] NCHAR (3)      NULL,
            [StateProvinceName] NVARCHAR (50)  NULL,
            [CountryRegionNK]   NVARCHAR (3)   NULL,
            [CountryRegionName] NVARCHAR (50)  NULL,
            --Metadata
            [ModifiedDate]      DATETIME2      NULL,
            [ExtractDatetime]   DATETIME2      DEFAULT GETDATE() NULL,
            --Change detection
            [RowHash]           VARBINARY (32) NULL
        );
        --Index fields used for date-agnostic joins
        CREATE NONCLUSTERED INDEX IX_DIM_Address_AddressNK
            ON MRT.DIM_Address(AddressNK);
    END


GO
IF NOT EXISTS (SELECT 1
               FROM   MRT.DIM_Address
               WHERE  AddressSK = -1)
    BEGIN
        SET IDENTITY_INSERT MRT.DIM_Address ON;
        INSERT  INTO MRT.DIM_Address (
            AddressSK,
            AddressNK,
            AddressLine1,
            AddressLine2,
            City,
            PostalCode,
            SpatialLocation,
            StateProvinceNK,
            StateProvinceCode,
            StateProvinceName,
            CountryRegionNK,
            CountryRegionName,
            ModifiedDate,
            ExtractDatetime,
            RowHash
        )
        VALUES                      (-1, -1, 'NA', 'NA', 'NA', 'NA', NULL, -1, 'NA', 'NA', 'NA', 'NA', '1900-01-01', '1900-01-01', HASHBYTES('SHA2_256', 'FallbackEntityRow'));
        SET IDENTITY_INSERT MRT.DIM_Address OFF;
    END


GO
IF NOT EXISTS (SELECT 1
               FROM   MRT.DIM_Product
               WHERE  ProductSK = -1)
    BEGIN
        SET IDENTITY_INSERT MRT.DIM_Product ON;
        INSERT  INTO MRT.DIM_Product (
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
        VALUES                      (-1, -1, 'NA', 'NA', NULL, 'NA', NULL, 'NA', 'NA', NULL, NULL, NULL, NULL, 'NA', 'NA', 'NA', NULL, NULL, 'NA', 'NA', 'NA', -1, 'NA', -1, 'NA', -1, 'NA', '1900-01-01', NULL, NULL, NULL, '1900-01-01', HASHBYTES('SHA2_256', 'FallbackEntityRow'), '1900-01-01', NULL, 1);
        SET IDENTITY_INSERT MRT.DIM_Product OFF;
    END


GO
IF OBJECT_ID(N'MRT.DIM_ShipMethod', N'U') IS NULL
    BEGIN
        CREATE TABLE MRT.DIM_ShipMethod (
            --Keys
            [ShipMethodSK]   INT            IDENTITY (1, 1) PRIMARY KEY,
            [ShipMethodNK]   INT            NOT NULL,
            --SCD-T2 Tracked
            [ShipMethodName] NVARCHAR (50)  NOT NULL,
            [ShipBase]       MONEY          NULL,
            [ShipRate]       MONEY          NULL,
            --Metadata
            [ModifiedDate]   DATETIME2      NULL,
            ExtractDatetime  DATETIME2      DEFAULT GETDATE() NULL,
            --Change detection
            RowHash          VARBINARY (32) NULL,
            --Tracking
            ValidFrom        DATETIME2 (7)  NOT NULL,
            ValidTo          DATETIME2 (7)  NULL,
            Valid            BIT            DEFAULT 1 NOT NULL
        );
        --Index fields used for time-agnostic joins
        CREATE NONCLUSTERED INDEX IX_DIM_ShipMethod_ShipMethodNK_Valid
            ON MRT.DIM_ShipMethod(ShipMethodNK, Valid);
        --Index fields used for time-based joins
        CREATE NONCLUSTERED INDEX IX_DIM_ShipMethod_ShipMethodNK_ValidFrom_ValidTo
            ON MRT.DIM_ShipMethod(ShipMethodNK, ValidFrom, ValidTo);
    END


GO
IF NOT EXISTS (SELECT 1
               FROM   MRT.DIM_ShipMethod
               WHERE  ShipMethodSK = -1)
    BEGIN
        SET IDENTITY_INSERT MRT.DIM_ShipMethod ON;
        INSERT  INTO MRT.DIM_ShipMethod (
            [ShipMethodSK],
            [ShipMethodNK],
            [ShipMethodName],
            [ShipBase],
            [ShipRate],
            [ModifiedDate],
            [ExtractDatetime],
            [RowHash],
            [ValidFrom],
            [ValidTo],
            [Valid]
        )
        VALUES                         (-1, -1, 'NA', NULL, NULL, '1900-01-01', '1900-01-01', HASHBYTES('SHA2_256', 'FallbackEntityRow'), '1900-01-01', NULL, 1);
        SET IDENTITY_INSERT MRT.DIM_ShipMethod OFF;
    END


GO
IF OBJECT_ID(N'MRT.DIM_SalesPerson', N'U') IS NULL
    BEGIN
        CREATE TABLE MRT.DIM_SalesPerson (
            --Keys
            [SalesPersonSK]        INT            IDENTITY (1, 1) PRIMARY KEY,
            [SalesPersonNK]        INT            NOT NULL,
            [TerritoryNK]          INT            NULL,
            --SCD-T1
            [SalesQuota]           MONEY          NULL,
            [Bonus]                MONEY          NULL,
            [CommissionPercentage] SMALLMONEY     NULL,
            [SalesYTD]             MONEY          NULL,
            [SalesLastYear]        MONEY          NULL,
            --Metadata
            [ModifiedDate]         DATETIME2     ,
            [ExtractDatetime]      DATETIME2     ,
            --Change detection
            [RowHash]              VARBINARY (32),
            --Tracking
            [ValidFrom]            DATETIME2      NOT NULL,
            [ValidTo]              DATETIME2      NULL,
            [Valid]                BIT            DEFAULT 1
        );
        --Index fields used for time-agnostic joins
        CREATE NONCLUSTERED INDEX IX_DIM_SalesPerson_SalesPersonNK_Valid
            ON MRT.DIM_SalesPerson(SalesPersonNK, Valid);
        --Index fields used for time-based joins
        CREATE NONCLUSTERED INDEX IX_DIM_SalesPerson_SalesPersonNK_ValidFrom_ValidTo
            ON MRT.DIM_SalesPerson(SalesPersonNK, ValidFrom, ValidTo);
    END


GO
IF NOT EXISTS (SELECT 1
               FROM   MRT.DIM_SalesPerson
               WHERE  SalesPersonSK = -1)
    BEGIN
        SET IDENTITY_INSERT MRT.DIM_SalesPerson ON;
        INSERT  INTO MRT.DIM_SalesPerson (
            SalesPersonSK,
            SalesPersonNK,
            TerritoryNK,
            SalesQuota,
            Bonus,
            CommissionPercentage,
            SalesYTD,
            SalesLastYear,
            ModifiedDate,
            ExtractDatetime,
            RowHash,
            ValidFrom,
            ValidTo,
            Valid
        )
        VALUES                          (-1, -1, -1, 0, 0, 0, 0, 0, '1900-01-01', '1900-01-01', HASHBYTES('SHA2_256', 'FallbackEntityRow'), '1900-01-01', NULL, 1);
        SET IDENTITY_INSERT MRT.DIM_SalesPerson OFF;
    END


GO
IF OBJECT_ID(N'MRT.DIM_CreditCard', N'U') IS NULL
    BEGIN
        CREATE TABLE MRT.DIM_CreditCard (
            [CreditCardSK]    INT            IDENTITY (1, 1) PRIMARY KEY,
            [CreditCardNK]    INT            NOT NULL,
            [CardType]        NVARCHAR (50)  NULL,
            [CardNumber]      NVARCHAR (25)  NULL,
            [ExpMonth]        TINYINT        NULL,
            [ExpYear]         SMALLINT       NULL,
            [ModifiedDate]    DATETIME2      NULL,
            [ExtractDatetime] DATETIME2      DEFAULT GETDATE() NULL,
            [RowHash]         VARBINARY (32) NULL
        );
        CREATE NONCLUSTERED INDEX IX_DIM_CREDITCARD_CREDITCARDNK
            ON MRT.DIM_CreditCard(CreditCardNK);
    END


GO
IF NOT EXISTS (SELECT 1
               FROM   MRT.DIM_CreditCard
               WHERE  CreditCardSK = -1)
    BEGIN
        SET IDENTITY_INSERT MRT.DIM_CreditCard ON;
        INSERT  INTO MRT.DIM_CreditCard (
            [CreditCardSK],
            [CreditCardNK],
            [CardType],
            [CardNumber],
            [ExpMonth],
            [ExpYear],
            [ModifiedDate],
            [ExtractDatetime],
            [RowHash]
        )
        VALUES                         (-1, -1, 'NA', 'NA', NULL, NULL, '1900-01-01', '1900-01-01', HASHBYTES('SHA2_256', 'FallbackEntityRow'));
        SET IDENTITY_INSERT MRT.DIM_CreditCard OFF;
    END


GO
IF OBJECT_ID(N'MRT.DIM_CurrencyRate', N'U') IS NULL
    BEGIN
        CREATE TABLE MRT.DIM_CurrencyRate (
            [CurrencyRateSK]   INT            IDENTITY (1, 1) PRIMARY KEY,
            [CurrencyRateNK]   INT            NOT NULL,
            [CurrencyRateDate] DATETIME2      NULL,
            --Currency FROM
            [FromCurrencyCode] NVARCHAR (3)   NULL,
            [FromCurrencyName] NVARCHAR (50)  NULL,
            --Currency TO
            [ToCurrencyCode]   NVARCHAR (3)   NULL,
            [ToCurrencyName]   NVARCHAR (50)  NULL,
            --Rates
            [AverageRate]      MONEY          NULL,
            [EndOfDayRate]     MONEY          NULL,
            --Metadata
            [ModifiedDate]     DATETIME2      NULL,
            [ExtractDatetime]  DATETIME2      NOT NULL,
            --Change detection
            [RowHash]          VARBINARY (32) NOT NULL
        );
        --Index for time-agnostic joins and lookups
        CREATE NONCLUSTERED INDEX IX_DIM_CURRENCYRATE_CURRENCYRATENK
            ON MRT.DIM_CurrencyRate(CurrencyRateNK);
    END


GO
IF NOT EXISTS (SELECT 1
               FROM   MRT.DIM_CurrencyRate
               WHERE  CurrencyRateSK = -1)
    BEGIN
        SET IDENTITY_INSERT MRT.DIM_CurrencyRate ON;
        INSERT  INTO MRT.DIM_CurrencyRate (
            [CurrencyRateSK],
            [CurrencyRateNK],
            [CurrencyRateDate],
            [FromCurrencyCode],
            [FromCurrencyName],
            [ToCurrencyCode],
            [ToCurrencyName],
            [AverageRate],
            [EndOfDayRate],
            [ModifiedDate],
            [ExtractDatetime],
            [RowHash]
        )
        VALUES                           (-1, -1, '1900-01-01', 'NA', 'NA', 'NA', 'NA', NULL, NULL, '1900-01-01', '1900-01-01', HASHBYTES('SHA2_256', 'FallbackEntityRow'));
        SET IDENTITY_INSERT MRT.DIM_CurrencyRate OFF;
    END


GO
IF OBJECT_ID(N'MRT.DIM_SpecialOffer', N'U') IS NULL
    BEGIN
        CREATE TABLE MRT.Dim_SpecialOffer (
            --Keys
            [SpecialOfferSK]     INT            IDENTITY (1, 1) PRIMARY KEY,
            [SpecialOfferNK]     INT            NOT NULL,
            --SCD-T2 tracked
            [Description]        NVARCHAR (255) NOT NULL,
            [DiscountPercentage] SMALLMONEY     NOT NULL,
            [OfferType]          NVARCHAR (50)  NOT NULL,
            [Category]           NVARCHAR (50)  NOT NULL,
            [StartDate]          DATETIME2      NULL,
            [EndDate]            DATETIME2      NULL,
            [MinQty]             INT            NOT NULL,
            [MaxQty]             INT            NOT NULL,
            --Metadata
            [ModifiedDate]       DATETIME2      NULL,
            [ExtractDatetime]    DATETIME2      DEFAULT GETDATE() NULL,
            --Change detection
            [RowHash]            VARBINARY (32) NULL,
            --Tracking
            [ValidFrom]          DATETIME2      NOT NULL,
            [ValidTo]            DATETIME2      NULL,
            [Valid]              BIT            DEFAULT 1 NOT NULL
        );
        CREATE NONCLUSTERED INDEX IX_DIM_SpecialOffer_SpecialOfferNK_Valid
            ON MRT.DIM_SpecialOffer(SpecialOfferNK, Valid);
        CREATE NONCLUSTERED INDEX IX_DIM_SpecialOffer_SpecialOfferNK_ValidFrom_ValidTo
            ON MRT.DIM_SpecialOffer(SpecialOfferNK, ValidFrom, ValidTo);
    END


GO
IF NOT EXISTS (SELECT 1
               FROM   MRT.DIM_SpecialOffer
               WHERE  SpecialOfferSK = -1)
    BEGIN
        SET IDENTITY_INSERT MRT.DIM_SpecialOffer ON;
        INSERT  INTO MRT.DIM_SpecialOffer (
            SpecialOfferSK,
            SpecialOfferNK,
            [Description],
            DiscountPercentage,
            OfferType,
            Category,
            StartDate,
            EndDate,
            MinQty,
            MaxQty,
            ModifiedDate,
            ExtractDatetime,
            RowHash,
            ValidFrom,
            ValidTo,
            Valid
        )
        VALUES                           (-1, -1, 'NA', 0, 'NA', 'NA', NULL, NULL, 0, 0, '1900-01-01', '1900-01-01', HASHBYTES('SHA2_256', 'FallbackEntityRow'), '1900-01-01', NULL, 1);
        SET IDENTITY_INSERT MRT.DIM_SpecialOffer OFF;
    END


GO
IF OBJECT_ID(N'MRT.DIM_Store', N'U') IS NULL
    BEGIN
        CREATE TABLE MRT.DIM_Store (
            --Keys
            [StoreSK]         INT            IDENTITY (1, 1) PRIMARY KEY,
            [StoreNK]         INT            NOT NULL,
            [SalesPersonSK]   INT            NULL,
            --SCD-T2 tracked
            [StoreName]       NVARCHAR (50)  NOT NULL,
            [BusinessType]    NVARCHAR (5)   NOT NULL,
            [Specialty]       NVARCHAR (50)  NOT NULL,
            --SCD-T1
            [AnnualSales]     MONEY          NOT NULL,
            [AnnualRevenue]   MONEY          NOT NULL,
            [YearOpened]      INT            NULL,
            [EmployeeCount]   INT            NULL,
            --Metadata
            [ModifiedDate]    DATETIME2      NULL,
            [ExtractDatetime] DATETIME2      NOT NULL,
            --Change detection
            [RowHash]         VARBINARY (32) NOT NULL,
            --Tracking
            [ValidFrom]       DATETIME2 (7)  NOT NULL,
            [ValidTo]         DATETIME2 (7)  NULL,
            [Valid]           BIT            DEFAULT 1 NOT NULL
        );
        --Index fields used for time-agnostic joins
        CREATE NONCLUSTERED INDEX IX_DIM_Store_StoreNK_Valid
            ON MRT.DIM_Store(StoreNK, Valid);
        --Index fields used for time-based joins
        CREATE NONCLUSTERED INDEX IX_DIM_Store_StoreNK_ValidFrom_ValidTo
            ON MRT.DIM_Store(StoreNK, ValidFrom, ValidTo);
    END


GO
IF NOT EXISTS (SELECT 1
               FROM   MRT.DIM_Store
               WHERE  StoreSK = -1)
    BEGIN
        SET IDENTITY_INSERT MRT.DIM_Store ON;
        INSERT  INTO MRT.DIM_Store (
            StoreSK,
            StoreNK,
            SalesPersonSK,
            StoreName,
            AnnualSales,
            AnnualRevenue,
            BusinessType,
            Specialty,
            YearOpened,
            EmployeeCount,
            ModifiedDate,
            ExtractDatetime,
            RowHash,
            ValidFrom,
            ValidTo,
            Valid
        )
        VALUES                    (-1, -1, -1, 'NA', 0, 0, 'NA', 'NA', 0, 0, '1900-01-01', '1900-01-01', HASHBYTES('SHA2_256', 'FallbackEntityRow'), '1900-01-01', NULL, 1);
        SET IDENTITY_INSERT MRT.DIM_Store OFF;
    END


GO
IF OBJECT_ID(N'MRT.DIM_Territory', N'U') IS NULL
    BEGIN
        CREATE TABLE MRT.DIM_Territory (
            --Keys
            [TerritorySK]       INT            IDENTITY (1, 1) PRIMARY KEY,
            [TerritoryNK]       INT            NOT NULL,
            --SCD-T2 Tracked
            [TerritoryName]     NVARCHAR (50)  NOT NULL,
            [CountryRegionCode] NVARCHAR (3)   NOT NULL,
            [TerritoryGroup]    NVARCHAR (50)  NOT NULL,
            --SCD-T1
            [SalesYTD]          MONEY          NULL,
            [SalesLastYear]     MONEY          NULL,
            [CostYTD]           MONEY          NULL,
            [CostLastYear]      MONEY          NULL,
            --Metadata
            [ModifiedDate]      DATETIME2      NULL,
            [ExtractDatetime]   DATETIME2      NULL,
            --Change Detection
            [RowHash]           VARBINARY (32) NOT NULL,
            --Tracking
            [ValidFrom]         DATETIME2      NOT NULL,
            [ValidTo]           DATETIME2      NULL,
            [Valid]             BIT            DEFAULT 1 NOT NULL
        );
        --Index fields used for time-agnostic joins
        CREATE NONCLUSTERED INDEX IX_DIM_Territory_TerritoryNK_Valid
            ON MRT.DIM_Territory(TerritoryNK, Valid);
        --Index fields used for time-based joins
        CREATE NONCLUSTERED INDEX IX_DIM_Territory_TerritoryNK_ValidFrom_ValidTo
            ON MRT.DIM_Territory(TerritoryNK, ValidFrom, ValidTo);
    END


GO
IF NOT EXISTS (SELECT 1
               FROM   MRT.DIM_Territory
               WHERE  TerritorySK = -1)
    BEGIN
        SET IDENTITY_INSERT MRT.DIM_Territory ON;
        INSERT  INTO MRT.DIM_Territory (
            TerritorySK,
            TerritoryNK,
            TerritoryName,
            CountryRegionCode,
            TerritoryGroup,
            SalesYTD,
            SalesLastYear,
            CostYTD,
            CostLastYear,
            ModifiedDate,
            ExtractDatetime,
            RowHash,
            ValidFrom,
            ValidTo,
            Valid
        )
        VALUES                        (-1, -1, 'NA', 'NA', 'NA', NULL, NULL, NULL, NULL, '1900-01-01', '1900-01-01', HASHBYTES('SHA2_256', 'FallbackEntityRow'), '1900-01-01', NULL, 1);
        SET IDENTITY_INSERT MRT.DIM_Territory OFF;
    END


GO
IF OBJECT_ID(N'MRT.DIM_Customer', N'U') IS NULL
    BEGIN
        CREATE TABLE MRT.DIM_Customer (
            [CustomerSK]                      INT            IDENTITY (1, 1) PRIMARY KEY,
            [CustomerNK]                      INT            NOT NULL,
            [PersonSK]                        INT            NOT NULL,
            [StoreSK]                         INT            NOT NULL,
            [TerritorySK]                     INT            NOT NULL,
            [AccountNumber]                   VARCHAR (10)   NOT NULL,
            [CustomerType]                    VARCHAR (20)   NOT NULL,
            [StoreName]                       NVARCHAR (50)  NULL,
            [Store_AnnualRevenue]             MONEY          NULL,
            [Store_AnnualSales]               MONEY          NULL,
            [Store_BusinessType]              NVARCHAR (50)  NULL,
            [Store_Specialty]                 NVARCHAR (50)  NULL,
            [Store_YearOpened]                INT            NULL,
            [Store_EmployeeCount]             INT            NULL,
            [PersonTypeDescription]           NVARCHAR (50)  NULL,
            [Individual_FullName]             NVARCHAR (180) NULL,
            [Individual_EmailAddress]         NVARCHAR (50)  NULL,
            [Individual_EmailPromotionSignUp] VARCHAR (3)    NULL,
            [RowHash]                         VARBINARY (32) NOT NULL,
            [ValidFrom]                       DATETIME2 (7)  NOT NULL,
            [ValidTo]                         DATETIME2 (7)  NULL,
            [Valid]                           BIT            DEFAULT 1 NOT NULL
        );
        --Index fields used for time-agnostic joins
        CREATE NONCLUSTERED INDEX IX_DIM_Customer_CustomerNK_Valid
            ON MRT.DIM_Customer(CustomerNK, Valid);
        --Index fields for time-based joins
        CREATE NONCLUSTERED INDEX IX_DIM_Customer_CustomerNK_ValidFrom_ValidTo
            ON MRT.DIM_Customer(CustomerNK, ValidFrom, ValidTo);
    END


GO
IF NOT EXISTS (SELECT 1
               FROM   MRT.DIM_Customer
               WHERE  CustomerSK = -1)
    BEGIN
        SET IDENTITY_INSERT MRT.DIM_Customer ON;
        INSERT  INTO MRT.DIM_Customer (
            CustomerSK,
            CustomerNK,
            PersonSK,
            StoreSK,
            TerritorySK,
            AccountNumber,
            CustomerType,
            StoreName,
            Store_AnnualRevenue,
            Store_AnnualSales,
            Store_BusinessType,
            Store_Specialty,
            Store_YearOpened,
            Store_EmployeeCount,
            PersonTypeDescription,
            Individual_FullName,
            Individual_EmailAddress,
            Individual_EmailPromotionSignUp,
            RowHash,
            ValidFrom,
            ValidTo,
            Valid
        )
        VALUES                       (-1, -1, -1, -1, -1, 'NA', 'NA', 'NA', 0, 0, 'NA', 'NA', NULL, NULL, 'NA', 'NA', 'NA', 'NA', HASHBYTES('SHA2_256', 'FallbackEntityRow'), '1900-01-01', NULL, 1);
        SET IDENTITY_INSERT MRT.DIM_Customer OFF;
    END


GO
--------------------
--------FACTS-------
--------------------
IF OBJECT_ID(N'MRT.Fact_Sales', N'U') IS NULL
    BEGIN
        CREATE TABLE MRT.Fact_Sales (
            [FactSalesSK]                     INT             IDENTITY (1, 1) PRIMARY KEY,
            [SalesOrderNK]                    INT             NOT NULL,
            [SalesOrderDetailNK]              INT             NOT NULL,
            [ProductSK]                       INT             NOT NULL,
            [SpecialOfferSK]                  INT             NOT NULL,
            [BillToAddressSK]                 INT             NOT NULL,
            [ShipToAddressSK]                 INT             NOT NULL,
            [ShipMethodSK]                    INT             NOT NULL,
            [CreditCardSK]                    INT             NOT NULL,
            [CustomerSK]                      INT             NOT NULL,
            [SalesPersonSK]                   INT             NOT NULL,
            [TerritorySK]                     INT             NOT NULL,
            [CurrencyRateSK]                  INT             NOT NULL,
            --Header
            [RevisionNumber]                  TINYINT         NULL,
            [OrderDate]                       DATETIME2       NULL,
            [DueDate]                         DATETIME2       NULL,
            [ShipDate]                        DATETIME2       NULL,
            [StatusDescription]               NVARCHAR (50)   NULL,
            [OnlineOrderFlag]                 BIT             NULL,
            [OnlineOrderDescription]          NVARCHAR (50)   NULL,
            [SalesOrderNumber]                NVARCHAR (25)   NULL,
            [PurchaseOrderNumber]             NVARCHAR (25)   NULL,
            [AccountNumber]                   NVARCHAR (15)   NULL,
            [CreditCardApprovalCode]          NVARCHAR (15)   NULL,
            [SubTotal]                        MONEY           NULL,
            [TaxAmt]                          MONEY           NULL,
            [Freight]                         MONEY           NULL,
            [TotalDue]                        MONEY           NULL,
            [Comment]                         NVARCHAR (128)  NULL,
            --Detail
            [CarrierTrackingNumber]           NVARCHAR (25)   NULL,
            [OrderQty]                        SMALLINT        NULL,
            [UnitPrice]                       MONEY           NULL,
            [UnitPriceDiscount]               MONEY           NULL,
            [LineTotal]                       NUMERIC (38, 6) NULL,
            --Metadata
            [HeaderLastModifiedDate]          DATETIME2       NOT NULL,
            [DetailLastModifiedDate]          DATETIME2       NOT NULL,
            [SalesOrderHeaderExtractDateTime] DATETIME2       NOT NULL,
            [SalesOrderDetailExtractDateTime] DATETIME2       NOT NULL,
            [SalesOrderHeaderHash]            VARBINARY (32)  NULL,
            [SalesOrderDetailHash]            VARBINARY (32)  NULL,
            --Change detection
            [FactSalesHash]                   VARBINARY (32)  NULL CONSTRAINT UQ_FactSales_SalesOrderDetailNK UNIQUE (SalesOrderDetailNK) --Grain protection of one-row-per-sale
        ); --Constraints
        --Index on DIMensions for better future join performance.
        CREATE NONCLUSTERED INDEX IX_FactSales_ProductSK
            ON MRT.Fact_Sales(ProductSK);
        CREATE NONCLUSTERED INDEX IX_FactSales_SalesPersonSK
            ON MRT.Fact_Sales(SalesPersonSK);
        CREATE NONCLUSTERED INDEX IX_FactSales_CustomerSK
            ON MRT.Fact_Sales(CustomerSK);
        CREATE NONCLUSTERED INDEX IX_FactSales_TerritorySK
            ON MRT.Fact_Sales(TerritorySK);
        CREATE NONCLUSTERED INDEX IX_FactSales_SpecialOfferSK
            ON MRT.Fact_Sales(SpecialOfferSK);
        CREATE NONCLUSTERED INDEX IX_FactSales_ShipMethodSK
            ON MRT.Fact_Sales(ShipMethodSK);
        CREATE NONCLUSTERED INDEX IX_FactSales_CreditCardSK
            ON MRT.Fact_Sales(CreditCardSK);
        CREATE NONCLUSTERED INDEX IX_FactSales_BillToAddressSK
            ON MRT.Fact_Sales(BillToAddressSK);
        CREATE NONCLUSTERED INDEX IX_FactSales_ShipToAddressSK
            ON MRT.Fact_Sales(ShipToAddressSK);
        CREATE NONCLUSTERED INDEX IX_FactSales_CurrencyRateSK
            ON MRT.Fact_Sales(CurrencyRateSK);
        /**Below index overkill for AdventureWorks but
    included as example of columnstore to improve performance
    on common expected analyst quieries like sum(linetotal)
    by orderdate, avg(linetotal) by SalesPerson, etc...*/
        CREATE NONCLUSTERED COLUMNSTORE INDEX IX_FactSales_Columnstore
            ON MRT.Fact_Sales(ProductSK, CustomerSK, SalesPersonSK, TerritorySK, OrderDate, OrderQty, UnitPrice, UnitPriceDiscount, LineTotal);
    END