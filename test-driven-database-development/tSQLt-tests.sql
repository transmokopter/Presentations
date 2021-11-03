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
