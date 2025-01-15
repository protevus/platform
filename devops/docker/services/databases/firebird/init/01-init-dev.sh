#!/bin/bash
set -e

# Wait for Firebird to be ready
until isql -user sysdba -password masterkey -q -bail localhost:employee > /dev/null 2>&1; do
    echo "Waiting for Firebird to be ready..."
    sleep 2
done

# Initialize development database
echo "Initializing development database..."
isql -user sysdba -password masterkey -i /docker-entrypoint-initdb.d/01-init-dev-db.sql

# Create development utility scripts
echo "Creating utility scripts..."

# Create monitoring script
cat > /usr/local/bin/firebird-monitor <<'EOF'
#!/bin/bash
case "$1" in
    "connections")
        isql -user $ISC_USER -password $ISC_PASSWORD -q <<< "SELECT * FROM MONITOR_CONNECTIONS;"
        ;;
    "transactions")
        isql -user $ISC_USER -password $ISC_PASSWORD -q <<< "SELECT * FROM MONITOR_TRANSACTIONS;"
        ;;
    "statements")
        isql -user $ISC_USER -password $ISC_PASSWORD -q <<< "SELECT * FROM MONITOR_STATEMENTS;"
        ;;
    "stats")
        isql -user $ISC_USER -password $ISC_PASSWORD -q <<< "
            SELECT MON\$STAT_NAME, MON\$STAT_VALUE 
            FROM MON\$DATABASE_STATS;"
        ;;
    "io-stats")
        isql -user $ISC_USER -password $ISC_PASSWORD -q <<< "
            SELECT MON\$STAT_NAME, MON\$STAT_VALUE 
            FROM MON\$IO_STATS;"
        ;;
    *)
        echo "Usage: $0 {connections|transactions|statements|stats|io-stats}"
        exit 1
        ;;
esac
EOF
chmod +x /usr/local/bin/firebird-monitor

# Create database analysis script
cat > /usr/local/bin/firebird-analyze <<'EOF'
#!/bin/bash
case "$1" in
    "table")
        if [ -z "$2" ]; then
            echo "Table name required"
            exit 1
        fi
        isql -user $ISC_USER -password $ISC_PASSWORD -q <<< "
            EXECUTE PROCEDURE ANALYZE_TABLE '$2';"
        ;;
    "indexes")
        if [ -z "$2" ]; then
            echo "Table name required"
            exit 1
        fi
        isql -user $ISC_USER -password $ISC_PASSWORD -q <<< "
            EXECUTE PROCEDURE ANALYZE_INDEXES '$2';"
        ;;
    "dependencies")
        if [ -z "$2" ]; then
            echo "Object name required"
            exit 1
        fi
        isql -user $ISC_USER -password $ISC_PASSWORD -q <<< "
            EXECUTE PROCEDURE ANALYZE_DEPENDENCIES '$2';"
        ;;
    "tables")
        isql -user $ISC_USER -password $ISC_PASSWORD -q <<< "
            SELECT RDB\$RELATION_NAME FROM RDB\$RELATIONS 
            WHERE RDB\$SYSTEM_FLAG = 0 ORDER BY 1;"
        ;;
    *)
        echo "Usage: $0 {table|indexes|dependencies|tables} [name]"
        exit 1
        ;;
esac
EOF
chmod +x /usr/local/bin/firebird-analyze

# Create backup script
cat > /usr/local/bin/firebird-backup <<'EOF'
#!/bin/bash
backup_dir="/firebird/backups"
timestamp=$(date +%Y%m%d_%H%M%S)

case "$1" in
    "full")
        gbak -b -user $ISC_USER -password $ISC_PASSWORD \
            localhost:development.fdb \
            "$backup_dir/full_backup_$timestamp.fbk"
        ;;
    "metadata")
        gbak -b -user $ISC_USER -password $ISC_PASSWORD \
            -m localhost:development.fdb \
            "$backup_dir/metadata_backup_$timestamp.fbk"
        ;;
    "restore")
        if [ -z "$2" ]; then
            echo "Backup file required"
            exit 1
        fi
        gbak -c -user $ISC_USER -password $ISC_PASSWORD \
            "$2" localhost:restored_db.fdb
        ;;
    *)
        echo "Usage: $0 {full|metadata|restore} [file]"
        exit 1
        ;;
esac
EOF
chmod +x /usr/local/bin/firebird-backup

# Create database management script
cat > /usr/local/bin/firebird-utils <<'EOF'
#!/bin/bash
case "$1" in
    "create-db")
        if [ -z "$2" ]; then
            echo "Database name required"
            exit 1
        fi
        isql -user $ISC_USER -password $ISC_PASSWORD -q <<< "
            CREATE DATABASE 'localhost:$2.fdb'
            USER '$ISC_USER' PASSWORD '$ISC_PASSWORD'
            PAGE_SIZE 16384
            DEFAULT CHARACTER SET UTF8
            COLLATION UTF8;"
        ;;
    "drop-db")
        if [ -z "$2" ]; then
            echo "Database name required"
            exit 1
        fi
        isql -user $ISC_USER -password $ISC_PASSWORD -q <<< "
            DROP DATABASE;"
        ;;
    "list-dbs")
        find /firebird/data -name "*.fdb" -printf "%f\n"
        ;;
    "gfix")
        if [ -z "$2" ]; then
            echo "Database name required"
            exit 1
        fi
        gfix -user $ISC_USER -password $ISC_PASSWORD localhost:$2.fdb
        ;;
    *)
        echo "Usage: $0 {create-db|drop-db|list-dbs|gfix} [name]"
        exit 1
        ;;
esac
EOF
chmod +x /usr/local/bin/firebird-utils

echo "Development environment initialization completed successfully"
