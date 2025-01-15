#!/bin/bash
set -e

# Wait for RabbitMQ to be ready
until rabbitmq-diagnostics -q ping; do
    echo "Waiting for RabbitMQ to be ready..."
    sleep 2
done

# Enable plugins
echo "Enabling plugins..."
rabbitmq-plugins enable \
    rabbitmq_management \
    rabbitmq_management_agent \
    rabbitmq_prometheus \
    rabbitmq_mqtt \
    rabbitmq_stomp \
    rabbitmq_federation \
    rabbitmq_federation_management \
    rabbitmq_shovel \
    rabbitmq_shovel_management \
    rabbitmq_delayed_message_exchange \
    rabbitmq_consistent_hash_exchange \
    rabbitmq_top \
    rabbitmq_tracing

# Wait for management plugin to be ready
until curl -s -u guest:guest http://localhost:15672/api/overview > /dev/null 2>&1; do
    echo "Waiting for management plugin to be ready..."
    sleep 2
done

# Create development user if specified
if [ -n "$DEV_USER" ] && [ -n "$DEV_PASSWORD" ]; then
    echo "Creating development user..."
    rabbitmqctl add_user "$DEV_USER" "$DEV_PASSWORD" || true
    rabbitmqctl set_user_tags "$DEV_USER" administrator
    rabbitmqctl set_permissions -p / "$DEV_USER" ".*" ".*" ".*"
fi

# Create development vhost if specified
if [ -n "$DEV_VHOST" ]; then
    echo "Creating development vhost..."
    rabbitmqctl add_vhost "$DEV_VHOST" || true
    rabbitmqctl set_permissions -p "$DEV_VHOST" "$DEV_USER" ".*" ".*" ".*"
fi

# Create test vhost if enabled
if [ "${CREATE_TEST_VHOST:-false}" = "true" ]; then
    echo "Creating test vhost..."
    rabbitmqctl add_vhost "test" || true
    rabbitmqctl set_permissions -p "test" "$DEV_USER" ".*" ".*" ".*"
fi

# Set resource limits for development
echo "Configuring resource limits..."
rabbitmqctl set_vm_memory_high_watermark 0.8
rabbitmqctl set_disk_free_limit "2GB"

# Enable tracing for development
echo "Enabling tracing..."
rabbitmqctl trace_on

# Create development exchanges and queues
echo "Setting up development resources..."
VHOST=${DEV_VHOST:-development}

# Create development exchanges
declare -a EXCHANGES=(
    "dev.topic:topic"
    "dev.direct:direct"
    "dev.fanout:fanout"
    "dev.headers:headers"
    "dev.dlx:direct"
)

for exchange in "${EXCHANGES[@]}"; do
    IFS=':' read -r name type <<< "$exchange"
    rabbitmqadmin -u "$DEV_USER" -p "$DEV_PASSWORD" declare exchange \
        --vhost="$VHOST" \
        name="$name" \
        type="$type" \
        durable=true
done

# Create development queues
declare -a QUEUES=(
    "dev.notifications:86400000"
    "dev.events:86400000"
    "dev.logs:86400000"
    "dev.dl.queue:0"
)

for queue in "${QUEUES[@]}"; do
    IFS=':' read -r name ttl <<< "$queue"
    if [ "$ttl" -eq 0 ]; then
        rabbitmqadmin -u "$DEV_USER" -p "$DEV_PASSWORD" declare queue \
            --vhost="$VHOST" \
            name="$name" \
            durable=true
    else
        rabbitmqadmin -u "$DEV_USER" -p "$DEV_PASSWORD" declare queue \
            --vhost="$VHOST" \
            name="$name" \
            durable=true \
            arguments="{\"x-message-ttl\":$ttl,\"x-queue-type\":\"classic\"}"
    fi
done

# Create bindings
declare -a BINDINGS=(
    "dev.topic:dev.notifications:notifications.#"
    "dev.topic:dev.events:events.#"
    "dev.topic:dev.logs:logs.#"
    "dev.dlx:dev.dl.queue:dead-letter"
)

for binding in "${BINDINGS[@]}"; do
    IFS=':' read -r exchange queue routing_key <<< "$binding"
    rabbitmqadmin -u "$DEV_USER" -p "$DEV_PASSWORD" declare binding \
        --vhost="$VHOST" \
        source="$exchange" \
        destination_type="queue" \
        destination="$queue" \
        routing_key="$routing_key"
done

# Set policies
echo "Setting up policies..."
rabbitmqctl set_policy -p "$VHOST" \
    "dev-ha-policy" \
    "^dev\." \
    '{"ha-mode":"all","ha-sync-mode":"automatic","message-ttl":86400000}' \
    --apply-to all \
    --priority 1

rabbitmqctl set_policy -p "$VHOST" \
    "dev-dl-policy" \
    "^(?!amq\.|dev\.dl\.).*" \
    '{"dead-letter-exchange":"dev.dlx","dead-letter-routing-key":"dead-letter"}' \
    --apply-to queues \
    --priority 2

# Enable prometheus metrics
echo "Enabling Prometheus metrics..."
rabbitmqctl set_parameter federation-upstream all '{"uri":"amqp://localhost","expires":3600000}'

# Create development utility scripts
echo "Creating utility scripts..."
cat > /usr/local/bin/rabbitmq-dev-tools <<'EOF'
#!/bin/bash
case "$1" in
    "list-queues")
        rabbitmqctl list_queues -p "${2:-/}" name messages consumers
        ;;
    "list-exchanges")
        rabbitmqctl list_exchanges -p "${2:-/}" name type
        ;;
    "list-bindings")
        rabbitmqctl list_bindings -p "${2:-/}"
        ;;
    "monitor-queue")
        watch -n 1 "rabbitmqctl list_queues -p ${2:-/} name messages consumers"
        ;;
    "trace-on")
        rabbitmqctl trace_on -p "${2:-/}"
        ;;
    "trace-off")
        rabbitmqctl trace_off -p "${2:-/}"
        ;;
    *)
        echo "Usage: $0 {list-queues|list-exchanges|list-bindings|monitor-queue|trace-on|trace-off} [vhost]"
        exit 1
        ;;
esac
EOF
chmod +x /usr/local/bin/rabbitmq-dev-tools

echo "Development environment initialization completed successfully"
