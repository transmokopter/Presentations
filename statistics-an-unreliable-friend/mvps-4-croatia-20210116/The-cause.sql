USE StatsDemo
DBCC SHOW_STATISTICS("Sales.OrderHeader",'ix_OrderDate');
DBCC SHOW_STATISTICS("Sales.OrderHeader",'ix_OrderDate') WITH HISTOGRAM;

