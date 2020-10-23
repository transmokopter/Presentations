use ssisdb;
DELETE internal.executions where execution_id<40;
SELECT * FROM internal.executions 
