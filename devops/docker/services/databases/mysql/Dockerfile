ARG VERSION
FROM mysql:${VERSION}

LABEL maintainer="DevOps Team"
LABEL description="MySQL database server for development"

# Install additional tools
RUN apt-get update && apt-get install -y \
    procps \
    vim \
    netcat \
    && rm -rf /var/lib/apt/lists/*

# Copy configuration
COPY config/my.cnf /etc/mysql/my.cnf

# Copy initialization scripts
COPY init/*.sh /docker-entrypoint-initdb.d/

# Create directories
RUN mkdir -p /var/log/mysql /backups \
    && chown -R mysql:mysql /var/log/mysql /backups

# Set permissions
RUN chmod 644 /etc/mysql/my.cnf \
    && chmod +x /docker-entrypoint-initdb.d/*.sh

# Expose ports
EXPOSE 3306 33060

# Set up volumes
VOLUME ["/var/lib/mysql", "/var/log/mysql", "/backups"]

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 \
    CMD mysqladmin ping -h localhost -u root --password="${MYSQL_ROOT_PASSWORD}" || exit 1

# Default command
CMD ["mysqld"]
