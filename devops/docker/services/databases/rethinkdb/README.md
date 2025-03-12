# RethinkDB Service Module

This module provides a RethinkDB real-time database server optimized for development environments. It includes development-friendly defaults, monitoring tools, and utility scripts for common development tasks.

## Features

- Multiple RethinkDB versions support (2.3, 2.4)
- Development-optimized configuration
- Real-time change feeds monitoring
- Built-in web admin interface
- Development utility scripts
- Backup and restore tools
- Health monitoring
- Persistent storage

## Configuration

### Basic Configuration

```yaml
services:
  databases:
    rethinkdb:
      enabled: true
      version: "2.4"
      config:
        driver_port: 28015
        http_port: 8080
        cache_size: "1024"
```

### Environment Variables

#### Required Variables
- `RETHINKDB_PASSWORD` - Admin password

#### Optional Variables
- `RETHINKDB_USERNAME` - Admin username (default: admin)
- `RETHINKDB_DATABASE` - Default database name
- `DEV_DB_NAME` - Development database name
- `DEV_DB_USER` - Development database user
- `DEV_DB_PASSWORD` - Development database password
- `CREATE_TEST_DB` - Create test database (true/false)
- `RETHINKDB_CACHE_SIZE` - Cache size in MB
- `RETHINKDB_IO_THREADS` - Number of IO threads
- `TZ` - Container timezone

### Configuration Options

#### Memory Settings
- `cache_size` - Memory cache size
- `max_cache_size_mb` - Maximum cache size

#### Network Settings
- `driver_port` - Driver connection port
- `http_port` - Web admin interface port
- `cluster_port` - Cluster communication port

## Usage

### Starting the Service

```bash
# Start RethinkDB service
dev up rethinkdb

# Start with specific configuration
dev configure rethinkdb --config "cache_size=2048&io_threads=128"
```

### Development Utilities

#### Database Tools

1. Table Management
```bash
# List tables in a database
dev exec rethinkdb rethinkdb-dev-tools tables mydb

# Show table information
dev exec rethinkdb rethinkdb-dev-tools info mydb mytable

# List indexes
dev exec rethinkdb rethinkdb-dev-tools indexes mydb mytable

# Show server status
dev exec rethinkdb rethinkdb-dev-tools status
```

2. Monitoring
```bash
# View server statistics
dev exec rethinkdb rethinkdb-monitor stats

# View running jobs
dev exec rethinkdb rethinkdb-monitor jobs

# View recent logs
dev exec rethinkdb rethinkdb-monitor logs

# View current issues
dev exec rethinkdb rethinkdb-monitor issues
```

3. Backup Tools
```bash
# Full database dump
dev exec rethinkdb rethinkdb-backup dump

# Export specific database
dev exec rethinkdb rethinkdb-backup export mydb

# Restore from backup
dev exec rethinkdb rethinkdb-backup restore /backups/dump_20230101_120000.tar.gz
```

### Web Admin Interface

The RethinkDB web interface is available at `http://localhost:8080` and provides:
- Real-time cluster monitoring
- Query explorer
- Table management
- Performance metrics
- Log viewer

### Development Features

#### Real-time Capabilities

RethinkDB's real-time features are enabled by default:

1. Change Feeds
```javascript
r.table('users').changes().run(conn, function(err, cursor) {
    cursor.each(function(err, change) {
        console.log(change);
    });
});
```

2. Real-time Monitoring
```javascript
// Monitor server statistics
r.db('rethinkdb').table('stats').changes().run(conn);

// Monitor current issues
r.db('rethinkdb').table('current_issues').changes().run(conn);
```

### Database Initialization

The service automatically:
1. Creates a development database
2. Sets up monitoring tables
3. Creates utility functions
4. Optionally creates a test database
5. Configures development-friendly settings

### Backup and Restore

Backup directory is mounted at `/backups` in the container.

```bash
# Create backup
dev exec rethinkdb rethinkdb-backup dump

# Restore backup
dev exec rethinkdb rethinkdb-backup restore /backups/dump_20230101_120000.tar.gz
```

## Directory Structure

```
rethinkdb/
├── config/
│   └── rethinkdb.conf    # Main configuration file
├── init/
│   └── 01-init-dev-db.js # Initialization script
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
- Reasonable cache sizes
- Development-friendly timeouts
- Extended logging
- Real-time monitoring enabled
- Web interface enabled

## Troubleshooting

### Common Issues

1. Connection refused
   - Check if service is running: `dev status rethinkdb`
   - Verify port configuration
   - Check authentication settings

2. Authentication failed
   - Verify environment variables
   - Check user credentials
   - Review authentication settings

3. Performance issues
   - Monitor cache usage
   - Check IO thread utilization
   - Review table indexes
   - Analyze query performance

### Logs

```bash
# View real-time logs
dev logs rethinkdb

# View job logs
dev exec rethinkdb rethinkdb-monitor logs

# View current issues
dev exec rethinkdb rethinkdb-monitor issues
```

## Security Notes

The default configuration is optimized for development and includes:
- Web admin interface enabled
- Development user with full access
- Extended logging enabled
- Real-time monitoring enabled
- All ports exposed

**Warning**: These settings are for development only. Do not use in production!

## Development Tools

### Monitoring Commands

```bash
# Server monitoring
rethinkdb-monitor stats
rethinkdb-monitor jobs

# Database monitoring
rethinkdb-dev-tools tables mydb
rethinkdb-dev-tools info mydb mytable
```

### Backup Commands

```bash
# Full backup
rethinkdb-backup dump

# Database export
rethinkdb-backup export mydb

# Restore backup
rethinkdb-backup restore backup_file.tar.gz
```

### Debugging

For debugging, you can:
1. Use the web admin interface
2. Monitor real-time changes
3. Track server statistics
4. Analyze query performance
5. View system logs
