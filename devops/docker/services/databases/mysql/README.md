# MySQL Service Module

This module provides a MySQL database service optimized for development environments. It includes development-friendly defaults, automatic initialization, and utility procedures for common development tasks.

## Features

- Multiple MySQL versions support (5.7, 8.0)
- Automatic database and user creation
- Development-optimized configuration
- Built-in monitoring and debugging tools
- Utility procedures for common tasks
- Persistent data storage
- Automated backups support
- Health monitoring

## Configuration

### Basic Configuration

```yaml
services:
  databases:
    mysql:
      enabled: true
      version: "8.0"
      config:
        port: 3306
        max_connections: 100
        innodb_buffer_pool_size: "256M"
```

### Environment Variables

#### Required Variables
- `MYSQL_ROOT_PASSWORD` - Root user password

#### Optional Variables
- `MYSQL_DATABASE` - Default database name
- `MYSQL_USER` - Default user name
- `MYSQL_PASSWORD` - Default user password
- `DEV_DB_NAME` - Development database name
- `DEV_DB_USER` - Development database user
- `DEV_DB_PASSWORD` - Development database password
- `CREATE_TEST_DB` - Create test database (true/false)
- `TZ` - Container timezone

### Configuration Options

#### Memory Settings
- `innodb_buffer_pool_size` - Buffer pool size
- `innodb_log_file_size` - Log file size
- `key_buffer_size` - MyISAM key buffer size
- `query_cache_size` - Query cache size

#### Connection Settings
- `max_connections` - Maximum concurrent connections
- `max_allowed_packet` - Maximum packet size
- `thread_cache_size` - Thread cache size

## Usage

### Starting the Service

```bash
# Start MySQL service
dev up mysql

# Start with specific configuration
dev configure mysql --config "max_connections=200&innodb_buffer_pool_size=512M"
```

### Accessing the Database

```bash
# Using mysql client
dev exec mysql mysql -u developer -p development

# View logs
dev logs mysql

# Check status
dev status mysql
```

### Development Features

#### Utility Procedures

1. Show Table Sizes
```sql
CALL show_table_sizes();
```

2. Show Running Queries
```sql
CALL show_running_queries();
```

3. Kill Long Running Queries
```sql
CALL kill_long_queries(300); -- Kill queries running > 300 seconds
```

#### Monitoring View

```sql
SELECT * FROM v_table_statistics;
```

### Database Initialization

The service automatically:
1. Creates a development database and user
2. Sets up monitoring and logging
3. Creates utility procedures and views
4. Optionally creates a test database
5. Configures development-friendly settings

### Backup and Restore

Backup directory is mounted at `/backups` in the container.

```bash
# Create backup
dev exec mysql mysqldump -u root -p development > /backups/backup.sql

# Restore backup
dev exec mysql mysql -u root -p development < /backups/backup.sql
```

## Directory Structure

```
mysql/
├── config/
│   └── my.cnf           # Main configuration file
├── init/
│   └── 01-init-dev-db.sh # Initialization script
├── Dockerfile           # Container definition
├── manifest.yaml        # Service manifest
└── README.md           # This file
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
   - Check if service is running: `dev status mysql`
   - Verify port configuration
   - Check network settings

2. Authentication failed
   - Verify environment variables
   - Check user credentials
   - Review authentication plugin settings

3. Performance issues
   - Check InnoDB buffer pool size
   - Review slow query log
   - Monitor connection count

### Logs

```bash
# View real-time logs
dev logs mysql -f

# View last 100 lines
dev logs mysql --tail 100
```

## Security Notes

The default configuration is optimized for development and includes:
- Native password authentication
- Remote root access disabled
- Development user with limited privileges
- Extended logging enabled

**Warning**: These settings are for development only. Do not use in production!
