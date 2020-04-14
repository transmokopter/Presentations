--Import some stuff
DECLARE @dt DATE='2019-03-01';
DECLARE @filename VARCHAR(100)=CONCAT(DATENAME(MONTH,@dt),YEAR(@dt),'.txt');
Declare @execution_id bigint
EXEC [SSISDB].[catalog].[create_execution] @package_name=N'Import.dtsx', @execution_id=@execution_id OUTPUT, @folder_name=N'GroupByDemo', @project_name=N'GroupByDemo', @use32bitruntime=False, @reference_id=Null, @runinscaleout=False
Select @execution_id
DECLARE @var0 sql_variant = N'c:\ETLDATA\' + @filename;
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id,  @object_type=20, @parameter_name=N'CM.Flat File Connection Manager.ConnectionString', @parameter_value=@var0
DECLARE @var1 smallint = 3
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id,  @object_type=50, @parameter_name=N'LOGGING_LEVEL', @parameter_value=@var1
EXEC [SSISDB].[catalog].[start_execution] @execution_id
GO


--Import stuff v2
DECLARE @dt DATE='2019-07-01';
DECLARE @filename VARCHAR(100)=CONCAT(DATENAME(MONTH,@dt),YEAR(@dt),'.txt');
Declare @execution_id bigint
EXEC [SSISDB].[catalog].[create_execution] @package_name=N'ImportV2.dtsx', @execution_id=@execution_id OUTPUT, @folder_name=N'GroupByDemo', @project_name=N'GroupByDemo', @use32bitruntime=False, @reference_id=Null, @runinscaleout=False
Select @execution_id
DECLARE @var0 sql_variant = N'c:\etldata\' + @filename;
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id,  @object_type=20, @parameter_name=N'CM.Flat File Connection Manager.ConnectionString', @parameter_value=@var0
DECLARE @var1 smallint = 3
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id,  @object_type=50, @parameter_name=N'LOGGING_LEVEL', @parameter_value=@var1
EXEC [SSISDB].[catalog].[start_execution] @execution_id
GO



--Import stuff v3
DECLARE @dt DATE='2019-07-01';
DECLARE @filename VARCHAR(100)=CONCAT(DATENAME(MONTH,@dt),YEAR(@dt),'.txt');
Declare @execution_id bigint
EXEC [SSISDB].[catalog].[create_execution] @package_name=N'ImportV3.dtsx', @execution_id=@execution_id OUTPUT, @folder_name=N'GroupByDemo', @project_name=N'GroupByDemo', @use32bitruntime=False, @reference_id=Null, @runinscaleout=False
Select @execution_id
DECLARE @var0 sql_variant = N'c:\etldata\' + @filename;
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id,  @object_type=20, @parameter_name=N'CM.Flat File Connection Manager.ConnectionString', @parameter_value=@var0
DECLARE @var1 smallint = 3
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id,  @object_type=50, @parameter_name=N'LOGGING_LEVEL', @parameter_value=@var1
EXEC [SSISDB].[catalog].[start_execution] @execution_id
GO


--Export some stuff
DECLARE @dt DATE='2019-02-01';
DECLARE @filename VARCHAR(100)=CONCAT(DATENAME(MONTH,@dt),YEAR(@dt),'.txt');
Declare @execution_id bigint
EXEC [SSISDB].[catalog].[create_execution] @package_name=N'CreateData.dtsx', @execution_id=@execution_id OUTPUT, @folder_name=N'GroupByDemo', @project_name=N'GroupByDemo', @use32bitruntime=False, @reference_id=Null, @runinscaleout=False
Select @execution_id
DECLARE @var0 datetime = @dt;
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id,  @object_type=20, @parameter_name=N'dt', @parameter_value=@var0
DECLARE @var1 sql_variant = N'c:\etldata\' + @filename;
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id,  @object_type=20, @parameter_name=N'CM.Flat File Connection Manager.ConnectionString', @parameter_value=@var1
DECLARE @var2 smallint = 3
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id,  @object_type=50, @parameter_name=N'LOGGING_LEVEL', @parameter_value=@var2
EXEC [SSISDB].[catalog].[start_execution] @execution_id
GO

