USE DWH_ONPREM;
GO

CREATE OR ALTER VIEW INT.Person_Person
AS
    SELECT
        BusinessEntityID as PersonNK,
        PersonType,
        CASE PersonType
            WHEN 'SC' THEN 'Store Contact'
            WHEN 'IN' THEN 'Individual'
            WHEN 'SP' THEN 'Salesperson'
            WHEN 'EM' THEN 'Employee Non-Sales'
            WHEN 'VC' THEN 'Vendor Contact'
            WHEN 'GC' THEN 'General Contact'
            ELSE 'Unknown'
        END AS PersonTypeDescription,
        CASE PersonType
            WHEN 'SP' THEN 'Internal Employees'
            WHEN 'EM' THEN 'Internal Employees'
            ELSE 'External People'
        END AS PersonTypeGroup,
        Title,
        FirstName,
        MiddleName,
        LastName,
        Suffix,
        CONCAT_WS(' ',Title,FirstName,MiddleName,LastName,Suffix) as FullName,
        EmailPromotion as EmailPromotionSignUpFlag,
        IIF(EmailPromotion = 1, 'Yes','No') as EmailPromotionSignUp,
        ModifiedDate,
        ExtractDatetime,
        RowHash
    FROM STG.Person_Person;
GO

CREATE OR ALTER VIEW INT.Person_Address
AS
    SELECT
        A.AddressID AS PersonAddressNK,
        A.AddressLine1,
        A.AddressLine2,
        A.City,
        A.StateProvinceID,
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
        Name,
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
        Name,
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
        Name,
        TerritoryID AS TerritoryNK,
        ModifiedDate,
        ExtractDatetime,
        RowHash
    FROM STG.Person_StateProvince;
GO