USE DWH_ONPREM;
GO

----------------------------
-----------PERSON-----------
----------------------------

CREATE OR ALTER VIEW INT.Person_Person
AS
    SELECT
        p.BusinessEntityID as PersonNK,
        p.PersonType,
        CASE p.PersonType
            WHEN 'SC' THEN 'Store Contact'
            WHEN 'IN' THEN 'Individual'
            WHEN 'SP' THEN 'Salesperson'
            WHEN 'EM' THEN 'Employee Non-Sales'
            WHEN 'VC' THEN 'Vendor Contact'
            WHEN 'GC' THEN 'General Contact'
            ELSE 'NA'
        END AS PersonTypeDescription,
        CASE p.PersonType
            WHEN 'SP' THEN 'Internal Employees'
            WHEN 'EM' THEN 'Internal Employees'
            ELSE 'NA'
        END AS PersonTypeGroup,
        COALESCE(p.Title,'NA') AS Title,
        COALESCE(p.FirstName,'NA') AS FirstName,
        COALESCE(p.MiddleName,'NA') AS MiddleName,
        COALESCE(p.LastName,'NA') AS LastName,
        COALESCE(p.Suffix,'NA') as Suffix,
        CONCAT_WS(' ', NULLIF(p.Title,'NA'), NULLIF(p.FirstName,'NA'), NULLIF(p.MiddleName,'NA'), NULLIF(p.LastName,'NA'), NULLIF(p.Suffix,'NA')) AS FullName,
        COALESCE(e.EmailAddress, 'NA') AS EmailAddress,
        p.EmailPromotion as EmailPromotionSignUpFlag,
        IIF(p.EmailPromotion = 1, 'Yes','No') as EmailPromotionSignUp,
        p.ModifiedDate,
        p.ExtractDatetime,

        --TYPE 2 (versioned) tracked attributes
        HASHBYTES('SHA2_256', CONCAT_WS('|',
            COALESCE(p.PersonType, ''),
            CASE p.PersonType
                WHEN 'SC' THEN 'Store Contact'
                WHEN 'IN' THEN 'Individual'
                WHEN 'SP' THEN 'Salesperson'
                WHEN 'EM' THEN 'Employee Non-Sales'
                WHEN 'VC' THEN 'Vendor Contact'
                WHEN 'GC' THEN 'General Contact'
                ELSE 'NA'
            END,
            CASE p.PersonType
                WHEN 'SP' THEN 'Internal Employees'
                WHEN 'EM' THEN 'Internal Employees'
                ELSE 'NA'
            END,
            COALESCE(p.Title, ''),
            COALESCE(p.FirstName, ''),
            COALESCE(p.MiddleName, ''),
            COALESCE(p.LastName, ''),
            COALESCE(p.Suffix, ''),
            COALESCE(e.EmailAddress, ''),
            CAST(COALESCE(p.EmailPromotion, 0) AS VARCHAR(10))
        )) AS RowHash
        
    FROM STG.Person_Person p
        LEFT JOIN INT.Person_EmailAddress e
        ON e.PersonNK = p.BusinessEntityID;
GO

CREATE OR ALTER VIEW INT.Person_Address
AS
    SELECT
        A.AddressID AS PersonAddressNK,
        A.AddressLine1,
        A.AddressLine2,
        A.City,
        A.StateProvinceNK,
        A.PostalCode,
        A.SpatialLocation,
        A.ModifiedDate,
        A.ExtractDatetime,
        A.RowHash
    FROM STG.Person_Address A; 
GO

CREATE OR ALTER VIEW INT.Person_AddressType
AS
    SELECT
        AddressTypeID AS PersonAddressTypeNK,
        Name AS AddressTypeName,
        ModifiedDate,
        ExtractDatetime,
        RowHash
    FROM STG.Person_AddressType;
GO

CREATE OR ALTER VIEW INT.Person_BusinessEntity
AS
    SELECT
        BusinessEntityID as PersonNK,
        ModifiedDate,
        ExtractDatetime,
        RowHash
    FROM STG.Person_BusinessEntity;
GO


CREATE OR ALTER VIEW INT.Person_BusinessEntityAddress
AS
    SELECT
        BusinessEntityID AS PersonNK,
        AddressID AS PersonAddressNK,
        AddressTypeID AS PersonAddressTypeNK,
        CONCAT(BusinessEntityID,'-',AddressID,'-',AddressTypeID) AS BusinessEntityAddressCNK,
        ModifiedDate,
        ExtractDatetime,
        RowHash
    FROM STG.Person_BusinessEntityAddress;
GO

