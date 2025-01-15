# ZooKeeper Service Module

This module provides an Apache ZooKeeper service optimized for development environments. ZooKeeper is a centralized service for maintaining configuration information, naming, providing distributed synchronization, and providing group services.

## Features

- Multiple ZooKeeper versions support (3.7, 3.8, 3.9)
- Development-optimized configuration
- Built-in monitoring tools
- Four-letter words commands enabled
- JMX monitoring support
- Health monitoring
- Admin server interface

## Primary Use Cases

1. Configuration Management
   - Centralized configuration
   - Dynamic configuration updates
   - Configuration versioning

2. Leader Election
   - Distributed leader election
   - Leader failover handling
   - Election state monitoring

3. Distributed Synchronization
   - Distributed locks
   - Barriers
   - Queues
   - Two-phase commit

4. Service Discovery
   - Service registration
   - Service health monitoring
   - Dynamic service discovery

## Configuration

### Basic Configuration

```yaml
services:
  coordination:
    zookeeper:
      enabled: true
      version: "3.9"
      config:
        client_port: 2181
        tick_time: 2000
        init_limit: 10
        sync_limit: 5
```

### Environment Variables

#### Required Variables
- `ZOO_MY_ID` - Server ID in cluster

#### Optional Variables
- `ZOO_SERVERS` - Server list for clustering
- `ZOO_STANDALONE_ENABLED` - Enable standalone mode
- `ZOO_ADMINSERVER_ENABLED` - Enable admin server
- `ZOO_4LW_COMMANDS_WHITELIST` - Enabled four letter words
- `JVMFLAGS` - JVM configuration
- `TZ` - Container timezone

### Configuration Options

#### Performance Settings
- `tick_time` - Basic time unit in milliseconds
- `init_limit` - Follower connection timeout in ticks
- `sync_limit` - Follower sync timeout in ticks

#### Connection Settings
- `max_client_connections` - Maximum client connections
- `max_session_timeout` - Maximum session timeout
- `min_session_timeout` - Minimum session timeout

## Usage

### Starting the Service

```bash
# Start ZooKeeper service
dev up zookeeper

# Start with specific configuration
dev configure zookeeper --config "heap_size=2G&max_client_connections=100"
```

### Development Utilities

#### Service Monitoring
```bash
# Check server status
echo ruok | nc localhost 2181

# Get server configuration
echo conf | nc localhost 2181

# Monitor server statistics
echo mntr | nc localhost 2181

# Get environment information
echo envi | nc localhost 2181

# Get server statistics
echo stat | nc localhost 2181
```

#### JMX Monitoring
```bash
# Connect to JMX port
jconsole localhost:9998
```

### Development Features

#### Admin Server Interface

The admin server provides a web interface at `http://localhost:8080` with:
- Server status
- Server configuration
- Performance metrics
- Connection information

#### Four Letter Words Commands

Enabled commands for monitoring and diagnostics:
- `mntr` - Server statistics
- `conf` - Server configuration
- `ruok` - Server status check
- `stat` - Connection statistics
- `envi` - Environment information

### Cluster Configuration

For development clustering:

```yaml
environment:
  ZOO_MY_ID: 1
  ZOO_SERVERS: server.1=localhost:2888:3888;2181 server.2=zoo2:2888:3888;2181 server.3=zoo3:2888:3888;2181
```

## Directory Structure

```
zookeeper/
├── config/
│   └── zoo.cfg         # ZooKeeper configuration
├── Dockerfile        # Container definition
├── manifest.yaml     # Service manifest
└── README.md        # This file
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
- Quick session timeouts
- Enabled monitoring
- Admin server enabled
- Four letter words enabled

## Troubleshooting

### Common Issues

1. Connection refused
   - Check if service is running: `dev status zookeeper`
   - Verify port configuration
   - Check network connectivity

2. Session expired
   - Check session timeout settings
   - Monitor client connections
   - Review server logs

3. Performance issues
   - Monitor JVM heap usage
   - Check snapshot count
   - Review transaction logs
   - Analyze connection count

### Logs

```bash
# View real-time logs
dev logs zookeeper

# View specific logs
dev exec zookeeper tail -f /logs/zookeeper.log
```

## Security Notes

The default configuration is optimized for development and includes:
- Admin server enabled
- Four letter words enabled
- JMX monitoring enabled
- No authentication required
- No encryption enabled

**Warning**: These settings are for development only. Do not use in production!

## Development Tools

### Monitoring Commands

```bash
# Server monitoring
echo mntr | nc localhost 2181
echo stat | nc localhost 2181

# Configuration monitoring
echo conf | nc localhost 2181
echo envi | nc localhost 2181
```

### JMX Monitoring

```bash
# Memory monitoring
jconsole localhost:9998

# Performance metrics
jconsole localhost:9998 -> MBeans -> org.apache.ZooKeeper
```

### Debugging

For debugging, you can:
1. Use Admin Server interface
2. Monitor JMX metrics
3. Use four letter words
4. Track connection states
5. Monitor transaction logs
