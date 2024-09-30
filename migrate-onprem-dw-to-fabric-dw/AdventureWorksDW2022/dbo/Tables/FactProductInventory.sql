CREATE TABLE [dbo].[FactProductInventory] (
    [ProductKey]   INT   NOT NULL,
    [DateKey]      INT   NOT NULL,
    [MovementDate] DATE  NOT NULL,
    [UnitCost]     numeric(14,4) NOT NULL,
    [UnitsIn]      INT   NOT NULL,
    [UnitsOut]     INT   NOT NULL,
    [UnitsBalance] INT   NOT NULL
);
GO

ALTER TABLE [dbo].[FactProductInventory]
    ADD CONSTRAINT [PK_FactProductInventory] PRIMARY KEY NONCLUSTERED ([ProductKey] ASC, [DateKey] ASC) NOT ENFORCED;
GO

ALTER TABLE [dbo].[FactProductInventory]
    ADD CONSTRAINT [FK_FactProductInventory_DimDate] FOREIGN KEY ([DateKey]) REFERENCES [dbo].[DimDate] ([DateKey]) NOT ENFORCED;
GO

ALTER TABLE [dbo].[FactProductInventory]
    ADD CONSTRAINT [FK_FactProductInventory_DimProduct] FOREIGN KEY ([ProductKey]) REFERENCES [dbo].[DimProduct] ([ProductKey]) NOT ENFORCED;
GO

