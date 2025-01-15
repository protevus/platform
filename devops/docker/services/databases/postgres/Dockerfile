ARG VERSION
FROM postgres:${VERSION}

LABEL maintainer="DevOps Team"
LABEL description="PostgreSQL database server for development"

# Install additional utilities
RUN apt-get update && apt-get install -y \
    postgresql-contrib \
    && rm -rf /var/lib/apt/lists/*

# Copy configuration files
COPY config/postgresql.conf /etc/postgresql/postgresql.conf
COPY config/pg_hba.conf /etc/postgresql/pg_hba.conf

# Copy initialization scripts
COPY init/*.sql /docker-entrypoint-initdb.d/
COPY init/*.sh /docker-entrypoint-initdb.d/

# Create backup directory
RUN mkdir -p /backups && chown postgres:postgres /backups

# Default command
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 \
    CMD pg_isready -U postgres || exit 1
