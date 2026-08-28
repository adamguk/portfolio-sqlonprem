USE DWH_ONPREM;


GO
/*------------------
LOAD AUDITING
------------------*/
CREATE OR ALTER PROCEDURE ETL.USP_LOAD_AUDIT
@TableName NVARCHAR (128), @LoadPattern NVARCHAR (50), @RowsAffected INT, @Status NVARCHAR (20), @MaxModifiedDateSeen DATETIME2 (7)=NULL, @ExecutionID BIGINT=NULL
AS
BEGIN
    INSERT  INTO ETL.LoadAudit (
        TableName,
        LoadPattern,
        RowsAffected,
        Status,
        MaxModifiedDateSeen,
        ExecutionID
    )
    VALUES                    (@TableName, @LoadPattern, @RowsAffected, @Status, @MaxModifiedDateSeen, @ExecutionID);
END


GO
/*------------------
LOAD MART DIMENSIONS
------------------*/
CREATE OR ALTER PROCEDURE MRT.USP_LOAD_DIM_PERSON
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @ExecutionTime AS DATETIME2 (7) = GETDATE();
    BEGIN TRY
        BEGIN TRANSACTION;
        --Invalidate out-of-date SCD-T2 records
        UPDATE dim
        SET    dim.ValidTo = @ExecutionTime,
               dim.Valid   = 0
        FROM   MRT.DIM_Person AS dim
               INNER JOIN
               INT.Person_Person AS new
               ON dim.PersonNK = new.PersonNK
        WHERE  dim.Valid = 1
               AND dim.RowHash <> new.RowHash;
        INSERT INTO MRT.DIM_Person (
            PersonNK,
            PersonType,
            PersonTypeDescription,
            PersonTypeGroup,
            Title,
            FirstName,
            MiddleName,
            LastName,
            Suffix,
            FullName,
            EmailAddress,
            EmailPromotionSignUpFlag,
            EmailPromotionSignUp,
            ModifiedDate,
            ExtractDatetime,
            ValidFrom,
            ValidTo,
            Valid,
            RowHash
        )
        SELECT p.PersonNK,
               p.PersonType,
               p.PersonTypeDescription,
               p.PersonTypeGroup,
               p.Title,
               p.FirstName,
               p.MiddleName,
               p.LastName,
               p.Suffix,
               p.FullName,
               p.EmailAddress,
               p.EmailPromotionSignUpFlag,
               p.EmailPromotionSignUp,
               p.ModifiedDate,
               p.ExtractDatetime,
               @ExecutionTime AS ValidFrom,
               NULL AS ValidTo,
               1 AS Valid,
               p.RowHash
        FROM   INT.Person_Person AS p
               LEFT OUTER JOIN
               MRT.DIM_Person AS dim
               ON p.PersonNK = dim.PersonNK
                  AND dim.Valid = 1
        WHERE  dim.PersonSK IS NULL;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        THROW;
    END CATCH
END


GO
CREATE OR ALTER PROCEDURE MRT.USP_LOAD_DIM_PERSON_ADDRESS
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @ExecutionTime AS DATETIME2 (7) = GETDATE();
    BEGIN TRY
        BEGIN TRANSACTION;
        --Invalidate out-of-date SCD-T2 records
        UPDATE dim
        SET    dim.ValidTo = @ExecutionTime,
               dim.Valid   = 0
        FROM   MRT.DIM_Person_Address AS dim
               INNER JOIN
               INT.Person_Address_Joined AS new
               ON dim.PersonAddressCNK = new.PersonAddressCNK
        WHERE  dim.Valid = 1
               AND dim.RowHash <> new.NewRowHash;
        INSERT INTO MRT.DIM_Person_Address (
            PersonNK,
            PersonAddressCNK,
            PersonAddressTypeNK,
            PersonAddressNK,
            CountryRegionNK,
            StateProvinceNK,
            AddressLine1,
            AddressLine2,
            City,
            PostalCode,
            SpatialLocation,
            AddressTypeName,
            CountryRegionName,
            StateProvinceCode,
            StateProvinceName,
            IsOnlyStateProvinceFlag,
            IsOnlyStateProvinceDescription,
            ValidFrom,
            ValidTo,
            Valid,
            RowHash
        )
        SELECT pj.PersonNK,
               pj.PersonAddressCNK,
               pj.PersonAddressTypeNK,
               pj.PersonAddressNK,
               pj.CountryRegionNK,
               pj.StateProvinceNK,
               pj.AddressLine1,
               pj.AddressLine2,
               pj.City,
               pj.PostalCode,
               pj.SpatialLocation,
               pj.AddressTypeName,
               pj.CountryRegionName,
               pj.StateProvinceCode,
               pj.StateProvinceName,
               pj.IsOnlyStateProvinceFlag,
               pj.IsOnlyStateProvinceDescription,
               @ExecutionTime AS ValidFrom,
               NULL AS ValidTo,
               1 AS Valid,
               NewRowHash
        FROM   INT.Person_Address_Joined AS pj
               LEFT OUTER JOIN
               MRT.DIM_Person_Address AS dim
               ON pj.PersonAddressCNK = dim.PersonAddressCNK
                  AND dim.Valid = 1
        WHERE  dim.PersonAddressSK IS NULL;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        THROW;
    END CATCH
