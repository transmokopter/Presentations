USE master;
IF DB_ID('tSQLtDemo') IS NOT NULL
BEGIN
    ALTER DATABASE tSQLtDemo SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE tSQLtDemo;
END;
GO
CREATE DATABASE tSQLtDemo;
GO
USE tSQLtDemo;
GO
-- Create tSQLt objects in the database
:r "c:\git\Presentations\get-started-with-tsqlt\demo\tSQLt.Class.sql"
GO
-- Database is prepared. Let's run all tests
EXEC tSQLt.RunAll;

-- All of our tests are successful.
-- Also. All of our tests failed.
-- That's because we have zero tests.
-- Let's create our first test.

-- We group our tests in "classes".
EXEC tSQLt.NewTestClass 'TestDemo';
GO
-- A test is a stored procedure named "TEST somethingsomething"
CREATE PROC TestDemo.[Test that one equals one]
AS
BEGIN
    -- Assemble
    DECLARE @one1 INT = 1;
    -- Act
    DECLARE @one2 INT = 1;
    -- Assert
    EXEC tSQLt.AssertEquals @one1, @one2;
END;
GO
-- Run all tests again
EXEC tSQLt.RunAll;
-- Format the results as Xml - useful for Azure DevOps test reports
EXEC tSQLt.XmlResultFormatter;
GO
EXEC tsqlt.DropClass @ClassName = N'TestDemo' -- nvarchar(max)

-- Let's create a more meaningful test
GO
EXEC tSQLt.NewTestClass @ClassName = N'TestDateValidation';
GO
CREATE OR ALTER PROC TestDateValidation.[Test that Year 1996 is a LeapYear]
AS
BEGIN
    --Assemble
    DECLARE @isLeapYear INT;
    DECLARE @testYear SMALLINT = 1996;

    --Act
    SELECT @isLeapYear = IsLeapYear
    FROM dbo.isLeapYear(@testYear);

    --Assert
    EXEC tSQLt.AssertEquals @Expected = 1,
                            @Actual = @isLeapYear,
                            @Message = N'1996 should be a leapyear';

END;
GO
CREATE OR ALTER PROC TestDateValidation.[Test that Year 1900 is a LeapYear]
AS
BEGIN
    --Assemble
    DECLARE @isLeapYear INT;
    DECLARE @testYear SMALLINT = 1900;

    --Act
    SELECT @isLeapYear = IsLeapYear
    FROM dbo.isLeapYear(@testYear);

    --Assert
    EXEC tSQLt.AssertEquals @Expected = 1,
                            @Actual = @isLeapYear,
                            @Message = N'1900 should be a leapyear';

END;

GO
--And now a negative test

CREATE OR ALTER PROC TestDateValidation.[Test that Year 1901 is NOT a LeapYear]
AS
BEGIN
    --Assemble
    DECLARE @isLeapYear INT;
    DECLARE @testYear SMALLINT = 1901;

    --Act
    SELECT @isLeapYear = IsLeapYear
    FROM dbo.isLeapYear(@testYear);

    --Assert
    EXEC tSQLt.AssertNotEquals @Expected = 1,
                               @Actual = @isLeapYear,
                               @Message = N'1901 should NOT be a leapyear';

END;

-- Run all tests
EXEC tSQLt.RunAll;

-- We expected that error. Let's now create a function to "unfail" the test
GO
CREATE OR ALTER FUNCTION dbo.isLeapYear
(
    @InYear SMALLINT
)
RETURNS TABLE
AS
RETURN
(
    SELECT CASE
               WHEN @InYear % 4 = 0 THEN
                   1
               ELSE
                   0
           END AS IsLeapYear
);
GO

-- Rerun tests
EXEC tSQLt.RunAll;
GO





