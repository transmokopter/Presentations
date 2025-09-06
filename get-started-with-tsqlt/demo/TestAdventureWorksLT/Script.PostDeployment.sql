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

SET IDENTITY_INSERT SalesLT.ProductCategory ON;
MERGE SalesLT.ProductCategory AS t
USING
(
    SELECT *
    FROM
(
    VALUES
        (1, NULL, 'Bikes', CURRENT_TIMESTAMP),
        (2, NULL, 'Components', CURRENT_TIMESTAMP),
        (3, NULL, 'Clothing', CURRENT_TIMESTAMP),
        (4, NULL, 'Accessories', CURRENT_TIMESTAMP),
        (5, NULL, 'Mountain Bikes', CURRENT_TIMESTAMP)
) t (ProductCategoryId, ParentProductCategoryId, Name, ModifiedDate)
) AS s
ON s.ProductCategoryId = t.ProductCategoryId
WHEN NOT MATCHED BY TARGET THEN
    INSERT
    (
        ProductCategoryId,
        ParentProductCategoryId,
        Name,
        ModifiedDate
    )
    VALUES
    (s.ProductCategoryId, s.ParentProductCategoryId, s.Name, s.ModifiedDate)
WHEN MATCHED AND (
                     t.name <> s.Name
                     OR t.ParentProductCategoryId <> s.ParentProductCategoryId
                 ) THEN
    UPDATE SET t.ParentProductCategoryId = s.ParentProductCategoryId,
               t.Name = s.Name,
               t.ModifiedDate = s.ModifiedDate;
SET IDENTITY_INSERT SalesLT.ProductCategory OFF;

