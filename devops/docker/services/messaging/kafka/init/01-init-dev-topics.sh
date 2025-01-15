#!/bin/bash
set -e

# Wait for Kafka to be ready
until kafka-topics.sh --bootstrap-server localhost:9092 --list > /dev/null 2>&1; do
    echo "Waiting for Kafka to be ready..."
    sleep 2
done

# Function to create a topic with specific configurations
create_topic() {
    local topic=$1
    local partitions=$2
    local replication=$3
    local configs=$4

    echo "Creating topic: $topic"
    kafka-topics.sh --bootstrap-server localhost:9092 \
        --create \
        --if-not-exists \
        --topic "$topic" \
        --partitions "$partitions" \
        --replication-factor "$replication" \
        --config cleanup.policy=delete \
        --config retention.ms=86400000 \
        $configs
}

# Create development topics
echo "Creating development topics..."

# Events topic with multiple partitions for parallel processing
create_topic "dev.events" 3 1 "--config max.message.bytes=1000000"

# Logs topic with longer retention
create_topic "dev.logs" 2 1 "--config retention.ms=604800000"

# Notifications topic with smaller message size
create_topic "dev.notifications" 2 1 "--config max.message.bytes=65536"

# Dead letter queue topic
create_topic "dev.dlq" 1 1 "--config retention.ms=1209600000"

# Test topics
if [ "${CREATE_TEST_TOPICS:-true}" = "true" ]; then
    echo "Creating test topics..."
    create_topic "test.events" 3 1 ""
    create_topic "test.notifications" 2 1 ""
fi

# Create monitoring topics
echo "Creating monitoring topics..."
create_topic "dev.metrics" 1 1 "--config cleanup.policy=compact"
create_topic "dev.alerts" 1 1 "--config retention.ms=259200000"

# Set up topic monitoring
echo "Setting up topic monitoring..."
kafka-configs.sh --bootstrap-server localhost:9092 \
    --alter \
    --entity-type topics \
    --entity-name dev.events \
    --add-config segment.bytes=104857600,segment.ms=600000

# Create console consumer group for development
kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
    --group dev-console-consumer \
    --topic dev.events \
    --reset-offsets --to-earliest \
    --execute > /dev/null 2>&1 || true

# Set up JMX monitoring
if [ -n "$JMX_PORT" ]; then
    echo "Configuring JMX monitoring..."
    kafka-run-class.sh kafka.tools.JmxTool \
        --object-name kafka.server:type=BrokerTopicMetrics,name=MessagesInPerSec \
        --reporting-interval 1000 > /dev/null 2>&1 &
fi

# Create development ACLs (if security is enabled)
if [ "${KAFKA_SECURITY_ENABLED:-false}" = "true" ]; then
    echo "Setting up development ACLs..."
    kafka-acls.sh --bootstrap-server localhost:9092 \
        --add \
        --allow-principal User:developer \
        --operation All \
        --topic 'dev.*' \
        --group 'dev-*'
fi

# Print topic information
echo -e "\nCreated topics:"
kafka-topics.sh --bootstrap-server localhost:9092 --list

echo -e "\nTopic details:"
for topic in $(kafka-topics.sh --bootstrap-server localhost:9092 --list); do
    echo -e "\nTopic: $topic"
    kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic "$topic"
done

# Create utility scripts
cat > /usr/local/bin/kafka-dev-console <<'EOF'
#!/bin/bash
case "$1" in
    "produce")
        shift
        kafka-console-producer.sh --bootstrap-server localhost:9092 \
            --topic "${1:-dev.events}" \
            --property parse.key=true \
            --property key.separator=:
        ;;
    "consume")
        shift
        kafka-console-consumer.sh --bootstrap-server localhost:9092 \
            --topic "${1:-dev.events}" \
            --from-beginning \
            --property print.key=true \
            --property key.separator=: \
            --group dev-console-consumer
        ;;
    "monitor")
        shift
        kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
            --describe --all-groups
        ;;
    *)
        echo "Usage: $0 {produce|consume|monitor} [topic]"
        exit 1
        ;;
esac
EOF
chmod +x /usr/local/bin/kafka-dev-console

echo "Development environment initialization completed successfully"
