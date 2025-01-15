# PostgreSQL Service Module

This module provides a PostgreSQL database service optimized for development environments. It includes sensible defaults, automatic initialization, and common extensions.

## Features

- Multiple PostgreSQL versions support (10, 11, 12, 13, 14)
- Automatic database and user creation
- Common PostgreSQL extensions pre-installed
- Configurable settings via environment variables
- Persistent data storage
- Automated backups support
- Health monitoring

## Configuration

### Basic Configuration

```yaml
services:
  databases:
    postgres:
      enabled: true
      version: "14"
      config:
        port: 5432
        max_connections: 100
        shared_buffers: "256MB"
```

### Environment Variables

#### Required Variables
- `POSTGRES_USER` - Superuser username
- `POSTGRES_PASSWORD` - Superuser password

#### Optional Variables
- `POSTGRES_DB` - Default database name (defaults to POSTGRES_USER)
- `DEV_DB_NAME` - Development database name
- `DEV_DB_USER` - Development database user
- `DEV_DB_PASSWORD` - Development database password
- `CREATE_TEST_DB` - Create test database (true/false)
- `POSTGRES_INITDB_ARGS` - Arguments for database initialization
- `POSTGRES_HOST_AUTH_METHOD` - Authentication method
- `PGDATA` - Data directory location

### Configuration Options

#### Memory Settings
- `shared_buffers` - Shared memory buffer size
- `work_mem` - Memory for query operations
- `maintenance_work_mem` - Memory for maintenance operations
- `effective_cache_size` - Planner's assumption about disk cache

#### Connection Settings
- `max_connections` - Maximum concurrent connections
- `port` - Port number to listen on
- `timezone` - Server timezone

## Usage

### Starting the Service

```bash
# Start PostgreSQL service
dev up postgres

# Start with specific configuration
dev configure postgres --config "max_connections=200&shared_buffers=512MB"
```

### Accessing the Database

```bash
# Using psql
dev exec postgres psql -U developer -d development

# View logs
dev logs postgres

# Check status
dev status postgres
```

### Database Initialization

The service automatically:
1. Creates a development database and user
2. Installs common extensions:
   - uuid-ossp
   - hstore
   - pg_trgm
   - btree_gin
   - btree_gist
3. Sets up proper permissions
4. Optionally creates a test database

### Backup and Restore

Backup directory is mounted at `/backups` in the container.

```bash
# Create backup
dev exec postgres pg_dump -U developer development > /backups/backup.sql

# Restore backup
dev exec postgres psql -U developer development < /backups/backup.sql
```

## Directory Structure

```
postgres/
├── config/
│   ├── postgresql.conf    # Main configuration file
│   └── pg_hba.conf       # Client authentication config
├── init/
│   └── 01-init-dev-db.sh # Initialization script
├── Dockerfile            # Container definition
├── manifest.yaml         # Service manifest
└── README.md            # This file
```

## Health Checks

The service includes automatic health monitoring:
- Interval: 10 seconds
- Timeout: 5 seconds
- Start period: 30 seconds
- Retries: 3

## Performance Tuning

The default configuration is optimized for development environments with:
- Reasonable memory allocation
- Development-friendly logging
- Extended query analysis
- Automatic vacuuming
- Query plan debugging

## Troubleshooting

### Common Issues

1. Connection refused
   - Check if the service is running: `dev status postgres`
   - Verify port configuration
   - Check authentication settings in pg_hba.conf

2. Authentication failed
   - Verify environment variables are set correctly
   - Check user credentials
   - Review pg_hba.conf settings

3. Performance issues
   - Review memory settings
   - Check log files for slow queries
   - Verify connection count

### Logs

```bash
# View real-time logs
dev logs postgres -f

# View last 100 lines
dev logs postgres --tail 100
```

## Security Notes

The default configuration is optimized for development and includes:
- Trust authentication for local connections
- Password authentication for remote connections
- Superuser access
- Extended logging

**Warning**: Do not use these settings in production environments!
