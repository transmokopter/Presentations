Thanks to those attending the session. Great questions and good feedback during the session.

The Setup-script creates the main table but it also populates some tables from the AdventureWorks2014 table.

CSV files for the import are a bit too big to include in this bundle, but there's an export stored procedure in the setup-scripts which you can use to create a dataset to import.

I haven't included SSIS packages but recreating the SSIS-packages would be a simple thing. 

- A dataflow for moving data from csv to table Demo.ProductionSales makes up the whole first package
- Add the two Execute SQL tasks in the control flow for disabling and rebuild indexes from "3 Load product data indexdisable.sql" as steps before and after the dataflow task in the control flow.
- Change to use staging table instead of production table and add a few lines of code for partition switching from "6 Load with partitions.sql" as a final Execute SQL Task.

Best Regards
Magnus Ahlkvist
Twitter: @Transmokopter