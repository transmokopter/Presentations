CREATE FUNCTION [dbo].[IsLeapYear]
(
	@InYear smallint
)
RETURNS table
AS
RETURN
	(
		SELECT 
			CASE WHEN @InYear % 4 = 0 
					AND @InYear % 100 <> 0
			THEN 1 ELSE 0 END AS IsLeapYear
	);
