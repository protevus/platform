ARG VERSION
FROM jacobalberty/firebird:${VERSION}

LABEL maintainer="DevOps Team"
LABEL description="Firebird SQL database server for development"

# Install additional tools
USER root
RUN apt-get update && apt-get install -y \
    netcat \
    curl \
    jq \
    vim \
    net-tools \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /firebird/data /firebird/backups /firebird/logs /firebird/etc \
    && chown -R firebird:firebird /firebird

# Copy configuration
COPY config/firebird.conf /firebird/etc/firebird.conf
RUN chown firebird:firebird /firebird/etc/firebird.conf \
    && chmod 644 /firebird/etc/firebird.conf

# Copy initialization scripts
COPY init/01-init-dev-db.sql /docker-entrypoint-initdb.d/
COPY init/01-init-dev.sh /docker-entrypoint-initdb.d/
RUN chown firebird:firebird /docker-entrypoint-initdb.d/01-init-dev-db.sql \
    /docker-entrypoint-initdb.d/01-init-dev.sh \
    && chmod 755 /docker-entrypoint-initdb.d/01-init-dev-db.sql \
    /docker-entrypoint-initdb.d/01-init-dev.sh

# Create monitoring script
RUN echo '#!/bin/bash\n\
case "$1" in\n\
    "stats")\n\
        isql -user $ISC_USER -password $ISC_PASSWORD -q <<< "\n\
            SELECT MON\$STAT_NAME, MON\$STAT_VALUE \n\
            FROM MON\$DATABASE_STATS;"\n\
        ;;\n\
    "connections")\n\
        isql -user $ISC_USER -password $ISC_PASSWORD -q <<< "\n\
            SELECT MON\$USER, MON\$REMOTE_ADDRESS, MON\$REMOTE_PROCESS, \n\
                   MON\$TIMESTAMP, MON\$ISOLATION_MODE \n\
            FROM MON\$ATTACHMENTS \n\
            WHERE MON\$ATTACHMENT_ID <> CURRENT_CONNECTION;"\n\
        ;;\n\
    "transactions")\n\
        isql -user $ISC_USER -password $ISC_PASSWORD -q <<< "\n\
            SELECT MON\$TRANSACTION_ID, MON\$STATE, MON\$TIMESTAMP, \n\
                   MON\$ISOLATION_MODE, MON\$LOCK_TIMEOUT \n\
            FROM MON\$TRANSACTIONS;"\n\
        ;;\n\
    "locks")\n\
        isql -user $ISC_USER -password $ISC_PASSWORD -q <<< "\n\
            SELECT MON\$ATTACHMENT_ID, MON\$OBJECT_NAME, MON\$LOCK_TYPE, \n\
                   MON\$LOCK_TIMEOUT \n\
            FROM MON\$LOCK;"\n\
        ;;\n\
    "io")\n\
        isql -user $ISC_USER -password $ISC_PASSWORD -q <<< "\n\
            SELECT MON\$STAT_NAME, MON\$STAT_VALUE \n\
            FROM MON\$IO_STATS;"\n\
        ;;\n\
    *)\n\
        echo "Usage: $0 {stats|connections|transactions|locks|io}"\n\
        exit 1\n\
        ;;\n\
esac' > /usr/local/bin/firebird-monitor \
    && chmod +x /usr/local/bin/firebird-monitor

# Create performance analysis script
RUN echo '#!/bin/bash\n\
case "$1" in\n\
    "table-stats")\n\
        if [ -z "$2" ]; then\n\
            echo "Table name required"\n\
            exit 1\n\
        fi\n\
        isql -user $ISC_USER -password $ISC_PASSWORD -q <<< "\n\
            SELECT RDB\$RELATION_NAME, RDB\$FORMAT, RDB\$FIELD_COUNT \n\
            FROM RDB\$RELATIONS \n\
            WHERE RDB\$RELATION_NAME = UPPER('\''$2'\'');"\n\
        ;;\n\
    "index-stats")\n\
        if [ -z "$2" ]; then\n\
            echo "Table name required"\n\
            exit 1\n\
        fi\n\
        isql -user $ISC_USER -password $ISC_PASSWORD -q <<< "\n\
            SELECT RDB\$INDEX_NAME, RDB\$STATISTICS \n\
            FROM RDB\$INDICES \n\
            WHERE RDB\$RELATION_NAME = UPPER('\''$2'\'');"\n\
        ;;\n\
    "procedure-stats")\n\
        isql -user $ISC_USER -password $ISC_PASSWORD -q <<< "\n\
            SELECT RDB\$PROCEDURE_NAME, RDB\$PROCEDURE_INPUTS, \n\
                   RDB\$PROCEDURE_OUTPUTS \n\
            FROM RDB\$PROCEDURES;"\n\
        ;;\n\
    "trigger-stats")\n\
        isql -user $ISC_USER -password $ISC_PASSWORD -q <<< "\n\
            SELECT RDB\$TRIGGER_NAME, RDB\$RELATION_NAME, \n\
                   RDB\$TRIGGER_SEQUENCE \n\
            FROM RDB\$TRIGGERS \n\
            WHERE RDB\$SYSTEM_FLAG = 0;"\n\
        ;;\n\
    *)\n\
        echo "Usage: $0 {table-stats|index-stats|procedure-stats|trigger-stats} [name]"\n\
        exit 1\n\
        ;;\n\
esac' > /usr/local/bin/firebird-analyze \
    && chmod +x /usr/local/bin/firebird-analyze

# Create backup script
RUN echo '#!/bin/bash\n\
backup_dir="/firebird/backups"\n\
timestamp=$(date +%Y%m%d_%H%M%S)\n\
\n\
case "$1" in\n\
    "backup")\n\
        if [ -z "$2" ]; then\n\
            echo "Database name required"\n\
            exit 1\n\
        fi\n\
        gbak -b -v -user $ISC_USER -password $ISC_PASSWORD \\\n\
            "localhost:$2" \\\n\
            "$backup_dir/backup_${2}_$timestamp.fbk"\n\
        ;;\n\
    "restore")\n\
        if [ -z "$2" ] || [ -z "$3" ]; then\n\
            echo "Backup file and target database name required"\n\
            exit 1\n\
        fi\n\
        gbak -c -v -user $ISC_USER -password $ISC_PASSWORD \\\n\
            "$2" \\\n\
            "localhost:$3"\n\
        ;;\n\
    *)\n\
        echo "Usage: $0 {backup|restore} [database] [file]"\n\
        exit 1\n\
        ;;\n\
esac' > /usr/local/bin/firebird-backup \
    && chmod +x /usr/local/bin/firebird-backup

# Create healthcheck script
RUN echo '#!/bin/bash\n\
isql -user $ISC_USER -password $ISC_PASSWORD -q -bail localhost:employee' > /usr/local/bin/healthcheck \
    && chmod +x /usr/local/bin/healthcheck

USER firebird

# Expose ports
EXPOSE 3050 3051

# Set up volumes
VOLUME ["/firebird/data", "/firebird/backups", "/firebird/logs"]

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 \
    CMD /usr/local/bin/healthcheck || exit 1

# Default command
CMD ["fbguard"]
