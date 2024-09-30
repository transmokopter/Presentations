CREATE TABLE [dbo].[FactAdditionalInternationalProductDescription] (
    [ProductKey]         INT            NOT NULL,
    [CultureName]        VARCHAR (50)  NOT NULL,
    [ProductDescription] varchar (4000) NOT NULL
);
GO

ALTER TABLE [dbo].[FactAdditionalInternationalProductDescription]
    ADD CONSTRAINT [PK_FactAdditionalInternationalProductDescription_ProductKey_CultureName] PRIMARY KEY NONCLUSTERED ([ProductKey] ASC, [CultureName] ASC) NOT ENFORCED;
GO

