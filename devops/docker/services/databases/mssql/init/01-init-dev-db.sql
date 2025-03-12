-- SQL Server initialization script for development environment

USE [master]
GO

-- Enable advanced options
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO

-- Configure development settings
sp_configure 'optimize for ad hoc workloads', 1;
sp_configure 'cost threshold for parallelism', 50;
sp_configure 'max degree of parallelism', 2;
sp_configure 'remote query timeout', 600;
GO
RECONFIGURE;
GO

-- Create development database
DECLARE @DevDbName nvarchar(128) = COALESCE('$(DEV_DB_NAME)', 'development')
DECLARE @SQL nvarchar(max)

SET @SQL = N'
CREATE DATABASE ' + QUOTENAME(@DevDbName) + N'
COLLATE SQL_Latin1_General_CP1_CI_AS
WITH
    MAXSIZE = UNLIMITED,
    FILE = (
        NAME = ''' + @DevDbName + N'_data'',
        FILENAME = ''/var/opt/mssql/data/' + @DevDbName + N'.mdf'',
        SIZE = 512MB,
        FILEGROWTH = 128MB
    ),
    FILEGROUP [INDEXES] (
        NAME = ''' + @DevDbName + N'_indexes'',
        FILENAME = ''/var/opt/mssql/data/' + @DevDbName + N'_idx.ndf'',
        SIZE = 256MB,
        FILEGROWTH = 128MB
    ),
    LOG ON (
        NAME = ''' + @DevDbName + N'_log'',
        FILENAME = ''/var/opt/mssql/data/' + @DevDbName + N'_log.ldf'',
        SIZE = 256MB,
        FILEGROWTH = 64MB
    );

ALTER DATABASE ' + QUOTENAME(@DevDbName) + N' SET RECOVERY SIMPLE;
ALTER DATABASE ' + QUOTENAME(@DevDbName) + N' SET READ_COMMITTED_SNAPSHOT ON;
ALTER DATABASE ' + QUOTENAME(@DevDbName) + N' SET ALLOW_SNAPSHOT_ISOLATION ON;'

EXEC sp_executesql @SQL
GO

-- Create monitoring schema
USE [development]
GO

CREATE SCHEMA [monitoring]
GO

-- Create monitoring tables
CREATE TABLE [monitoring].[QueryStats] (
    [QueryStatsId] bigint IDENTITY(1,1) PRIMARY KEY,
    [DatabaseName] nvarchar(128),
    [ObjectName] nvarchar(128),
    [QueryText] nvarchar(max),
    [ExecutionCount] bigint,
    [TotalWorkerTime] bigint,
    [TotalElapsedTime] bigint,
    [TotalLogicalReads] bigint,
    [TotalPhysicalReads] bigint,
    [TotalLogicalWrites] bigint,
    [LastExecutionTime] datetime,
    [CaptureTime] datetime DEFAULT GETUTCDATE()
)
GO

CREATE TABLE [monitoring].[ConnectionStats] (
    [ConnectionStatsId] bigint IDENTITY(1,1) PRIMARY KEY,
    [SessionId] int,
    [LoginName] nvarchar(128),
    [HostName] nvarchar(128),
    [ProgramName] nvarchar(128),
    [DatabaseName] nvarchar(128),
    [Status] nvarchar(30),
    [CpuTime] bigint,
    [MemoryUsage] bigint,
    [TotalScheduledTime] bigint,
    [TotalElapsedTime] bigint,
    [LastRequestStartTime] datetime,
    [LastRequestEndTime] datetime,
    [CaptureTime] datetime DEFAULT GETUTCDATE()
)
GO

CREATE TABLE [monitoring].[WaitStats] (
    [WaitStatsId] bigint IDENTITY(1,1) PRIMARY KEY,
    [WaitType] nvarchar(60),
    [WaitingTasksCount] bigint,
    [WaitTimeMs] bigint,
    [MaxWaitTimeMs] bigint,
    [SignalWaitTimeMs] bigint,
    [CaptureTime] datetime DEFAULT GETUTCDATE()
)
GO

-- Create monitoring procedures
CREATE OR ALTER PROCEDURE [monitoring].[CaptureQueryStats]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [monitoring].[QueryStats]
    (
        [DatabaseName],
        [ObjectName],
        [QueryText],
        [ExecutionCount],
        [TotalWorkerTime],
        [TotalElapsedTime],
        [TotalLogicalReads],
        [TotalPhysicalReads],
        [TotalLogicalWrites],
        [LastExecutionTime]
    )
    SELECT
        DB_NAME(qt.dbid),
        OBJECT_NAME(qt.objectid, qt.dbid),
        qt.text,
        qs.execution_count,
        qs.total_worker_time,
        qs.total_elapsed_time,
        qs.total_logical_reads,
        qs.total_physical_reads,
        qs.total_logical_writes,
        qs.last_execution_time
    FROM sys.dm_exec_query_stats qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
    WHERE qt.dbid = DB_ID();
END
GO

CREATE OR ALTER PROCEDURE [monitoring].[CaptureConnectionStats]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [monitoring].[ConnectionStats]
    (
        [SessionId],
        [LoginName],
        [HostName],
        [ProgramName],
        [DatabaseName],
        [Status],
        [CpuTime],
        [MemoryUsage],
        [TotalScheduledTime],
        [TotalElapsedTime],
        [LastRequestStartTime],
        [LastRequestEndTime]
    )
    SELECT
        s.session_id,
        s.login_name,
        s.host_name,
        s.program_name,
        DB_NAME(s.database_id),
        s.status,
        s.cpu_time,
        s.memory_usage,
        s.total_scheduled_time,
        s.total_elapsed_time,
        s.last_request_start_time,
        s.last_request_end_time
    FROM sys.dm_exec_sessions s
    WHERE s.is_user_process = 1;
END
GO

CREATE OR ALTER PROCEDURE [monitoring].[CaptureWaitStats]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [monitoring].[WaitStats]
    (
        [WaitType],
        [WaitingTasksCount],
        [WaitTimeMs],
        [MaxWaitTimeMs],
        [SignalWaitTimeMs]
    )
    SELECT
        wait_type,
        waiting_tasks_count,
        wait_time_ms,
        max_wait_time_ms,
        signal_wait_time_ms
    FROM sys.dm_os_wait_stats
    WHERE wait_type NOT LIKE '%SLEEP%';
END
GO

-- Create analysis procedures
CREATE OR ALTER PROCEDURE [monitoring].[AnalyzeQueryPerformance]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 20
        [DatabaseName],
        [ObjectName],
        [QueryText],
        [ExecutionCount],
        [TotalWorkerTime] / 1000000.0 AS [TotalCPUSeconds],
        [TotalElapsedTime] / 1000000.0 AS [TotalDurationSeconds],
        [TotalLogicalReads] / [ExecutionCount] AS [AvgLogicalReads],
        [TotalPhysicalReads] / [ExecutionCount] AS [AvgPhysicalReads],
        [LastExecutionTime]
    FROM [monitoring].[QueryStats]
    ORDER BY [TotalWorkerTime] DESC;
END
GO

CREATE OR ALTER PROCEDURE [monitoring].[AnalyzeWaitStatistics]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 10
        [WaitType],
        [WaitingTasksCount],
        [WaitTimeMs] / 1000.0 AS [WaitTimeSeconds],
        [MaxWaitTimeMs] / 1000.0 AS [MaxWaitTimeSeconds],
        [SignalWaitTimeMs] / 1000.0 AS [SignalWaitTimeSeconds],
        [CaptureTime]
    FROM [monitoring].[WaitStats]
    ORDER BY [WaitTimeMs] DESC;
END
GO

-- Create development user if specified
IF '$(DEV_DB_USER)' != ''
BEGIN
    DECLARE @CreateUserSQL nvarchar(max)
    SET @CreateUserSQL = N'
    CREATE LOGIN [$(DEV_DB_USER)] WITH PASSWORD = ''$(DEV_DB_PASSWORD)'';
    USE [development];
    CREATE USER [$(DEV_DB_USER)] FOR LOGIN [$(DEV_DB_USER)];
    ALTER ROLE [db_owner] ADD MEMBER [$(DEV_DB_USER)];'
    
    EXEC sp_executesql @CreateUserSQL
END
GO

-- Create test database if enabled
IF '$(CREATE_TEST_DB)' = 'true'
BEGIN
    CREATE DATABASE [test]
    COLLATE SQL_Latin1_General_CP1_CI_AS;
    
    ALTER DATABASE [test] SET RECOVERY SIMPLE;
    ALTER DATABASE [test] SET READ_COMMITTED_SNAPSHOT ON;
    ALTER DATABASE [test] SET ALLOW_SNAPSHOT_ISOLATION ON;
END
GO

-- Create sample tables
USE [development]
GO

CREATE TABLE [dbo].[Customers] (
    [Id] int IDENTITY(1,1) PRIMARY KEY,
    [Name] nvarchar(100) NOT NULL,
    [Email] nvarchar(100) NOT NULL,
    [CreatedAt] datetime2 DEFAULT GETUTCDATE()
)
GO

CREATE TABLE [dbo].[Orders] (
    [Id] int IDENTITY(1,1) PRIMARY KEY,
    [CustomerId] int NOT NULL REFERENCES [dbo].[Customers]([Id]),
    [OrderDate] datetime2 DEFAULT GETUTCDATE(),
    [TotalAmount] decimal(15,2) NOT NULL
)
GO

CREATE TABLE [dbo].[OrderItems] (
    [Id] int IDENTITY(1,1) PRIMARY KEY,
    [OrderId] int NOT NULL REFERENCES [dbo].[Orders]([Id]),
    [ProductName] nvarchar(100) NOT NULL,
    [Quantity] int NOT NULL,
    [Price] decimal(15,2) NOT NULL
)
GO

-- Create indexes
CREATE INDEX [IX_Customers_Email] ON [dbo].[Customers]([Email]);
CREATE INDEX [IX_Orders_CustomerId] ON [dbo].[Orders]([CustomerId]);
CREATE INDEX [IX_Orders_OrderDate] ON [dbo].[Orders]([OrderDate]);
CREATE INDEX [IX_OrderItems_OrderId] ON [dbo].[OrderItems]([OrderId]);
GO

-- Enable Query Store
ALTER DATABASE [development] SET QUERY_STORE = ON
GO

ALTER DATABASE [development] 
SET QUERY_STORE (
    OPERATION_MODE = READ_WRITE,
    CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),
    DATA_FLUSH_INTERVAL_SECONDS = 60,
    MAX_STORAGE_SIZE_MB = 1000,
    INTERVAL_LENGTH_MINUTES = 5
)
GO
