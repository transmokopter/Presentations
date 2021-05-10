USE StatsDemo
DBCC SHOW_STATISTICS("Sales.OrderHeader",'ix_OrderDate') WITH HISTOGRAM;
DBCC SHOW_STATISTICS("Sales.OrderHeader",'ix_OrderDate');


SELECT COUNT(*) FROM sales.OrderHeader AS OH WHERE OH.OrderDate='2016-08-25'