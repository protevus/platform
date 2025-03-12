ARG VERSION
FROM rethinkdb:${VERSION}

LABEL maintainer="DevOps Team"
LABEL description="RethinkDB server for development"

# Install additional tools
RUN apt-get update && apt-get install -y \
    netcat \
    curl \
    jq \
    vim \
    net-tools \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install rethinkdb driver for initialization script
RUN npm install -g rethinkdb

# Create necessary directories
RUN mkdir -p /data /backups /var/log/rethinkdb /var/run/rethinkdb \
    && chown -R rethinkdb:rethinkdb /data /backups /var/log/rethinkdb /var/run/rethinkdb

# Copy configuration
COPY config/rethinkdb.conf /etc/rethinkdb/rethinkdb.conf
RUN chown rethinkdb:rethinkdb /etc/rethinkdb/rethinkdb.conf && chmod 644 /etc/rethinkdb/rethinkdb.conf

# Copy initialization scripts
COPY init/01-init-dev-db.js /docker-entrypoint-initdb.d/
RUN chown rethinkdb:rethinkdb /docker-entrypoint-initdb.d/01-init-dev-db.js \
    && chmod 755 /docker-entrypoint-initdb.d/01-init-dev-db.js

# Create development utility scripts
RUN echo '#!/bin/bash\n\
case "$1" in\n\
    "tables")\n\
        rethinkdb admin --connect localhost:28015 --password "$RETHINKDB_PASSWORD" \\\n\
            --exec "r.db(\"$2\").tableList()"\n\
        ;;\n\
    "info")\n\
        rethinkdb admin --connect localhost:28015 --password "$RETHINKDB_PASSWORD" \\\n\
            --exec "r.db(\"$2\").table(\"$3\").info()"\n\
        ;;\n\
    "indexes")\n\
        rethinkdb admin --connect localhost:28015 --password "$RETHINKDB_PASSWORD" \\\n\
            --exec "r.db(\"$2\").table(\"$3\").indexList()"\n\
        ;;\n\
    "status")\n\
        rethinkdb admin --connect localhost:28015 --password "$RETHINKDB_PASSWORD" \\\n\
            --exec "r.db(\"rethinkdb\").table(\"server_status\")"\n\
        ;;\n\
    *)\n\
        echo "Usage: $0 {tables|info|indexes|status} [database] [table]"\n\
        exit 1\n\
        ;;\n\
esac' > /usr/local/bin/rethinkdb-dev-tools \
    && chmod +x /usr/local/bin/rethinkdb-dev-tools

# Create monitoring script
RUN echo '#!/bin/bash\n\
case "$1" in\n\
    "stats")\n\
        rethinkdb admin --connect localhost:28015 --password "$RETHINKDB_PASSWORD" \\\n\
            --exec "r.db(\"rethinkdb\").table(\"stats\")"\n\
        ;;\n\
    "jobs")\n\
        rethinkdb admin --connect localhost:28015 --password "$RETHINKDB_PASSWORD" \\\n\
            --exec "r.db(\"rethinkdb\").table(\"jobs\")"\n\
        ;;\n\
    "logs")\n\
        rethinkdb admin --connect localhost:28015 --password "$RETHINKDB_PASSWORD" \\\n\
            --exec "r.db(\"dev_monitoring\").table(\"job_logs\").orderBy(r.desc(\"timestamp\")).limit(20)"\n\
        ;;\n\
    "issues")\n\
        rethinkdb admin --connect localhost:28015 --password "$RETHINKDB_PASSWORD" \\\n\
            --exec "r.db(\"rethinkdb\").table(\"current_issues\")"\n\
        ;;\n\
    *)\n\
        echo "Usage: $0 {stats|jobs|logs|issues}"\n\
        exit 1\n\
        ;;\n\
esac' > /usr/local/bin/rethinkdb-monitor \
    && chmod +x /usr/local/bin/rethinkdb-monitor

# Create backup script
RUN echo '#!/bin/bash\n\
backup_dir="/backups"\n\
timestamp=$(date +%Y%m%d_%H%M%S)\n\
\n\
case "$1" in\n\
    "dump")\n\
        rethinkdb dump -f "$backup_dir/dump_$timestamp.tar.gz" \\\n\
            -c localhost:28015 -p "$RETHINKDB_PASSWORD"\n\
        ;;\n\
    "export")\n\
        if [ -z "$2" ]; then\n\
            echo "Database name required"\n\
            exit 1\n\
        fi\n\
        rethinkdb export -f "$backup_dir/${2}_export_$timestamp.tar.gz" \\\n\
            -c localhost:28015 -p "$RETHINKDB_PASSWORD" -e "$2"\n\
        ;;\n\
    "restore")\n\
        if [ -z "$2" ]; then\n\
            echo "Backup file required"\n\
            exit 1\n\
        fi\n\
        rethinkdb restore "$2" -c localhost:28015 -p "$RETHINKDB_PASSWORD"\n\
        ;;\n\
    *)\n\
        echo "Usage: $0 {dump|export|restore} [database/file]"\n\
        exit 1\n\
        ;;\n\
esac' > /usr/local/bin/rethinkdb-backup \
    && chmod +x /usr/local/bin/rethinkdb-backup

# Create healthcheck script
RUN echo '#!/bin/bash\n\
rethinkdb admin --connect localhost:28015 --password "$RETHINKDB_PASSWORD" \\\n\
    --exec "r.db(\"rethinkdb\").table(\"server_status\").count()"' > /usr/local/bin/healthcheck \
    && chmod +x /usr/local/bin/healthcheck

# Expose ports
EXPOSE 28015 29015 8080

# Set up volumes
VOLUME ["/data", "/backups", "/var/log/rethinkdb"]

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 \
    CMD /usr/local/bin/healthcheck || exit 1

# Default command
CMD ["rethinkdb", "--config-file", "/etc/rethinkdb/rethinkdb.conf"]
