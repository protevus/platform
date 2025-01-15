ARG VERSION
FROM mariadb:${VERSION}

LABEL maintainer="DevOps Team"
LABEL description="MariaDB database server for development"

# Install additional tools
RUN apt-get update && apt-get install -y \
    netcat \
    pv \
    percona-toolkit \
    vim \
    net-tools \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /var/lib/mysql /var/log/mysql /var/run/mysqld /backups \
    && chown -R mysql:mysql /var/lib/mysql /var/log/mysql /var/run/mysqld /backups \
    && chmod 777 /var/run/mysqld

# Copy configuration
COPY config/my.cnf /etc/mysql/my.cnf
RUN chown mysql:mysql /etc/mysql/my.cnf && chmod 644 /etc/mysql/my.cnf

# Copy initialization scripts
COPY init/01-init-dev-db.sh /docker-entrypoint-initdb.d/
RUN chown mysql:mysql /docker-entrypoint-initdb.d/01-init-dev-db.sh \
    && chmod 755 /docker-entrypoint-initdb.d/01-init-dev-db.sh

# Create development utility scripts
RUN echo '#!/bin/bash\n\
case "$1" in\n\
    "tables")\n\
        mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "CALL dev_utils.show_table_sizes();"\n\
        ;;\n\
    "queries")\n\
        mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "CALL dev_utils.show_running_queries();"\n\
        ;;\n\
    "indexes")\n\
        mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "CALL dev_utils.show_indexes('\''$2'\'', '\''$3'\'');"\n\
        ;;\n\
    "analyze")\n\
        mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "CALL dev_utils.analyze_query('\''$2'\'');"\n\
        ;;\n\
    "status")\n\
        mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "CALL dev_utils.show_table_status('\''$2'\'');"\n\
        ;;\n\
    *)\n\
        echo "Usage: $0 {tables|queries|indexes|analyze|status} [schema] [table]"\n\
        exit 1\n\
        ;;\n\
esac' > /usr/local/bin/mariadb-dev-tools \
    && chmod +x /usr/local/bin/mariadb-dev-tools

# Create monitoring script
RUN echo '#!/bin/bash\n\
case "$1" in\n\
    "slow-queries")\n\
        tail -f /var/log/mysql/slow.log\n\
        ;;\n\
    "general-log")\n\
        tail -f /var/log/mysql/general.log\n\
        ;;\n\
    "error-log")\n\
        tail -f /var/log/mysql/error.log\n\
        ;;\n\
    "processlist")\n\
        watch -n 1 '\''mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW PROCESSLIST;"'\''\n\
        ;;\n\
    "status")\n\
        watch -n 1 '\''mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW GLOBAL STATUS;"'\''\n\
        ;;\n\
    "variables")\n\
        mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW GLOBAL VARIABLES;"\n\
        ;;\n\
    *)\n\
        echo "Usage: $0 {slow-queries|general-log|error-log|processlist|status|variables}"\n\
        exit 1\n\
        ;;\n\
esac' > /usr/local/bin/mariadb-monitor \
    && chmod +x /usr/local/bin/mariadb-monitor

# Create backup script
RUN echo '#!/bin/bash\n\
backup_dir="/backups"\n\
timestamp=$(date +%Y%m%d_%H%M%S)\n\
\n\
case "$1" in\n\
    "full")\n\
        mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD --all-databases --events --routines --triggers \\\n\
            | pv -q -L 10m > "$backup_dir/full_backup_$timestamp.sql"\n\
        ;;\n\
    "schema")\n\
        mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD --all-databases --no-data \\\n\
            | pv -q -L 10m > "$backup_dir/schema_backup_$timestamp.sql"\n\
        ;;\n\
    "database")\n\
        if [ -z "$2" ]; then\n\
            echo "Database name required"\n\
            exit 1\n\
        fi\n\
        mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD "$2" \\\n\
            | pv -q -L 10m > "$backup_dir/${2}_backup_$timestamp.sql"\n\
        ;;\n\
    *)\n\
        echo "Usage: $0 {full|schema|database} [database_name]"\n\
        exit 1\n\
        ;;\n\
esac' > /usr/local/bin/mariadb-backup \
    && chmod +x /usr/local/bin/mariadb-backup

# Create healthcheck script
RUN echo '#!/bin/bash\n\
mysqladmin ping -h localhost -u$MYSQL_USER -p$MYSQL_PASSWORD' > /usr/local/bin/healthcheck \
    && chmod +x /usr/local/bin/healthcheck

# Expose ports
EXPOSE 3306 33060

# Set up volumes
VOLUME ["/var/lib/mysql", "/var/log/mysql", "/backups"]

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 \
    CMD /usr/local/bin/healthcheck || exit 1

# Default command
CMD ["mysqld"]
