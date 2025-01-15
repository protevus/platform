#!/bin/bash
set -e

# Function to create a user and database
create_user_and_db() {
    local db=$1
    local user=$2
    local password=$3
    
    echo "Creating database '$db' and user '$user'..."
    
    # Create user if it doesn't exist
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        DO \$\$
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '$user') THEN
                CREATE USER $user WITH PASSWORD '$password';
            END IF;
        END
        \$\$;
        
        CREATE DATABASE $db;
        GRANT ALL PRIVILEGES ON DATABASE $db TO $user;
        
        -- Connect to the new database and set up extensions
        \c $db
        
        -- Common extensions
        CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
        CREATE EXTENSION IF NOT EXISTS "hstore";
        CREATE EXTENSION IF NOT EXISTS "pg_trgm";
        CREATE EXTENSION IF NOT EXISTS "btree_gin";
        CREATE EXTENSION IF NOT EXISTS "btree_gist";
        
        -- Grant permissions to the user
        GRANT ALL ON ALL TABLES IN SCHEMA public TO $user;
        GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO $user;
        GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO $user;
        
        -- Set default privileges for future objects
        ALTER DEFAULT PRIVILEGES IN SCHEMA public
            GRANT ALL ON TABLES TO $user;
        ALTER DEFAULT PRIVILEGES IN SCHEMA public
            GRANT ALL ON SEQUENCES TO $user;
        ALTER DEFAULT PRIVILEGES IN SCHEMA public
            GRANT ALL ON FUNCTIONS TO $user;
EOSQL
    
    echo "Database '$db' and user '$user' created successfully"
}

# Default development database setup
if [ -n "$DEV_DB_NAME" ] && [ -n "$DEV_DB_USER" ] && [ -n "$DEV_DB_PASSWORD" ]; then
    create_user_and_db "$DEV_DB_NAME" "$DEV_DB_USER" "$DEV_DB_PASSWORD"
else
    # Create default development database if environment variables are not set
    create_user_and_db "development" "developer" "developer_password"
fi

# Create test database if TEST_DB is enabled
if [ "${CREATE_TEST_DB:-false}" = "true" ]; then
    create_user_and_db "test" "tester" "test_password"
fi

echo "Database initialization completed"
