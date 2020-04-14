use ssisdb;
DELETE internal.executions where execution_id<31;
SELECT * FROM internal.executions 
