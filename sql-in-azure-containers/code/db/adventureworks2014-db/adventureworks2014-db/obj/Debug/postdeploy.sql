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

IF @@SERVERNAME=N'TSQLWS2'
BEGIN
    INSERT INTO Person.CountryRegion (CountryRegionCode, Name)
    VALUES('NA','Not Available');
END
GO
