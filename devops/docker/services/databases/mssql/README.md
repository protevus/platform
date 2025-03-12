# SQL Server Service Module

This module provides a Microsoft SQL Server optimized for development environments. It includes development-friendly defaults, monitoring tools, and utility scripts for common development tasks.

## Features

- Multiple SQL Server versions support (2017, 2019, 2022)
- Development-optimized configuration
- Query Store enabled
- Performance monitoring tools
- Development utility scripts
- Backup and restore utilities
- Health monitoring
- Index management tools

## Configuration

### Basic Configuration

```yaml
services:
  databases:
    mssql:
      enabled: true
      version: "2022"
      config:
        port: 1433
        memory_limit: "2GB"
        max_degree_of_parallelism: 2
        tempdb_files: 4
```

### Environment Variables

#### Required Variables
- `ACCEPT_EULA` - Accept SQL Server EULA (Y/N)
- `MSSQL_SA_PASSWORD` - SA user password

#### Optional Variables
- `MSSQL_PID` - SQL Server edition/product key
- `DEV_DB_NAME` - Development database name
- `DEV_DB_USER` - Development database user
- `DEV_DB_PASSWORD` - Development database password
- `CREATE_TEST_DB` - Create test database (true/false)
- `MSSQL_COLLATION` - Server collation
- `MSSQL_MEMORY_LIMIT_MB` - Memory limit in MB
- `MSSQL_AGENT_ENABLED` - Enable SQL Server Agent
- `TZ` - Container timezone

### Configuration Options

#### Memory Settings
- `max_server_memory` - Maximum server memory (MB)
- `min_server_memory` - Minimum server memory (MB)
- `memory_limit` - Container memory limit

#### Performance Settings
- `max_degree_of_parallelism` - MAXDOP setting
- `cost_threshold_for_parallelism` - Cost threshold
- `query_governor_cost_limit` - Query governor limit

#### TempDB Settings
- `tempdb_files` - Number of tempdb data files
- `tempdb_file_size` - Initial size of tempdb files
- `tempdb_file_growth` - Growth increment for tempdb files

## Usage

### Starting the Service

```bash
# Start SQL Server service
dev up mssql

# Start with specific configuration
dev configure mssql --config "memory_limit=4GB&max_degree_of_parallelism=4"
```

### Development Utilities

#### Performance Monitoring
```bash
# Monitor performance counters
dev exec mssql mssql-monitor performance

# Monitor blocking sessions
dev exec mssql mssql-monitor blocking

# Monitor I/O statistics
dev exec mssql mssql-monitor io

# Monitor memory usage
dev exec mssql mssql-monitor memory
```

#### Performance Analysis
```bash
# Analyze expensive queries
dev exec mssql mssql-analyze expensive-queries

# Analyze index usage
dev exec mssql mssql-analyze index-usage

# Analyze table sizes
dev exec mssql mssql-analyze table-sizes
```

#### Database Management
```bash
# Shrink transaction log
dev exec mssql mssql-utils shrink-log development

# Rebuild all indexes
dev exec mssql mssql-utils rebuild-indexes development

# Update statistics
dev exec mssql mssql-utils update-stats development
```

### Development Features

#### Query Store

The development database has Query Store enabled with optimized settings:
- Operation Mode: Read Write
- Data Flush Interval: 60 seconds
- Statistics Collection Interval: 5 minutes
- Stale Query Threshold: 30 days
- Max Storage Size: 1000 MB

#### Monitoring Schema

1. Query Statistics
```sql
SELECT *
FROM [monitoring].[QueryStats]
ORDER BY TotalWorkerTime DESC;
```

2. Connection Statistics
```sql
SELECT *
FROM [monitoring].[ConnectionStats]
WHERE Status = 'running';
```

3. Wait Statistics
```sql
SELECT *
FROM [monitoring].[WaitStats]
ORDER BY WaitTimeMs DESC;
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
dev exec mssql mssql-backup full development

# Create differential backup
dev exec mssql mssql-backup diff development

# Create log backup
dev exec mssql mssql-backup log development

# Restore database
dev exec mssql mssql-backup restore backup_file.bak new_db
```

## Directory Structure

```
mssql/
├── config/
│   └── mssql.conf       # SQL Server configuration
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
- Reasonable memory limits
- Multiple tempdb files
- Query Store enabled
- Optimized for ad hoc workloads
- Extended events enabled
- Performance monitoring enabled

## Troubleshooting

### Common Issues

1. Connection refused
   - Check if service is running: `dev status mssql`
   - Verify port configuration
   - Check authentication settings

2. Authentication failed
   - Verify environment variables
   - Check SA password
   - Review login permissions

3. Performance issues
   - Monitor memory usage
   - Check wait statistics
   - Review query plans
   - Analyze index usage

### Logs

```bash
# View real-time logs
dev logs mssql

# View SQL Server error log
dev exec mssql tail -f /var/opt/mssql/log/errorlog
```

## Security Notes

The default configuration is optimized for development and includes:
- SA user enabled
- Development user with db_owner rights
- Extended events enabled
- Query Store enabled
- Performance monitoring enabled

**Warning**: These settings are for development only. Do not use in production!

## Development Tools

### Monitoring Commands

```bash
# Performance monitoring
mssql-monitor performance
mssql-monitor blocking
mssql-monitor io

# Resource monitoring
mssql-monitor memory
```

### Analysis Commands

```bash
# Query analysis
mssql-analyze expensive-queries
mssql-analyze index-usage

# Storage analysis
mssql-analyze table-sizes
```

### Maintenance Commands

```bash
# Database maintenance
mssql-utils shrink-log
mssql-utils rebuild-indexes
mssql-utils update-stats
```

### Debugging

For debugging, you can:
1. Use Query Store
2. Monitor wait statistics
3. Analyze execution plans
4. Track blocking chains
5. Monitor memory clerks
