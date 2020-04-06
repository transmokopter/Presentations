
--Import some stuff
DECLARE @dt DATE='2019-01-01';
DECLARE @filename VARCHAR(100)=CONCAT(DATENAME(MONTH,@dt),YEAR(@dt),'.txt');

DECLARE @execution_id BIGINT
EXEC [SSISDB].[catalog].[create_execution] @package_name=N'Import.dtsx', @execution_id=@execution_id OUTPUT, @folder_name=N'SqlSaturdayCork2019', @project_name=N'SqlSaturdayCork2019', @use32bitruntime=False, @reference_id=NULL, @runinscaleout=False
SELECT @execution_id
DECLARE @var0 SQL_VARIANT = N'C:\Users\Magnus\OneDrive\Dokument\Presentationer\SqlSaturdayCork2019\' + @filename;
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id,  @object_type=20, @parameter_name=N'CM.Flat File Connection Manager.ConnectionString', @parameter_value=@var0
DECLARE @var1 SMALLINT = 1
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id,  @object_type=50, @parameter_name=N'LOGGING_LEVEL', @parameter_value=@var1
EXEC [SSISDB].[catalog].[start_execution] @execution_id
GO



--Export some stuff
DECLARE @dt DATE='2019-02-01';
DECLARE @filename VARCHAR(100)=CONCAT(DATENAME(MONTH,@dt),YEAR(@dt),'.txt');
DECLARE @execution_id bigint
EXEC [SSISDB].[catalog].[create_execution] @package_name=N'Export.dtsx', @execution_id=@execution_id OUTPUT, @folder_name=N'SqlSaturdayCork2019', @project_name=N'SqlSaturdayCork2019', @use32bitruntime=False, @reference_id=Null, @runinscaleout=False
Select @execution_id
DECLARE @var0 datetime = @dt;
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id,  @object_type=20, @parameter_name=N'RefDate', @parameter_value=@var0
DECLARE @var1 sql_variant = N'C:\Users\Magnus\OneDrive\Dokument\Presentationer\SqlSaturdayCork2019\' + @filename;
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id,  @object_type=20, @parameter_name=N'CM.Flat File Connection Manager.ConnectionString', @parameter_value=@var1
DECLARE @var2 smallint = 1
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id,  @object_type=50, @parameter_name=N'LOGGING_LEVEL', @parameter_value=@var2
EXEC [SSISDB].[catalog].[start_execution] @execution_id
GO

