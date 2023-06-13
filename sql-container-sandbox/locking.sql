SELECT * FROM sys.dm_os_waiting_tasks AS DOWT WHERE session_id IN (58,64) AND wait_type<>'WAITFOR';