END


GO
CREATE OR ALTER PROCEDURE MRT.USP_LOAD_DIM_ADDRESS
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        --Overwrite changed rows in place (Type 1 — no history kept)
        UPDATE dim
        SET    dim.AddressLine1      = new.AddressLine1,
               dim.AddressLine2      = new.AddressLine2,
               dim.City              = new.City,
               dim.PostalCode        = new.PostalCode,
               dim.SpatialLocation   = new.SpatialLocation,
               dim.StateProvinceNK   = new.StateProvinceNK,
               dim.StateProvinceCode = new.StateProvinceCode,
               dim.StateProvinceName = new.StateProvinceName,
               dim.CountryRegionNK   = new.CountryRegionNK,
               dim.CountryRegionName = new.CountryRegionName,
               dim.ModifiedDate      = new.ModifiedDate,
               dim.ExtractDatetime   = new.ExtractDatetime,
               dim.RowHash           = new.RowHash
        FROM   MRT.DIM_Address AS dim
               INNER JOIN
               INT.Address AS new
               ON dim.AddressNK = new.AddressNK
        WHERE  dim.RowHash <> new.RowHash;
        --Insert brand-new addresses
        INSERT INTO MRT.DIM_Address (
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
        SELECT new.AddressNK,
               new.AddressLine1,
               new.AddressLine2,
               new.City,
               new.PostalCode,
               new.SpatialLocation,
               new.StateProvinceNK,
               new.StateProvinceCode,
               new.StateProvinceName,
               new.CountryRegionNK,
               new.CountryRegionName,
               new.ModifiedDate,
               new.ExtractDatetime,
               new.RowHash
        FROM   INT.Address AS new
               LEFT OUTER JOIN
               MRT.DIM_Address AS dim
               ON new.AddressNK = dim.AddressNK
        WHERE  dim.AddressSK IS NULL;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        THROW;
    END CATCH
END


GO
CREATE OR ALTER PROCEDURE MRT.USP_LOAD_DIM_PRODUCT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @ExecutionTime AS DATETIME2 (7) = GETDATE();
    BEGIN TRY
        BEGIN TRANSACTION;
        --Invalidate out-of-date SCD-T2 records
        UPDATE dim
        SET    dim.ValidTo = @ExecutionTime,
               dim.Valid   = 0
        FROM   MRT.DIM_Product AS dim
               INNER JOIN
               INT.Production_Product AS new
               ON new.ProductNK = dim.ProductNK
        WHERE  dim.Valid = 1
               AND dim.RowHash <> new.RowHash;
        --Insert new/changed SCDT2 records
        INSERT INTO MRT.DIM_Product (
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
        SELECT new.ProductNK,
               new.ProductName,
               new.ProductNumber,
               new.MakeFlag,
               new.MakeFlagDescription,
               new.FinishedGoodsFlag,
               new.FinishedGoodsDescription,
               new.Color,
               new.SafetyStockLevel,
               new.ReorderPoint,
               new.StandardCost,
               new.ListPrice,
               new.Size,
               new.SizeUnitMeasureCodeNK,
               new.WeightUnitMeasureCodeNK,
               new.Weight,
               new.DaysToManufacture,
               new.ProductLine,
               new.Class,
               new.Style,
               new.ProductCategoryNK,
               new.ProductCategoryName,
               new.ProductSubcategoryNK,
               new.ProductSubCategoryName,
               new.ProductModelNK,
               new.ProductModelName,
               new.SellStartDate,
               new.SellEndDate,
               new.DiscontinuedDate,
               new.ModifiedDate,
               new.ExtractDatetime,
               new.RowHash,
               @ExecutionTime AS ValidFrom,
               NULL AS ValidTo,
               1 AS Valid
        FROM   INT.Production_Product AS new
               LEFT OUTER JOIN
               MRT.DIM_Product AS dim
               ON dim.ProductNK = new.ProductNK
                  AND dim.Valid = 1
        WHERE  dim.ProductSK IS NULL;
        --Update SCDT1 records
        UPDATE dim
        SET    dim.ProductNumber     = new.ProductNumber,
               dim.SafetyStockLevel  = new.SafetyStockLevel,
               dim.ReorderPoint      = new.ReorderPoint,
               dim.DaysToManufacture = new.DaysToManufacture,
               dim.ModifiedDate      = new.ModifiedDate,
               dim.ExtractDatetime   = new.ExtractDatetime
        FROM   MRT.DIM_Product AS dim
               INNER JOIN
               INT.Production_Product AS new
               ON dim.ProductNK = new.ProductNK
        WHERE  dim.Valid = 1;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        THROW;
    END CATCH
END


GO
CREATE OR ALTER PROCEDURE MRT.USP_LOAD_DIM_SHIPMETHOD
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @ExecutionTime AS DATETIME2 (7) = GETDATE();
    BEGIN TRY
        BEGIN TRANSACTION;
        --Invalidate out-of-date SCD-T2 records
        UPDATE dim
        SET    dim.ValidTo = @ExecutionTime,
               dim.Valid   = 0
        FROM   MRT.DIM_ShipMethod AS dim
               INNER JOIN
               INT.Purchasing_ShipMethod AS new
               ON dim.ShipMethodNK = new.ShipMethodNK
        WHERE  dim.Valid = 1
               AND dim.RowHash <> new.RowHash;
        --Insert new & updated record
        INSERT INTO MRT.DIM_ShipMethod (
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
        SELECT new.[ShipMethodNK],
               new.[ShipMethodName],
               new.[ShipBase],
               new.[ShipRate],
               new.[ModifiedDate],
               new.[ExtractDatetime],
               new.[RowHash],
               @ExecutionTime AS ValidFrom,
               NULL AS ValidTo,
               1 AS Valid
        FROM   INT.Purchasing_ShipMethod AS new
               LEFT OUTER JOIN
               MRT.DIM_ShipMethod AS dim
               ON new.ShipMethodNK = dim.ShipMethodNK
                  AND dim.Valid = 1
        WHERE  dim.ShipMethodSK IS NULL;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        THROW;
    END CATCH
END


GO
CREATE OR ALTER PROCEDURE MRT.USP_LOAD_DIM_CREDITCARD
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        --scd-t1 updates
        UPDATE dim
        SET    dim.[CardType]        = new.[CardType],
               dim.[CardNumber]      = new.[CardNumber],
               dim.[ExpMonth]        = new.[ExpMonth],
               dim.[ExpYear]         = new.[ExpYear],
               dim.[ModifiedDate]    = new.[ModifiedDate],
               dim.[ExtractDatetime] = new.[ExtractDatetime],
               dim.[RowHash]         = new.[RowHash]
        FROM   MRT.DIM_CreditCard AS dim
               INNER JOIN
               INT.Sales_CreditCard AS new
               ON dim.CreditCardNK = new.CreditCardNK
        WHERE  dim.RowHash <> new.RowHash;
        --new records
        INSERT INTO MRT.DIM_CreditCard (
            [CreditCardNK],
            [CardType],
            [CardNumber],
            [ExpMonth],
            [ExpYear],
            [ModifiedDate],
            [ExtractDatetime],
            [RowHash]
        )
        SELECT new.[CreditCardNK],
               new.[CardType],
               new.[CardNumber],
               new.[ExpMonth],
               new.[ExpYear],
               new.[ModifiedDate],
               new.[ExtractDatetime],
               new.[RowHash]
        FROM   INT.Sales_CreditCard AS new
               LEFT OUTER JOIN
               MRT.DIM_CreditCard AS dim
               ON new.CreditCardNK = dim.CreditCardNK
        WHERE  dim.CreditCardSK IS NULL;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        THROW;
    END CATCH
END


GO
CREATE OR ALTER PROCEDURE MRT.USP_LOAD_DIM_CURRENCYRATE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @ExecutionTime AS DATETIME2 (7) = GETDATE();
    BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE dim
        SET    dim.[CurrencyRateDate] = new.[CurrencyRateDate],
               dim.[FromCurrencyCode] = new.[FromCurrencyCode],
               dim.[FromCurrencyName] = new.[FromCurrencyName],
               dim.[ToCurrencyCode]   = new.[ToCurrencyCode],
               dim.[ToCurrencyName]   = new.[ToCurrencyName],
               dim.[AverageRate]      = new.[AverageRate],
               dim.[EndOfDayRate]     = new.[EndOfDayRate],
               dim.[ModifiedDate]     = new.[ModifiedDate],
               dim.[ExtractDatetime]  = new.[ExtractDatetime],
               dim.[RowHash]          = new.[RowHash]
        FROM   MRT.DIM_CurrencyRate AS dim
               INNER JOIN
               INT.Sales_CurrencyRate AS new
               ON dim.CurrencyRateNK = new.CurrencyRateNK
        WHERE  dim.RowHash <> new.RowHash;
        INSERT INTO MRT.DIM_CurrencyRate (
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
        SELECT new.[CurrencyRateNK],
               new.[CurrencyRateDate],
               new.[FromCurrencyCode],
               new.[FromCurrencyName],
               new.[ToCurrencyCode],
               new.[ToCurrencyName],
               new.[AverageRate],
               new.[EndOfDayRate],
               new.[ModifiedDate],
               new.[ExtractDatetime],
               new.[RowHash]
        FROM   INT.Sales_CurrencyRate AS new
               LEFT OUTER JOIN
               MRT.DIM_CurrencyRate AS dim
               ON new.CurrencyRateNK = dim.CurrencyRateNK
        WHERE  dim.CurrencyRateSK IS NULL;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        THROW;
    END CATCH
END


GO
CREATE OR ALTER PROCEDURE MRT.USP_LOAD_DIM_SALESPERSON
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @ExecutionTime AS DATETIME2 (7) = GETDATE();
    BEGIN TRY
        BEGIN TRANSACTION;
        --Invalidate out-of-date SCD-T2 records
        UPDATE dim
        SET    dim.ValidTo = @ExecutionTime,
               dim.Valid   = 0
        FROM   MRT.DIM_SalesPerson AS dim
               INNER JOIN
               INT.SalesPerson AS new
               ON dim.SalesPersonNK = new.SalesPersonNK
        WHERE  dim.Valid = 1
               AND dim.RowHash <> new.RowHash;
        --Insert new & updated records
        INSERT INTO MRT.DIM_SalesPerson (
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
        SELECT new.SalesPersonNK,
               new.TerritoryNK,
               new.SalesQuota,
               new.Bonus,
               new.CommissionPercentage,
               new.SalesYTD,
               new.SalesLastYear,
               new.ModifiedDate,
               new.ExtractDatetime,
               new.RowHash,
               @ExecutionTime AS ValidFrom,
               NULL AS ValidTo,
               1 AS Valid
        FROM   INT.SalesPerson AS new
               LEFT OUTER JOIN
               MRT.DIM_SalesPerson AS dim
               ON dim.SalesPersonNK = new.SalesPersonNK
                  AND dim.Valid = 1
        WHERE  dim.SalesPersonSK IS NULL;
        --Update existing valid rows for type 1 fields
        UPDATE dim
        SET    dim.SalesQuota           = new.SalesQuota,
               dim.Bonus                = new.Bonus,
               dim.CommissionPercentage = new.CommissionPercentage,
               dim.SalesYTD             = new.SalesYTD,
               dim.SalesLastYear        = new.SalesLastYear,
               dim.ModifiedDate         = new.ModifiedDate,
               dim.ExtractDatetime      = new.ExtractDatetime
        FROM   MRT.DIM_SalesPerson AS dim
               INNER JOIN
               INT.SalesPerson AS new
               ON dim.SalesPersonNK = new.SalesPersonNK
        WHERE  dim.Valid = 1;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        THROW;
    END CATCH
END


GO
CREATE OR ALTER PROCEDURE MRT.USP_LOAD_DIM_SPECIALOFFER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @ExecutionTime AS DATETIME2 (7) = GETDATE();
    BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE dim
        SET    dim.ValidTo = @ExecutionTime,
               dim.Valid   = 0
        FROM   MRT.DIM_SpecialOffer AS dim
               INNER JOIN
               INT.Sales_SpecialOffer AS new
               ON dim.SpecialOfferNK = new.SpecialOfferNK
        WHERE  dim.Valid = 1
               AND dim.RowHash <> new.RowHash;
        INSERT INTO MRT.DIM_SpecialOffer (
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
        SELECT new.SpecialOfferNK,
               new.[Description],
               new.DiscountPercentage,
               new.OfferType,
               new.Category,
               new.StartDate,
               new.EndDate,
               new.MinQty,
               new.MaxQty,
               new.ModifiedDate,
               new.ExtractDatetime,
               new.RowHash,
               @ExecutionTime AS ValidFrom,
               NULL AS ValidTo,
               1 AS Valid
        FROM   INT.Sales_SpecialOffer AS new
               LEFT OUTER JOIN
               MRT.DIM_SpecialOffer AS dim
               ON new.SpecialOfferNK = dim.SpecialOfferNK
                  AND dim.Valid = 1
        WHERE  dim.SpecialOfferSK IS NULL;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        THROW;
    END CATCH
END


GO
CREATE OR ALTER PROCEDURE MRT.USP_LOAD_DIM_STORE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @ExecutionTime AS DATETIME2 (7) = GETDATE();
    BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE dim
        SET    dim.ValidTo = @ExecutionTime,
               dim.Valid   = 0
        FROM   MRT.DIM_Store AS dim
               INNER JOIN
               INT.Sales_Store AS new
               ON dim.StoreNK = new.StoreNK
        WHERE  dim.Valid = 1
               AND dim.RowHash <> new.RowHash;
        INSERT INTO MRT.DIM_Store (
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
        SELECT new.StoreNK,
               sp.SalesPersonSK,
               new.StoreName,
               new.AnnualSales,
               new.AnnualRevenue,
               new.BusinessType,
               new.Specialty,
               new.YearOpened,
               new.EmployeeCount,
               new.ModifiedDate,
               new.ExtractDatetime,
               new.RowHash,
               @ExecutionTime AS ValidFrom,
               NULL AS ValidTo,
               1 AS Valid
        FROM   INT.Sales_Store AS new
               LEFT OUTER JOIN
               MRT.DIM_Store AS dim
               ON new.StoreNK = dim.StoreNK
                  AND dim.Valid = 1
               LEFT OUTER JOIN
               MRT.DIM_SalesPerson AS sp
               ON new.SalesPersonNK = sp.SalesPersonNK
                  AND sp.Valid = 1
        WHERE  dim.StoreSK IS NULL;
        UPDATE dim
        SET    dim.AnnualSales     = new.AnnualSales,
               dim.AnnualRevenue   = new.AnnualRevenue,
               dim.YearOpened      = new.YearOpened,
               dim.EmployeeCount   = new.EmployeeCount,
               dim.ModifiedDate    = new.ModifiedDate,
               dim.ExtractDatetime = new.ExtractDatetime
        FROM   MRT.DIM_Store AS dim
               INNER JOIN
               INT.Sales_Store AS new
               ON dim.StoreNK = new.StoreNK
        WHERE  dim.Valid = 1;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        THROW;
    END CATCH
END


GO
CREATE OR ALTER PROCEDURE MRT.USP_LOAD_DIM_TERRITORY
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @ExecutionTime AS DATETIME2 = GETDATE();
    BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE dim
        SET    dim.ValidTo = @ExecutionTime,
               dim.Valid   = 0
        FROM   MRT.DIM_Territory AS dim
               INNER JOIN
               INT.Sales_Territory AS new
               ON dim.TerritoryNK = new.TerritoryNK
        WHERE  dim.Valid = 1
               AND dim.RowHash <> new.RowHash;
        INSERT INTO MRT.DIM_Territory (
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
        SELECT new.TerritoryNK,
               new.TerritoryName,
               new.CountryRegionCode,
               new.TerritoryGroup,
               new.SalesYTD,
               new.SalesLastYear,
               new.CostYTD,
               new.CostLastYear,
               new.ModifiedDate,
               new.ExtractDatetime,
               new.RowHash,
               @ExecutionTime AS ValidFrom,
               NULL AS ValidTo,
               1 AS Valid
        FROM   INT.Sales_Territory AS new
               LEFT OUTER JOIN
               MRT.DIM_Territory AS dim
               ON new.TerritoryNK = dim.TerritoryNK
                  AND dim.Valid = 1
        WHERE  dim.TerritorySK IS NULL;
        UPDATE dim
        SET    dim.SalesYTD        = new.SalesYTD,
               dim.SalesLastYear   = new.SalesLastYear,
               dim.CostYTD         = new.CostYTD,
               dim.CostLastYear    = new.CostLastYear,
               dim.ModifiedDate    = new.ModifiedDate,
               dim.ExtractDatetime = new.ExtractDatetime
        FROM   MRT.DIM_Territory AS dim
               INNER JOIN
               INT.Sales_Territory AS new
               ON dim.TerritoryNK = new.TerritoryNK
        WHERE  dim.Valid = 1;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        THROW;
    END CATCH
END


GO
CREATE OR ALTER PROCEDURE MRT.USP_LOAD_DIM_CUSTOMER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @ExecutionTime AS DATETIME2 (7) = GETDATE();
    BEGIN TRY
        BEGIN TRANSACTION;
        --Invalidate out-of-date SCD-T2 records
        UPDATE dim
        SET    dim.ValidTo = @ExecutionTime,
               dim.Valid   = 0
        FROM   MRT.DIM_Customer AS dim
               INNER JOIN
               INT.Sales_Customer AS new
               ON dim.CustomerNK = new.CustomerNK
        WHERE  dim.Valid = 1
               AND dim.RowHash <> new.RowHash;
        --Insert new and updated records
        INSERT INTO MRT.DIM_Customer (
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
        SELECT c.CustomerNK,
               p.PersonSK,
               s.StoreSK,
               t.TerritorySK,
               c.AccountNumber,
               c.CustomerType,
               c.StoreName,
               c.Store_AnnualRevenue,
               c.Store_AnnualSales,
               c.Store_BusinessType,
               c.Store_Specialty,
               c.Store_YearOpened,
               c.Store_EmployeeCount,
               c.PersonTypeDescription,
               c.Individual_FullName,
               c.Individual_EmailAddress,
               c.Individual_EmailPromotionSignUp,
               c.RowHash,
               @ExecutionTime AS ValidFrom,
               NULL AS ValidTo,
               1 AS Valid
        FROM   INT.Sales_Customer AS c
               LEFT OUTER JOIN
               MRT.DIM_Customer AS dim
               ON c.CustomerNK = dim.CustomerNK
                  AND dim.Valid = 1
               LEFT OUTER JOIN
               MRT.DIM_Store AS s
               ON c.StoreNK = s.StoreNK
                  AND s.Valid = 1
               LEFT OUTER JOIN
               MRT.DIM_Territory AS t
               ON c.TerritoryNK = t.TerritoryNK
                  AND t.Valid = 1
               LEFT OUTER JOIN
               MRT.DIM_Person AS p
               ON c.PersonNK = p.PersonNK
                  AND p.Valid = 1
        WHERE  dim.CustomerSK IS NULL;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        THROW;
    END CATCH
END


GO
/*-------------
LOAD MART FACTS
-------------*/
CREATE OR ALTER PROCEDURE MRT.USP_LOAD_FACT_SALES
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        --UPDATE existing records
        UPDATE fct
        SET    fct.ProductSK                         = p.ProductSK,
               fct.SpecialOfferSK                    = so.SpecialOfferSK,
               fct.BillToAddressSK                   = bill.AddressSK,
               fct.ShipToAddressSK                   = ship.AddressSK,
               fct.ShipMethodSK                      = sm.ShipMethodSK,
               fct.CreditCardSK                      = cc.CreditCardSK,
               fct.CustomerSK                        = c.CustomerSK,
               fct.SalesPersonSK                     = sp.SalesPersonSK,
               fct.TerritorySK                       = t.TerritorySK,
               fct.CurrencyRateSK                    = rate.CurrencyRateSK,
               --Header
               fct.RevisionNumber                    = new.RevisionNumber,
               fct.OrderDate                         = new.OrderDate,
               fct.DueDate                           = new.DueDate,
               fct.ShipDate                          = new.ShipDate,
               fct.StatusDescription                 = new.StatusDescription,
               fct.OnlineOrderFlag                   = new.OnlineOrderFlag,
               fct.OnlineOrderDescription            = new.OnlineOrderDescription,
               fct.SalesOrderNumber                  = new.SalesOrderNumber,
               fct.PurchaseOrderNumber               = new.PurchaseOrderNumber,
               fct.AccountNumber                     = new.AccountNumber,
               fct.CreditCardApprovalCode            = new.CreditCardApprovalCode,
               fct.SubTotal                          = new.SubTotal,
               fct.TaxAmt                            = new.TaxAmt,
               fct.Freight                           = new.Freight,
               fct.TotalDue                          = new.TotalDue,
               fct.Comment                           = new.Comment,
               --Detail
               fct.CarrierTrackingNumber             = new.CarrierTrackingNumber,
               fct.OrderQty                          = new.OrderQty,
               fct.UnitPrice                         = new.UnitPrice,
               fct.UnitPriceDiscount                 = new.UnitPriceDiscount,
               fct.LineTotal                         = new.LineTotal,
               --Metadata
               fct.HeaderLastModifiedDate            = new.HeaderLastModifiedDate,
               fct.DetailLastModifiedDate            = new.DetailLastModifiedDate,
               fct.SalesOrderHeaderExtractedDateTime = new.SalesOrderHeaderExtractedDateTime,
               fct.SalesOrderDetailExtractedDateTime = new.SalesOrderDetailExtractedDateTime,
               fct.SalesOrderHeaderHash              = new.SalesOrderHeaderHash,
               fct.SalesOrderDetailHash              = new.SalesOrderDetailHash,
               fct.FactSalesHash                     = new.FactSalesHash
        FROM   MRT.Fact_Sales AS fct
               INNER JOIN
               INT.FactSales AS new
               ON fct.SalesOrderDetailNK = new.SalesOrderDetailNK
               LEFT OUTER JOIN
               MRT.DIM_Product AS p
               ON new.ProductNK = p.ProductNK
                  AND new.OrderDate >= p.ValidFrom
                  AND (new.OrderDate < p.ValidTo
                       OR p.ValidTo IS NULL)
               LEFT OUTER JOIN
               MRT.DIM_SalesPerson AS sp
               ON new.SalesPersonNK = sp.SalesPersonNK
                  AND new.OrderDate >= sp.ValidFrom
                  AND (new.OrderDate < sp.ValidTo
                       OR sp.ValidTo IS NULL)
               LEFT OUTER JOIN
               MRT.DIM_Customer AS c
               ON new.CustomerNK = c.CustomerNK
                  AND new.OrderDate >= c.ValidFrom
                  AND (new.OrderDate < c.ValidTo
                       OR c.ValidTo IS NULL)
               LEFT OUTER JOIN
               MRT.DIM_Territory AS t
               ON new.TerritoryNK = t.TerritoryNK
                  AND new.OrderDate >= t.ValidFrom
                  AND (new.OrderDate < t.ValidTo
                       OR t.ValidTo IS NULL)
               LEFT OUTER JOIN
               MRT.DIM_SpecialOffer AS so
               ON new.SpecialOfferNK = so.SpecialOfferNK
                  AND new.OrderDate >= so.ValidFrom
                  AND (new.OrderDate < so.ValidTo
                       OR so.ValidTo IS NULL)
               LEFT OUTER JOIN
               MRT.DIM_ShipMethod AS sm
               ON new.ShipMethodNK = sm.ShipMethodNK
                  AND new.OrderDate >= sm.ValidFrom
                  AND (new.OrderDate < sm.ValidTo
                       OR sm.ValidTo IS NULL)
               LEFT OUTER JOIN
               MRT.DIM_CreditCard AS cc
               ON new.CreditCardNK = cc.CreditCardNK
               LEFT OUTER JOIN
               MRT.DIM_Address AS bill
               ON new.BillToAddressNK = bill.AddressNK
               LEFT OUTER JOIN
               MRT.DIM_Address AS ship
               ON new.ShipToAddressNK = ship.AddressNK
               LEFT OUTER JOIN
               MRT.DIM_CurrencyRate AS rate
               ON new.CurrencyRateNK = rate.CurrencyRateNK
        WHERE  fct.FactSalesHash <> new.FactSalesHash;
        --INSERT new records
        INSERT INTO MRT.Fact_Sales (
            SalesOrderNK,
            SalesOrderDetailNK,
            ProductSK,
            SpecialOfferSK,
            BillToAddressSK,
            ShipToAddressSK,
            ShipMethodSK,
            CreditCardSK,
            CustomerSK,
            SalesPersonSK,
            TerritorySK,
            CurrencyRateSK,
            --Header
            RevisionNumber,
            OrderDate,
            DueDate,
            ShipDate,
            StatusDescription,
            OnlineOrderFlag,
            OnlineOrderDescription,
            SalesOrderNumber,
            PurchaseOrderNumber,
            AccountNumber,
            CreditCardApprovalCode,
            SubTotal,
            TaxAmt,
            Freight,
            TotalDue,
            Comment,
            --Detail
            CarrierTrackingNumber,
            OrderQty,
            UnitPrice,
            UnitPriceDiscount,
            LineTotal,
            --Metadata
            HeaderLastModifiedDate,
            DetailLastModifiedDate,
            SalesOrderHeaderExtractedDateTime,
            SalesOrderDetailExtractedDateTime,
            SalesOrderHeaderHash,
            SalesOrderDetailHash,
            FactSalesHash
        )
        SELECT new.SalesOrderNK,
               new.SalesOrderDetailNK,
               p.ProductSK,
               so.SpecialOfferSK,
               bill.AddressSK,
               ship.AddressSK,
               sm.ShipMethodSK,
               cc.CreditCardSK,
               c.CustomerSK,
               sp.SalesPersonSK,
               t.TerritorySK,
               rate.CurrencyRateSK,
               --Header
               new.RevisionNumber,
               new.OrderDate,
               new.DueDate,
               new.ShipDate,
               new.StatusDescription,
               new.OnlineOrderFlag,
               new.OnlineOrderDescription,
               new.SalesOrderNumber,
               new.PurchaseOrderNumber,
               new.AccountNumber,
               new.CreditCardApprovalCode,
               new.SubTotal,
               new.TaxAmt,
               new.Freight,
               new.TotalDue,
               new.Comment,
               --Detail
               new.CarrierTrackingNumber,
               new.OrderQty,
               new.UnitPrice,
               new.UnitPriceDiscount,
               new.LineTotal,
               --Metadata
               new.HeaderLastModifiedDate,
               new.DetailLastModifiedDate,
               new.SalesOrderHeaderExtractedDateTime,
               new.SalesOrderDetailExtractedDateTime,
               new.SalesOrderHeaderHash,
               new.SalesOrderDetailHash,
               new.FactSalesHash
        FROM   INT.FactSales AS new
               LEFT OUTER JOIN
               MRT.Fact_Sales AS fct
               ON new.SalesOrderDetailNK = fct.SalesOrderDetailNK
               LEFT OUTER JOIN
               MRT.DIM_Product AS p
               ON new.ProductNK = p.ProductNK
                  AND new.OrderDate >= p.ValidFrom
                  AND (new.OrderDate < p.ValidTo
                       OR p.ValidTo IS NULL)
               LEFT OUTER JOIN
               MRT.DIM_SalesPerson AS sp
               ON new.SalesPersonNK = sp.SalesPersonNK
                  AND new.OrderDate >= sp.ValidFrom
                  AND (new.OrderDate < sp.ValidTo
                       OR sp.ValidTo IS NULL)
               LEFT OUTER JOIN
               MRT.DIM_Customer AS c
               ON new.CustomerNK = c.CustomerNK
                  AND new.OrderDate >= c.ValidFrom
                  AND (new.OrderDate < c.ValidTo
                       OR c.ValidTo IS NULL)
               LEFT OUTER JOIN
               MRT.DIM_Territory AS t
               ON new.TerritoryNK = t.TerritoryNK
                  AND new.OrderDate >= t.ValidFrom
                  AND (new.OrderDate < t.ValidTo
                       OR t.ValidTo IS NULL)
               LEFT OUTER JOIN
               MRT.DIM_SpecialOffer AS so
               ON new.SpecialOfferNK = so.SpecialOfferNK
                  AND new.OrderDate >= so.ValidFrom
                  AND (new.OrderDate < so.ValidTo
                       OR so.ValidTo IS NULL)
               LEFT OUTER JOIN
               MRT.DIM_ShipMethod AS sm
               ON new.ShipMethodNK = sm.ShipMethodNK
                  AND new.OrderDate >= sm.ValidFrom
                  AND (new.OrderDate < sm.ValidTo
                       OR sm.ValidTo IS NULL)
               LEFT OUTER JOIN
               MRT.DIM_CreditCard AS cc
               ON new.CreditCardNK = cc.CreditCardNK
               LEFT OUTER JOIN
               MRT.DIM_Address AS bill
               ON new.BillToAddressNK = bill.AddressNK
               LEFT OUTER JOIN
               MRT.DIM_Address AS ship
               ON new.ShipToAddressNK = ship.AddressNK
               LEFT OUTER JOIN
               MRT.DIM_CurrencyRate AS rate
               ON new.CurrencyRateNK = rate.CurrencyRateNK
        WHERE  fct.FactSalesSK IS NULL;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        THROW;
    END CATCH
END