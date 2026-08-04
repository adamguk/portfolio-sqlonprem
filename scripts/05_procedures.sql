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
            HASHBYTES('SHA2_256', CONCAT(
                    ISNULL(PersonType, ''), '|',
                    ISNULL(PersonTypeDescription, ''), '|',
                    ISNULL(PersonTypeGroup, ''), '|',
                    ISNULL(Title, ''), '|',
                    ISNULL(FirstName, ''), '|',
                    ISNULL(MiddleName, ''), '|',
                    ISNULL(LastName, ''), '|',
                    ISNULL(Suffix, ''), '|',
                    ISNULL(FullName, ''), '|',
                    ISNULL(EmailPromotionSignUpFlag, 0)
                )) AS NewRowHash
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
        p.EmailPromotionSignUpFlag,
        p.EmailPromotionSignUp,
        p.ModifiedDate,
        p.ExtractDatetime,
        @ExecutionTime AS ValidFrom,
        NULL AS ValidTo,
        1 AS Valid,
        HASHBYTES('SHA2_256', CONCAT(
                ISNULL(p.PersonType, ''), '|',
                ISNULL(p.PersonTypeDescription, ''), '|',
                ISNULL(p.PersonTypeGroup, ''), '|',
                ISNULL(p.Title, ''), '|',
                ISNULL(p.FirstName, ''), '|',
                ISNULL(p.MiddleName, ''), '|',
                ISNULL(p.LastName, ''), '|',
                ISNULL(p.Suffix, ''), '|',
                ISNULL(p.FullName, ''), '|',
                ISNULL(p.EmailPromotionSignUpFlag, 0)
            )) AS RowHash
    FROM INT.Person_Person p
        LEFT JOIN MRT.Dim_Person dim
        ON p.PersonNK =  dim.PersonNK
            AND dim.Valid = 1
    WHERE dim.PersonSK IS NULL;

            COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH 
        IF @TRANCOUNT > 0 
            ROLLBACK TRANSACTION;
        THROW; 
    END CATCH

END;
GO