USE AdventureWorks2014
--Let's start with our tests.
--We group tests by classes.
EXEC tsqlt.NewTestClass @ClassName = N'TestDateValidation'
GO
CREATE OR ALTER PROC TestDateValidation.[Test that Year 1996 is a LeapYear]
AS
BEGIN 
	--Assemble
	DECLARE @isLeapYear INT;
	DECLARE @testYear SMALLINT = 1996;
	
	--Act
	SELECT @IsLeapYear = IsLeapYear FROM dbo.IsLeapYear(@testYear);

	--Assert
	EXEC tSQLt.AssertEquals @Expected = 1,
	                        @Actual = @IsLeapYear,
	                        @Message = N'1996 should be a leapyear'

END 
GO

CREATE OR ALTER PROC TestDateValidation.[Test that Year 1900 is NOT a LeapYear]
AS
BEGIN 
	--Assemble
	DECLARE @isLeapYear INT;
	DECLARE @testYear SMALLINT = 1900;
	
	--Act
	SELECT @IsLeapYear = IsLeapYear FROM dbo.IsLeapYear(@testYear);

	--Assert
	EXEC tSQLt.AssertNotEquals @Expected = 1,
	                        @Actual = @IsLeapYear,
	                        @Message = N'1900 should NOT be a leapyear'

END 

GO
--And now a negative test

CREATE OR ALTER PROC TestDateValidation.[Test that Year 1901 is NOT a LeapYear]
AS
BEGIN 
	--Assemble
	DECLARE @isLeapYear INT;
	DECLARE @testYear SMALLINT = 1901;
	
	--Act
	SELECT @IsLeapYear = IsLeapYear FROM dbo.IsLeapYear(@testYear);

	--Assert
	EXEC tSQLt.AssertNotEquals 	@Expected = 1,
								@Actual = @IsLeapYear,
								@Message = N'1901 should NOT be a leapyear'

END 

GO
EXEC tSQLt.RunAll;


GO

















CREATE OR ALTER FUNCTION dbo.isLeapYear(
	@InYear SMALLINT 
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT CASE WHEN @inYear % 4 = 0 THEN 1 ELSE 0 END AS IsLeapYear
);
GO

EXEC tSQLt.RunAll;

GO

--Second version
CREATE OR ALTER FUNCTION dbo.isLeapYear(
	@InYear SMALLINT 
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT CASE WHEN @inYear % 4 = 0 AND @inYear % 100 <> 0 THEN 1 ELSE 0 END AS IsLeapYear
);
GO


EXEC tSQLt.RunAll;

GO



EXEC tSQLt.DropClass @ClassName = N'TestDateValidation' -- nvarchar(max)
GO




























-- Test with data

--First, a new test class
EXEC tSQLt.NewTestClass @ClassName = N'TestHumanResources'
GO
CREATE OR ALTER PROC TestHumanResources.[Test that uspUpdateEmployeeHireInfo updates Job Title]
AS
BEGIN
	--Assemble
	SELECT JobTitle
	INTO #Expected FROM HumanResources.Employee WHERE 1 = 0;

	INSERT INTO #Expected
	(
	    JobTitle
	)
	VALUES
	(N'CEO')

	EXEC tSQLt.FakeTable @TableName = N'Employee', @SchemaName = N'HumanResources';

	INSERT INTO HumanResources.Employee
	(
	    BusinessEntityID,
	    NationalIDNumber,
	    LoginID,
	    JobTitle,
	    BirthDate,
	    MaritalStatus,
	    Gender,
	    HireDate,
	    SalariedFlag,
	    VacationHours,
	    SickLeaveHours,
	    CurrentFlag,
	    ModifiedDate
	)
	VALUES
	(   1,         -- BusinessEntityID - int
	    N'1234',       -- NationalIDNumber - nvarchar(15)
	    N'login',       -- LoginID - nvarchar(256)
	    N'Not CEO',       -- JobTitle - nvarchar(50)
	    '1960-01-01', -- BirthDate - date
	    N'M',       -- MaritalStatus - nchar(1)
	    N'M',       -- Gender - nchar(1)
	    GETDATE(), -- HireDate - date
	    1,      -- SalariedFlag - Flag
	    0,         -- VacationHours - smallint
	    0,         -- SickLeaveHours - smallint
	    1,
	    GETDATE()  -- ModifiedDate - datetime
	    )
	
	--Act
	EXEC HumanResources.uspUpdateEmployeeHireInfo 
	@BusinessEntityID = 1,                   -- int
	@JobTitle = N'CEO',                         -- nvarchar(50)
	@HireDate = '2021-10-31 09:52:02',       -- datetime
	@RateChangeDate = '2021-10-31 09:52:02', -- datetime
	@Rate = 100,                            -- money
	@PayFrequency = 1,                       -- tinyint
	@CurrentFlag = NULL                      -- Flag

	SELECT JobTitle 
	INTO #Actual
	FROM HumanResources.Employee WHERE BusinessEntityID = 1;

	--Assert
	EXEC tSQLt.AssertEqualsTable 
		@Expected = N'#Expected', -- nvarchar(max)
	    @Actual = N'#Actual',   -- nvarchar(max)
	    @Message = N'Job title successfully updated by uspUpdateEmployeeHireInfo',  -- nvarchar(max)
	    @FailMsg = N'uspUpdateEmployeeHireInfo failed to update JobTitle'   -- nvarchar(max)
	
	
