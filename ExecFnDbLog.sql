/* Get the max LSN number from the master database log file 
   Concatenate '0x' to the LSN for use with fn_dblog */
DECLARE @maxlsn NVARCHAR(46);
SELECT @maxlsn = CONCAT(N'0x',MAX([Current LSN])) FROM fn_dblog(NULL,NULL);

CREATE DATABASE TranAnatomy;

/* Select from fn_dblog twice
   First, from the master database, returning all log records associated with the CREATE DATABASE statement
   Second, from the TranAnatomy database showing all existing log records */
USE master;

SELECT [Current LSN]
,[Transaction ID]
,[Transaction Name]
,Operation
,Context
,[Description]
,[Previous LSN]
,AllocUnitName
,[Page ID]
,[Slot ID]
,[Begin Time]
,[Database Name]
,[Number of Locks]
,[Lock Information]
,[New Split Page]
FROM fn_dblog(@maxlsn,NULL);