-- Perfect. Except our leapyear function is wrong. 1900 wasn't a leapyear.
-- Let's first change the test.
DROP PROC TestDateValidation.[Test that Year 1900 is a LeapYear];
GO
CREATE OR ALTER PROC TestDateValidation.[Test that Year 1900 is NOT a LeapYear]
AS
BEGIN
    --Assemble
    DECLARE @isLeapYear INT;
    DECLARE @testYear SMALLINT = 1900;

    --Act
    SELECT @isLeapYear = IsLeapYear
    FROM dbo.isLeapYear(@testYear);

    --Assert
    EXEC tSQLt.AssertNotEquals @Expected = 1,
                               @Actual = @isLeapYear,
                               @Message = N'1900 should NOT be a leapyear';

END;

GO
-- Rerun all tests
EXEC tSQLt.RunAll;
GO

-- Now we want to "unfail" the test by changing our procedure
CREATE OR ALTER FUNCTION dbo.isLeapYear
(
    @InYear SMALLINT
)
RETURNS TABLE
AS
RETURN
(
    SELECT CASE
               WHEN @InYear % 4 = 0
                    AND @InYear % 100 <> 0 THEN
                   1
               ELSE
                   0
           END AS IsLeapYear
);
GO

-- Rerun tests
EXEC tSQLt.RunAll;
GO
-- Now we're happy. Right?

-- Let's test on schema and metadata
-- Cleanup first
EXEC tSQLt.DropClass 'TestDateValidation';
EXEC tSQLt.DropClass 'TestDemo';
EXEC tSQLt.RunAll;

GO
EXEC tSQLt.NewTestClass 'TestSchema';
GO
-- preparing a table that we should use for schema testing
CREATE TABLE dbo.Person
(
    id INT IDENTITY(1, 1),
    FirstName VARCHAR(200),
    LastName VARCHAR(200)
);
GO
CREATE OR ALTER PROC TestSchema.[Test that two result sets have the same metadata]
AS
BEGIN
    -- Assemble

    -- Act

    -- Assert
    EXEC tSQLt.AssertResultSetsHaveSameMetaData @expectedCommand = N'declare @t table(id int, FirstName varchar(200), LastName varchar(200)); select * from @t;',
                                                @actualCommand = N'select top(0) * from dbo.Person';
END;
GO
EXEC tSQLt.RunAll;
-- Oh no. Our test is wrong, not the table!

GO
CREATE OR ALTER PROC TestSchema.[Test that two result sets have the same metadata]
AS
BEGIN
    -- Assemble

    -- Act

    -- Assert
    EXEC tSQLt.AssertResultSetsHaveSameMetaData @expectedCommand = N'declare @t table(id int identity(1,1), FirstName varchar(200), LastName varchar(200)); select * from @t;',
                                                @actualCommand = N'select top(0) * from dbo.Person';
END;
GO

EXEC tSQLt.RunAll;
GO
CREATE OR ALTER PROC TestSchema.[test Person Names schema]
AS
BEGIN
    --Arrange
    CREATE TABLE TestSchema.ExpectedPerson
    (
        Id INT NOT NULL,
        FirstName VARCHAR(200) NULL,
        LastName VARCHAR(200) NULL
    );

    --Act
    SELECT TOP (0)
           id,
           FirstName,
           LastName
    INTO TestSchema.ActualPerson
    FROM dbo.Person;

    --Assert
    EXEC tSQLt.AssertEqualsTableSchema @Expected = N'TestSchema.ExpectedPerson',
                                       @Actual = N'TestSchema.ActualPerson';

END;
GO
EXEC tSQLt.RunAll;
GO

CREATE OR ALTER PROC TestSchema.[test Person Names schema]
AS
BEGIN
    --Arrange
    CREATE TABLE TestSchema.ExpectedPerson
    (
        Id INT NOT NULL,
        FirstName VARCHAR(200) NOT NULL,
        LastName VARCHAR(200) NOT NULL
    );

    --Act
    SELECT TOP (0)
           id,
           FirstName,
           LastName
    INTO TestSchema.ActualPerson
    FROM dbo.Person;

    --Assert
    EXEC tSQLt.AssertEqualsTableSchema @Expected = N'TestSchema.ExpectedPerson',
                                       @Actual = N'TestSchema.ActualPerson';

