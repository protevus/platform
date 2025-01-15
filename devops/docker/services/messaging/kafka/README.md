# Kafka Service Module

This module provides an Apache Kafka message broker with ZooKeeper for development environments. It includes development-optimized configurations, monitoring tools, and utility scripts for common development tasks.

## Features

- Multiple Kafka versions support (3.3, 3.4, 3.5)
- Automatic topic creation and configuration
- Development utilities and monitoring tools
- Built-in health checks
- JMX monitoring support
- Persistent storage
- ZooKeeper coordination

## Configuration

### Basic Configuration

```yaml
services:
  messaging:
    kafka:
      enabled: true
      version: "3.5"
      config:
        port: 9092
        internal_port: 9093
        num_partitions: 3
        replication_factor: 1
```

### Environment Variables

#### Kafka Variables
- `KAFKA_HEAP_OPTS` - JVM heap settings
- `KAFKA_JMX_OPTS` - JMX configuration
- `KAFKA_OPTS` - Additional Kafka options
- `KAFKA_JMX_PORT` - JMX port
- `KAFKA_BROKER_ID` - Broker ID
- `KAFKA_ZOOKEEPER_CONNECT` - ZooKeeper connection string

#### ZooKeeper Variables
- `ZOOKEEPER_CLIENT_PORT` - Client port
- `ZOOKEEPER_TICK_TIME` - Base tick time
- `ZOOKEEPER_INIT_LIMIT` - Initial synchronization limit
- `ZOOKEEPER_SYNC_LIMIT` - Synchronization limit

### Configuration Options

#### Kafka Settings
- `num_partitions` - Default partition count
- `replication_factor` - Replication factor
- `log_retention_hours` - Log retention period
- `log_retention_bytes` - Log size limit

#### ZooKeeper Settings
- `autopurge_purge_interval` - Purge interval
- `autopurge_snap_retain_count` - Snapshot retention
- `max_client_connections` - Max client connections

## Usage

### Starting the Service

```bash
# Start Kafka and ZooKeeper
dev up kafka

# Start with specific configuration
dev configure kafka --config "num_partitions=5&log_retention_hours=48"
```

### Development Utilities

#### Kafka Tools

1. Topic Management
```bash
# List topics
dev exec kafka kafka-dev-tools topics

# Describe topic
dev exec kafka kafka-dev-tools describe my-topic

# View partitions
dev exec kafka kafka-dev-tools partitions my-topic

# View consumer groups
dev exec kafka kafka-dev-tools groups
```

2. Topic Creation and Configuration
```bash
# Create topic
dev exec kafka kafka-topic-manager create my-topic 3 1

# Modify topic config
dev exec kafka kafka-topic-manager config my-topic "retention.ms=86400000"

# Delete topic
dev exec kafka kafka-topic-manager delete my-topic
```

3. Monitoring
```bash
# View consumer lag
dev exec kafka kafka-monitor lag

# View broker metrics
dev exec kafka kafka-monitor metrics

# Check under-replicated partitions
dev exec kafka kafka-monitor under-replicated

# View topic sizes
dev exec kafka kafka-monitor topics-size
```

4. Console Tools
```bash
# Produce messages
dev exec kafka kafka-dev-console produce my-topic

# Consume messages
dev exec kafka kafka-dev-console consume my-topic

# Monitor consumer groups
dev exec kafka kafka-dev-console monitor
```

#### ZooKeeper Tools

1. Status Checks
```bash
# Check ZooKeeper status
dev exec zookeeper zk-dev-tools status

# View configuration
dev exec zookeeper zk-dev-tools conf

# Check server health
dev exec zookeeper zk-dev-tools ruok
```

2. Monitoring
```bash
# View watches
dev exec zookeeper zk-monitor watch

# View connections
dev exec zookeeper zk-monitor connections

# View statistics
dev exec zookeeper zk-monitor stats
```

### Development Topics

The service automatically creates several development topics:

1. Event Topics
   - `dev.events` - Main event topic (3 partitions)
   - `dev.notifications` - Notifications (2 partitions)
   - `dev.logs` - Application logs (2 partitions)

2. Monitoring Topics
   - `dev.metrics` - Application metrics
   - `dev.alerts` - System alerts

3. Management Topics
   - `dev.dlq` - Dead letter queue
   - `test.events` - Test events (when enabled)

### Backup and Restore

```bash
# Create topic backup
dev exec kafka kafka-topics.sh --bootstrap-server localhost:9092 \
    --describe --topic my-topic > /backups/my-topic-config.txt

# Restore topic
dev exec kafka kafka-topics.sh --bootstrap-server localhost:9092 \
    --create --if-not-exists --topic my-topic \
    --config-file /backups/my-topic-config.txt
```

## Directory Structure

```
kafka/
├── config/
│   └── server.properties    # Kafka configuration
├── init/
│   └── 01-init-dev-topics.sh # Topic initialization
├── Dockerfile              # Kafka container definition
├── manifest.yaml          # Service manifest
└── README.md             # This file

zookeeper/
├── config/
│   └── zoo.cfg            # ZooKeeper configuration
├── Dockerfile            # ZooKeeper container definition
└── manifest.yaml        # Service manifest
```

## Health Checks

Both Kafka and ZooKeeper include automatic health monitoring:
- Interval: 10 seconds
- Timeout: 5 seconds
- Start period: 30 seconds
- Retries: 3

## Performance Tuning

The default configuration is optimized for development with:
- Reasonable memory allocation
- Development-friendly timeouts
- Extended logging
- Monitoring enabled
- Fast leader election

## Troubleshooting

### Common Issues

1. Connection Issues
   - Check if both Kafka and ZooKeeper are running
   - Verify port configurations
   - Check network settings

2. Topic Creation Fails
   - Verify ZooKeeper connection
   - Check broker status
   - Review partition/replica settings

3. Performance Issues
   - Monitor consumer lag
   - Check broker metrics
   - Review topic configurations

### Logs

```bash
# View Kafka logs
dev logs kafka

# View ZooKeeper logs
dev logs zookeeper

# View specific topic
dev exec kafka kafka-topics.sh --bootstrap-server localhost:9092 \
    --describe --topic my-topic
```

## Security Notes

The default configuration is optimized for development and includes:
- PLAINTEXT listeners enabled
- No authentication required
- All development commands enabled
- Extended logging
- JMX monitoring enabled

**Warning**: These settings are for development only. Do not use in production!

## Development Tools

### Monitoring Commands

```bash
# Topic monitoring
kafka-dev-tools topics
kafka-dev-tools describe my-topic

# Consumer group monitoring
kafka-dev-tools groups
kafka-dev-tools group-info my-group

# Performance monitoring
kafka-monitor metrics
kafka-monitor lag
```

### Utility Scripts

```bash
# Topic management
kafka-topic-manager create my-topic 3 1
kafka-topic-manager config my-topic "retention.ms=86400000"

# ZooKeeper management
zk-dev-tools status
zk-monitor stats
```

### Debugging

For debugging, you can:
1. Use the built-in monitoring tools
2. Enable verbose logging
3. Monitor consumer lag
4. Track topic metrics
5. Analyze broker performance
