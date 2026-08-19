USE DWH_ONPREM;
GO

/*------------------
LOAD MART DIMENSIONS
------------------*/

CREATE OR ALTER PROCEDURE MRT.USP_LOAD_DIM_PERSON
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @ExecutionTime DATETIME2(7) = GETDATE();

    BEGIN TRY 
        BEGIN TRANSACTION;

        --Invalidate out-of-date SCD-T2 records
        UPDATE dim
        SET
            dim.ValidTo = @ExecutionTime,
            dim.Valid = 0
        FROM MRT.DIM_Person dim
        INNER JOIN INT.Person_Person new
        ON dim.PersonNK = new.PersonNK
        WHERE dim.Valid = 1
        AND dim.RowHash <> new.RowHash;

        INSERT INTO MRT.DIM_Person
        (
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
    SELECT
        p.PersonNK,
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
    FROM INT.Person_Person p
        LEFT JOIN MRT.DIM_Person dim
        ON p.PersonNK =  dim.PersonNK
            AND dim.Valid = 1
    WHERE dim.PersonSK IS NULL;

            COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH 
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION;
        THROW; 
    END CATCH

END;
GO

CREATE OR ALTER PROCEDURE MRT.USP_LOAD_DIM_PERSON_ADDRESS
AS
BEGIN

    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @ExecutionTime DATETIME2(7) = GETDATE();

    BEGIN TRY
        BEGIN TRANSACTION

        --Invalidate out-of-date SCD-T2 records
            UPDATE dim
             SET dim.ValidTo = @ExecutionTime,
                dim.Valid = 0
            FROM MRT.DIM_Person_Address dim
        INNER JOIN INT.Person_Address_Joined new
        ON dim.PersonAddressCNK = new.PersonAddressCNK
            WHERE dim.Valid=1
        AND dim.RowHash <> new.NewRowHash;

        INSERT INTO MRT.DIM_Person_Address
        (
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
    SELECT
        pj.PersonNK,
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
    FROM INT.Person_Address_Joined pj
        LEFT JOIN MRT.DIM_Person_Address dim
        ON pj.PersonAddressCNK = dim.PersonAddressCNK
            AND dim.Valid=1
    WHERE dim.PersonAddressSK IS NULL;
            COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH 
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION;
        THROW; 
    END CATCH

END;
GO

CREATE OR ALTER PROCEDURE MRT.USP_LOAD_DIM_PRODUCT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @ExecutionTime DATETIME2(7) = GETDATE();

    BEGIN TRY
        BEGIN TRANSACTION

        --Invalidate out-of-date SCD-T2 records
            UPDATE dim
            SET
                dim.ValidTo = @ExecutionTime,
                dim.Valid = 0
            FROM MRT.DIM_Product dim
        INNER JOIN INT.Production_Product new
        ON new.ProductNK = dim.ProductNK
            WHERE dim.Valid=1
        AND dim.RowHash <> new.RowHash;

        --Insert new/changed SCDT2 records
        INSERT INTO MRT.DIM_Product
        (
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
    SELECT
        new.ProductNK,
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
    FROM INT.Production_Product new
        LEFT JOIN MRT.DIM_Product dim
        ON dim.ProductNK = new.ProductNK
            AND dim.Valid = 1
    WHERE dim.ProductSK IS NULL;

        --Update SCDT1 records

        UPDATE dim
        SET 
            dim.ProductNumber = new.ProductNumber,
            dim.SafetyStockLevel = new.SafetyStockLevel,
            dim.ReorderPoint = new.ReorderPoint,
            dim.DaysToManufacture = new.DaysToManufacture,
            dim.ModifiedDate = new.ModifiedDate,
            dim.ExtractDatetime = new.ExtractDatetime
        FROM MRT.DIM_Product dim
        INNER JOIN INT.Production_Product new
        ON dim.ProductNK = new.ProductNK
            WHERE dim.Valid = 1;
            COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH 
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION;
        THROW; 
    END CATCH

END;
GO

CREATE OR ALTER PROCEDURE MRT.USP_LOAD_DIM_SALESPERSON
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @ExecutionTime DATETIME2(7) = GETDATE();

    BEGIN TRY
        BEGIN TRANSACTION

            --Invalidate out-of-date SCD-T2 records
            UPDATE dim
            SET
                dim.ValidTo = @ExecutionTime,
                dim.Valid = 0
            FROM MRT.DIM_SalesPerson dim
        INNER JOIN INT.SalesPerson new
        ON dim.SalesPersonNK = new.SalesPersonNK
            WHERE
                dim.Valid = 1
        AND dim.RowHash <> new.RowHash;

            --Insert new & updated records
            INSERT INTO MRT.DIM_SalesPerson
        (
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
    SELECT
        new.SalesPersonNK,
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
    FROM INT.SalesPerson new
        LEFT JOIN MRT.DIM_SalesPerson dim
        ON dim.SalesPersonNK = new.SalesPersonNK
            AND dim.Valid = 1
    WHERE dim.SalesPersonSK IS NULL;


    --Update existing valid rows for type 1 fields
        UPDATE dim
            SET
                dim.SalesQuota = new.SalesQuota,
                dim.Bonus = new.Bonus,
                dim.CommissionPercentage = new.CommissionPercentage,
                dim.SalesYTD = new.SalesYTD,
                dim.SalesLastYear = new.SalesLastYear,
                dim.ModifiedDate = new.ModifiedDate,
                dim.ExtractDatetime = new.ExtractDatetime
            FROM MRT.DIM_SalesPerson dim
        INNER JOIN INT.SalesPerson new
        ON dim.SalesPersonNK = new.SalesPersonNK
            WHERE dim.Valid = 1;


            COMMIT TRANSACTION;
            END TRY
        BEGIN CATCH 
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION;
        THROW; 
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE MRT.USP_LOAD_DIM_STORE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @ExecutionTime DATETIME2(7) = GETDATE();

    BEGIN TRY
            BEGIN TRANSACTION
                UPDATE dim
                SET
                    dim.ValidTo = @ExecutionTime,
                    dim.Valid = 0
                FROM MRT.DIM_Store dim
        INNER JOIN INT.Sales_Store new
        ON dim.StoreNK = new.StoreNK
                WHERE dim.Valid = 1
        AND dim.RowHash <> new.RowHash;

        INSERT INTO MRT.DIM_Store
        (
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
    SELECT
        new.StoreNK,
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
    FROM INT.Sales_Store new

        LEFT JOIN MRT.DIM_Store dim
        ON new.StoreNK = dim.StoreNK
            AND dim.Valid = 1

        LEFT JOIN MRT.DIM_SalesPerson sp
        ON new.SalesPersonNK = sp.SalesPersonNK
            AND sp.Valid = 1

    WHERE dim.StoreSK IS NULL;

    UPDATE dim
        SET
            dim.AnnualSales = new.AnnualSales,
            dim.AnnualRevenue = new.AnnualRevenue,
            dim.YearOpened = new.YearOpened,
            dim.EmployeeCount = new.EmployeeCount,
            dim.ModifiedDate = new.ModifiedDate,
            dim.ExtractDatetime = new.ExtractDatetime
        FROM MRT.DIM_Store dim
        INNER JOIN INT.Sales_Store new
        ON dim.StoreNK = new.StoreNK
        WHERE dim.Valid = 1;

        COMMIT TRANSACTION;
        END TRY

        BEGIN CATCH
            IF @@TRANCOUNT >0
                ROLLBACK TRANSACTION;
            THROW;
        END CATCH
END;
GO

CREATE OR ALTER PROCEDURE MRT.USP_LOAD_DIM_TERRITORY
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @ExecutionTime DATETIME2 = GETDATE();

    BEGIN TRY
        BEGIN TRANSACTION
            UPDATE dim
            SET
                dim.ValidTo = @ExecutionTime,
                dim.Valid = 0
            FROM MRT.DIM_Territory dim
        INNER JOIN INT.Sales_Territory new
        ON dim.TerritoryNK = new.TerritoryNK
                WHERE dim.Valid = 1
        AND dim.RowHash <> new.RowHash;

        INSERT INTO MRT.DIM_Territory
        (
        TerritoryNK,
        TerritoryName,
        CountryRegionCode,
        TerritoryGroup,
        SalesYTD,
        SalesLastYear,
        CostYTD,
        CostLastYear,
        ModifiedDate,
        ExtractedDatetime,
        RowHash,
        ValidFrom,
        ValidTo,
        Valid
        )
    SELECT
        new.TerritoryNK,
        new.TerritoryName,
        new.CountryRegionCode,
        new.TerritoryGroup,
        new.SalesYTD,
        new.SalesLastYear,
        new.CostYTD,
        new.CostLastYear,
        new.ModifiedDate,
        new.ExtractedDatetime,
        new.RowHash,
        @ExecutionTime AS ValidFrom,
        NULL AS ValidTo,
        1 AS Valid
    FROM INT.Sales_Territory new
        LEFT JOIN MRT.DIM_Territory dim
        ON new.TerritoryNK = dim.TerritoryNK
            AND dim.Valid = 1
    WHERE dim.TerritorySK IS NULL;

    UPDATE dim
        SET
            dim.SalesYTD = new.SalesYTD,
            dim.SalesLastYear = new.SalesLastYear,
            dim.CostYTD = new.CostYTD,
            dim.CostLastYear = new.CostLastYear,
            dim.ModifiedDate = new.ModifiedDate,
            dim.ExtractedDatetime = new.ExtractedDatetime
        FROM MRT.DIM_Territory dim
        INNER JOIN INT.Sales_Territory new
        ON dim.TerritoryNK = new.TerritoryNK
        WHERE dim.Valid = 1;
    COMMIT TRANSACTION;

        END TRY

        BEGIN CATCH
            IF @@TRANCOUNT >0
                ROLLBACK TRANSACTION;
            THROW;
        END CATCH
END;
GO

CREATE OR ALTER PROCEDURE MRT.USP_LOAD_DIM_CUSTOMER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @ExecutionTime DATETIME2(7) = GETDATE();

    BEGIN TRY
        BEGIN TRANSACTION
            --Invalidate out-of-date SCD-T2 records
            UPDATE dim
                SET
                    dim.ValidTo = @ExecutionTime,
                    dim.Valid = 0
            FROM MRT.DIM_Customer dim
        INNER JOIN INT.Sales_Customer new
        ON dim.CustomerNK = new.CustomerNK
                    WHERE dim.Valid = 1
        AND dim.RowHash <> new.RowHash;

            --Insert new and updated records
        INSERT INTO MRT.DIM_Customer
        (
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
    SELECT
        c.CustomerNK,
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
    FROM INT.Sales_Customer c

        LEFT JOIN MRT.DIM_Customer dim
        ON c.CustomerNK = dim.CustomerNK
            AND dim.Valid = 1

        LEFT JOIN MRT.DIM_Store s
        ON c.StoreNK = s.StoreNK
            AND s.Valid = 1

        LEFT JOIN MRT.DIM_Territory t
        ON c.TerritoryNK = t.TerritoryNK
            AND t.Valid = 1

        LEFT JOIN MRT.DIM_Person p
        ON c.PersonNK = p.PersonNK
            AND p.Valid = 1

    WHERE dim.CustomerSK IS NULL;

            COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
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
        BEGIN TRANSACTION
            --UPDATE existing records
            UPDATE fct
            SET
                fct.ProductSK = p.ProductSK,
                fct.SpecialOfferNK = new.SpecialOfferNK,
                fct.BillToAddressNK = new.BillToAddressNK,
                fct.ShipToAddressNK = new.ShipToAddressNK,
                fct.ShipMethodNK = new.ShipMethodNK,
                fct.CreditCardNK = new.CreditCardNK,
                fct.CustomerSK = c.CustomerSK,
                fct.SalesPersonSK = sp.SalesPersonSK,
                fct.TerritorySK = t.TerritorySK,
                fct.CurrencyRateNK = new.CurrencyRateNK,

                --Header
                fct.RevisionNumber = new.RevisionNumber,
                fct.OrderDate = new.OrderDate,
                fct.DueDate = new.DueDate,
                fct.ShipDate = new.ShipDate,
                fct.StatusDescription = new.StatusDescription,
                fct.OnlineOrderFlag = new.OnlineOrderFlag,
                fct.OnlineOrderDescription = new.OnlineOrderDescription,
                fct.SalesOrderNumber = new.SalesOrderNumber,
                fct.PurchaseOrderNumber = new.PurchaseOrderNumber,
                fct.AccountNumber = new.AccountNumber,
                fct.CreditCardApprovalCode = new.CreditCardApprovalCode,
                fct.SubTotal = new.SubTotal,
                fct.TaxAmt = new.TaxAmt,
                fct.Freight = new.Freight,
                fct.TotalDue = new.TotalDue,
                fct.Comment = new.Comment,

                --Detail
                fct.CarrierTrackingNumber = new.CarrierTrackingNumber,
                fct.OrderQty = new.OrderQty,
                fct.UnitPrice = new.UnitPrice,
                fct.UnitPriceDiscount = new.UnitPriceDiscount,
                fct.LineTotal = new.LineTotal,

                --Metadata
                fct.HeaderLastModifiedDate = new.HeaderLastModifiedDate,
                fct.DetailLastModifiedDate = new.DetailLastModifiedDate,
                fct.SalesOrderHeaderExtractedDateTime = new.SalesOrderHeaderExtractedDateTime,
                fct.SalesOrderDetailExtractedDateTime = new.SalesOrderDetailExtractedDateTime,
                fct.SalesOrderHeaderHash = new.SalesOrderHeaderHash,
                fct.SalesOrderDetailHash = new.SalesOrderDetailHash,
                fct.FactSalesHash = new.FactSalesHash
            FROM MRT.Fact_Sales fct
        INNER JOIN INT.FactSales new
        ON fct.SalesOrderDetailNK = new.SalesOrderDetailNK

        LEFT JOIN MRT.DIM_Product p
        ON new.ProductNK = p.ProductNK
            AND new.OrderDate >= p.ValidFrom
            AND (new.OrderDate < p.ValidTo OR p.ValidTo IS NULL)

        LEFT JOIN MRT.DIM_SalesPerson sp
        ON new.SalesPersonNK = sp.SalesPersonNK
            AND new.OrderDate >= sp.ValidFrom
            AND (new.OrderDate < sp.ValidTo OR sp.ValidTo IS NULL)

        LEFT JOIN MRT.DIM_Customer c
        ON new.CustomerNK = c.CustomerNK
            AND new.OrderDate >= c.ValidFrom
            AND (new.OrderDate < c.ValidTo OR c.ValidTo IS NULL)

        LEFT JOIN MRT.DIM_Territory t
        ON new.TerritoryNK = t.TerritoryNK
            AND new.OrderDate >= t.ValidFrom
            AND (new.OrderDate < t.ValidTo OR t.ValidTo IS NULL)
        
        WHERE fct.FactSalesHash <> new.FactSalesHash;

            --INSERT new records
        INSERT INTO MRT.Fact_Sales
        (
        SalesOrderNK,
        SalesOrderDetailNK,
        ProductSK,
        SpecialOfferNK,
        BillToAddressNK,
        ShipToAddressNK,
        ShipMethodNK,
        CreditCardNK,
        CustomerSK,
        SalesPersonSK,
        TerritorySK,
        CurrencyRateNK,

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
    SELECT
        new.SalesOrderNK,
        new.SalesOrderDetailNK,
        p.ProductSK,
        new.SpecialOfferNK,
        new.BillToAddressNK,
        new.ShipToAddressNK,
        new.ShipMethodNK,
        new.CreditCardNK,
        c.CustomerSK,
        sp.SalesPersonSK,
        t.TerritorySK,
        new.CurrencyRateNK,

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
    FROM INT.FactSales new
        LEFT JOIN MRT.Fact_Sales fct
        ON new.SalesOrderDetailNK = fct.SalesOrderDetailNK

        LEFT JOIN MRT.DIM_Product p
        ON new.ProductNK = p.ProductNK
            AND new.OrderDate >= p.ValidFrom
            AND (new.OrderDate < p.ValidTo OR p.ValidTo IS NULL)

        LEFT JOIN MRT.DIM_SalesPerson sp
        ON new.SalesPersonNK = sp.SalesPersonNK
            AND new.OrderDate >= sp.ValidFrom
            AND (new.OrderDate < sp.ValidTo OR sp.ValidTo IS NULL)

        LEFT JOIN MRT.DIM_Customer c
        ON new.CustomerNK = c.CustomerNK
            AND new.OrderDate >= c.ValidFrom
            AND (new.OrderDate < c.ValidTo OR c.ValidTo IS NULL)

        LEFT JOIN MRT.DIM_Territory t
        ON new.TerritoryNK = t.TerritoryNK
            AND new.OrderDate >= t.ValidFrom
            AND (new.OrderDate < t.ValidTo OR t.ValidTo IS NULL)

    WHERE fct.FactSalesSK IS NULL;
            COMMIT TRANSACTION;
            END TRY

        BEGIN CATCH 
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION;
        THROW; 
        END CATCH
END;
GO