END;
GO

EXEC tSQLt.RunAll;
EXEC tSQLt.DropClass 'TestSchema';


-- Some more assertions
EXEC tSQLt.NewTestClass 'TestAssert';
GO

CREATE OR ALTER PROC TestAssert.[Test AssertLike]
AS
BEGIN
    -- Assemble
    DECLARE @like NVARCHAR(100) = N'%oo%';
    DECLARE @string NVARCHAR(100) = N'hello';
    -- Act

    -- Assert
    EXEC tSQLt.AssertLike @like,
                          @string,
                          N'String didn''t look anything like the like pattern';
END;
GO
EXEC tSQLt.RunAll;
GO
CREATE OR ALTER PROC TestAssert.[Test AssertLike]
AS
BEGIN
    -- Assemble
    DECLARE @like NVARCHAR(100) = N'%oo%';
    DECLARE @string NVARCHAR(100) = N'hellooooooooooo!!!!';
    -- Act

    -- Assert
    EXEC tSQLt.AssertLike @like,
                          @string,
                          N'String didn''t look anything like the like pattern';
END;
GO
EXEC tSQLt.RunAll;
GO
-- Compare strings
CREATE OR ALTER PROC TestAssert.[Test string assertion]
AS
BEGIN
    -- assemble
    DECLARE @string NVARCHAR(100);
    DECLARE @assertstring NVARCHAR(100) = N'hello';
    -- act

    -- assert
    EXEC tSQLt.AssertEqualsString @assertstring, @string;
END;
GO
EXEC tSQLt.RunAll;



GO
CREATE OR ALTER PROC TestAssert.[Test string assertion]
AS
BEGIN
    -- assemble
    DECLARE @string NVARCHAR(100) = NULL;
    DECLARE @assertstring NVARCHAR(100) = NULL;
    -- act

    -- assert
    EXEC tSQLt.AssertEqualsString @assertstring, @string;
END;
GO
EXEC tSQLt.RunAll;
GO
EXEC tSQLt.DropClass 'TestAssert';
GO


-- Let's explore testing complex procedures
GO
--First we need two procedures.
CREATE OR ALTER PROC dbo.ProcCalledFromProc
AS
BEGIN
    DROP TABLE IF EXISTS dbo.ImportantTable;
    CREATE TABLE dbo.ImportantTable
    (
        id INT
            CONSTRAINT PK_ImportantTable PRIMARY KEY CLUSTERED
    );
END;
GO

CREATE OR ALTER PROC dbo.ProcRunsProc
(@OddOrEven TINYINT)
AS
BEGIN
    --Yeah, I know
    IF 0 = @OddOrEven % 2
        EXEC dbo.ProcCalledFromProc;
END;
GO
EXEC tSQLt.NewTestClass @ClassName = N'TestSpyStuff';
GO
CREATE OR ALTER PROC TestSpyStuff.[test that ProcRunsProc is NOT run with even numbers]
AS
BEGIN
    --Arrange
    EXEC tSQLt.SpyProcedure @ProcedureName = N'dbo.ProcCalledFromProc';

    --Act
    EXEC dbo.ProcRunsProc @OddOrEven = 2; -- tinyint

    --Assert
    EXEC tSQLt.AssertEmptyTable @TableName = N'dbo.ProcCalledFromProc_SpyProcedureLog';
END;
GO


EXEC tSQLt.RunAll;
GO

-- Fix proc
CREATE OR ALTER PROC dbo.ProcRunsProc
(@OddOrEven TINYINT)
AS
BEGIN
    --Yeah, I know
    IF 0 != @OddOrEven % 2
        EXEC dbo.ProcCalledFromProc;
END;
GO
--Rerun test
EXEC tSQLt.RunAll;
-- Final cleanup
EXEC tSQLt.DropClass 'TestSpyStuff';
