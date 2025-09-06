CREATE PROCEDURE [TestSales].[Test that orderlines without orders fail on insert]
AS
BEGIN
    -- Assemble
    -- First we need to drop the schemabound views
    -- Don't worry, we're in a transaction
    DECLARE @dropViewSql NVARCHAR(MAX) = N'DROP VIEW SalesLT.vGetAllCategories';
    EXEC sp_executesql @dropViewSql;
    SET @dropViewSql = N'DROP VIEW SalesLT.vProductAndDescription';
    EXEC sp_executesql @dropViewSql;
    -- Let's fake some tables so we start empty
    EXEC tSQLt.FakeTable @TableName = 'SalesOrderDetail',
                         @SchemaName = 'SalesLT';
    EXEC tSQLt.FakeTable @TableName = 'SalesOrderHeader',
                         @SchemaName = 'SalesLT';
    EXEC tSQLt.FakeTable @TableName = 'ProductCategory',
                         @SchemaName = 'SalesLT';
    EXEC tSQLt.FakeTable @TableName = 'ProductModel', @SchemaName = 'SalesLT';
    EXEC tSQLt.FakeTable @TableName = 'Product', @SchemaName = 'SalesLT';
    DECLARE @errorMessage NVARCHAR(MAX) = N'FAILURE_OK';
    -- Add back the foreign key constraint between SalesOrderHeader and SalesOrderDetail
    EXEC tSQLt.ApplyConstraint @TableName = 'SalesLT.SalesOrderDetail',
                               @ConstraintName = 'FK_SalesOrderDetail_SalesOrderHeader_SalesOrderID';

    -- Act and Assert in the same block
    BEGIN TRY
        INSERT SalesLT.SalesOrderDetail
        (
            SalesOrderId,
            OrderQty,
            ProductId,
            UnitPrice
        )
        VALUES
        (1, 1, 1, 1);
        -- This is supposed to fail. If it didn't throw an error, we fail the test
        SET @errorMessage = N'Expected foreign key error but no error was thrown';
    END TRY
    BEGIN CATCH
        -- Check that the error-message contains the constraint name
        IF ERROR_MESSAGE()NOT LIKE '%FK_SalesOrderDetail_SalesOrderHeader_SalesOrderID%'
            SET @errorMessage
                = N'Error was thrown in test but error message didn''t contain ''FK_SalesOrderDetail_SalesOrderHeader_SalesOrderID''. Error message was '
                  + ERROR_MESSAGE();
    END CATCH;

    IF @errorMessage IS DISTINCT FROM 'FAILURE_OK'
        EXEC tSQLt.Fail @errorMessage;


END;
