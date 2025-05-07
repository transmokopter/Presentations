CREATE TABLE [dbo].[Customer] (
    [CustomerId]   INT            IDENTITY (1, 1) NOT NULL,
    [CustomerName] NVARCHAR (100) NOT NULL
);
GO

ALTER TABLE [dbo].[Customer]
    ADD CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED ([CustomerId] ASC);
GO

