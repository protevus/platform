ARG VERSION
FROM mcr.microsoft.com/mssql/server:${VERSION}-latest

LABEL maintainer="DevOps Team"
LABEL description="Microsoft SQL Server for development"

# Install additional tools
USER root
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    vim \
    net-tools \
    procps \
    netcat \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /var/opt/mssql/data \
    /var/opt/mssql/log \
    /var/opt/mssql/backups \
    /var/opt/mssql/config \
    && chown -R mssql:mssql /var/opt/mssql

# Copy initialization scripts
COPY init/01-init-dev-db.sql /docker-entrypoint-initdb.d/
COPY init/01-init-dev.sh /docker-entrypoint-initdb.d/
RUN chown mssql:mssql /docker-entrypoint-initdb.d/01-init-dev-db.sql \
    /docker-entrypoint-initdb.d/01-init-dev.sh \
    && chmod 755 /docker-entrypoint-initdb.d/01-init-dev-db.sql \
    /docker-entrypoint-initdb.d/01-init-dev.sh

# Create monitoring script
RUN echo '#!/bin/bash\n\
case "$1" in\n\
    "performance")\n\
        /opt/mssql-tools/bin/sqlcmd -S localhost -U $MSSQL_USER -P $MSSQL_PASSWORD -Q "\n\
            SELECT object_name, counter_name, instance_name, cntr_value\n\
            FROM sys.dm_os_performance_counters\n\
            WHERE object_name NOT LIKE '%Deprecated%'\n\
            ORDER BY object_name, counter_name;"\n\
        ;;\n\
    "blocking")\n\
        /opt/mssql-tools/bin/sqlcmd -S localhost -U $MSSQL_USER -P $MSSQL_PASSWORD -Q "\n\
            SELECT blocking.session_id as blocking_session,\n\
                   blocked.session_id as blocked_session,\n\
                   waitstats.wait_type,\n\
                   waitstats.wait_duration_ms\n\
            FROM sys.dm_exec_requests blocked\n\
            JOIN sys.dm_exec_sessions blocking\n\
                ON blocked.blocking_session_id = blocking.session_id\n\
            JOIN sys.dm_os_waiting_tasks waitstats\n\
                ON waitstats.session_id = blocked.session_id;"\n\
        ;;\n\
    "io")\n\
        /opt/mssql-tools/bin/sqlcmd -S localhost -U $MSSQL_USER -P $MSSQL_PASSWORD -Q "\n\
            SELECT DB_NAME(database_id) as database_name,\n\
                   file_id, io_stall_read_ms, io_stall_write_ms,\n\
                   num_of_reads, num_of_writes,\n\
                   size_on_disk_bytes/1024/1024 as size_mb\n\
            FROM sys.dm_io_virtual_file_stats(NULL, NULL);"\n\
        ;;\n\
    "memory")\n\
        /opt/mssql-tools/bin/sqlcmd -S localhost -U $MSSQL_USER -P $MSSQL_PASSWORD -Q "\n\
            SELECT type, pages_kb/1024 as pages_mb,\n\
                   virtual_memory_reserved_kb/1024 as virtual_reserved_mb,\n\
                   virtual_memory_committed_kb/1024 as virtual_committed_mb\n\
            FROM sys.dm_os_memory_clerks\n\
            WHERE pages_kb > 0\n\
            ORDER BY pages_kb DESC;"\n\
        ;;\n\
    *)\n\
        echo "Usage: $0 {performance|blocking|io|memory}"\n\
        exit 1\n\
        ;;\n\
esac' > /usr/local/bin/mssql-monitor \
    && chmod +x /usr/local/bin/mssql-monitor

