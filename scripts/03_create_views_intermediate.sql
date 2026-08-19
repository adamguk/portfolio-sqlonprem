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
            CONVERT(NVARCHAR(50), p.StandardCost, 2),
            CONVERT(NVARCHAR(50), p.ListPrice, 2),
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

----------------------------
-----------SALES------------
----------------------------

CREATE OR ALTER VIEW INT.Sales_SalesOrderDetail
AS
    SELECT
        [SalesOrderID] AS SalesOrderNK,
        [SalesOrderDetailID] AS SalesOrderDetailNK,
        [CarrierTrackingNumber],
        [OrderQty],
        COALESCE([ProductID],-1) AS ProductNK,
        COALESCE([SpecialOfferID],-1)  AS SpecialOfferNK,
        [UnitPrice],
        [UnitPriceDiscount],
        [LineTotal],
        [ModifiedDate],
        [ExtractDatetime] AS SalesOrderDetailExtractedDateTime,
        [RowHash] AS SalesOrderDetailHash
    FROM STG.Sales_SalesOrderDetail;
GO

CREATE OR ALTER VIEW INT.Sales_SalesOrderHeader
AS
    SELECT
        [SalesOrderID] AS SalesOrderNK,
        [RevisionNumber],
        [OrderDate],
        [DueDate],
        [ShipDate],
        [Status] AS StatusNumber,
        CASE [Status] 
            WHEN 1 THEN 'In process'
            WHEN 2 THEN 'Approved'
            WHEN 3 THEN 'Backordered'
            WHEN 4 THEN 'Rejected'
            WHEN 5 THEN 'Shipped'
            WHEN 6 THEN 'Cancelled'
            ELSE 'No Status'
        END AS StatusDescription,
        [OnlineOrderFlag],
        IIF([OnlineOrderFlag] = 0,'Offline Order','Online Order') AS OnlineOrderDescription,
        [SalesOrderNumber],
        [PurchaseOrderNumber],
        [AccountNumber],
        COALESCE([CustomerID],-1) AS CustomerNK,
        COALESCE([SalesPersonID],-1) AS SalesPersonNK,
        COALESCE([TerritoryID],-1) AS TerritoryNK,
        COALESCE([BillToAddressID],-1) AS BillToAddressNK,
        COALESCE([ShipToAddressID],-1) AS ShipToAddressNK,
        COALESCE([ShipMethodID],-1) AS ShipMethodNK,
        COALESCE([CreditCardID],-1) AS CreditCardNK,
        COALESCE([CreditCardApprovalCode],'NA') AS CreditCardApprovalCode,
        COALESCE([CurrencyRateID],-1) AS CurrencyRateNK,
        [SubTotal],
        [TaxAmt],
        [Freight],
        [TotalDue],
        [Comment],
        [ModifiedDate],
        [ExtractDatetime] AS SalesOrderHeaderExtractedDateTime,
        [RowHash] AS SalesOrderHeaderHash
    FROM STG.Sales_SalesOrderHeader;
GO

CREATE OR ALTER VIEW INT.Sales_Store
AS
    WITH
        XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey')
    SELECT
        --Keys
        s.BusinessEntityID AS StoreNK,
        s.SalesPersonID AS SalesPersonNK,

        --SCD-T2 tracked
        s.Name AS StoreName,
        COALESCE(s.Demographics.value('(BusinessType)[1]','NVARCHAR(5)'),'NA') AS BusinessType,
        COALESCE(s.Demographics.value('(Specialty)[1]','NVARCHAR(50)'),'NA') AS Specialty,


        --SCD-T1 
        s.Demographics.value('(NumberEmployees)[1]','INT') AS EmployeeCount,
        COALESCE(s.Demographics.value('(AnnualSales)[1]','MONEY'),0) AS AnnualSales,
        COALESCE(s.Demographics.value('(AnnualRevenue)[1]','MONEY'),0) AS AnnualRevenue,
        s.Demographics.value('(YearOpened)[1]', 'INT') AS YearOpened,

        --Metadata
        s.ModifiedDate,
        s.ExtractDatetime,

        --Change detection
        HASHBYTES('SHA2_256',CONCAT_WS('|',
                COALESCE(s.Name,'NA'),
                CAST(COALESCE(s.SalesPersonID,-1) AS VARCHAR(10)),
                COALESCE(s.Demographics.value('(BusinessType)[1]','NVARCHAR(5)'),'NA'),
                COALESCE(s.Demographics.value('(Specialty)[1]','NVARCHAR(50)'),'NA'))) AS RowHash

    FROM STG.Sales_Store s;
GO

CREATE OR ALTER VIEW INT.SalesPerson
AS
    SELECT
        --Keys
        s.BusinessEntityID AS SalesPersonNK,
        --SCD-T2 Tracked
        COALESCE(s.TerritoryID,-1) AS TerritoryNK,

        --SCD-T1 
        s.SalesQuota,
        s.Bonus,
        s.CommissionPct AS CommissionPercentage,
        s.SalesYTD,
        s.SalesLastYear,

        --Metadata
        s.ModifiedDate,
        s.ExtractDatetime,

        --Change detection
        HASHBYTES('SHA2_256',CAST(COALESCE(s.TerritoryID,-1) AS VARCHAR(10))) AS RowHash

    FROM STG.Sales_SalesPerson s;
GO

