#!/bin/bash
set -eo pipefail

# Function to create a database and user
create_db_and_user() {
    local db=$1
    local user=$2
    local password=$3
    local host=${4:-"%"}

    echo "Creating database '$db' and user '$user'@'$host'..."

    mysql -u root -p"${MARIADB_ROOT_PASSWORD}" <<-EOSQL
        -- Create database
        CREATE DATABASE IF NOT EXISTS \`$db\`
        CHARACTER SET utf8mb4
        COLLATE utf8mb4_unicode_ci;

        -- Create user if it doesn't exist
        CREATE USER IF NOT EXISTS '$user'@'$host'
        IDENTIFIED BY '$password';

        -- Grant privileges
        GRANT ALL PRIVILEGES ON \`$db\`.* TO '$user'@'$host';

        -- Additional development grants
        GRANT PROCESS, REFERENCES, SHOW VIEW, TRIGGER, LOCK TABLES ON *.* TO '$user'@'$host';
EOSQL

    echo "Database '$db' and user '$user'@'$host' created successfully"
}

# Wait for MariaDB to be ready
until mysqladmin ping -h"localhost" -p"${MARIADB_ROOT_PASSWORD}" --silent; do
    echo "Waiting for MariaDB to be ready..."
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

# Create development utility procedures
mysql -u root -p"${MARIADB_ROOT_PASSWORD}" <<-EOSQL
    -- Create utility database
    CREATE DATABASE IF NOT EXISTS dev_utils;
    USE dev_utils;

    -- Procedure to show table sizes
    DELIMITER //
    CREATE OR REPLACE PROCEDURE show_table_sizes()
    BEGIN
        SELECT 
            table_schema as 'Database',
            table_name as 'Table',
            round(((data_length + index_length) / 1024 / 1024), 2) as 'Size (MB)',
            table_rows as 'Rows'
        FROM information_schema.TABLES
        WHERE table_schema NOT IN ('information_schema', 'mysql', 'performance_schema')
        ORDER BY (data_length + index_length) DESC;
    END //

    -- Procedure to show running queries
    CREATE OR REPLACE PROCEDURE show_running_queries()
    BEGIN
        SELECT 
            ID as 'Connection ID',
            USER as 'User',
            HOST as 'Host',
            DB as 'Database',
            COMMAND as 'Command',
            TIME as 'Time (sec)',
            STATE as 'State',
            INFO as 'Query'
        FROM information_schema.PROCESSLIST
        WHERE COMMAND != 'Sleep'
        ORDER BY TIME DESC;
    END //

    -- Procedure to show table indexes
    CREATE OR REPLACE PROCEDURE show_indexes(IN p_schema VARCHAR(64), IN p_table VARCHAR(64))
    BEGIN
        SELECT 
            table_schema as 'Database',
            table_name as 'Table',
            index_name as 'Index',
            GROUP_CONCAT(column_name ORDER BY seq_in_index) as 'Columns',
            index_type as 'Type',
            non_unique as 'Not Unique'
        FROM information_schema.statistics
        WHERE table_schema = COALESCE(p_schema, table_schema)
        AND table_name = COALESCE(p_table, table_name)
        GROUP BY table_schema, table_name, index_name, index_type, non_unique
        ORDER BY table_schema, table_name, index_name;
    END //

    -- Procedure to analyze query performance
    CREATE OR REPLACE PROCEDURE analyze_query(IN query TEXT)
    BEGIN
        SET @query = query;
        EXPLAIN FORMAT=JSON @query;
        EXPLAIN ANALYZE @query;
    END //

    -- Procedure to show table status
    CREATE OR REPLACE PROCEDURE show_table_status(IN p_schema VARCHAR(64))
    BEGIN
        SELECT 
            Name as 'Table',
            Engine,
            Version,
            Row_format as 'Row Format',
            Rows,
            Avg_row_length as 'Avg Row Length',
            Data_length as 'Data Length',
            Max_data_length as 'Max Data Length',
            Index_length as 'Index Length',
            Data_free as 'Free Space',
            Auto_increment as 'Next Auto Inc',
            Create_time as 'Created',
            Update_time as 'Updated',
            Check_time as 'Checked',
            Collation,
            Create_options as 'Options'
        FROM information_schema.TABLES
        WHERE table_schema = COALESCE(p_schema, DATABASE());
    END //

    -- Function to format size in bytes to human readable
    CREATE OR REPLACE FUNCTION format_bytes(bytes BIGINT)
    RETURNS VARCHAR(20)
    DETERMINISTIC
    BEGIN
        DECLARE unit VARCHAR(5);
        DECLARE value DECIMAL(10,2);
        
        IF bytes >= 1099511627776 THEN
            SET unit = 'TB';
            SET value = bytes / 1099511627776;
        ELSEIF bytes >= 1073741824 THEN
            SET unit = 'GB';
            SET value = bytes / 1073741824;
        ELSEIF bytes >= 1048576 THEN
            SET unit = 'MB';
            SET value = bytes / 1048576;
        ELSEIF bytes >= 1024 THEN
            SET unit = 'KB';
            SET value = bytes / 1024;
        ELSE
            SET unit = 'B';
            SET value = bytes;
        END IF;
        
        RETURN CONCAT(ROUND(value, 2), ' ', unit);
    END //

    DELIMITER ;

    -- Create views for monitoring
    CREATE OR REPLACE VIEW v_table_statistics AS
    SELECT 
        table_schema as \`database\`,
        table_name as \`table\`,
        table_rows as rows,
        format_bytes(data_length) as data_size,
        format_bytes(index_length) as index_size,
        format_bytes(data_length + index_length) as total_size
    FROM information_schema.TABLES
    WHERE table_schema NOT IN ('information_schema', 'mysql', 'performance_schema');

    -- Grant access to developer user
    GRANT EXECUTE ON dev_utils.* TO 'developer'@'%';
    GRANT EXECUTE ON dev_utils.* TO 'developer'@'localhost';

    -- Enable additional features for development
    SET GLOBAL slow_query_log = 1;
    SET GLOBAL long_query_time = 2;
    SET GLOBAL log_queries_not_using_indexes = 1;
    SET GLOBAL general_log = 1;

    -- Create admin user for development tools
    CREATE USER IF NOT EXISTS 'admin'@'%'
    IDENTIFIED BY 'admin_password';
    GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%'
    WITH GRANT OPTION;

    FLUSH PRIVILEGES;
EOSQL

echo "Development environment initialization completed successfully"
