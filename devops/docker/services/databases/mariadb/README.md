# MariaDB Service Module

This module provides a MariaDB database server optimized for development environments. It includes development-friendly defaults, monitoring tools, and utility procedures for common development tasks.

## Features

- Multiple MariaDB versions support (10.9, 10.10, 10.11)
- Development-optimized configuration
- Built-in monitoring and profiling
- Development utility procedures
- Backup and restore tools
- Health monitoring
- Persistent storage

## Configuration

### Basic Configuration

```yaml
services:
  databases:
    mariadb:
      enabled: true
      version: "10.11"
      config:
        port: 3306
        max_connections: 100
        innodb_buffer_pool_size: "256M"
```

### Environment Variables

#### Required Variables
- `MARIADB_ROOT_PASSWORD` - Root password

#### Optional Variables
- `MARIADB_DATABASE` - Default database name
- `MARIADB_USER` - Default user name
- `MARIADB_PASSWORD` - Default user password
- `DEV_DB_NAME` - Development database name
- `DEV_DB_USER` - Development database user
- `DEV_DB_PASSWORD` - Development database password
- `CREATE_TEST_DB` - Create test database (true/false)
- `TZ` - Container timezone

### Configuration Options

#### Memory Settings
- `innodb_buffer_pool_size` - InnoDB buffer pool size
- `innodb_log_file_size` - InnoDB log file size
- `key_buffer_size` - MyISAM key buffer size
- `query_cache_size` - Query cache size

#### Connection Settings
- `max_connections` - Maximum concurrent connections
- `max_allowed_packet` - Maximum packet size
- `thread_cache_size` - Thread cache size

## Usage

### Starting the Service

```bash
# Start MariaDB service
dev up mariadb

# Start with specific configuration
dev configure mariadb --config "max_connections=200&innodb_buffer_pool_size=512M"
```

### Development Utilities

#### Database Tools

1. Table Management
```bash
# Show table sizes
dev exec mariadb mariadb-dev-tools tables

# Show running queries
dev exec mariadb mariadb-dev-tools queries

# Show indexes for a schema/table
dev exec mariadb mariadb-dev-tools indexes myschema mytable

# Analyze query performance
dev exec mariadb mariadb-dev-tools analyze "SELECT * FROM mytable"

# Show table status
dev exec mariadb mariadb-dev-tools status myschema
```

2. Monitoring
```bash
# View slow queries
dev exec mariadb mariadb-monitor slow-queries

# View general log
dev exec mariadb mariadb-monitor general-log

# View error log
dev exec mariadb mariadb-monitor error-log

# Watch process list
dev exec mariadb mariadb-monitor processlist

# Show server status
dev exec mariadb mariadb-monitor status

# Show variables
dev exec mariadb mariadb-monitor variables
```

3. Backup Tools
```bash
# Full backup
dev exec mariadb mariadb-backup full

# Schema-only backup
dev exec mariadb mariadb-backup schema

# Single database backup
dev exec mariadb mariadb-backup database mydb
```

### Development Features

#### Utility Procedures

1. Show Table Sizes
```sql
CALL dev_utils.show_table_sizes();
```

2. Show Running Queries
```sql
CALL dev_utils.show_running_queries();
```

3. Show Table Indexes
```sql
CALL dev_utils.show_indexes('myschema', 'mytable');
```

4. Analyze Query Performance
```sql
CALL dev_utils.analyze_query('SELECT * FROM mytable');
```

5. Show Table Status
```sql
CALL dev_utils.show_table_status('myschema');
```

### Database Initialization

The service automatically:
1. Creates a development database and user
2. Sets up utility procedures and functions
3. Creates monitoring views
4. Optionally creates a test database
5. Configures development-friendly settings

### Backup and Restore

Backup directory is mounted at `/backups` in the container.

```bash
# Create backup
dev exec mariadb mariadb-backup full

# Restore backup
dev exec mariadb mysql -u root -p < /backups/full_backup_20230101_120000.sql
```

## Directory Structure

```
mariadb/
├── config/
│   └── my.cnf           # Main configuration file
├── init/
│   └── 01-init-dev-db.sh # Initialization script
├── Dockerfile          # Container definition
├── manifest.yaml       # Service manifest
└── README.md          # This file
```

## Health Checks

The service includes automatic health monitoring:
- Interval: 10 seconds
- Timeout: 5 seconds
- Start period: 30 seconds
- Retries: 3

## Performance Tuning

The default configuration is optimized for development with:
- InnoDB optimizations
- Query cache enabled
- Development-friendly logging
- Performance schema enabled
- Slow query logging

## Troubleshooting

### Common Issues

1. Connection refused
   - Check if service is running: `dev status mariadb`
   - Verify port configuration
   - Check authentication settings

2. Authentication failed
   - Verify environment variables
   - Check user credentials
   - Review authentication settings

3. Performance issues
   - Monitor slow queries
   - Check InnoDB buffer pool usage
   - Review table indexes
   - Analyze query performance

### Logs

```bash
# View real-time logs
dev logs mariadb

# View slow queries
dev exec mariadb mariadb-monitor slow-queries

# View specific database
dev exec mariadb mysql -u developer -p development
```

## Security Notes

The default configuration is optimized for development and includes:
- Remote root access disabled
- Development user with limited privileges
- Extended logging enabled
- Performance schema enabled
- Query analysis tools enabled

**Warning**: These settings are for development only. Do not use in production!

## Development Tools

### Monitoring Commands

```bash
# Database monitoring
mariadb-dev-tools tables
mariadb-dev-tools queries

# Performance monitoring
mariadb-monitor slow-queries
mariadb-monitor processlist

# Server status
mariadb-monitor status
mariadb-monitor variables
```

### Backup Commands

```bash
# Full backup
mariadb-backup full

# Schema backup
mariadb-backup schema

# Database backup
mariadb-backup database mydb
```

### Debugging

For debugging, you can:
1. Use the built-in monitoring tools
2. Enable verbose logging
3. Monitor slow queries
4. Analyze query performance
5. Track table statistics
