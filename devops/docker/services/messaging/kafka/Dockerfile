ARG VERSION
FROM confluentinc/cp-kafka:${VERSION}

LABEL maintainer="DevOps Team"
LABEL description="Apache Kafka broker for development"

# Install additional tools
USER root
RUN apt-get update && apt-get install -y \
    netcat \
    curl \
    jq \
    vim \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /var/lib/kafka/data /var/log/kafka /etc/kafka/config \
    && chown -R appuser:appuser /var/lib/kafka /var/log/kafka /etc/kafka

# Copy configuration
COPY config/server.properties /etc/kafka/server.properties
RUN chown appuser:appuser /etc/kafka/server.properties && chmod 644 /etc/kafka/server.properties

# Copy initialization scripts
COPY init/01-init-dev-topics.sh /docker-entrypoint-initdb.d/
RUN chown appuser:appuser /docker-entrypoint-initdb.d/01-init-dev-topics.sh \
    && chmod 755 /docker-entrypoint-initdb.d/01-init-dev-topics.sh

# Create development utility scripts
RUN echo '#!/bin/bash\n\
case "$1" in\n\
    "topics")\n\
        kafka-topics.sh --bootstrap-server localhost:9092 --list\n\
        ;;\n\
    "describe")\n\
        kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic "$2"\n\
        ;;\n\
    "groups")\n\
        kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list\n\
        ;;\n\
    "group-info")\n\
        kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group "$2"\n\
        ;;\n\
    "partitions")\n\
        kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic "$2" | grep "PartitionCount"\n\
        ;;\n\
    "leaders")\n\
        kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic "$2" | grep "Leader"\n\
        ;;\n\
    *)\n\
        echo "Usage: $0 {topics|describe|groups|group-info|partitions|leaders} [topic/group]"\n\
        exit 1\n\
        ;;\n\
esac' > /usr/local/bin/kafka-dev-tools \
    && chmod +x /usr/local/bin/kafka-dev-tools

# Create monitoring script
RUN echo '#!/bin/bash\n\
case "$1" in\n\
    "lag")\n\
        kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --all-groups | grep "TOPIC\\|GROUP"\n\
        ;;\n\
    "metrics")\n\
        kafka-run-class.sh kafka.tools.JmxTool --object-name kafka.server:type=BrokerTopicMetrics,name=* --reporting-interval 1000\n\
        ;;\n\
    "under-replicated")\n\
        kafka-topics.sh --bootstrap-server localhost:9092 --describe --under-replicated-partitions\n\
        ;;\n\
    "topics-size")\n\
        for topic in $(kafka-topics.sh --bootstrap-server localhost:9092 --list); do\n\
            echo "Topic: $topic"\n\
            kafka-log-dirs.sh --bootstrap-server localhost:9092 --topic-list "$topic" --describe | grep "size"\n\
        done\n\
        ;;\n\
    *)\n\
        echo "Usage: $0 {lag|metrics|under-replicated|topics-size}"\n\
        exit 1\n\
        ;;\n\
esac' > /usr/local/bin/kafka-monitor \
    && chmod +x /usr/local/bin/kafka-monitor

# Create topic management script
RUN echo '#!/bin/bash\n\
case "$1" in\n\
    "create")\n\
        kafka-topics.sh --bootstrap-server localhost:9092 --create --topic "$2" \\\n\
            --partitions "${3:-3}" --replication-factor "${4:-1}" \\\n\
            --config cleanup.policy=delete --config retention.ms=86400000\n\
        ;;\n\
    "delete")\n\
        kafka-topics.sh --bootstrap-server localhost:9092 --delete --topic "$2"\n\
        ;;\n\
    "alter")\n\
        kafka-topics.sh --bootstrap-server localhost:9092 --alter --topic "$2" \\\n\
            --partitions "$3"\n\
        ;;\n\
    "config")\n\
        kafka-configs.sh --bootstrap-server localhost:9092 --alter \\\n\
            --entity-type topics --entity-name "$2" --add-config "$3"\n\
        ;;\n\
    *)\n\
        echo "Usage: $0 {create|delete|alter|config} [topic] [partitions/config] [replication-factor]"\n\
        exit 1\n\
        ;;\n\
esac' > /usr/local/bin/kafka-topic-manager \
    && chmod +x /usr/local/bin/kafka-topic-manager

# Create healthcheck script
RUN echo '#!/bin/bash\n\
kafka-topics.sh --bootstrap-server localhost:9092 --list > /dev/null' > /usr/local/bin/healthcheck \
    && chmod +x /usr/local/bin/healthcheck

USER appuser

# Expose ports
# 9092: PLAINTEXT listener
# 9093: INTERNAL listener
# 9999: JMX
EXPOSE 9092 9093 9999

# Set up volumes
VOLUME ["/var/lib/kafka/data", "/var/log/kafka"]

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 \
    CMD /usr/local/bin/healthcheck || exit 1

# Default command
CMD ["kafka-server-start", "/etc/kafka/server.properties"]
