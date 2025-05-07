CREATE TABLE [dbo].[CustomerOrder] (
    [OrderId]    INT      IDENTITY (1, 1) NOT NULL,
    [OrderDate]  DATETIME CONSTRAINT [DF_CustomerOrder_OrderDate_Now] DEFAULT (getdate()) NOT NULL,
    [CustomerId] INT      NOT NULL,
    CONSTRAINT [PK_CustomerOrder] PRIMARY KEY CLUSTERED ([OrderId] ASC),
    CONSTRAINT [FK_CustomerOrder_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([CustomerId])
);


GO
CREATE NONCLUSTERED INDEX [ix_CustomerOrder_CustomerId_OrderDate]
    ON [dbo].[CustomerOrder]([CustomerId] ASC, [OrderDate] ASC) WITH (FILLFACTOR = 85, DATA_COMPRESSION = PAGE);

