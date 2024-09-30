CREATE TABLE [dbo].[DimPromotion] (
    [PromotionKey]             INT             NOT NULL,
    [PromotionAlternateKey]    INT            NULL,
    [EnglishPromotionName]     VARCHAR (255) NULL,
    [SpanishPromotionName]     VARCHAR (255) NULL,
    [FrenchPromotionName]      VARCHAR (255) NULL,
    [DiscountPct]              FLOAT     NULL,
    [EnglishPromotionType]     VARCHAR (50)  NULL,
    [SpanishPromotionType]     VARCHAR (50)  NULL,
    [FrenchPromotionType]      VARCHAR (50)  NULL,
    [EnglishPromotionCategory] VARCHAR (50)  NULL,
    [SpanishPromotionCategory] VARCHAR (50)  NULL,
    [FrenchPromotionCategory]  VARCHAR (50)  NULL,
    [StartDate]                datetime2(6)       NOT NULL,
    [EndDate]                  datetime2(6)       NULL,
    [MinQty]                   INT            NULL,
    [MaxQty]                   INT            NULL
);
GO

ALTER TABLE [dbo].[DimPromotion]
    ADD CONSTRAINT [AK_DimPromotion_PromotionAlternateKey] UNIQUE NONCLUSTERED ([PromotionAlternateKey] ASC) NOT ENFORCED;
GO

ALTER TABLE [dbo].[DimPromotion]
    ADD CONSTRAINT [PK_DimPromotion_PromotionKey] PRIMARY KEY NONCLUSTERED ([PromotionKey] ASC) NOT ENFORCED;
GO

