CREATE PROCEDURE [TestSales].[Test that one equals one]
AS
	EXEC tSQLt.AssertEquals 1,1;