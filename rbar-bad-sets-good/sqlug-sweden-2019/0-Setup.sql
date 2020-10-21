:setvar is_sqlcmd_mode "1"
:setvar setupstep "1"
go
declare @is_sqlcmd_mode varchar(100);
begin try
  set @is_sqlcmd_mode='$(is_sqlcmd_mode)'
end try
begin catch
  print error_message();
end catch

if @is_sqlcmd_mode <> '1'
begin
	raiserror('Script must be running in sqlcmd mode',20,1) with log;
end 
go
--Script is running in sqlcmd mode. Now continue with real setup.

use master;
if $(setupstep)=1
BEGIN
	if db_id('rbar') is not null
	begin
		alter database rbar set single_user with rollback immediate;
		DROP database rbar;
	end
	create database rbar;
	alter authorization on database::rbar to sa;
END
GO
use rbar;
if $(setupstep)=1
BEGIN
	if object_id('DimDate') IS NULL
	BEGIN
		CREATE TABLE dbo.DimDate
			(datekey int CONSTRAINT PK_DimDate PRIMARY KEY CLUSTERED,
			 dt date not null,
			 Weekday tinyint not null,
			 WeekdayName_EN nvarchar(10)not null,
			 MonthNumber tinyint not null,
			 MonthName_EN nvarchar(10) not null,
			 YearNumber smallint not null
			);
	END
END
