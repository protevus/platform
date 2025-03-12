ARG VERSION
FROM redis:${VERSION}

LABEL maintainer="DevOps Team"
LABEL description="Redis server for development"

# Install additional tools
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "deb http://deb.debian.org/debian bullseye main" > /etc/apt/sources.list && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        procps \
        vim \
        netcat \
        gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /data /backups /var/log/redis /var/run/redis \
    && chown -R redis:redis /data /backups /var/log/redis /var/run/redis

# Copy configuration
COPY config/redis.conf /etc/redis/redis.conf.template
RUN chown redis:redis /etc/redis/redis.conf.template && chmod 644 /etc/redis/redis.conf.template

# Create script to substitute environment variables
RUN echo '#!/bin/sh\n\
envsubst < /etc/redis/redis.conf.template > /etc/redis/redis.conf\n\
chown redis:redis /etc/redis/redis.conf\n\
chmod 644 /etc/redis/redis.conf\n\
exec "$@"' > /usr/local/bin/docker-entrypoint.sh \
    && chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh", "redis-server", "/etc/redis/redis.conf"]

# Copy initialization scripts
COPY init/01-init-dev-utils.lua /docker-entrypoint-initdb.d/
RUN chown redis:redis /docker-entrypoint-initdb.d/01-init-dev-utils.lua \
    && chmod 644 /docker-entrypoint-initdb.d/01-init-dev-utils.lua

# Create script to initialize development utilities
RUN echo '#!/bin/sh\n\
redis-cli --eval /docker-entrypoint-initdb.d/01-init-dev-utils.lua' \
    > /usr/local/bin/init-dev-utils \
    && chmod +x /usr/local/bin/init-dev-utils

# Create script to check Redis status
RUN echo '#!/bin/sh\n\
redis-cli -a "${REDIS_PASSWORD}" ping' > /usr/local/bin/healthcheck \
    && chmod +x /usr/local/bin/healthcheck

# Create development utility scripts
RUN echo '#!/bin/sh\n\
redis-cli -a "${REDIS_PASSWORD}" --eval /docker-entrypoint-initdb.d/01-init-dev-utils.lua' \
    > /usr/local/bin/reload-dev-utils \
    && chmod +x /usr/local/bin/reload-dev-utils

# Create monitoring script
RUN echo '#!/bin/sh\n\
case "$1" in\n\
    "memory") redis-cli -a "${REDIS_PASSWORD}" EVALSHA $(redis-cli -a "${REDIS_PASSWORD}" HGET dev:scripts monitor_memory) 0 ;;\n\
    "keys") redis-cli -a "${REDIS_PASSWORD}" EVALSHA $(redis-cli -a "${REDIS_PASSWORD}" HGET dev:scripts analyze_keys) 0 "$2" "$3" ;;\n\
    "commands") redis-cli -a "${REDIS_PASSWORD}" EVALSHA $(redis-cli -a "${REDIS_PASSWORD}" HGET dev:scripts command_stats) 0 ;;\n\
    "clients") redis-cli -a "${REDIS_PASSWORD}" EVALSHA $(redis-cli -a "${REDIS_PASSWORD}" HGET dev:scripts client_monitor) 0 ;;\n\
    "big-keys") redis-cli -a "${REDIS_PASSWORD}" EVALSHA $(redis-cli -a "${REDIS_PASSWORD}" HGET dev:scripts find_big_keys) 0 "$2" "$3" ;;\n\
    *) echo "Usage: $0 {memory|keys|commands|clients|big-keys} [pattern] [limit]" ;;\n\
esac' > /usr/local/bin/redis-monitor \
    && chmod +x /usr/local/bin/redis-monitor

# Expose ports
# 6379: Redis default port
# 16379: Redis Cluster bus port (if needed)
EXPOSE 6379 16379

# Set up volumes
VOLUME ["/data", "/backups", "/var/log/redis"]

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 \
    CMD /usr/local/bin/healthcheck || exit 1
