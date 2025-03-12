# Firebird Service Module

This module provides a Firebird SQL database server optimized for development environments. It includes development-friendly defaults, monitoring tools, and utility scripts for common development tasks.

## Features

- Multiple Firebird versions support (3.0, 4.0)
- Development-optimized configuration
- Built-in monitoring tools
- Development utility procedures
- Backup and restore utilities
- Health monitoring
- Performance analysis tools

## Configuration

### Basic Configuration

```yaml
services:
  databases:
    firebird:
      enabled: true
      version: "4.0"
      config:
        port: 3050
        architecture: "superclassic"
        page_size: 16384
        max_connections: 100
```

### Environment Variables

#### Required Variables
- `ISC_USER` - SYSDBA username
- `ISC_PASSWORD` - SYSDBA password

#### Optional Variables
- `FIREBIRD_DATABASE` - Default database name
- `DEV_DB_NAME` - Development database name
- `DEV_DB_USER` - Development database user
- `DEV_DB_PASSWORD` - Development database password
- `CREATE_TEST_DB` - Create test database (true/false)
- `FB_ARCHITECTURE` - Server architecture (SuperClassic/SuperServer)
- `TZ` - Container timezone

### Configuration Options

#### Memory Settings
- `temp_cache_limit` - Temporary cache size limit
- `page_size` - Database page size
- `max_connections` - Maximum concurrent connections

#### Connection Settings
- `wire_compression` - Enable wire protocol compression
- `wire_encryption` - Enable wire protocol encryption
- `connection_timeout` - Connection timeout

## Usage

### Starting the Service

```bash
# Start Firebird service
dev up firebird

# Start with specific configuration
dev configure firebird --config "page_size=32768&max_connections=200"
```

### Development Utilities

#### Database Monitoring
```bash
# Monitor connections
dev exec firebird firebird-monitor connections

# Monitor transactions
dev exec firebird firebird-monitor transactions

# Monitor locks
dev exec firebird firebird-monitor locks

# View I/O statistics
dev exec firebird firebird-monitor io

# View general statistics
dev exec firebird firebird-monitor stats
```

#### Database Analysis
```bash
# Analyze table structure
dev exec firebird firebird-analyze table CUSTOMERS

# View table indexes
dev exec firebird firebird-analyze indexes CUSTOMERS

# View stored procedures
dev exec firebird firebird-analyze procedure-stats

# View triggers
dev exec firebird firebird-analyze trigger-stats
```

#### Database Management
```bash
# Create new database
dev exec firebird firebird-utils create-db mydb

# List databases
dev exec firebird firebird-utils list-dbs

# Database maintenance
dev exec firebird firebird-utils gfix mydb
```

### Development Features

#### Monitoring Procedures

1. Connection Monitoring
```sql
EXECUTE PROCEDURE MONITOR_CONNECTIONS;
```

2. Transaction Monitoring
```sql
EXECUTE PROCEDURE MONITOR_TRANSACTIONS;
```

3. Statement Monitoring
```sql
EXECUTE PROCEDURE MONITOR_STATEMENTS;
```

#### Analysis Procedures

1. Table Analysis
```sql
EXECUTE PROCEDURE ANALYZE_TABLE('CUSTOMERS');
```

2. Index Analysis
```sql
EXECUTE PROCEDURE ANALYZE_INDEXES('CUSTOMERS');
```

3. Dependency Analysis
```sql
EXECUTE PROCEDURE ANALYZE_DEPENDENCIES('CUSTOMERS');
```

### Sample Database

The service includes a sample database with:
1. Customers table
2. Orders table
3. Order Items table
4. Appropriate indexes and foreign keys
5. Monitoring tables and procedures

### Backup and Restore

```bash
# Create full backup
dev exec firebird firebird-backup backup development.fdb

# Create metadata-only backup
dev exec firebird firebird-backup metadata development.fdb

# Restore database
dev exec firebird firebird-backup restore backup_file.fbk new_db.fdb
```

## Directory Structure

```
firebird/
├── config/
│   └── firebird.conf     # Main configuration file
├── init/
│   ├── 01-init-dev-db.sql # Database initialization
│   └── 01-init-dev.sh    # Setup script
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
- Reasonable page sizes
- Development-friendly logging
- Monitoring enabled
- Performance statistics collection
- Debug information enabled

## Troubleshooting

### Common Issues

1. Connection refused
   - Check if service is running: `dev status firebird`
   - Verify port configuration
   - Check authentication settings

2. Authentication failed
   - Verify environment variables
   - Check user credentials
   - Review security database

3. Performance issues
   - Monitor page cache
   - Check I/O statistics
   - Review transaction logs
   - Analyze statement execution

### Logs

```bash
# View real-time logs
dev logs firebird

# View specific logs
dev exec firebird tail -f /firebird/logs/firebird.log
```

## Security Notes

The default configuration is optimized for development and includes:
- Full database access enabled
- Development user with admin rights
- Extended logging enabled
- Monitoring enabled
- Wire compression enabled

**Warning**: These settings are for development only. Do not use in production!

## Development Tools

### Monitoring Commands

```bash
# Database monitoring
firebird-monitor stats
firebird-monitor connections
firebird-monitor transactions

# Performance monitoring
firebird-monitor io
firebird-monitor locks
```

### Analysis Commands

```bash
# Structure analysis
firebird-analyze table-stats
firebird-analyze index-stats

# Object analysis
firebird-analyze procedure-stats
firebird-analyze trigger-stats
```

### Debugging

For debugging, you can:
1. Use monitoring procedures
2. Analyze execution plans
3. Track transaction logs
4. Monitor I/O statistics
5. View connection details
