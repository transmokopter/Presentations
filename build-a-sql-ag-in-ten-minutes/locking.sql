-- Check out SPIDs in the other two windows.


SELECT * FROM sys.dm_os_waiting_tasks AS DOWT WHERE session_id IN (58,55) AND wait_type<>'WAITFOR';