CREATE OR ALTER VIEW INT.Person_BusinessEntityContact
AS
    SELECT
        BusinessEntityID AS CompanyNK,
        PersonID AS PersonNK ,
        ContactTypeID AS ContactTypeNK,
        CONCAT(BusinessEntityID,'-',PersonID,'-',ContactTypeID) AS BusinessEntityContactCNK,
        ModifiedDate,
        ExtractDatetime,
        RowHash
    FROM STG.Person_BusinessEntityContact;
GO

CREATE OR ALTER VIEW INT.Person_ContactType
AS
    SELECT
        ContactTypeID AS ContactTypeNK,
        Name,
        ModifiedDate,
        ExtractDatetime,
        RowHash
    FROM STG.Person_ContactType;
GO

CREATE OR ALTER VIEW INT.Person_CountryRegion
AS
    SELECT
        CountryRegionCode AS CountryRegionNK,
        Name AS CountryRegionName,
        ModifiedDate,
        ExtractDatetime,
        RowHash
    FROM STG.Person_CountryRegion;
GO

CREATE OR ALTER VIEW INT.Person_EmailAddress
AS
    SELECT
        BusinessEntityID AS PersonNK,
        EmailAddressID AS EmailNK,
        CONCAT(BusinessEntityID,'-',EmailAddressID) AS EmailAddressCNK,
        EmailAddress,
        ModifiedDate,
        ExtractDatetime,
        RowHash
    FROM STG.Person_EmailAddress;
GO

CREATE OR ALTER VIEW INT.Person_Password
AS
    SELECT
        BusinessEntityID AS PersonNK,
        PasswordHash,
        PasswordSalt,
        ModifiedDate,
        ExtractDatetime,
        RowHash
    FROM STG.Person_Password;
GO

CREATE OR ALTER VIEW INT.Person_PersonPhone
AS
    SELECT
        BusinessEntityID AS PersonNK,
        PhoneNumber,
        PhoneNumberTypeID AS PhoneNumberTypeNK,
        CONCAT(BusinessEntityID,'-', PhoneNumberTypeID,'-', PhoneNumber) AS PersonPhoneCNK,
        ModifiedDate,
        ExtractDatetime,
        RowHash
    FROM STG.Person_PersonPhone;
GO

CREATE OR ALTER VIEW INT.Person_PhoneNumberType
AS
    SELECT
        PhoneNumberTypeID AS PhoneNumberTypeNK,
        Name,
        ModifiedDate,
        ExtractDatetime,
        RowHash
    FROM STG.Person_PhoneNumberType;
GO

CREATE OR ALTER VIEW INT.Person_StateProvince
AS
    SELECT
        StateProvinceID AS StateProvinceNK,
        StateProvinceCode,
        CountryRegionCode AS CountryRegionNK,
        IsOnlyStateProvinceFlag,
        IIF(IsOnlyStateProvinceFlag = 1,'Yes','No') AS IsOnlyStateProvinceDescription,
        Name AS StateProvinceName,
        TerritoryID AS TerritoryNK,
        ModifiedDate,
        ExtractDatetime,
        RowHash
    FROM STG.Person_StateProvince;
GO

CREATE OR ALTER VIEW INT.Person_Address_Joined
AS
    SELECT
        CONCAT(p.PersonNK, '|', a.PersonAddressNK, '|', t.PersonAddressTypeNK) AS PersonAddressCNK,
        p.PersonNK,
        a.PersonAddressNK,
        t.PersonAddressTypeNK,
        cr.CountryRegionNK,
        sp.StateProvinceNK,
        a.AddressLine1,
        a.AddressLine2,
        a.City,
        a.PostalCode,
        a.SpatialLocation,
        t.AddressTypeName,
        cr.CountryRegionName,
        sp.StateProvinceCode,
        sp.StateProvinceName,
        sp.IsOnlyStateProvinceFlag,
        sp.IsOnlyStateProvinceDescription,

        --TYPE 2 (versioned) tracked attributes
        HASHBYTES('SHA2_256', CONCAT_WS('|',
            COALESCE(a.AddressLine1, ''),
            COALESCE(a.AddressLine2, ''),
            COALESCE(a.City, ''),
            COALESCE(a.PostalCode, ''),
            COALESCE(t.AddressTypeName, ''),
            COALESCE(cr.CountryRegionName, ''),
            COALESCE(sp.StateProvinceCode, '')
        )) AS NewRowHash

    FROM INT.Person_Person p
        INNER JOIN INT.Person_BusinessEntityAddress bea
        ON p.PersonNK = bea.PersonNK
        INNER JOIN INT.Person_Address a
        ON bea.PersonAddressNK = a.PersonAddressNK
        INNER JOIN INT.Person_AddressType t
        ON bea.PersonAddressTypeNK = t.PersonAddressTypeNK
        INNER JOIN INT.Person_StateProvince sp
        ON a.StateProvinceNK = sp.StateProvinceNK
        INNER JOIN INT.Person_CountryRegion cr
        ON sp.CountryRegionNK = cr.CountryRegionNK;
