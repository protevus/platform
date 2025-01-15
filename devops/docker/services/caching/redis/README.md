# Redis Service Module

This module provides a Redis in-memory data structure store optimized for development environments. Redis is primarily used as a cache, message broker, and queue, with support for various data structures and eviction policies.

## Features

- Multiple Redis versions support (6.0, 6.2, 7.0)
- Development-optimized configuration
- Multiple eviction policies (LRU, LFU)
- Pub/Sub messaging capabilities
- Rich data structure support
- Lua scripting enabled
- Monitoring tools
- Background task processing

## Primary Use Cases

1. Caching
   - Application cache
   - Session storage
   - Page cache
   - API response cache
   - Query results cache

2. Data Structures
   - Lists (queues, stacks)
   - Sets (unique collections)
   - Sorted Sets (rankings, leaderboards)
   - Hashes (object storage)
   - Bitmaps (feature flags)
   - HyperLogLog (cardinality estimation)

3. Message Broker
   - Pub/Sub messaging
   - Stream processing
   - Event distribution
   - Real-time notifications

4. Rate Limiting
   - API rate limiting
   - Request throttling
   - Usage quotas

## Configuration

### Basic Configuration

```yaml
services:
  caching:
    redis:
      enabled: true
      version: "7.0"
      config:
        port: 6379
        maxmemory: "256mb"
        maxmemory_policy: "allkeys-lru"
```

### Environment Variables

#### Required Variables
- `REDIS_PASSWORD` - Redis password

#### Optional Variables
- `REDIS_MAX_MEMORY` - Maximum memory limit
- `REDIS_MAX_MEMORY_POLICY` - Eviction policy
- `REDIS_DATABASES` - Number of databases
- `REDIS_APPEND_ONLY` - Enable AOF persistence
- `TZ` - Container timezone

### Configuration Options

#### Memory Management
- `maxmemory` - Maximum memory limit
- `maxmemory_policy` - Eviction policy
- `maxmemory_samples` - LRU/LFU sample size
- `active_defrag` - Memory defragmentation

#### Performance Settings
- `lazyfree_lazy_eviction` - Background eviction
- `lazyfree_lazy_expire` - Background expiration
- `latency_monitor_threshold` - Latency monitoring

## Usage

### Starting the Service

```bash
# Start Redis service
dev up redis

# Start with specific configuration
dev configure redis --config "maxmemory=512mb&maxmemory_policy=volatile-lru"
```

### Development Utilities

#### Cache Management
```bash
# Monitor cache usage
redis-cli info memory

# View eviction statistics
redis-cli info stats | grep evicted

# Clear cache
redis-cli flushdb
```

#### Performance Monitoring
```bash
# Monitor real-time metrics
redis-cli monitor

# View slow log
redis-cli slowlog get

# Memory analysis
redis-cli memory stats
```

### Development Features

#### Eviction Policies

1. Least Recently Used (LRU)
```bash
# Configure LRU eviction
redis-cli config set maxmemory-policy allkeys-lru
```

2. Least Frequently Used (LFU)
```bash
# Configure LFU eviction
redis-cli config set maxmemory-policy allkeys-lfu
```

3. Time-To-Live (TTL)
```bash
# Configure TTL-based eviction
redis-cli config set maxmemory-policy volatile-ttl
```

#### Data Structure Examples

1. Caching with TTL
```bash
# Set cache with expiration
redis-cli set mykey "value" ex 3600
```

2. List Operations
```bash
# Use as queue
redis-cli lpush myqueue "job1"
redis-cli rpop myqueue
```

3. Set Operations
```bash
# Unique collections
redis-cli sadd myset "item1"
redis-cli smembers myset
```

4. Sorted Sets
```bash
# Leaderboard
redis-cli zadd leaderboard 100 "player1"
redis-cli zrange leaderboard 0 -1 withscores
```

### Monitoring and Statistics

```bash
# View cache hit/miss ratio
redis-cli info stats | grep -E "keyspace_hits|keyspace_misses"

# Monitor memory usage
redis-cli info memory

# View client connections
redis-cli info clients
```

## Directory Structure

```
redis/
├── config/
│   └── redis.conf      # Redis configuration
├── init/
│   └── init-dev.lua    # Development utilities
├── Dockerfile        # Container definition
├── manifest.yaml     # Service manifest
└── README.md        # This file
```

## Health Checks

The service includes automatic health monitoring:
- Interval: 10 seconds
- Timeout: 5 seconds
- Retries: 3
- Start period: 5 seconds

## Performance Tuning

The default configuration is optimized for development with:
- Reasonable memory limits
- Background tasks enabled
- Monitoring enabled
- Persistence enabled
- Defragmentation available

## Troubleshooting

### Common Issues

1. Memory limit reached
   - Check maxmemory setting
   - Review eviction policy
   - Monitor eviction stats
   - Analyze key space

2. High latency
   - Check slow log
   - Monitor command stats
   - Review persistence settings
   - Check network issues

3. Connection issues
   - Verify port configuration
   - Check authentication
   - Review client limits
   - Monitor connections

### Logs

```bash
# View real-time logs
dev logs redis

# View slow log
dev exec redis redis-cli slowlog get
```

## Security Notes

The default configuration is optimized for development and includes:
- Protected mode disabled
- Password authentication optional
- All interfaces bound
- Commands unrestricted

**Warning**: These settings are for development only. Do not use in production!

## Development Tools

### Monitoring Commands

```bash
# Cache monitoring
redis-cli info memory
redis-cli info stats

# Performance monitoring
redis-cli latency doctor
redis-cli slowlog get
```

### Analysis Commands

```bash
# Key space analysis
redis-cli --bigkeys
redis-cli --memkeys

# Client analysis
redis-cli client list
```

### Debugging

For debugging, you can:
1. Monitor command execution
2. Analyze memory usage
3. Track eviction stats
4. Review slow queries
5. Monitor client connections
