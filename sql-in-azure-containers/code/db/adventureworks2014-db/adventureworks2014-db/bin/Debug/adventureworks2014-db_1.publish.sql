﻿/*
Deployment script for AdventureWorks2014

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "AdventureWorks2014"
:setvar DefaultFilePrefix "AdventureWorks2014"
:setvar DefaultDataPath "D:\sqldata\localhost\Data\"
:setvar DefaultLogPath "C:\sqldata\localhost\DATA\"

GO
:on error exit
GO
/*
Detect SQLCMD mode and disable script execution if SQLCMD mode is not supported.
To re-enable the script after enabling SQLCMD mode, execute the following:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END


GO
USE [$(DatabaseName)];


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ANSI_NULL_DEFAULT ON,
                CURSOR_DEFAULT LOCAL,
                RECOVERY FULL 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET PAGE_VERIFY NONE 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET QUERY_STORE (QUERY_CAPTURE_MODE = ALL) 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET TEMPORAL_HISTORY_RETENTION ON 
            WITH ROLLBACK IMMEDIATE;
    END


GO
PRINT N'Dropping Extended Property [MS_Description]...';


GO
EXECUTE sp_dropextendedproperty @name = N'MS_Description';


GO
PRINT N'Dropping Full-text Index Full-text Index on [HumanResources].[JobCandidate]...';


GO
DROP FULLTEXT INDEX ON [HumanResources].[JobCandidate];


GO
PRINT N'Dropping Full-text Index Full-text Index on [Production].[Document]...';


GO
DROP FULLTEXT INDEX ON [Production].[Document];


GO
PRINT N'Dropping Full-text Index Full-text Index on [Production].[ProductReview]...';


GO
DROP FULLTEXT INDEX ON [Production].[ProductReview];


GO
PRINT N'Creating Function [dbo].[IsLeapYear]...';


GO
CREATE FUNCTION [dbo].[IsLeapYear]
(
	@InYear smallint
)
RETURNS table
AS
RETURN
	(
		SELECT 
			CASE WHEN @InYear % 4 = 0 
			OR @inYear % 100 <> 0
			THEN 1 ELSE 0 END AS IsLeapYear
	);
GO
/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
WITH CTE AS (
    SELECT * FROM (VALUES
        (N'SE', N'Sweden'),
        (N'US', N'United States'),
        (N'UK', N'United Kingdom')
    )t(CountryRegionCode,Name)
) MERGE Person.CountryRegion as t
    USING (SELECT * from CTE) as s
    ON t.CountryRegionCode = s.CountryRegionCode
    WHEN MATCHED THEN UPDATE
        SET t.Name = s.Name
    WHEN NOT MATCHED THEN INSERT
    (CountryRegionCode, Name)
    VALUES(s.CountryRegionCode, s.Name)
    WHEN NOT MATCHED BY SOURCE THEN DELETE;

IF @@SERVERNAME=N'sql1'
BEGIN
    INSERT INTO Person.CountryRegion (CountryRegionCode, Name)
    VALUES('NA','Not Available');
END
GO

GO
PRINT N'Update complete.';


GO
