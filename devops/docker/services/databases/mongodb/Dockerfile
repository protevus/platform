ARG VERSION
FROM mongo:${VERSION}

LABEL maintainer="DevOps Team"
LABEL description="MongoDB database server for development"

# Install additional tools
RUN apt-get update && apt-get install -y \
    netcat \
    procps \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /data/db /data/configdb /backups /var/log/mongodb /var/run/mongodb \
    && chown -R mongodb:mongodb /data/db /data/configdb /backups /var/log/mongodb /var/run/mongodb

# Copy configuration
COPY config/mongod.conf /etc/mongod.conf
RUN chown mongodb:mongodb /etc/mongod.conf && chmod 644 /etc/mongod.conf

# Copy initialization scripts
COPY init/01-init-dev-db.js /docker-entrypoint-initdb.d/
RUN chown mongodb:mongodb /docker-entrypoint-initdb.d/01-init-dev-db.js \
    && chmod 644 /docker-entrypoint-initdb.d/01-init-dev-db.js

# Create script to check MongoDB status
RUN echo '#!/bin/bash\n\
mongosh --eval "db.runCommand({ ping: 1 })"' > /usr/local/bin/healthcheck \
    && chmod +x /usr/local/bin/healthcheck

# Expose ports
# 27017: MongoDB default port
# 27018: MongoDB shard server port (if needed)
# 27019: MongoDB config server port (if needed)
EXPOSE 27017 27018 27019

# Set up volumes
VOLUME ["/data/db", "/data/configdb", "/backups", "/var/log/mongodb"]

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 \
    CMD /usr/local/bin/healthcheck || exit 1

# Set the config file location
ENV MONGODB_CONFIG_FILE=/etc/mongod.conf

# Default command
CMD ["mongod", "--config", "/etc/mongod.conf"]
