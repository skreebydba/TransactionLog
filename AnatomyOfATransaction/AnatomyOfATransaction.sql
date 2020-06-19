USE master;

/* This script creates a database, table, and clustered index.  It inserts several
   rows into the table and runs a full and transaction log backup.  After each step
   fn_dblog is selected from to analyze the contents of the transaction log */

/* fn_dblog is a table-valued function that will return the contents of the transaction
   log.  It takes two input parameters, begin log sequence number and end log sequence
   number. */

SELECT * FROM fn_dblog(NULL,NULL);

/* fn_dblog returns log records for the current database.  If NULL is passed in for
   both input parameters, all log records will be returned.  SELECT * FROM fn_dblog(NULL, NULL)
   will return all log records.  Because it is a table-valued function, a SELECT list
   can be used */
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
FROM fn_dblog(NULL,NULL);

/* Transaction Name */
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
FROM fn_dblog(NULL,NULL)
WHERE [Transaction Name] IS NOT NULL;

/* Operation - What action is being taken */
SELECT DISTINCT Operation
FROM fn_dblog(NULL,NULL)
ORDER BY Operation;

/* Context - Where that operation is being taken */
SELECT DISTINCT Context
FROM fn_dblog(NULL,NULL)
ORDER BY Context;

/* Description - Description of what action is being taken
   Not always very descriptive */
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
FROM fn_dblog(NULL,NULL);

/* Previous LSN - Identifies the previous log record for
   this transaction */
SELECT [Transaction ID]
,Operation
,[Current LSN]
,[Previous LSN]
FROM fn_dblog(NULL,NULL)
WHERE [Transaction ID] <> '0000:00000000';

/* AllocUnitName - The object that is being affected 
   Page ID - The data page that is being affected
			 hexadecimal value FileID:PageID
   Slot ID - The position of the row on the page
             zero-based  
   Number of Locks - Number of Locks
   Lock Information - Shows the lock escalation
					  Generally, Object, Page, Row */
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
FROM fn_dblog(NULL,NULL)
WHERE AllocUnitName = 'dbo.CommandLog.PK_CommandLog';

/* Here's where the real fun starts */
/* Create TranAnatomy database */
DROP DATABASE IF EXISTS TranAnatomy;

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

USE TranAnatomy;

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
FROM fn_dblog(NULL,NULL);
GO

USE TranAnatomy;

DECLARE @maxlsn NVARCHAR(46);
SELECT @maxlsn = CONCAT(N'0x',MAX([Current LSN])) FROM fn_dblog(NULL,NULL);

CREATE TABLE TranTable
(RowID INT IDENTITY(1,1)
,TextField NVARCHAR(10));

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
GO

DECLARE @maxlsn NVARCHAR(46);
SELECT @maxlsn = CONCAT(N'0x',MAX([Current LSN])) FROM fn_dblog(NULL,NULL);

CREATE UNIQUE CLUSTERED INDEX IX_TranAnatomy_TranTable ON TranTable(RowID);

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
GO

/* I lied, this is where the fun REALLY starts */
DECLARE @maxlsn NVARCHAR(46);
SELECT @maxlsn = CONCAT(N'0x',MAX([Current LSN])) FROM fn_dblog(NULL,NULL);

INSERT INTO TranTable
VALUES
('0123456789');

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
GO

DECLARE @maxlsn NVARCHAR(46);
SELECT @maxlsn = CONCAT(N'0x',MAX([Current LSN])) FROM fn_dblog(NULL,NULL);

INSERT INTO TranTable
VALUES
('9876543210');

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
GO


DECLARE @maxlsn NVARCHAR(46);
SELECT @maxlsn = CONCAT(N'0x',MAX([Current LSN])) FROM fn_dblog(NULL,NULL);

BACKUP DATABASE TranAnatomy
TO DISK = 'C:\Backup\TranAnatomy_Full.bak' WITH COMPRESSION, FORMAT, INIT, STATS = 5;

SELECT [Current LSN]
,[Transaction ID]
,[Transaction Name]
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
GO

DECLARE @maxlsn NVARCHAR(46);
SELECT @maxlsn = CONCAT(N'0x',MAX([Current LSN])) FROM fn_dblog(NULL,NULL);

BACKUP LOG TranAnatomy
TO DISK = 'C:\Backup\TranAnatomy_Log.trn' WITH COMPRESSION, FORMAT, INIT, STATS = 5;

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
GO

/* 	E
	ROLLBACK TRANSACTION will roll the activity back and will
	generate an ANTI operation in the log

	For inserts, an ANTI delete will generate */

	USE TranAnatomy;

	DECLARE @maxlsn NVARCHAR(46);

	SELECT @maxlsn = CONCAT(N'0x',MAX([Current LSN]))
	FROM fn_dblog(NULL,NULL);

	BEGIN TRANSACTION

		INSERT INTO TranTable
		VALUES
		('0123456789');

	ROLLBACK

			SELECT [Current LSN]
			,[Transaction ID]
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
			GO

/* 	F
	For deletes, an ANTI insert will generate */

	USE TranAnatomy;

	DECLARE @maxlsn NVARCHAR(46);
	DECLARE @maxrow INT;

	SELECT @maxlsn = CONCAT(N'0x',MAX([Current LSN]))
	FROM fn_dblog(NULL,NULL);
		
	SELECT @maxrow = MAX(RowID)
	FROM TranTable;

	BEGIN TRANSACTION

		DELETE FROM TranTable
		WHERE RowID = @maxrow;

	ROLLBACK

			SELECT [Current LSN]
			,[Transaction ID]
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
			GO

/* 	G
	For updates, an ANTI update will generate */
	DECLARE @maxlsn NVARCHAR(46);
	DECLARE @maxrow INT;

	SELECT @maxlsn = CONCAT(N'0x',MAX([Current LSN]))
	FROM fn_dblog(NULL,NULL);

	SELECT @maxrow = MAX(RowID)
	FROM TranTable;

	BEGIN TRANSACTION

		UPDATE TranTable
		SET TextField = '8876543210'
		WHERE RowID = @maxrow;

	ROLLBACK

	SELECT [Current LSN]
	,[Transaction ID]
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
	GO

USE TranAnatomy;

DROP TABLE IF EXISTS BigRows;

CREATE TABLE BigRows
(RowID INT 
,BigColumn VARCHAR(3000));

CREATE UNIQUE CLUSTERED INDEX IX_BigRows_RowID ON BigRows(RowID);

DECLARE @maxlsn NVARCHAR(46);

SELECT @maxlsn = CONCAT(N'0x',MAX([Current LSN])) FROM fn_dblog(NULL,NULL);
INSERT INTO BigRows
VALUES
(1,REPLICATE('a',3000)),
(3,REPLICATE('a',3000))

	SELECT [Current LSN]
	,[Transaction ID]
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
	GO

DECLARE @maxlsn NVARCHAR(46);

SELECT @maxlsn = CONCAT(N'0x',MAX([Current LSN])) FROM fn_dblog(NULL,NULL);

BEGIN TRANSACTION BigInsert

INSERT INTO BigRows
VALUES
(6,REPLICATE('a',3000))

COMMIT TRANSACTION

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
	GO

/* Demonstrate page split */

DECLARE @maxlsn NVARCHAR(46);

SELECT @maxlsn = CONCAT(N'0x',MAX([Current LSN])) FROM fn_dblog(NULL,NULL);

BEGIN TRANSACTION BigInsert

INSERT INTO BigRows
VALUES
(2,REPLICATE('a',3000))

COMMIT TRANSACTION

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
	GO


	SELECT * FROM fn_dblog(NULL, NULL)