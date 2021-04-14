USE StatsDemo
DBCC SHOW_STATISTICS("Sales.OrderHeader",'ix_OrderDate');
DBCC SHOW_STATISTICS("Sales.OrderHeader",'ix_OrderDate') WITH HISTOGRAM;

--Density
--Density 0.004 means "every one in 1/0.004" or "every one in 250"

SELECT CAST(1/0.004 AS int) AS OrderDate, CAST(1/(7.970891E-07) AS int) AS OrderDate_CustomerId, CAST(1/(3.200639E-07) AS int) AS OrderDate_CustomerId_OrderHeaderID

--Low Density = High Selectivity and vice versa