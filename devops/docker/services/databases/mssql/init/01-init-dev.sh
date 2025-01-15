#!/bin/bash
set -e

# Wait for SQL Server to be ready
until /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -Q "SELECT 1" &> /dev/null; do
    echo "Waiting for SQL Server to be ready..."
    sleep 2
done

# Initialize development database
echo "Initializing development database..."
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" \
    -i /docker-entrypoint-initdb.d/01-init-dev-db.sql \
    -v DEV_DB_NAME="${DEV_DB_NAME}" \
    DEV_DB_USER="${DEV_DB_USER}" \
    DEV_DB_PASSWORD="${DEV_DB_PASSWORD}" \
    CREATE_TEST_DB="${CREATE_TEST_DB}"

# Create monitoring script
echo "Creating monitoring scripts..."
cat > /usr/local/bin/mssql-monitor <<'EOF'
#!/bin/bash
case "$1" in
    "queries")
        /opt/mssql-tools/bin/sqlcmd -S localhost -U $MSSQL_USER -P $MSSQL_PASSWORD -d development -Q "
            EXEC [monitoring].[AnalyzeQueryPerformance];"
        ;;
    "waits")
        /opt/mssql-tools/bin/sqlcmd -S localhost -U $MSSQL_USER -P $MSSQL_PASSWORD -d development -Q "
            EXEC [monitoring].[AnalyzeWaitStatistics];"
        ;;
    "connections")
        /opt/mssql-tools/bin/sqlcmd -S localhost -U $MSSQL_USER -P $MSSQL_PASSWORD -d development -Q "
            SELECT session_id, login_name, host_name, program_name,
                   DB_NAME(database_id) as database_name,
                   cpu_time, memory_usage, total_elapsed_time
            FROM sys.dm_exec_sessions
            WHERE is_user_process = 1;"
        ;;
    "locks")
        /opt/mssql-tools/bin/sqlcmd -S localhost -U $MSSQL_USER -P $MSSQL_PASSWORD -Q "
            SELECT request_session_id, resource_type, resource_database_id,
                   request_mode, request_status
            FROM sys.dm_tran_locks;"
        ;;
    "memory")
        /opt/mssql-tools/bin/sqlcmd -S localhost -U $MSSQL_USER -P $MSSQL_PASSWORD -Q "
            SELECT counter_name, cntr_value
            FROM sys.dm_os_performance_counters
            WHERE object_name LIKE '%Memory Manager%';"
        ;;
    *)
        echo "Usage: $0 {queries|waits|connections|locks|memory}"
        exit 1
        ;;
esac
EOF
chmod +x /usr/local/bin/mssql-monitor

# Create performance analysis script
cat > /usr/local/bin/mssql-analyze <<'EOF'
#!/bin/bash
case "$1" in
    "table")
        if [ -z "$2" ]; then
            echo "Table name required"
            exit 1
        fi
        /opt/mssql-tools/bin/sqlcmd -S localhost -U $MSSQL_USER -P $MSSQL_PASSWORD -d development -Q "
            SELECT OBJECT_NAME(object_id) as table_name,
                   rows, total_pages, used_pages,
                   data_compression_desc
            FROM sys.partitions p
            JOIN sys.allocation_units a ON p.partition_id = a.container_id
            WHERE OBJECT_NAME(object_id) = '$2';"
        ;;
    "index")
        if [ -z "$2" ]; then
            echo "Table name required"
            exit 1
        fi
        /opt/mssql-tools/bin/sqlcmd -S localhost -U $MSSQL_USER -P $MSSQL_PASSWORD -d development -Q "
            SELECT i.name as index_name, i.type_desc,
                   i.is_primary_key, i.is_unique,
                   us.user_seeks, us.user_scans,
                   us.user_lookups, us.user_updates
            FROM sys.indexes i
            LEFT JOIN sys.dm_db_index_usage_stats us
                ON i.object_id = us.object_id
                AND i.index_id = us.index_id
            WHERE OBJECT_NAME(i.object_id) = '$2';"
        ;;
    "querystore")
        /opt/mssql-tools/bin/sqlcmd -S localhost -U $MSSQL_USER -P $MSSQL_PASSWORD -d development -Q "
            SELECT TOP 10 qt.query_sql_text, q.count_compiles,
                   rs.count_executions, rs.avg_duration,
                   rs.avg_logical_io_reads
            FROM sys.query_store_query_text qt
            JOIN sys.query_store_query q
                ON qt.query_text_id = q.query_text_id
            JOIN sys.query_store_plan p
                ON q.query_id = p.query_id
            JOIN sys.query_store_runtime_stats rs
                ON p.plan_id = rs.plan_id
            ORDER BY rs.avg_duration DESC;"
        ;;
    *)
        echo "Usage: $0 {table|index|querystore} [name]"
        exit 1
        ;;
esac
EOF
chmod +x /usr/local/bin/mssql-analyze

# Create backup script
cat > /usr/local/bin/mssql-backup <<'EOF'
#!/bin/bash
backup_dir="/var/opt/mssql/backups"
timestamp=$(date +%Y%m%d_%H%M%S)

case "$1" in
    "full")
        if [ -z "$2" ]; then
            echo "Database name required"
            exit 1
        fi
        /opt/mssql-tools/bin/sqlcmd -S localhost -U $MSSQL_USER -P $MSSQL_PASSWORD -Q "
            BACKUP DATABASE [$2]
            TO DISK = '${backup_dir}/full_${2}_${timestamp}.bak'
            WITH COMPRESSION, STATS = 10;"
        ;;
    "diff")
        if [ -z "$2" ]; then
            echo "Database name required"
            exit 1
        fi
        /opt/mssql-tools/bin/sqlcmd -S localhost -U $MSSQL_USER -P $MSSQL_PASSWORD -Q "
            BACKUP DATABASE [$2]
            TO DISK = '${backup_dir}/diff_${2}_${timestamp}.bak'
            WITH DIFFERENTIAL, COMPRESSION, STATS = 10;"
        ;;
    "log")
        if [ -z "$2" ]; then
            echo "Database name required"
            exit 1
        fi
        /opt/mssql-tools/bin/sqlcmd -S localhost -U $MSSQL_USER -P $MSSQL_PASSWORD -Q "
            BACKUP LOG [$2]
            TO DISK = '${backup_dir}/log_${2}_${timestamp}.trn'
            WITH COMPRESSION, STATS = 10;"
        ;;
    "restore")
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Backup file and database name required"
            exit 1
        fi
        /opt/mssql-tools/bin/sqlcmd -S localhost -U $MSSQL_USER -P $MSSQL_PASSWORD -Q "
            RESTORE DATABASE [$3]
            FROM DISK = '$2'
            WITH REPLACE, STATS = 10;"
        ;;
    *)
        echo "Usage: $0 {full|diff|log|restore} [database] [file]"
        exit 1
        ;;
esac
EOF
chmod +x /usr/local/bin/mssql-backup

echo "Development environment initialization completed successfully"
