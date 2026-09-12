USE DWH_ONPREM;

GO

IF OBJECT_ID (N'STG.Person_Address', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Person_Address
    (
        [AddressID] INT NOT NULL,
        [AddressLine1] NVARCHAR(60) NULL,
        [AddressLine2] NVARCHAR(60) NULL,
        [City] NVARCHAR(30) NULL,
        [StateProvinceID] INT NULL,
        [PostalCode] NVARCHAR(15) NULL,
        [SpatialLocation] GEOGRAPHY NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE (),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Person_AddressType', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Person_AddressType
    (
        [AddressTypeID] INT NOT NULL,
        [Name] NVARCHAR(50) NOT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE (),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Production_BillOfMaterials', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Production_BillOfMaterials
    (
        [BillOfMaterialsID] INT NOT NULL,
        [ProductAssemblyID] INT NULL,
        [ComponentID] INT NOT NULL,
        [StartDate] DATETIME2 NOT NULL,
        [EndDate] DATETIME2 NOT NULL,
        [UnitOfMeasure] NCHAR(3) NULL,
        [BOMLevel] SMALLINT NULL,
        [PerAssembly] DECIMAL(8,2) NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE (),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Person_BusinessEntity', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Person_BusinessEntity
    (
        [BusinessEntityID] INT NOT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE (),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Person_BusinessEntityAddress', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Person_BusinessEntityAddress
    (
        [BusinessEntityID] INT NOT NULL,
        [AddressID] INT NOT NULL,
        [AddressTypeID] INT NOT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE (),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Person_BusinessEntityContact', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Person_BusinessEntityContact
    (
        [BusinessEntityID] INT NOT NULL,
        [PersonID] INT NOT NULL,
        [ContactTypeID] INT NOT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE (),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Person_ContactType', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Person_ContactType
    (
        [ContactTypeID] INT NOT NULL,
        [Name] NVARCHAR(50) NOT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE (),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Person_CountryRegion', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Person_CountryRegion
    (
        [CountryRegionCode] NVARCHAR(3) NOT NULL,
        [Name] NVARCHAR(50) NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE (),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Sales_CountryRegionCurrency', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Sales_CountryRegionCurrency
    (
        [CountryRegionCode] NVARCHAR(3) NOT NULL,
        [CurrencyCode] nchar(3) NOT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE (),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Sales_CreditCard', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Sales_CreditCard
    (
        [CreditCardID] INT NOT NULL,
        [CardType] NVARCHAR(50) NULL,
        [CardNumber] NVARCHAR(25) NULL,
        [ExpMonth] TINYINT NULL,
        [ExpYear] SMALLINT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE (),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Production_Culture', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Production_Culture
    (
        [CultureID] nchar(6) NOT NULL,
        [Name] NVARCHAR(50) NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE (),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Sales_Currency', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Sales_Currency
    (
        [CurrencyCode] nchar(3) NOT NULL,
        [Name] NVARCHAR(50) NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE (),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Sales_CurrencyRate', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Sales_CurrencyRate
    (
        [CurrencyRateID] INT NOT NULL,
        [CurrencyRateDate] DATETIME2 NULL,
        [FromCurrencyCode] nchar(3) NULL,
        [ToCurrencyCode] nchar(3) NULL,
        [AverageRate] MONEY NULL,
        [EndOfDayRate] MONEY NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE (),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Sales_Customer', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Sales_Customer
    (
        [CustomerID] INT NOT NULL,
        [PersonID] INT NULL,
        [StoreID] INT NULL,
        [TerritoryID] INT NULL,
        [AccountNumber] varchar(10) NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE (),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.HumanResources_Department', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.HumanResources_Department
    (
        [DepartmentID] SMALLINT NOT NULL,
        [Name] NVARCHAR(50) NULL,
        [GroupName] NVARCHAR(50) NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE (),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Production_Document', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Production_Document
    (
        [DocumentNode] hierarchyid NOT NULL,
        [DocumentLevel] SMALLINT NULL,
        [Title] NVARCHAR(50) NULL,
        [Owner] INT NULL,
        [FolderFlag] BIT NULL,
        [FileName] NVARCHAR(400) NULL,
        [FileExtension] NVARCHAR(8) NULL,
        [Revision] NVARCHAR(5) NULL,
        [ChangeNumber] INT NULL,
        [Status] TINYINT NULL,
        [DocumentSummary] NVARCHAR(max) NULL,
        [Document] varbinary(max) NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE (),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Person_EmailAddress', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Person_EmailAddress
    (
        [BusinessEntityID] INT NOT NULL,
        [EmailAddressID] INT NOT NULL,
        [EmailAddress] NVARCHAR(50) NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE (),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.HumanResources_Employee', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.HumanResources_Employee
    (
        [BusinessEntityID] INT NOT NULL,
        [NationalIDNumber] NVARCHAR(15) NOT NULL,
        [LoginID] NVARCHAR(256) NOT NULL,
        [OrganizationNode] HIERARCHYID NULL,
        [OrganizationLevel] SMALLINT NULL,
        [JobTitle] NVARCHAR(50) NULL,
        [BirthDate] DATETIME2 NULL,
        [MaritalStatus] NCHAR(1) NULL,
        [Gender] NCHAR(1) NULL,
        [HireDate] DATETIME2 NULL,
        [SalariedFlag] BIT NULL,
        [VacationHours] SMALLINT NULL,
        [SickLeaveHours] SMALLINT NULL,
        [CurrentFlag] BIT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE (),
        RowHash VARBINARY(32) NULL
    )

END;
GO

IF OBJECT_ID (N'STG.HumanResources_EmployeeDepartmentHistory', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.HumanResources_EmployeeDepartmentHistory
    (
        [BusinessEntityID] INT NOT NULL,
        [DepartmentID] SMALLINT NOT NULL,
        [ShiftID] TINYINT NOT NULL,
        [StartDate] DATETIME2,
        [EndDate] DATETIME2,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.HumanResources_EmployeePayHistory', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.HumanResources_EmployeePayHistory
    (
        [BusinessEntityID] INT NOT NULL,
        [RateChangeDate] DATETIME2 NOT NULL,
        [Rate] MONEY NOT NULL,
        [PayFrequency] TINYINT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Production_Illustration', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Production_Illustration
    (
        [IllustrationID] INT NOT NULL,
        [Diagram] XML NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.HumanResources_JobCandidate', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.HumanResources_JobCandidate
    (
        [JobCandidateID] INT NOT NULL,
        [BusinessEntityID] INT NULL,
        [Resume] XML NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Production_Location', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Production_Location
    (
        [LocationID] SMALLINT NOT NULL,
        [Name] NVARCHAR(50) NOT NULL,
        [CostRate] smallmoney NOT NULL,
        [Availability] decimal(8, 2) NOT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Person_Password', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Person_Password
    (
        [BusinessEntityID] INT NOT NULL,
        [PasswordHash] varchar(128) NOT NULL,
        [PasswordSalt] varchar(10) NOT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Person_Person', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Person_Person
    (
        [BusinessEntityID] INT NOT NULL,
        [PersonType] NCHAR(2) NULL,
        [NameStyle] BIT NULL,
        [Title] NVARCHAR(8) NULL,
        [FirstName] NVARCHAR(50) NULL,
        [MiddleName] NVARCHAR(50) NULL,
        [LastName] NVARCHAR(50) NULL,
        [Suffix] NVARCHAR(10) NULL,
        [EmailPromotion] INT NULL,
        [AdditionalContactInfo] XML NULL,
        [Demographics] XML NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )

END;
GO

IF OBJECT_ID (N'STG.Sales_PersonCreditCard', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Sales_PersonCreditCard
    (
        [BusinessEntityID] INT NOT NULL,
        [CreditCardID] INT NOT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Person_PersonPhone', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Person_PersonPhone
    (
        [BusinessEntityID] INT NOT NULL,
        [PhoneNumber] NVARCHAR(25) NOT NULL,
        [PhoneNumberTypeID] INT NOT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Person_PhoneNumberType', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Person_PhoneNumberType
    (
        [PhoneNumberTypeID] INT NOT NULL,
        [Name] NVARCHAR(50) NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Production_Product', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Production_Product
    (
        [ProductID] INT NOT NULL,
        [Name] NVARCHAR(50) NULL,
        [ProductNumber] NVARCHAR(25) NULL,
        [MakeFlag] BIT NULL,
        [FinishedGoodsFlag] BIT NULL,
        [Color] NVARCHAR(15) NULL,
        [SafetyStockLevel] SMALLINT NULL,
        [ReorderPoint] SMALLINT NULL,
        [StandardCost] MONEY NULL,
        [ListPrice] MONEY NULL,
        [Size] NVARCHAR(5) NULL,
        [SizeUnitMeasureCode] nchar(3) NULL,
        [WeightUnitMeasureCode] nchar(3) NULL,
        [Weight] decimal(8, 2) NULL,
        [DaysToManufacture] INT NULL,
        [ProductLine] nchar(2) NULL,
        [Class] nchar(2) NULL,
        [Style] nchar(2) NULL,
        [ProductSubcategoryID] INT NULL,
        [ProductModelID] INT NULL,
        [SellStartDate] DATETIME2 NULL,
        [SellEndDate] DATETIME2 NULL,
        [DiscontinuedDate] DATETIME2 NULL,
        [ModifiedDate] DATETIME2 NOT NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE()
    )
END;
GO

IF OBJECT_ID (N'STG.Production_ProductCategory', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Production_ProductCategory
    (
        [ProductCategoryID] INT NOT NULL,
        [Name] NVARCHAR(50) NOT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Production_ProductCostHistory', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Production_ProductCostHistory
    (
        [ProductID] INT NOT NULL,
        [StartDate] DATETIME2 NOT NULL,
        [EndDate] DATETIME2 NULL,
        [StandardCost] MONEY NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Production_ProductDescription', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Production_ProductDescription
    (
        [ProductDescriptionID] INT NOT NULL,
        [Description] NVARCHAR(400) NOT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Production_ProductDocument', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Production_ProductDocument
    (
        [ProductID] INT NOT NULL,
        [DocumentNode] hierarchyid NOT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Production_ProductInventory', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Production_ProductInventory
    (
        [ProductID] INT NOT NULL,
        [LocationID] SMALLINT NOT NULL,
        [Shelf] NVARCHAR(10) NOT NULL,
        [Bin] TINYINT NOT NULL,
        [Quantity] SMALLINT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Production_ProductListPriceHistory', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Production_ProductListPriceHistory
    (
        [ProductID] INT NOT NULL,
        [StartDate] DATETIME2 NOT NULL,
        [EndDate] DATETIME2 NULL,
        [ListPrice] MONEY NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Production_ProductModel', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Production_ProductModel
    (
        [ProductModelID] INT NOT NULL,
        [Name] NVARCHAR(50) NOT NULL,
        [CatalogDescription] XML NULL,
        [Instructions] XML NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Production_ProductModelIllustration', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Production_ProductModelIllustration
    (
        [ProductModelID] INT NOT NULL,
        [IllustrationID] INT NOT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Production_ProductModelProductDescriptionCulture', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Production_ProductModelProductDescriptionCulture
    (
        [ProductModelID] INT NOT NULL,
        [ProductDescriptionID] INT NOT NULL,
        [CultureID] nchar(6),
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Production_ProductPhoto', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Production_ProductPhoto
    (
        [ProductPhotoID] INT NOT NULL,
        [ThumbNailPhoto] varbinary(MAX) NULL,
        [ThumbnailPhotoFileName] NVARCHAR(50) NULL,
        [LargePhoto] varbinary(MAX) NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Production_ProductProductPhoto', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Production_ProductProductPhoto
    (
        [ProductID] INT NOT NULL,
        [ProductPhotoID] INT NOT NULL,
        [Primary] BIT NOT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Production_ProductReview', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Production_ProductReview
    (
        [ProductReviewID] INT NOT NULL,
        [ProductID] INT NOT NULL,
        [ReviewerName] NVARCHAR(50) NOT NULL,
        [ReviewDate] DATETIME2 NOT NULL,
        [EmailAddress] NVARCHAR(50) NULL,
        [Rating] INT NULL,
        [Comments] NVARCHAR(3850) NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Production_ProductSubcategory', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Production_ProductSubcategory
    (
        [ProductSubcategoryID] INT NOT NULL,
        [ProductCategoryID] INT NOT NULL,
        [Name] NVARCHAR(50) NOT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Purchasing_ProductVendor', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Purchasing_ProductVendor
    (
        [ProductID] INT NOT NULL,
        [BusinessEntityID] INT NOT NULL,
        [AverageLeadTime] INT NOT NULL,
        [StandardPrice] MONEY NOT NULL,
        [LastReceiptCost] MONEY NULL,
        [LastReceiptDate] DATETIME2 NULL,
        [MinOrderQty] INT NULL,
        [MaxOrderQty] INT NULL,
        [OnOrderQty] INT NULL,
        [UnitMeasureCode] NCHAR(3),
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Purchasing_PurchaseOrderDetail', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Purchasing_PurchaseOrderDetail
    (
        [PurchaseOrderID] INT NOT NULL,
        [PurchaseOrderDetailID] INT NOT NULL,
        [DueDate] DATETIME2 NOT NULL,
        [OrderQty] SMALLINT NULL,
        [ProductID] INT NULL,
        [UnitPrice] MONEY NULL,
        [LineTotal] MONEY NULL,
        [ReceivedQty] DECIMAL(8,2) NULL,
        [RejectedQty] DECIMAL(8,2) NULL,
        [StockQty] DECIMAL(9,2) NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Purchasing_PurchaseOrderHeader', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Purchasing_PurchaseOrderHeader
    (
        [PurchaseOrderID] INT NOT NULL,
        [RevisionNumber] TINYINT NULL,
        [Status] TINYINT NULL,
        [EmployeeID] INT NULL,
        [VendorID] INT NULL,
        [ShipMethod] INT NULL,
        [OrderDate] DATETIME2 NULL,
        [ShipDate] DATETIME2 NULL,
        [SubTotal] MONEY NULL,
        [TaxAmt] MONEY NULL,
        [Freight] MONEY NULL,
        [TotalDue] MONEY NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Sales_SalesOrderDetail', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Sales_SalesOrderDetail
    (
        [SalesOrderID] INT NOT NULL,
        [SalesOrderDetailID] INT NOT NULL,
        [CarrierTrackingNumber] NVARCHAR(25) NULL,
        [OrderQty] SMALLINT NULL,
        [ProductID] INT NULL,
        [SpecialOfferID] INT NULL,
        [UnitPrice] MONEY NULL,
        [UnitPriceDiscount] MONEY NULL,
        [LineTotal] NUMERIC(38,6) NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Sales_SalesOrderHeader', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Sales_SalesOrderHeader
    (
        [SalesOrderID] INT NOT NULL,
        [RevisionNumber] TINYINT NULL,
        [OrderDate] DATETIME2 NULL,
        [DueDate] DATETIME2 NULL,
        [ShipDate] DATETIME2 NULL,
        [Status] TINYINT NULL,
        [OnlineOrderFlag] BIT NULL,
        [SalesOrderNumber] NVARCHAR(25) NULL ,
        [PurchaseOrderNumber] NVARCHAR(25) NULL,
        [AccountNumber] NVARCHAR(15) NULL,
        [CustomerID] INT NULL,
        [SalesPersonID] INT NULL,
        [TerritoryID] INT NULL,
        [BillToAddressID] INT NULL,
        [ShipToAddressID] INT NULL,
        [ShipMethodID] INT NULL,
        [CreditCardID] INT NULL,
        [CreditCardApprovalCode] varchar(15) NULL,
        [CurrencyRateID] INT NULL,
        [SubTotal] MONEY NULL,
        [TaxAmt] MONEY NULL,
        [Freight] MONEY NULL,
        [TotalDue] MONEY NULL,
        [Comment] NVARCHAR(128) NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Sales_SalesOrderHeaderSalesReason', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Sales_SalesOrderHeaderSalesReason
    (
        [SalesOrderID] INT NOT NULL,
        [SalesReasonID] INT NOT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Sales_SalesPerson', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Sales_SalesPerson
    (
        [BusinessEntityID] INT NOT NULL,
        [TerritoryID] INT NULL,
        [SalesQuota] MONEY NULL,
        [Bonus] MONEY NULL,
        [CommissionPct] smallmoney NULL,
        [SalesYTD] MONEY NULL,
        [SalesLastYear] MONEY NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Sales_SalesPersonQuotaHistory', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Sales_SalesPersonQuotaHistory
    (
        [BusinessEntityID] INT NOT NULL,
        [QuotaDate] DATETIME2 NOT NULL,
        [SalesQuota] MONEY NOT NULL,
        [ModifiedDate] DATETIME2,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Sales_SalesReason', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Sales_SalesReason
    (
        [SalesReasonID] INT NOT NULL,
        [Name] NVARCHAR(50) NULL,
        [ReasonType] NVARCHAR(50) NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Sales_SalesTaxRate', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Sales_SalesTaxRate
    (
        [SalesTaxRateID] INT NOT NULL,
        [StateProvinceID] INT NULL,
        [TaxType] TINYINT NULL,
        [TaxRate] smallmoney NULL,
        [Name] NVARCHAR(50) NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Sales_SalesTerritory', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Sales_SalesTerritory
    (
        [TerritoryID] INT NOT NULL,
        [Name] NVARCHAR(50) NOT NULL,
        [CountryRegionCode] NVARCHAR(3) NOT NULL,
        [Group] NVARCHAR(50) NOT NULL,
        [SalesYTD] MONEY NULL,
        [SalesLastYear] MONEY NULL,
        [CostYTD] MONEY NULL,
        [CostLastYear] MONEY NULL,
        [ModifiedDate] DATETIME2 NULL,
        [ExtractDatetime] DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )

END;
GO

IF OBJECT_ID (N'STG.Sales_SalesTerritoryHistory', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Sales_SalesTerritoryHistory
    (
        [BusinessEntityID] INT NOT NULL,
        [TerritoryID] INT NOT NULL,
        [StartDate] DATETIME2 NOT NULL,
        [EndDate] DATETIME2 NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Production_ScrapReason', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Production_ScrapReason
    (
        [ScrapReasonID] SMALLINT NOT NULL,
        [Name] NVARCHAR(50) NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.HumanResources_Shift', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.HumanResources_Shift
    (
        [ShiftID] TINYINT NOT NULL,
        [Name] NVARCHAR(50) NOT NULL,
        [StartTime] time NOT NULL,
        [EndTime] time NOT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Purchasing_ShipMethod', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Purchasing_ShipMethod
    (
        [ShipMethodID] INT NOT NULL,
        [Name] NVARCHAR(50) NOT NULL,
        [ShipBase] MONEY NOT NULL,
        [ShipRate] MONEY NOT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Sales_ShoppingCartItem', N'U') IS NULL
BEGIN
    CREATE TABLE STG.Sales_ShoppingCartItem
    (
        [ShoppingCartItemID] INT NOT NULL,
        [ShoppingCartID] NVARCHAR(50) NOT NULL,
        [Quantity] INT NULL,
        [ProductID] INT NULL,
        [DateCreated] DATETIME2 NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Sales_SpecialOffer', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Sales_SpecialOffer
    (
        [SpecialOfferID] INT NOT NULL,
        [Description] NVARCHAR(255) NOT NULL,
        [DiscountPct] smallmoney NOT NULL,
        [Type] NVARCHAR(50) NOT NULL,
        [Category] NVARCHAR(50) NULL,
        [StartDate] DATETIME2 NULL,
        [EndDate] DATETIME2 NULL,
        [MinQty] INT NULL,
        [MaxQty] INT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Sales_SpecialOfferProduct', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Sales_SpecialOfferProduct
    (
        [SpecialOfferID] INT NOT NULL,
        [ProductID] INT NOT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Person_StateProvince', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Person_StateProvince
    (
        [StateProvinceID] INT NOT NULL,
        [StateProvinceCode] nchar(3) NOT NULL,
        [CountryRegionCode] NVARCHAR(3) NOT NULL,
        [IsOnlyStateProvinceFlag] BIT NULL,
        [Name] NVARCHAR(50) NULL,
        [TerritoryID] INT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Sales_Store', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Sales_Store
    (
        [BusinessEntityID] INT NOT NULL,
        [Name] NVARCHAR(50) NOT NULL,
        [SalesPersonID] INT NULL,
        [Demographics] XML NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Production_TransactionHistory', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Production_TransactionHistory
    (
        [TransactionID] INT NOT NULL,
        [ProductID] INT NULL,
        [ReferenceOrderID] INT NULL,
        [ReferenceOrderLineID] INT NULL,
        [TransactionDate] DATETIME2 NULL,
        [TransactionType] NCHAR(1) NULL,
        [Quantity] INT NULL,
        [ActualCost] MONEY NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Production_TransactionHistoryArchive', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Production_TransactionHistoryArchive
    (
        [TransactionID] INT NOT NULL,
        [ProductID] INT NOT NULL,
        [ReferenceOrderID] INT NOT NULL,
        [ReferenceOrderLineID] INT NULL,
        [TransactionDate] DATETIME2 NULL,
        [TransactionType] NCHAR(1) NULL,
        [Quantity] INT NULL,
        [ActualCost] MONEY NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Production_UnitMeasure', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Production_UnitMeasure
    (
        [UnitMeasureCode] NCHAR(3) NOT NULL,
        [Name] NVARCHAR(50) NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Purchasing_Vendor', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Purchasing_Vendor
    (
        [BusinessEntityID] INT NOT NULL,
        [AccountNumber] NVARCHAR(15) NOT NULL,
        [Name] NVARCHAR(50) NULL,
        [CreditRating] TINYINT NOT NULL,
        [PreferredVendorStatus] BIT NULL,
        [ActiveFlag] BIT NULL,
        [PurchasingWebServiceURL] NVARCHAR(1024) NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Production_WorkOrder', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Production_WorkOrder
    (
        [WorkOrderID] INT NOT NULL,
        [ProductID] INT NULL,
        [OrderQty] INT NULL,
        [StockedQty] INT NULL,
        [ScrappedQty] SMALLINT NULL,
        [StartDate] DATETIME2 NULL,
        [EndDate] DATETIME2 NULL,
        [DueDate] DATETIME2 NULL,
        [ScrapReasonID] SMALLINT NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

IF OBJECT_ID (N'STG.Production_WorkOrderRouting', N'U') IS NULL 
BEGIN
    CREATE TABLE STG.Production_WorkOrderRouting
    (
        [WorkOrderID] INT NOT NULL,
        [ProductID] INT NOT NULL,
        [OperationSequence] SMALLINT NOT NULL,
        [LocationID] SMALLINT NOT NULL,
        [ScheduledStartDate] DATETIME2 NULL,
        [ScheduledEndDate] DATETIME2 NULL,
        [ActualStartDate] DATETIME2 NULL,
        [ActualEndDate] DATETIME2 NULL,
        [ActualResourceHrs] DECIMAL(9,4) NULL,
        [PlannedCost] MONEY NULL,
        [ActualCost] MONEY NULL,
        [ModifiedDate] DATETIME2 NULL,
        ExtractDatetime DATETIME2 NULL DEFAULT GETDATE(),
        RowHash VARBINARY(32) NULL
    )
END;
GO

