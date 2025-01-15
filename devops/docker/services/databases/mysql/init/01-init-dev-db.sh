#!/bin/bash
set -eo pipefail

# Function to create a database and user
create_db_and_user() {
    local db=$1
    local user=$2
    local password=$3
    local host=${4:-"%"}

    echo "Creating database '$db' and user '$user'@'$host'..."

    mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<-EOSQL
        -- Create database
        CREATE DATABASE IF NOT EXISTS \`$db\`
        CHARACTER SET utf8mb4
        COLLATE utf8mb4_unicode_ci;

        -- Create user if it doesn't exist
        CREATE USER IF NOT EXISTS '$user'@'$host'
        IDENTIFIED BY '$password';

        -- Grant privileges
        GRANT ALL PRIVILEGES ON \`$db\`.* TO '$user'@'$host';

        -- Additional grants for development
        GRANT PROCESS ON *.* TO '$user'@'$host';
        GRANT REFERENCES ON *.* TO '$user'@'$host';
        GRANT SHOW VIEW ON *.* TO '$user'@'$host';
        GRANT TRIGGER ON *.* TO '$user'@'$host';
        GRANT LOCK TABLES ON *.* TO '$user'@'$host';
EOSQL

    echo "Database '$db' and user '$user'@'$host' created successfully"
}

# Wait for MySQL to be ready
until mysqladmin ping -h"localhost" -p"${MYSQL_ROOT_PASSWORD}" --silent; do
    echo "Waiting for MySQL to be ready..."
    sleep 2
done

# Development database setup
if [ -n "$DEV_DB_NAME" ] && [ -n "$DEV_DB_USER" ] && [ -n "$DEV_DB_PASSWORD" ]; then
    create_db_and_user "$DEV_DB_NAME" "$DEV_DB_USER" "$DEV_DB_PASSWORD"
else
    # Create default development database if environment variables are not set
    create_db_and_user "development" "developer" "developer_password"
fi

# Create test database if enabled
if [ "${CREATE_TEST_DB:-false}" = "true" ]; then
    create_db_and_user "test" "tester" "test_password"
fi

# Create local user for host machine connections
create_db_and_user "development" "developer" "developer_password" "localhost"

# Development optimizations
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<-EOSQL
    -- Enable additional features for development
    SET GLOBAL log_output = 'TABLE';
    SET GLOBAL general_log = 1;
    SET GLOBAL slow_query_log = 1;
    SET GLOBAL long_query_time = 2;
    SET GLOBAL log_queries_not_using_indexes = 1;

    -- Create admin user for development tools
    CREATE USER IF NOT EXISTS 'admin'@'%'
    IDENTIFIED BY 'admin_password';
    GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%'
    WITH GRANT OPTION;

    -- Flush privileges to apply changes
    FLUSH PRIVILEGES;

    -- Development utility procedures
    DELIMITER //

    -- Procedure to show table sizes
    CREATE PROCEDURE IF NOT EXISTS show_table_sizes()
    BEGIN
        SELECT 
            table_schema as 'Database',
            table_name as 'Table',
            round(((data_length + index_length) / 1024 / 1024), 2) as 'Size (MB)'
        FROM information_schema.TABLES
        ORDER BY (data_length + index_length) DESC;
    END //

    -- Procedure to show running queries
    CREATE PROCEDURE IF NOT EXISTS show_running_queries()
    BEGIN
        SELECT 
            ID,
            USER,
            HOST,
            DB,
            COMMAND,
            TIME as 'Seconds',
            STATE,
            INFO as 'Query'
        FROM information_schema.PROCESSLIST
        WHERE COMMAND != 'Sleep'
        ORDER BY TIME DESC;
    END //

    -- Procedure to kill long running queries
    CREATE PROCEDURE IF NOT EXISTS kill_long_queries(in max_time int)
    BEGIN
        DECLARE done INT DEFAULT FALSE;
        DECLARE process_id BIGINT;
        DECLARE cur CURSOR FOR 
            SELECT ID 
            FROM information_schema.PROCESSLIST
            WHERE COMMAND != 'Sleep'
            AND TIME > max_time;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

        OPEN cur;
        read_loop: LOOP
            FETCH cur INTO process_id;
            IF done THEN
                LEAVE read_loop;
            END IF;
            KILL process_id;
        END LOOP;
        CLOSE cur;
    END //

    DELIMITER ;

    -- Create views for monitoring
    CREATE OR REPLACE VIEW v_table_statistics AS
    SELECT 
        TABLE_SCHEMA as 'database',
        TABLE_NAME as 'table',
        TABLE_ROWS as 'rows',
        ROUND(DATA_LENGTH/1024/1024, 2) as 'data_size_mb',
        ROUND(INDEX_LENGTH/1024/1024, 2) as 'index_size_mb',
        ROUND((DATA_LENGTH + INDEX_LENGTH)/1024/1024, 2) as 'total_size_mb'
    FROM information_schema.TABLES
    WHERE TABLE_SCHEMA NOT IN ('mysql', 'information_schema', 'performance_schema');
EOSQL

echo "Database initialization and optimization completed"
