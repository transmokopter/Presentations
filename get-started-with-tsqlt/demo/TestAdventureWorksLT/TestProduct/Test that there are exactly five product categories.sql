CREATE PROCEDURE [TestProduct].[Test that there are exactly five product categories]
AS
-- Assemble
DECLARE @ProductCategoryCount INT;
-- Act

SELECT @ProductCategoryCount = COUNT(*)
FROM SalesLT.ProductCategory;

-- Assert
EXEC tSQLt.AssertEquals @Expected = 5, @Actual = @ProductCategoryCount;