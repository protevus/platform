ARG VERSION
FROM rabbitmq:${VERSION}-management

LABEL maintainer="DevOps Team"
LABEL description="RabbitMQ message broker for development"

# Install additional tools
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    vim \
    net-tools \
    procps \
    netcat \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /var/lib/rabbitmq /var/log/rabbitmq /etc/rabbitmq/conf.d \
    && chown -R rabbitmq:rabbitmq /var/lib/rabbitmq /var/log/rabbitmq /etc/rabbitmq

# Copy configuration files
COPY config/rabbitmq.conf /etc/rabbitmq/rabbitmq.conf
COPY config/advanced.config /etc/rabbitmq/advanced.config
COPY config/definitions.json /etc/rabbitmq/definitions.json
RUN chown rabbitmq:rabbitmq /etc/rabbitmq/rabbitmq.conf \
    /etc/rabbitmq/advanced.config \
    /etc/rabbitmq/definitions.json \
    && chmod 644 /etc/rabbitmq/rabbitmq.conf \
    /etc/rabbitmq/advanced.config \
    /etc/rabbitmq/definitions.json

# Copy initialization scripts
COPY init/01-init-dev.sh /docker-entrypoint-initdb.d/
RUN chown rabbitmq:rabbitmq /docker-entrypoint-initdb.d/01-init-dev.sh \
    && chmod 755 /docker-entrypoint-initdb.d/01-init-dev.sh

# Create monitoring script
RUN echo '#!/bin/bash\n\
case "$1" in\n\
    "queues")\n\
        rabbitmqctl list_queues -p "${2:-/}" name messages consumers memory state\n\
        ;;\n\
    "connections")\n\
        rabbitmqctl list_connections -p "${2:-/}" user peer_host state channels protocol auth_mechanism\n\
        ;;\n\
    "channels")\n\
        rabbitmqctl list_channels -p "${2:-/}" user connection consumer_count messages_unacknowledged\n\
        ;;\n\
    "exchanges")\n\
        rabbitmqctl list_exchanges -p "${2:-/}" name type durable auto_delete\n\
        ;;\n\
    "bindings")\n\
        rabbitmqctl list_bindings -p "${2:-/}"\n\
        ;;\n\
    "consumers")\n\
        rabbitmqctl list_consumers -p "${2:-/}"\n\
        ;;\n\
    "overview")\n\
        curl -s -u "$RABBITMQ_DEFAULT_USER:$RABBITMQ_DEFAULT_PASS" http://localhost:15672/api/overview | jq .\n\
        ;;\n\
    *)\n\
        echo "Usage: $0 {queues|connections|channels|exchanges|bindings|consumers|overview} [vhost]"\n\
        exit 1\n\
        ;;\n\
esac' > /usr/local/bin/rabbitmq-monitor \
    && chmod +x /usr/local/bin/rabbitmq-monitor

# Create utility script for common operations
RUN echo '#!/bin/bash\n\
case "$1" in\n\
    "declare-exchange")\n\
        rabbitmqadmin -u "$RABBITMQ_DEFAULT_USER" -p "$RABBITMQ_DEFAULT_PASS" declare exchange \\\n\
            --vhost="${2:-/}" name="$3" type="${4:-topic}" durable=true\n\
        ;;\n\
    "declare-queue")\n\
        rabbitmqadmin -u "$RABBITMQ_DEFAULT_USER" -p "$RABBITMQ_DEFAULT_PASS" declare queue \\\n\
            --vhost="${2:-/}" name="$3" durable=true\n\
        ;;\n\
    "bind")\n\
        rabbitmqadmin -u "$RABBITMQ_DEFAULT_USER" -p "$RABBITMQ_DEFAULT_PASS" declare binding \\\n\
            --vhost="${2:-/}" source="$3" destination_type="queue" \\\n\
            destination="$4" routing_key="$5"\n\
        ;;\n\
    "publish")\n\
        rabbitmqadmin -u "$RABBITMQ_DEFAULT_USER" -p "$RABBITMQ_DEFAULT_PASS" publish \\\n\
            --vhost="${2:-/}" exchange="$3" routing_key="$4" payload="$5"\n\
        ;;\n\
    "get")\n\
        rabbitmqadmin -u "$RABBITMQ_DEFAULT_USER" -p "$RABBITMQ_DEFAULT_PASS" get queue="$2" \\\n\
            --vhost="${3:-/}" count="${4:-1}"\n\
        ;;\n\
    *)\n\
        echo "Usage: $0 {declare-exchange|declare-queue|bind|publish|get} [vhost] [name] [type/key] [payload/count]"\n\
        exit 1\n\
        ;;\n\
esac' > /usr/local/bin/rabbitmq-utils \
    && chmod +x /usr/local/bin/rabbitmq-utils

# Create backup script
RUN echo '#!/bin/bash\n\
backup_dir="/backups"\n\
timestamp=$(date +%Y%m%d_%H%M%S)\n\
\n\
case "$1" in\n\
    "definitions")\n\
        curl -s -u "$RABBITMQ_DEFAULT_USER:$RABBITMQ_DEFAULT_PASS" \\\n\
            http://localhost:15672/api/definitions > "$backup_dir/definitions_$timestamp.json"\n\
        ;;\n\
    "messages")\n\
        rabbitmqadmin -u "$RABBITMQ_DEFAULT_USER" -p "$RABBITMQ_DEFAULT_PASS" \\\n\
            export "$backup_dir/messages_$timestamp.json"\n\
        ;;\n\
    "restore-definitions")\n\
        if [ -z "$2" ]; then\n\
            echo "Backup file required"\n\
            exit 1\n\
        fi\n\
        curl -s -u "$RABBITMQ_DEFAULT_USER:$RABBITMQ_DEFAULT_PASS" \\\n\
            -H "Content-Type: application/json" \\\n\
            -X POST -d @"$2" \\\n\
            http://localhost:15672/api/definitions\n\
        ;;\n\
    *)\n\
        echo "Usage: $0 {definitions|messages|restore-definitions} [file]"\n\
        exit 1\n\
        ;;\n\
esac' > /usr/local/bin/rabbitmq-backup \
    && chmod +x /usr/local/bin/rabbitmq-backup

# Create healthcheck script
RUN echo '#!/bin/bash\n\
rabbitmq-diagnostics -q ping' > /usr/local/bin/healthcheck \
    && chmod +x /usr/local/bin/healthcheck

# Expose ports
EXPOSE 5672 15672 1883 61613 15692 25672

# Set up volumes
VOLUME ["/var/lib/rabbitmq", "/var/log/rabbitmq", "/etc/rabbitmq/conf.d"]

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 \
    CMD /usr/local/bin/healthcheck || exit 1

# Default command
CMD ["rabbitmq-server"]
