SELECT * FROM sys.dm_os_waiting_tasks AS DOWT WHERE session_id IN (67,97) AND wait_type<>'WAITFOR';

