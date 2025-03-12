# MongoDB Service Module

This module provides a MongoDB database service optimized for development environments. It includes development-friendly defaults, automatic initialization, and utility functions for common development tasks.

## Features

- Multiple MongoDB versions support (4.4, 5.0, 6.0)
- Automatic database and user creation
- Development-optimized configuration
- Built-in monitoring and profiling
- Utility functions for development
- Persistent data storage
- Automated backups support
- Health monitoring

## Configuration

### Basic Configuration

```yaml
services:
  databases:
    mongodb:
      enabled: true
      version: "6.0"
      config:
        port: 27017
        wired_tiger_cache_size: "256MB"
        max_connections: 100
```

### Environment Variables

#### Required Variables
- `MONGO_INITDB_ROOT_PASSWORD` - Root password

#### Optional Variables
- `MONGO_INITDB_ROOT_USERNAME` - Root username (defaults to 'admin')
- `MONGO_INITDB_DATABASE` - Default database name
- `DEV_DB_NAME` - Development database name
- `DEV_DB_USER` - Development database user
- `DEV_DB_PASSWORD` - Development database password
- `CREATE_TEST_DB` - Create test database (true/false)
- `MONGODB_EXTRA_FLAGS` - Additional MongoDB flags

### Configuration Options

#### Memory Settings
- `wired_tiger_cache_size` - WiredTiger cache size
- `oplog_size` - Size of oplog in MB

#### Connection Settings
- `max_connections` - Maximum concurrent connections
- `port` - Port number to listen on

#### Storage Settings
- `storage_engine` - Storage engine (wiredTiger)
- `journal_enabled` - Enable journaling

## Usage

### Starting the Service

```bash
# Start MongoDB service
dev up mongodb

# Start with specific configuration
dev configure mongodb --config "max_connections=200&wired_tiger_cache_size=512MB"
```

### Accessing the Database

```bash
# Using mongosh
dev exec mongodb mongosh -u developer -p development

# View logs
dev logs mongodb

# Check status
dev status mongodb
```

### Development Features

#### Utility Functions

1. Show Collection Sizes
```javascript
db.eval('showCollectionSizes()');
```

2. Show Slow Queries
```javascript
db.eval('showSlowQueries(100)'); // Show queries slower than 100ms
```

3. Analyze Indexes
```javascript
db.eval('analyzeIndexes()');
```

4. Show Current Operations
```javascript
db.eval('showOperations()');
```

### Database Initialization

The service automatically:
1. Creates a development database and user
2. Sets up profiling and monitoring
3. Creates utility functions
4. Creates system collections and indexes
5. Optionally creates a test database

### Backup and Restore

Backup directory is mounted at `/backups` in the container.

```bash
# Create backup
dev exec mongodb mongodump --out /backups/backup-$(date +%Y%m%d)

# Restore backup
dev exec mongodb mongorestore /backups/backup-20230101
```

## Directory Structure

```
mongodb/
├── config/
│   └── mongod.conf       # Main configuration file
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
- WiredTiger storage engine
- Reasonable cache sizes
- Development-friendly logging
- Profiling enabled
- Slow query logging

## Troubleshooting

### Common Issues

1. Connection refused
   - Check if service is running: `dev status mongodb`
   - Verify port configuration
   - Check authentication settings

2. Authentication failed
   - Verify environment variables
   - Check user credentials
   - Review authorization settings

3. Performance issues
   - Check WiredTiger cache size
   - Review slow query log
   - Monitor connection count

### Logs

```bash
# View real-time logs
dev logs mongodb -f

# View last 100 lines
dev logs mongodb --tail 100
```

## Security Notes

The default configuration is optimized for development and includes:
- Authentication enabled
- JavaScript enabled
- Development user with limited privileges
- Extended logging
- Test commands enabled

**Warning**: These settings are for development only. Do not use in production!

## Development Tools

### Built-in Functions

```javascript
// Show sizes of all collections
db.eval('showCollectionSizes()');

// Analyze query performance
db.eval('showSlowQueries(100)');

// Analyze index usage
db.eval('analyzeIndexes()');

// Monitor operations
db.eval('showOperations(true)');
```

### Monitoring

The service includes:
- Slow query logging
- Operation profiling
- System metrics collection
- Index usage statistics

### Debugging

For debugging, you can:
1. Enable verbose logging in mongod.conf
2. Use the profiler to analyze queries
3. Monitor system metrics
4. Track index usage