GO

----------------------------
---------PRODUCT------------
----------------------------

CREATE OR ALTER VIEW INT.Production_Product
AS
    SELECT
        p.ProductID AS ProductNK,
        COALESCE(p.Name,'NA') AS ProductName,
        p.ProductNumber,
        p.MakeFlag,
        IIF(p.MakeFlag = 0, 'Vendor Supplied','Made In-House') as MakeFlagDescription,
        p.FinishedGoodsFlag,
        IIF(p.FinishedGoodsFlag = 0, 'Production Component','Consumer Product') as FinishedGoodsDescription,
        COALESCE(p.Color,'NA') as Color,
        p.SafetyStockLevel,
        p.ReorderPoint,
        p.StandardCost,
        p.ListPrice,
        p.Size,
        COALESCE(TRIM(p.SizeUnitMeasureCode),'NA') AS SizeUnitMeasureCodeNK,
        COALESCE(TRIM(p.WeightUnitMeasureCode),'NA') AS WeightUnitMeasureCodeNK,
        p.Weight,
        p.DaysToManufacture,
        COALESCE(TRIM(p.ProductLine),'NA') AS ProductLine,
        COALESCE(TRIM(p.Class),'NA') AS Class,
        COALESCE(TRIM(p.Style),'NA') AS Style,
        COALESCE(pc.ProductCategoryID,-1) AS ProductCategoryNK,
        COALESCE(pc.Name,'NA') AS ProductCategoryName,
        COALESCE(p.ProductSubcategoryID,-1) AS ProductSubcategoryNK,
        COALESCE(sub.Name,'NA') AS ProductSubCategoryName,
        COALESCE(p.ProductModelID,-1) AS ProductModelNK,
        COALESCE(mod.Name,'NA') AS ProductModelName,
        p.SellStartDate,
        p.SellEndDate,
        p.DiscontinuedDate,
        p.ModifiedDate,
        p.ExtractDatetime,

        --TYPE 2 (versioned) tracked attributes
        HASHBYTES('SHA2_256',CONCAT_WS('|',
            COALESCE(p.Name,'NA'),
            CAST(p.MakeFlag AS VARCHAR(10)),
            IIF(p.MakeFlag = 0, 'Vendor Supplied','Made In-House'),
            CAST(p.FinishedGoodsFlag AS VARCHAR(10)),
            IIF(p.FinishedGoodsFlag = 0, 'Production Component','Consumer Product'),
            COALESCE(p.Color,'NA'),
            CAST(p.StandardCost AS VARCHAR(50)),
            CAST(p.ListPrice AS VARCHAR(50)),
            CAST(p.Size AS VARCHAR(50)),
            COALESCE(TRIM(p.SizeUnitMeasureCode),'NA'),
            COALESCE(TRIM(p.WeightUnitMeasureCode),'NA'),
            CAST(p.Weight AS VARCHAR(50)),
            COALESCE(TRIM(p.ProductLine),'NA'),
            COALESCE(TRIM(p.Class),'NA'),
            COALESCE(TRIM(p.Style),'NA'),
            CAST(COALESCE(pc.ProductCategoryID,-1) AS VARCHAR(50)),
            COALESCE(pc.Name,'NA'),
            CAST(COALESCE(p.ProductSubcategoryID,-1) AS VARCHAR(50)),
            COALESCE(sub.Name,'NA'),
            CAST(COALESCE(p.ProductModelID,-1) AS VARCHAR(50)),
            COALESCE(mod.Name,'NA'),
            COALESCE(CONVERT(NVARCHAR(30), p.SellStartDate, 126), 'NA'),
            COALESCE(CONVERT(NVARCHAR(30), p.SellEndDate, 126), 'NA'),
            COALESCE(CONVERT(NVARCHAR(30), p.DiscontinuedDate, 126), 'NA')
            ))
        AS RowHash

    FROM STG.Production_Product p
    LEFT JOIN STG.Production_ProductSubcategory AS sub 
        ON p.ProductSubcategoryID = sub.ProductSubcategoryID
    LEFT JOIN STG.Production_ProductCategory AS pc 
        ON sub.ProductCategoryID = pc.ProductCategoryID
    LEFT JOIN STG.Production_ProductModel AS mod
        ON p.ProductModelID = mod.ProductModelID;
GO

