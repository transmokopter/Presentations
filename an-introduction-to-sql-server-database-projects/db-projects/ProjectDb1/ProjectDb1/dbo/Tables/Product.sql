CREATE TABLE [dbo].[Product] (
    [ProductId]   INT            IDENTITY (1, 1) NOT NULL,
    [ProductName] NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_Product] PRIMARY KEY CLUSTERED ([ProductId] ASC)
);

