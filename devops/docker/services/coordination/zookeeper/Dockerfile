ARG VERSION
FROM confluentinc/cp-zookeeper:${VERSION}

LABEL maintainer="DevOps Team"
LABEL description="ZooKeeper server for Kafka development environment"

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
RUN mkdir -p /data /datalog /logs /conf \
    && chown -R appuser:appuser /data /datalog /logs /conf

# Copy configuration
COPY config/zoo.cfg /etc/zookeeper/zoo.cfg
RUN chown appuser:appuser /etc/zookeeper/zoo.cfg && chmod 644 /etc/zookeeper/zoo.cfg

# Create development utility scripts
RUN echo '#!/bin/bash\n\
case "$1" in\n\
    "status")\n\
        echo stat | nc localhost 2181\n\
        ;;\n\
    "mntr")\n\
        echo mntr | nc localhost 2181\n\
        ;;\n\
    "conf")\n\
        echo conf | nc localhost 2181\n\
        ;;\n\
    "cons")\n\
        echo cons | nc localhost 2181\n\
        ;;\n\
    "dump")\n\
        echo dump | nc localhost 2181\n\
        ;;\n\
    "ruok")\n\
        echo ruok | nc localhost 2181\n\
        ;;\n\
    "wchs")\n\
        echo wchs | nc localhost 2181\n\
        ;;\n\
    "wchc")\n\
        echo wchc | nc localhost 2181\n\
        ;;\n\
    *)\n\
        echo "Usage: $0 {status|mntr|conf|cons|dump|ruok|wchs|wchc}"\n\
        exit 1\n\
        ;;\n\
esac' > /usr/local/bin/zk-dev-tools \
    && chmod +x /usr/local/bin/zk-dev-tools

# Create monitoring script
RUN echo '#!/bin/bash\n\
case "$1" in\n\
    "watch")\n\
        echo wchs | nc localhost 2181\n\
        ;;\n\
    "connections")\n\
        echo cons | nc localhost 2181\n\
        ;;\n\
    "stats")\n\
        echo mntr | nc localhost 2181\n\
        ;;\n\
    "latency")\n\
        echo srst | nc localhost 2181\n\
        ;;\n\
    *)\n\
        echo "Usage: $0 {watch|connections|stats|latency}"\n\
        exit 1\n\
        ;;\n\
esac' > /usr/local/bin/zk-monitor \
    && chmod +x /usr/local/bin/zk-monitor

# Create healthcheck script
RUN echo '#!/bin/bash\n\
echo ruok | nc localhost 2181 | grep imok' > /usr/local/bin/healthcheck \
    && chmod +x /usr/local/bin/healthcheck

USER appuser

# Expose ports
# 2181: Client connections
# 2888: Peer communication
# 3888: Leader election
# 8080: Admin server
# 9998: JMX
EXPOSE 2181 2888 3888 8080 9998

# Set up volumes
VOLUME ["/data", "/datalog", "/logs"]

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 \
    CMD /usr/local/bin/healthcheck || exit 1

# Environment variables
ENV ZOOKEEPER_CLIENT_PORT=2181 \
    ZOOKEEPER_TICK_TIME=2000 \
    ZOOKEEPER_INIT_LIMIT=10 \
    ZOOKEEPER_SYNC_LIMIT=5 \
    ZOOKEEPER_ADMIN_ENABLE_SERVER=true \
    ZOOKEEPER_ADMIN_SERVER_PORT=8080 \
    ZOOKEEPER_MAX_CLIENT_CNXNS=60 \
    ZOOKEEPER_4LW_COMMANDS_WHITELIST=mntr,conf,ruok \
    ZOOKEEPER_AUTOPURGE_PURGEINTERVAL=24 \
    ZOOKEEPER_AUTOPURGE_SNAPRETAINCOUNT=3 \
    KAFKA_OPTS="-Djava.security.auth.login.config=/etc/zookeeper/zookeeper_jaas.conf"

# Default command
CMD ["/etc/confluent/docker/run"]
