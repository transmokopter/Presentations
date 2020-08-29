USE StatsDemo
DBCC SHOW_STATISTICS("Sales.OrderHeader",'ix_OrderDate') WITH HISTOGRAM;
DBCC SHOW_STATISTICS("Sales.OrderHeader",'ix_OrderDate');


SELECT 0.01 * 5000000