# Create performance analysis script
RUN echo '#!/bin/bash\n\
case "$1" in\n\
    "expensive-queries")\n\
        /opt/mssql-tools/bin/sqlcmd -S localhost -U $MSSQL_USER -P $MSSQL_PASSWORD -Q "\n\
            SELECT TOP 10\n\
                   qs.total_elapsed_time/qs.execution_count as avg_elapsed_time,\n\
                   qs.total_worker_time/qs.execution_count as avg_cpu_time,\n\
                   qs.execution_count,\n\
                   SUBSTRING(qt.text, (qs.statement_start_offset/2)+1,\n\
                   ((CASE qs.statement_end_offset\n\
                       WHEN -1 THEN DATALENGTH(qt.text)\n\
                       ELSE qs.statement_end_offset\n\
                     END - qs.statement_start_offset)/2) + 1) as query_text\n\
            FROM sys.dm_exec_query_stats qs\n\
            CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt\n\
            ORDER BY avg_elapsed_time DESC;"\n\
        ;;\n\
    "index-usage")\n\
        /opt/mssql-tools/bin/sqlcmd -S localhost -U $MSSQL_USER -P $MSSQL_PASSWORD -Q "\n\
            SELECT OBJECT_NAME(i.object_id) as table_name,\n\
                   i.name as index_name,\n\
                   i.type_desc,\n\
                   us.user_seeks + us.user_scans + us.user_lookups as reads,\n\
                   us.user_updates as writes,\n\
                   us.last_user_seek,\n\
                   us.last_user_update\n\
            FROM sys.indexes i\n\
            LEFT JOIN sys.dm_db_index_usage_stats us\n\
                ON i.object_id = us.object_id\n\
                AND i.index_id = us.index_id\n\
            WHERE OBJECTPROPERTY(i.object_id, '\''IsUserTable'\'') = 1;"\n\
        ;;\n\
    "table-sizes")\n\
        /opt/mssql-tools/bin/sqlcmd -S localhost -U $MSSQL_USER -P $MSSQL_PASSWORD -Q "\n\
            SELECT t.name as table_name,\n\
                   p.rows as row_count,\n\
                   SUM(a.total_pages) * 8 as total_space_kb,\n\
                   SUM(a.used_pages) * 8 as used_space_kb\n\
            FROM sys.tables t\n\
            INNER JOIN sys.indexes i ON t.object_id = i.object_id\n\
            INNER JOIN sys.partitions p ON i.object_id = p.object_id\n\
                AND i.index_id = p.index_id\n\
            INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id\n\
            GROUP BY t.name, p.rows\n\
            ORDER BY total_space_kb DESC;"\n\
        ;;\n\
    *)\n\
        echo "Usage: $0 {expensive-queries|index-usage|table-sizes}"\n\
        exit 1\n\
        ;;\n\
esac' > /usr/local/bin/mssql-analyze \
    && chmod +x /usr/local/bin/mssql-analyze

# Create database management script
RUN echo '#!/bin/bash\n\
case "$1" in\n\
    "shrink-log")\n\
        if [ -z "$2" ]; then\n\
            echo "Database name required"\n\
            exit 1\n\
        fi\n\
        /opt/mssql-tools/bin/sqlcmd -S localhost -U $MSSQL_USER -P $MSSQL_PASSWORD -Q "\n\
            ALTER DATABASE [$2] SET RECOVERY SIMPLE;\n\
            DBCC SHRINKFILE (N'\''$2_log'\'', 1);\n\
            ALTER DATABASE [$2] SET RECOVERY FULL;"\n\
        ;;\n\
    "rebuild-indexes")\n\
        if [ -z "$2" ]; then\n\
            echo "Database name required"\n\
            exit 1\n\
        fi\n\
        /opt/mssql-tools/bin/sqlcmd -S localhost -U $MSSQL_USER -P $MSSQL_PASSWORD -d "$2" -Q "\n\
            EXEC sp_MSforeachtable @command1='\''ALTER INDEX ALL ON ? REBUILD'\'';"\n\
        ;;\n\
    "update-stats")\n\
        if [ -z "$2" ]; then\n\
            echo "Database name required"\n\
            exit 1\n\
        fi\n\
        /opt/mssql-tools/bin/sqlcmd -S localhost -U $MSSQL_USER -P $MSSQL_PASSWORD -d "$2" -Q "\n\
            EXEC sp_updatestats;"\n\
        ;;\n\
    *)\n\
        echo "Usage: $0 {shrink-log|rebuild-indexes|update-stats} [database]"\n\
        exit 1\n\
        ;;\n\
esac' > /usr/local/bin/mssql-utils \
    && chmod +x /usr/local/bin/mssql-utils

# Create healthcheck script
RUN echo '#!/bin/bash\n\
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -Q "SELECT 1" || exit 1' > /usr/local/bin/healthcheck \
    && chmod +x /usr/local/bin/healthcheck

USER mssql

# Expose ports
EXPOSE 1433 1434

# Set up volumes
VOLUME ["/var/opt/mssql/data", "/var/opt/mssql/log", "/var/opt/mssql/backups"]

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 \
    CMD /usr/local/bin/healthcheck

# Default command
CMD ["/opt/mssql/bin/sqlservr"]
