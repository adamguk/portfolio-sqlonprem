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
       SET QUOTED_IDENTIFIER ON;
       DECLARE @ExecutionTime AS DATETIME2 (7) = GETDATE();
       BEGIN TRY
              BEGIN TRANSACTION;
              --Invalidate out-of-date SCD-T2 records
              UPDATE dim
              SET    dim.ValidTo         = @ExecutionTime,
                     dim.Valid           = 0,
                     dim.ValidityContext = 'Superseded'
              FROM   MRT.DIM_Person AS dim
                     INNER JOIN
                     INT.Person_Person AS new
                     ON dim.PersonNK = new.PersonNK
              WHERE  dim.Valid = 1
                     AND dim.RowHash <> new.RowHash;
              --Invalidate deleted SCD-T2 records
              UPDATE dim
              SET    dim.ValidTo         = @ExecutionTime,
                     dim.Valid           = 0,
                     dim.ValidityContext = 'Deleted'
              FROM   MRT.DIM_Person AS dim
              WHERE  dim.Valid = 1
                     AND dim.PersonNK <> -1
                     AND NOT EXISTS (SELECT 1
                                     FROM   INT.Person_Person AS new
                                     WHERE  dim.PersonNK = new.PersonNK);
              --Insert new or updated SCD-T2 records
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
              SELECT new.PersonNK,
                     new.PersonType,
                     new.PersonTypeDescription,
                     new.PersonTypeGroup,
                     new.Title,
                     new.FirstName,
                     new.MiddleName,
                     new.LastName,
                     new.Suffix,
                     new.FullName,
                     new.EmailAddress,
                     new.EmailPromotionSignUpFlag,
                     new.EmailPromotionSignUp,
                     new.ModifiedDate,
                     new.ExtractDatetime,
                     CASE WHEN EXISTS (SELECT 1
                                       FROM   MRT.DIM_Person AS hist
                                       WHERE  hist.PersonNK = new.PersonNK) THEN @ExecutionTime ELSE '1900-01-01' END AS ValidFrom,
                     NULL AS ValidTo,
                     1 AS Valid,
                     new.RowHash
              FROM   INT.Person_Person AS new
                     LEFT OUTER JOIN
                     MRT.DIM_Person AS dim
                     ON new.PersonNK = dim.PersonNK
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
       SET QUOTED_IDENTIFIER ON;
       DECLARE @ExecutionTime AS DATETIME2 (7) = GETDATE();
       BEGIN TRY
              BEGIN TRANSACTION;
              --Invalidate out-of-date SCD-T2 records
              UPDATE dim
              SET    dim.ValidTo         = @ExecutionTime,
                     dim.Valid           = 0,
                     dim.ValidityContext = 'Superseded'
              FROM   MRT.DIM_Person_Address AS dim
                     INNER JOIN
                     INT.Person_Address_Joined AS new
                     ON dim.PersonAddressCNK = new.PersonAddressCNK
              WHERE  dim.Valid = 1
                     AND dim.RowHash <> new.RowHash;
              --Invalidate deleted SCD-T2 records
              UPDATE dim
              SET    dim.ValidTo         = @ExecutionTime,
                     dim.Valid           = 0,
                     dim.ValidityContext = 'Deleted'
              FROM   MRT.DIM_Person_Address AS dim
              WHERE  dim.Valid = 1
                     AND dim.PersonAddressCNK <> '-1|-1|-1'
                     AND NOT EXISTS (SELECT 1
                                     FROM   INT.Person_Address_Joined AS new
                                     WHERE  dim.PersonAddressCNK = new.PersonAddressCNK);
              --Insert new or updated SCD-T2 records
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
              SELECT new.PersonNK,
                     new.PersonAddressCNK,
                     new.PersonAddressTypeNK,
                     new.PersonAddressNK,
                     new.CountryRegionNK,
                     new.StateProvinceNK,
                     new.AddressLine1,
                     new.AddressLine2,
                     new.City,
                     new.PostalCode,
                     new.SpatialLocation,
                     new.AddressTypeName,
                     new.CountryRegionName,
                     new.StateProvinceCode,
                     new.StateProvinceName,
                     new.IsOnlyStateProvinceFlag,
                     new.IsOnlyStateProvinceDescription,
                     CASE WHEN EXISTS (SELECT 1
                                       FROM   MRT.DIM_Person_Address AS hist
                                       WHERE  hist.PersonAddressCNK = new.PersonAddressCNK) THEN @ExecutionTime ELSE '1900-01-01' END AS ValidFrom,
                     NULL AS ValidTo,
                     1 AS Valid,
                     new.RowHash
              FROM   INT.Person_Address_Joined AS new
                     LEFT OUTER JOIN
                     MRT.DIM_Person_Address AS dim
                     ON new.PersonAddressCNK = dim.PersonAddressCNK
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
       SET QUOTED_IDENTIFIER ON;
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
       SET QUOTED_IDENTIFIER ON;
       DECLARE @ExecutionTime AS DATETIME2 (7) = GETDATE();
       BEGIN TRY
              BEGIN TRANSACTION;
              --Invalidate out-of-date SCD-T2 records
              UPDATE dim
              SET    dim.ValidTo         = @ExecutionTime,
                     dim.Valid           = 0,
                     dim.ValidityContext = 'Superseded'
              FROM   MRT.DIM_Product AS dim
                     INNER JOIN
                     INT.Production_Product AS new
                     ON new.ProductNK = dim.ProductNK
              WHERE  dim.Valid = 1
                     AND dim.RowHash <> new.RowHash;
              --Invalidate deleted SCD-T2 records
              UPDATE dim
              SET    dim.ValidTo         = @ExecutionTime,
                     dim.Valid           = 0,
                     dim.ValidityContext = 'Deleted'
              FROM   MRT.DIM_Product AS dim
              WHERE  dim.Valid = 1
                     AND dim.ProductNK <> -1
                     AND NOT EXISTS (SELECT 1
                                     FROM   INT.Production_Product AS new
                                     WHERE  dim.ProductNK = new.ProductNK);
              --Insert new or updated SCD-T2 records
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
                     CASE WHEN EXISTS (SELECT 1
                                       FROM   MRT.Dim_Product AS hist
                                       WHERE  hist.ProductNK = new.ProductNK) THEN @ExecutionTime ELSE '1900-01-01' END AS ValidFrom, -- a prior version exists (even if expired) → this is a real change
                     -- never existed before → backdate to cover history
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
       SET QUOTED_IDENTIFIER ON;
       DECLARE @ExecutionTime AS DATETIME2 (7) = GETDATE();
       BEGIN TRY
              BEGIN TRANSACTION;
              --Invalidate out-of-date SCD-T2 records
              UPDATE dim
              SET    dim.ValidTo         = @ExecutionTime,
                     dim.Valid           = 0,
                     dim.ValidityContext = 'Superseded'
              FROM   MRT.DIM_ShipMethod AS dim
                     INNER JOIN
                     INT.Purchasing_ShipMethod AS new
                     ON dim.ShipMethodNK = new.ShipMethodNK
              WHERE  dim.Valid = 1
                     AND dim.RowHash <> new.RowHash;
              --Invalidate deleted SCD-T2 records
              UPDATE dim
              SET    dim.ValidTo         = @ExecutionTime,
                     dim.Valid           = 0,
                     dim.ValidityContext = 'Deleted'
              FROM   MRT.DIM_ShipMethod AS dim
              WHERE  dim.Valid = 1
                     AND dim.ShipMethodNK <> -1
                     AND NOT EXISTS (SELECT 1
                                     FROM   INT.Purchasing_ShipMethod AS new
                                     WHERE  dim.ShipMethodNK = new.ShipMethodNK);
              --Insert new or updated SCD-T2 records
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
                     CASE WHEN EXISTS (SELECT 1
                                       FROM   MRT.DIM_ShipMethod AS hist
                                       WHERE  hist.ShipMethodNK = new.ShipMethodNK) THEN @ExecutionTime ELSE '1900-01-01' END AS ValidFrom,
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
       SET QUOTED_IDENTIFIER ON;
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
              --Invalidate deleted records
              UPDATE dim
              SET    dim.Valid = 0
              FROM   MRT.DIM_CreditCard AS dim
              WHERE  dim.Valid = 1
                     AND dim.CreditCardNK <> -1
                     AND NOT EXISTS (SELECT 1
                                     FROM   INT.Sales_CreditCard AS new
                                     WHERE  dim.CreditCardNK = new.CreditCardNK);
              --Insert new/updated records
              INSERT INTO MRT.DIM_CreditCard (
                     [CreditCardNK],
                     [CardType],
                     [CardNumber],
                     [ExpMonth],
                     [ExpYear],
                     [ModifiedDate],
                     [ExtractDatetime],
                     [RowHash],
                     [Valid]
              )
              SELECT new.[CreditCardNK],
                     new.[CardType],
                     new.[CardNumber],
                     new.[ExpMonth],
                     new.[ExpYear],
                     new.[ModifiedDate],
                     new.[ExtractDatetime],
                     new.[RowHash],
                     1 AS Valid
              FROM   INT.Sales_CreditCard AS new
                     LEFT OUTER JOIN
                     MRT.DIM_CreditCard AS dim
                     ON new.CreditCardNK = dim.CreditCardNK
                        AND dim.Valid = 1
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
       SET QUOTED_IDENTIFIER ON;
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
       SET QUOTED_IDENTIFIER ON;
       DECLARE @ExecutionTime AS DATETIME2 (7) = GETDATE();
       BEGIN TRY
              BEGIN TRANSACTION;
              --Invalidate out-of-date SCD-T2 records
              UPDATE dim
              SET    dim.ValidTo         = @ExecutionTime,
                     dim.Valid           = 0,
                     dim.ValidityContext = 'Superseded'
              FROM   MRT.DIM_SalesPerson AS dim
                     INNER JOIN
                     INT.SalesPerson AS new
                     ON dim.SalesPersonNK = new.SalesPersonNK
              WHERE  dim.Valid = 1
                     AND dim.RowHash <> new.RowHash;
              --Invalidate deleted SCD-T2 records
              UPDATE dim
              SET    dim.ValidTo         = @ExecutionTime,
                     dim.Valid           = 0,
                     dim.ValidityContext = 'Deleted'
              FROM   MRT.DIM_SalesPerson AS dim
              WHERE  dim.Valid = 1
                     AND dim.SalesPersonNK <> -1
                     AND NOT EXISTS (SELECT 1
                                     FROM   INT.SalesPerson AS new
                                     WHERE  dim.SalesPersonNK = new.SalesPersonNK);
              --Insert new or updated SCD-T2 records
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
                     CASE WHEN EXISTS (SELECT 1
                                       FROM   MRT.DIM_SalesPerson AS hist
                                       WHERE  hist.SalesPersonNK = new.SalesPersonNK) THEN @ExecutionTime ELSE '1900-01-01' END AS ValidFrom,
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
       SET QUOTED_IDENTIFIER ON;
       DECLARE @ExecutionTime AS DATETIME2 (7) = GETDATE();
       BEGIN TRY
              BEGIN TRANSACTION;
              UPDATE dim
              SET    dim.ValidTo         = @ExecutionTime,
                     dim.Valid           = 0,
                     dim.ValidityContext = 'Superseded'
              FROM   MRT.DIM_SpecialOffer AS dim
                     INNER JOIN
                     INT.Sales_SpecialOffer AS new
                     ON dim.SpecialOfferNK = new.SpecialOfferNK
              WHERE  dim.Valid = 1
                     AND dim.RowHash <> new.RowHash;
              --Invalidate deleted SCD-T2 records
              UPDATE dim
              SET    dim.ValidTo         = @ExecutionTime,
                     dim.Valid           = 0,
                     dim.ValidityContext = 'Deleted'
              FROM   MRT.DIM_SpecialOffer AS dim
              WHERE  dim.Valid = 1
                     AND dim.SpecialOfferNK <> -1
                     AND NOT EXISTS (SELECT 1
                                     FROM   INT.Sales_SpecialOffer AS new
                                     WHERE  dim.SpecialOfferNK = new.SpecialOfferNK);
              --Insert new or updated SCD-T2 records
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
                     CASE WHEN EXISTS (SELECT 1
                                       FROM   MRT.DIM_SpecialOffer AS hist
                                       WHERE  hist.SpecialOfferNK = new.SpecialOfferNK) THEN @ExecutionTime ELSE '1900-01-01' END AS ValidFrom,
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
       SET QUOTED_IDENTIFIER ON;
       DECLARE @ExecutionTime AS DATETIME2 (7) = GETDATE();
       BEGIN TRY
              BEGIN TRANSACTION;
              UPDATE dim
              SET    dim.ValidTo         = @ExecutionTime,
                     dim.Valid           = 0,
                     dim.ValidityContext = 'Superseded'
              FROM   MRT.DIM_Store AS dim
                     INNER JOIN
                     INT.Sales_Store AS new
                     ON dim.StoreNK = new.StoreNK
              WHERE  dim.Valid = 1
                     AND dim.RowHash <> new.RowHash;
              --Invalidate deleted SCD-T2 records
              UPDATE dim
              SET    dim.ValidTo         = @ExecutionTime,
                     dim.Valid           = 0,
                     dim.ValidityContext = 'Deleted'
              FROM   MRT.DIM_Store AS dim
              WHERE  dim.Valid = 1
                     AND dim.StoreNK <> -1
                     AND NOT EXISTS (SELECT 1
                                     FROM   INT.Sales_Store AS new
                                     WHERE  dim.StoreNK = new.StoreNK);
              --Insert new or updated SCD-T2 records
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
                     CASE WHEN EXISTS (SELECT 1
                                       FROM   MRT.DIM_Store AS hist
                                       WHERE  hist.StoreNK = new.StoreNK) THEN @ExecutionTime ELSE '1900-01-01' END AS ValidFrom,
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
       SET QUOTED_IDENTIFIER ON;
       DECLARE @ExecutionTime AS DATETIME2 = GETDATE();
       BEGIN TRY
              BEGIN TRANSACTION;
              UPDATE dim
              SET    dim.ValidTo         = @ExecutionTime,
                     dim.Valid           = 0,
                     dim.ValidityContext = 'Superseded'
              FROM   MRT.DIM_Territory AS dim
                     INNER JOIN
                     INT.Sales_Territory AS new
                     ON dim.TerritoryNK = new.TerritoryNK
              WHERE  dim.Valid = 1
                     AND dim.RowHash <> new.RowHash;
              --Invalidate deleted SCD-T2 records
              UPDATE dim
              SET    dim.ValidTo         = @ExecutionTime,
                     dim.Valid           = 0,
                     dim.ValidityContext = 'Deleted'
              FROM   MRT.DIM_Territory AS dim
              WHERE  dim.Valid = 1
                     AND dim.TerritoryNK <> -1
                     AND NOT EXISTS (SELECT 1
                                     FROM   INT.Sales_Territory AS new
                                     WHERE  dim.TerritoryNK = new.TerritoryNK);
              --Insert new or updated SCD-T2 records
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
                     CASE WHEN EXISTS (SELECT 1
                                       FROM   MRT.DIM_Territory AS hist
                                       WHERE  hist.TerritoryNK = new.TerritoryNK) THEN @ExecutionTime ELSE '1900-01-01' END AS ValidFrom,
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
       SET QUOTED_IDENTIFIER ON;
       DECLARE @ExecutionTime AS DATETIME2 (7) = GETDATE();
       BEGIN TRY
              BEGIN TRANSACTION;
              --Invalidate out-of-date SCD-T2 records
              UPDATE dim
              SET    dim.ValidTo         = @ExecutionTime,
                     dim.Valid           = 0,
                     dim.ValidityContext = 'Superseded'
              FROM   MRT.DIM_Customer AS dim
                     INNER JOIN
                     INT.Sales_Customer AS new
                     ON dim.CustomerNK = new.CustomerNK
              WHERE  dim.Valid = 1
                     AND dim.RowHash <> new.RowHash;
              --Invalidate deleted SCD-T2 records
              UPDATE dim
              SET    dim.ValidTo         = @ExecutionTime,
                     dim.Valid           = 0,
                     dim.ValidityContext = 'Deleted'
              FROM   MRT.DIM_Customer AS dim
              WHERE  dim.Valid = 1
                     AND dim.CustomerNK <> -1
                     AND NOT EXISTS (SELECT 1
                                     FROM   INT.Sales_Customer AS new
                                     WHERE  dim.CustomerNK = new.CustomerNK);
              --Insert new or updated SCD-T2 records
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
              SELECT new.CustomerNK,
                     p.PersonSK,
                     s.StoreSK,
                     t.TerritorySK,
                     new.AccountNumber,
                     new.CustomerType,
                     new.StoreName,
                     new.Store_AnnualRevenue,
                     new.Store_AnnualSales,
                     new.Store_BusinessType,
                     new.Store_Specialty,
                     new.Store_YearOpened,
                     new.Store_EmployeeCount,
                     new.PersonTypeDescription,
                     new.Individual_FullName,
                     new.Individual_EmailAddress,
                     new.Individual_EmailPromotionSignUp,
                     new.RowHash,
                     CASE WHEN EXISTS (SELECT 1
                                       FROM   MRT.DIM_Customer AS hist
                                       WHERE  hist.CustomerNK = new.CustomerNK) THEN @ExecutionTime ELSE '1900-01-01' END AS ValidFrom,
                     NULL AS ValidTo,
                     1 AS Valid
              FROM   INT.Sales_Customer AS new
                     LEFT OUTER JOIN
                     MRT.DIM_Customer AS dim
                     ON new.CustomerNK = dim.CustomerNK
                        AND dim.Valid = 1
                     LEFT OUTER JOIN
                     MRT.DIM_Store AS s
                     ON new.StoreNK = s.StoreNK
                        AND s.Valid = 1
                     LEFT OUTER JOIN
                     MRT.DIM_Territory AS t
                     ON new.TerritoryNK = t.TerritoryNK
                        AND t.Valid = 1
                     LEFT OUTER JOIN
                     MRT.DIM_Person AS p
                     ON new.PersonNK = p.PersonNK
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
       SET QUOTED_IDENTIFIER ON;
       BEGIN TRY
              BEGIN TRANSACTION;
              --UPDATE existing records
              UPDATE fct
              SET    fct.ProductSK                       = p.ProductSK,
                     fct.SpecialOfferSK                  = so.SpecialOfferSK,
                     fct.BillToAddressSK                 = bill.AddressSK,
                     fct.ShipToAddressSK                 = ship.AddressSK,
                     fct.ShipMethodSK                    = sm.ShipMethodSK,
                     fct.CreditCardSK                    = cc.CreditCardSK,
                     fct.CustomerSK                      = c.CustomerSK,
                     fct.SalesPersonSK                   = sp.SalesPersonSK,
                     fct.TerritorySK                     = t.TerritorySK,
                     fct.CurrencyRateSK                  = rate.CurrencyRateSK,
                     --Header
                     fct.RevisionNumber                  = new.RevisionNumber,
                     fct.OrderDate                       = new.OrderDate,
                     fct.DueDate                         = new.DueDate,
                     fct.ShipDate                        = new.ShipDate,
                     fct.StatusDescription               = new.StatusDescription,
                     fct.OnlineOrderFlag                 = new.OnlineOrderFlag,
                     fct.OnlineOrderDescription          = new.OnlineOrderDescription,
                     fct.SalesOrderNumber                = new.SalesOrderNumber,
                     fct.PurchaseOrderNumber             = new.PurchaseOrderNumber,
                     fct.AccountNumber                   = new.AccountNumber,
                     fct.CreditCardApprovalCode          = new.CreditCardApprovalCode,
                     fct.SubTotal                        = new.SubTotal,
                     fct.TaxAmt                          = new.TaxAmt,
                     fct.Freight                         = new.Freight,
                     fct.TotalDue                        = new.TotalDue,
                     fct.Comment                         = new.Comment,
                     --Detail
                     fct.CarrierTrackingNumber           = new.CarrierTrackingNumber,
                     fct.OrderQty                        = new.OrderQty,
                     fct.UnitPrice                       = new.UnitPrice,
                     fct.UnitPriceDiscount               = new.UnitPriceDiscount,
                     fct.LineTotal                       = new.LineTotal,
                     --Metadata
                     fct.HeaderLastModifiedDate          = new.HeaderLastModifiedDate,
                     fct.DetailLastModifiedDate          = new.DetailLastModifiedDate,
                     fct.SalesOrderHeaderExtractDateTime = new.SalesOrderHeaderExtractDateTime,
                     fct.SalesOrderDetailExtractDateTime = new.SalesOrderDetailExtractDateTime,
                     fct.SalesOrderHeaderHash            = new.SalesOrderHeaderHash,
                     fct.SalesOrderDetailHash            = new.SalesOrderDetailHash,
                     fct.FactSalesHash                   = new.FactSalesHash
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
                     SalesOrderHeaderExtractDateTime,
                     SalesOrderDetailExtractDateTime,
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
                     new.SalesOrderHeaderExtractDateTime,
                     new.SalesOrderDetailExtractDateTime,
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