CREATE TABLE [dbo].[CustomerOrderDetail] (
    [OrderId]          INT            NOT NULL,
    [OrderDetailLine]  TINYINT        NOT NULL,
    [ProductId]        INT            NOT NULL,
    [Quantity]         INT            NOT NULL,
    [ListPrice]        NUMERIC (8, 2) NOT NULL,
    [QuantityDiscount] NUMERIC (4, 4) NOT NULL,
    [LoyaltyDiscount]  NUMERIC (4, 4) NOT NULL,
    CONSTRAINT [FK_CustomerOrderDetail_CustomerOrder] FOREIGN KEY ([OrderId]) REFERENCES [dbo].[CustomerOrder] ([OrderId]),
    CONSTRAINT [FK_CustomerOrderDetail_Product] FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Product] ([ProductId])
);

