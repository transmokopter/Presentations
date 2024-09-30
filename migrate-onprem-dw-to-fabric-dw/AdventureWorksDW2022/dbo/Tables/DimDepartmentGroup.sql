CREATE TABLE [dbo].[DimDepartmentGroup] (
    [DepartmentGroupKey]       INT            NOT NULL,
    [ParentDepartmentGroupKey] INT           NULL,
    [DepartmentGroupName]      VARCHAR (50) NULL
);
GO

ALTER TABLE [dbo].[DimDepartmentGroup]
    ADD CONSTRAINT [PK_DimDepartmentGroup] PRIMARY KEY NONCLUSTERED ([DepartmentGroupKey] ASC) NOT ENFORCED;
GO

