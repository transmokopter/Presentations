CREATE TABLE [dbo].[Customer] (
    [CustomerId]   INT            IDENTITY (1, 1) NOT NULL,
    [CustomerName] NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED ([CustomerId] ASC)
);

