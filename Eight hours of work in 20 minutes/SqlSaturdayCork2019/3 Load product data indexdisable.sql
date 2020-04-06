use sqlsaturday433;



--disable indexes prior to loading data
declare @sql nvarchar(max)='';
SELECT 
	@sql = @sql + 
			'ALTER INDEX ' + name + ' ON DEMO.ProductionSales DISABLE;
'
from sys.indexes where object_id=object_id('demo.productionsales') and type=2;
print @sql;
--exec sp_executesql @sql;



--Rebuild indexes
declare @sql2 nvarchar(max)='';
SELECT 
	@sql2 = @sql2 + 
			'ALTER INDEX ' + name + ' ON DEMO.ProductionSales REBUILD;
' 
from sys.indexes where object_id=object_id('demo.productionsales') and type=2;
print @sql2;
--exec sp_executesql @sql2;



--Visual Studio