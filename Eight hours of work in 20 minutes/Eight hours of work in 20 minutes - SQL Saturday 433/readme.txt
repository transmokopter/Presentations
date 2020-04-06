Thanks to those attending the session. Great questions and good feedback during the session.

The Setup-script creates the main table but it also populates some tables from the AdventureWorks2014 table.

By using the procedure in the Setup-script, combined with a simple SSIS-package, you can generate the CSV-files which I have used for loading data.


I haven't included SSIS packages (because for some reason I broke them and wanted to upload the presentation as quick as possible)
But recreating the SSIS-packages would be a simple thing. 

- A dataflow for moving data from csv to table Demo.ProductionSales makes up the whole first package
- Add the two Execute SQL tasks in the control flow for disabling and rebuild indexes from "3 Load product data indexdisable.sql" as steps before and after the dataflow task in the control flow.
- Change to use staging table instead of production table and add a few lines of code for partition switching from "6 Load with partitions.sql" as a final Execute SQL Task.

Best Regards
Magnus Ahlkvist
Twitter: @OnlySql