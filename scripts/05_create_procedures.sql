USE DWH_ONPREM;
GO

CREATE OR ALTER PROCEDURE MRT.USP_LOAD_DIM_PERSON
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @ExecutionTime DATETIME2(7) = GETDATE();

    BEGIN TRY 
        BEGIN TRANSACTION;

        UPDATE dim
        SET dim.ValidTo = @ExecutionTime, 
            dim.Valid=0
        FROM MRT.DIM_Person dim
        INNER JOIN (
            SELECT
            PersonNK,
            RowHash
        FROM INT.Person_Person
        ) src ON dim.PersonNK = src.PersonNK
        WHERE dim.Valid = 1
        AND dim.RowHash <> src.RowHash;

        INSERT INTO MRT.Dim_Person
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
        LEFT JOIN MRT.Dim_Person dim
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
            UPDATE dim
             SET dim.ValidTo = @ExecutionTime,
                dim.Valid = 0
            FROM MRT.Dim_Person_Address dim
        INNER JOIN INT.Person_Address_Joined src
        ON dim.PersonAddressCNK = src.PersonAddressCNK
            WHERE dim.Valid=1
        AND dim.RowHash <> src.NewRowHash;

        INSERT INTO MRT.Dim_Person_Address
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
        LEFT JOIN MRT.Dim_Person_Address dim
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
        --Invalidate out-of-date SCDT2 records
            UPDATE dim
            SET
                dim.ValidTo = @ExecutionTime,
                dim.Valid = 0
            FROM MRT.Dim_Product dim
        INNER JOIN INT.Production_Product src
        ON src.ProductNK = dim.ProductNK
            WHERE dim.Valid=1
        AND dim.RowHash <> src.RowHash;

        --Insert new/changed SCDT2 records
        INSERT INTO MRT.Dim_Product
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
        src.ProductNK,
        src.ProductName,
        src.ProductNumber,
        src.MakeFlag,
        src.MakeFlagDescription,
        src.FinishedGoodsFlag,
        src.FinishedGoodsDescription,
        src.Color,
        src.SafetyStockLevel,
        src.ReorderPoint,
        src.StandardCost,
        src.ListPrice,
        src.Size,
        src.SizeUnitMeasureCodeNK,
        src.WeightUnitMeasureCodeNK,
        src.Weight,
        src.DaysToManufacture,
        src.ProductLine,
        src.Class,
        src.Style,
        src.ProductCategoryNK,
        src.ProductCategoryName,
        src.ProductSubcategoryNK,
        src.ProductSubCategoryName,
        src.ProductModelNK,
        src.ProductModelName,
        src.SellStartDate,
        src.SellEndDate,
        src.DiscontinuedDate,
        src.ModifiedDate,
        src.ExtractDatetime,
        src.RowHash,
        @ExecutionTime AS ValidFrom,
        NULL AS ValidTo,
        1 AS Valid
    FROM INT.Production_Product src
        LEFT JOIN MRT.Dim_Product dim
        ON dim.ProductNK = src.ProductNK
            AND dim.Valid = 1
    WHERE dim.ProductSK IS NULL;

        --Update SCDT1 records

        UPDATE dim
        SET 
            dim.ProductNumber = src.ProductNumber,
            dim.SafetyStockLevel = src.SafetyStockLevel,
            dim.ReorderPoint = src.ReorderPoint,
            dim.DaysToManufacture = src.DaysToManufacture,
            dim.ModifiedDate = src.ModifiedDate,
            dim.ExtractDatetime = src.ExtractDatetime
        FROM MRT.Dim_Product dim
        JOIN INT.Production_Product src
        ON dim.ProductNK = src.ProductNK
            WHERE dim.Valid = 1
            COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH 
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION;
        THROW; 
    END CATCH

END;
GO