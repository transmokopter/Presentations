CREATE TABLE [dbo].[CustomerOrder] (
    [OrderId]    INT      IDENTITY (1, 1) NOT NULL,
    [OrderDate]  DATETIME NOT NULL,
    [CustomerId] INT      NOT NULL
);
GO

ALTER TABLE [dbo].[CustomerOrder]
    ADD CONSTRAINT [PK_CustomerOrder] PRIMARY KEY CLUSTERED ([OrderId] ASC);
GO

CREATE NONCLUSTERED INDEX [ix_CustomerOrder_CustomerId_OrderDate]
    ON [dbo].[CustomerOrder]([CustomerId] ASC, [OrderDate] ASC) WITH (FILLFACTOR = 85, DATA_COMPRESSION = PAGE);
GO

ALTER TABLE [dbo].[CustomerOrder]
    ADD CONSTRAINT [DF_CustomerOrder_OrderDate_Now] DEFAULT (getdate()) FOR [OrderDate];
GO

ALTER TABLE [dbo].[CustomerOrder]
    ADD CONSTRAINT [FK_CustomerOrder_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([CustomerId]);
GO