END

GO

EXEC tSQLt.RunAll

EXEC tsqlt.DropClass @ClassName = N'TestHumanResources' -- nvarchar(max)


GO

--Schema and stuff

USE AdventureWorks2014
GO
EXEC tSQLt.NewTestClass @ClassName = N'TestPerson' -- nvarchar(max)
EXEC tSQLt.NewTestClass @ClassName = N'TestProduction' -- nvarchar(max)

GO
CREATE OR ALTER PROC TestPerson.[test Person Names metadata]
AS
BEGIN
--Arrange

--Act

--Assert
	EXEC tsqlt.AssertResultSetsHaveSameMetaData 
		@expectedCommand = 
			N'DECLARE @t TABLE(FirstName nvarchar(50) NOT NULL, MiddleName nvarchar(50) NULL,LastName nvarchar(50) NOT NULL);SELECT * FROM @t;', 
	    @actualCommand = N'SELECT TOP 0 FirstName, MiddleName, LastName FROM AdventureWorks2014.Person.Person'    

END 
GO
CREATE OR ALTER PROC TestPerson.[test Person Names schema]
AS
BEGIN
	--Arrange
	CREATE TABLE TestPerson.ExpectedPerson(FirstName nvarchar(50) NOT NULL, MiddleName nvarchar(50) NOT NULL,LastName nvarchar(50) NOT NULL);
	
	--Act
	SELECT TOP(0) FirstName,MiddleName,LastName INTO TestPerson.ActualPerson FROM Person.Person;

	--Assert
	EXEC tSQLt.AssertEqualsTableSchema @Expected = N'TestPerson.ExpectedPerson', 
	                             @Actual = N'TestPerson.ActualPerson'
	
END
GO

CREATE OR ALTER PROC TestProduction.[test ufnGetProductDealerPrice returns NULL for non existing product]
AS
BEGIN
--Arrange

--views w schema bindings aren't released in FakeTable
DECLARE @dropViewSql NVARCHAR(MAX)=N'';
WITH CTE AS (SELECT DISTINCT OBJECT_NAME(sd.object_id) AS ViewName,s.name AS schemaname,o.type_desc 
FROM sys.sql_dependencies AS SD 
INNER JOIN sys.objects AS O ON O.object_id = SD.object_id
INNER JOIN sys.schemas AS S ON S.schema_id = O.schema_id
WHERE SD.referenced_major_id=OBJECT_ID('production.product')
AND SD.class_desc NOT LIKE '%NON_SCHEMA_BOUND%'
AND o.type_desc ='view')
SELECT @dropViewSql = @dropViewSql + CONCAT('DROP VIEW ',QUOTENAME(CTE.schemaname),N'.',QUOTENAME(CTE.ViewName),N';')
FROM CTE;

EXEC sys.sp_executesql @dropViewSql;


EXEC tsqlt.FakeTable @TableName = N'Production.Product'

DECLARE @ProductDealerPrice MONEY;

--Act
	SET @ProductDealerPrice = dbo.ufnGetProductDealerPrice(0,CURRENT_TIMESTAMP)

--Assert
	EXEC tsqlt.AssertEquals @Expected = NULL,
	                        @Actual = @ProductDealerPrice
	
END

GO
EXEC tSQLt.RunAll;
EXEC tsqlt.DropClass @ClassName = N'TestProduction' -- nvarchar(max)
EXEC tsqlt.DropClass @ClassName = N'TestPerson' -- nvarchar(max)

GO
--More faking
GO
--First we need two procedures.
CREATE OR ALTER PROC dbo.ProcCalledFromProc
AS
BEGIN
	DROP TABLE IF EXISTS dbo.ImportantTable;
	CREATE TABLE dbo.ImportantTable(id INT CONSTRAINT PK_ImportantTable PRIMARY KEY CLUSTERED);
END
GO

CREATE OR ALTER PROC dbo.ProcRunsProc (
	@OddOrEven TINYINT
)
AS
BEGIN
--Yeah, I know
	IF 1 = @OddOrEven % 2
		EXEC dbo.ProcCalledFromProc
END
GO

--Now test case
EXEC tSQLt.NewTestClass @ClassName = N'TestSpyStuff' -- nvarchar(max)
GO
CREATE OR ALTER PROC TestSpyStuff.[test that ProcRunsProc is NOT run with even numbers]
AS
	--Arrange
		EXEC tsqlt.SpyProcedure @ProcedureName = N'dbo.ProcCalledFromProc'

	--Act
	EXEC dbo.ProcRunsProc @OddOrEven = 2 -- tinyint

	--Assert
	EXEC tSQLt.AssertEmptyTable
	 @TableName = N'dbo.ProcCalledFromProc_SpyProcedureLog'
GO

EXEC tsqlt.RunAll;

GO

--Fix proc
CREATE OR ALTER PROC dbo.ProcRunsProc (
	@OddOrEven TINYINT
)
AS
BEGIN
--Yeah, I know
	IF 0 != @OddOrEven % 2
		EXEC dbo.ProcCalledFromProc
END
GO
--Rerun test
EXEC tsqlt.RunAll;


GO
--Cleanup

EXEC tsqlt.DropClass @ClassName = N'TestSpyStuff' -- nvarchar(max)