CREATE OR ALTER VIEW INT.Sales_Territory
AS
    SELECT
        --Keys
        COALESCE(st.TerritoryID,-1) AS TerritoryNK,

        --SCD-T2 tracked
        COALESCE(st.[Name],'NA') AS TerritoryName,
        COALESCE(st.CountryRegionCode,'NA') AS CountryRegionCode,
        COALESCE(st.[Group],'NA') AS TerritoryGroup,

        --SCD-T1
        st.SalesYTD,
        st.SalesLastYear,
        st.CostYTD,
        st.CostLastYear,

        --Metadata
        st.ModifiedDate,
        st.ExtractDatetime,

        --Change detection
        HASHBYTES('SHA2_256',CONCAT_WS('|',
            COALESCE(st.[Name],'NA'),
            COALESCE(st.CountryRegionCode,'NA'),
            COALESCE(st.[Group],'NA')
            )) AS RowHash

    FROM STG.Sales_SalesTerritory st;
GO

CREATE OR ALTER VIEW INT.Sales_Customer
AS
    SELECT
        --Keys
        c.CustomerID AS CustomerNK,
        COALESCE(c.PersonID,-1) AS PersonNK,
        COALESCE(c.StoreID,-1) AS StoreNK,
        COALESCE(c.TerritoryID,-1) AS TerritoryNK,

        --Shared Fields
        CASE 
            WHEN c.PersonID IS NOT NULL THEN 'Individual' 
            WHEN c.StoreID IS NOT NULL THEN 'Store'
            ELSE 'NA' 
            END AS CustomerType,
        COALESCE(c.AccountNumber,'NA') AS AccountNumber,

        --Store Fields
        st.StoreName,
        st.AnnualRevenue AS Store_AnnualRevenue,
        st.AnnualSales AS Store_AnnualSales,
        st.BusinessType AS Store_BusinessType,
        st.Specialty AS Store_Specialty,
        st.YearOpened AS Store_YearOpened,
        st.NumberEmployees AS Store_EmployeeCount,

        --Individual Customer Fields
        p.PersonTypeDescription,
        p.FullName AS Individual_FullName,
        p.EmailAddress AS Individual_EmailAddress,
        p.EmailPromotionSignUp AS Individual_EmailPromotionSignUp,

        --Metadata
        c.ModifiedDate,
        c.ExtractDatetime,

        --Change detection
        HASHBYTES('SHA2_256',CONCAT_WS('|',
            CASE 
                WHEN c.PersonID IS NOT NULL THEN 'Individual' 
                WHEN c.StoreID IS NOT NULL THEN 'Store'
            ELSE 'NA' 
            END,
            COALESCE(c.AccountNumber,'NA'),
            COALESCE(st.StoreName,'NA'),
            COALESCE(CONVERT(NVARCHAR(50),st.AnnualRevenue,2),'NA'),
            COALESCE(CONVERT(NVARCHAR(50),st.AnnualSales,2),'NA'),
            COALESCE(st.BusinessType,'NA'),
            COALESCE(st.Specialty,'NA'),
            COALESCE(CAST(st.YearOpened AS NVARCHAR(10)),'NA'),
            COALESCE(CAST(st.NumberEmployees AS NVARCHAR(50)),'NA'),
            COALESCE(p.PersonTypeDescription,'NA'),
            COALESCE(p.FullName,'NA'),
            COALESCE(p.EmailAddress,'NA'),
            COALESCE(p.EmailPromotionSignUp,'NA')        
        )) AS RowHash

    FROM STG.Sales_Customer c
        LEFT JOIN INT.Sales_Store st
        ON c.StoreID = st.StoreNK
        LEFT JOIN INT.Person_Person p
        ON c.PersonID = p.PersonNK;
GO

CREATE OR ALTER VIEW INT.FactSales
AS
    SELECT
        --Keys
        d.SalesOrderNK,
        d.SalesOrderDetailNK,
        d.ProductNK,
        d.SpecialOfferNK,
        h.BillToAddressNK,
        h.ShipToAddressNK,
        h.ShipMethodNK,
        h.CreditCardNK,
        h.CustomerNK,
        h.SalesPersonNK,
        h.TerritoryNK,
        h.CurrencyRateNK,

        --Header
        h.RevisionNumber,
        h.OrderDate,
        h.DueDate,
        h.ShipDate,
        h.StatusDescription,
        h.OnlineOrderFlag,
        h.OnlineOrderDescription,
        h.SalesOrderNumber,
        h.PurchaseOrderNumber,
        h.AccountNumber,
        h.CreditCardApprovalCode,
        h.SubTotal,
        h.TaxAmt,
        h.Freight,
        h.TotalDue,
        h.Comment,

        --Detail
        d.CarrierTrackingNumber,
        d.OrderQty,
        d.UnitPrice,
        d.UnitPriceDiscount,
        d.LineTotal,

        --Metadata
        h.ModifiedDate AS HeaderLastModifiedDate,
        d.ModifiedDate AS DetailLastModifiedDate,
        h.SalesOrderHeaderExtractedDateTime,
        d.SalesOrderDetailExtractedDateTime,
        h.SalesOrderHeaderHash,
        d.SalesOrderDetailHash,

        --Change detection
        HASHBYTES('SHA2_256', CONCAT_WS('|',
            CONVERT(NVARCHAR(64), h.SalesOrderHeaderHash, 2),
            CONVERT(NVARCHAR(64), d.SalesOrderDetailHash, 2)
        )) AS FactSalesHash

    FROM INT.Sales_SalesOrderDetail d
        INNER JOIN INT.Sales_SalesOrderHeader h
        ON d.SalesOrderNK = h.SalesOrderNK;
GO
