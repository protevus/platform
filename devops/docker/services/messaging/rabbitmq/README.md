# RabbitMQ Service Module

This module provides a RabbitMQ message broker optimized for development environments. It includes development-friendly defaults, monitoring tools, and utility scripts for common development tasks.

## Features

- Multiple RabbitMQ versions support (3.10, 3.11, 3.12)
- Development-optimized configuration
- Built-in management interface
- Multiple protocol support (AMQP, MQTT, STOMP)
- Development utility scripts
- Monitoring and tracing tools
- Backup and restore utilities
- Health monitoring
- Prometheus metrics

## Configuration

### Basic Configuration

```yaml
services:
  messaging:
    rabbitmq:
      enabled: true
      version: "3.12"
      config:
        amqp_port: 5672
        management_port: 15672
        mqtt_port: 1883
        stomp_port: 61613
```

### Environment Variables

#### Required Variables
- `RABBITMQ_DEFAULT_USER` - Default admin username
- `RABBITMQ_DEFAULT_PASS` - Default admin password

#### Optional Variables
- `DEV_USER` - Development user name
- `DEV_PASSWORD` - Development user password
- `DEV_VHOST` - Development virtual host
- `CREATE_TEST_VHOST` - Create test virtual host (true/false)
- `RABBITMQ_ERLANG_COOKIE` - Erlang cookie for clustering
- `TZ` - Container timezone

### Configuration Options

#### Memory Settings
- `memory_high_watermark` - Memory high watermark
- `vm_memory_high_watermark_paging_ratio` - Memory paging ratio
- `disk_free_limit` - Free disk space limit

#### Connection Settings
- `channel_max` - Maximum number of channels per connection
- `heartbeat` - Connection heartbeat timeout
- `default_vhost` - Default virtual host

## Usage

### Starting the Service

```bash
# Start RabbitMQ service
dev up rabbitmq

# Start with specific configuration
dev configure rabbitmq --config "memory_high_watermark=0.6&channel_max=2048"
```

### Development Utilities

#### Queue Management
```bash
# List queues
dev exec rabbitmq rabbitmq-monitor queues

# List connections
dev exec rabbitmq rabbitmq-monitor connections

# List channels
dev exec rabbitmq rabbitmq-monitor channels

# List exchanges
dev exec rabbitmq rabbitmq-monitor exchanges

# List bindings
dev exec rabbitmq rabbitmq-monitor bindings

# List consumers
dev exec rabbitmq rabbitmq-monitor consumers

# Show overview
dev exec rabbitmq rabbitmq-monitor overview
```

#### Exchange and Queue Operations
```bash
# Declare exchange
dev exec rabbitmq rabbitmq-utils declare-exchange development my-exchange topic

# Declare queue
dev exec rabbitmq rabbitmq-utils declare-queue development my-queue

# Create binding
dev exec rabbitmq rabbitmq-utils bind development my-exchange my-queue "my.routing.key"

# Publish message
dev exec rabbitmq rabbitmq-utils publish development my-exchange "my.routing.key" "Hello World"

# Get messages
dev exec rabbitmq rabbitmq-utils get my-queue development 10
```

### Development Features

#### Pre-configured Resources

1. Exchanges:
   - `dev.topic` - Topic exchange for pub/sub
   - `dev.direct` - Direct exchange for routing
   - `dev.fanout` - Fanout exchange for broadcasting
   - `dev.headers` - Headers exchange for header-based routing
   - `dev.dlx` - Dead letter exchange

2. Queues:
   - `dev.notifications` - For notification messages
   - `dev.events` - For event messages
   - `dev.logs` - For logging messages
   - `dev.dl.queue` - Dead letter queue

3. Bindings:
   - Topic bindings for notifications, events, and logs
   - Dead letter queue binding

### Management Interface

The RabbitMQ management interface is available at `http://localhost:15672` and provides:
- Queue, exchange, and binding management
- Message rates and metrics
- Connection and channel monitoring
- Performance statistics
- User management

### Backup and Restore

```bash
# Backup definitions
dev exec rabbitmq rabbitmq-backup definitions

# Backup messages
dev exec rabbitmq rabbitmq-backup messages

# Restore definitions
dev exec rabbitmq rabbitmq-backup restore-definitions /backups/definitions_20230101_120000.json
```

## Directory Structure

```
rabbitmq/
├── config/
│   ├── rabbitmq.conf       # Main configuration
│   ├── advanced.config     # Advanced Erlang configuration
│   └── definitions.json    # Pre-defined resources
├── init/
│   └── 01-init-dev.sh     # Initialization script
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

The default configuration is optimized for development with:
- Reasonable memory limits
- Development-friendly persistence
- Extended logging
- Monitoring enabled
- Management interface enabled

## Troubleshooting

### Common Issues

1. Connection refused
   - Check if service is running: `dev status rabbitmq`
   - Verify port configuration
   - Check authentication settings

2. Authentication failed
   - Verify environment variables
   - Check user credentials
   - Review permissions

3. Performance issues
   - Monitor memory usage
   - Check disk space
   - Review queue lengths
   - Analyze consumer counts

### Logs

```bash
# View real-time logs
dev logs rabbitmq

# View specific logs
dev exec rabbitmq tail -f /var/log/rabbitmq/rabbit@localhost.log
```

## Security Notes

The default configuration is optimized for development and includes:
- Management interface enabled
- Development user with full access
- Extended logging enabled
- All protocols enabled
- MQTT anonymous access enabled

**Warning**: These settings are for development only. Do not use in production!

## Development Tools

### Monitoring Commands

```bash
# Queue monitoring
rabbitmq-monitor queues
rabbitmq-monitor consumers

# Connection monitoring
rabbitmq-monitor connections
rabbitmq-monitor channels

# System monitoring
rabbitmq-monitor overview
```

### Utility Commands

```bash
# Resource management
rabbitmq-utils declare-exchange
rabbitmq-utils declare-queue
rabbitmq-utils bind

# Message operations
rabbitmq-utils publish
rabbitmq-utils get
```

### Debugging

For debugging, you can:
1. Use the management interface
2. Monitor queue statistics
3. Track consumer activity
4. View connection details
5. Analyze message rates
