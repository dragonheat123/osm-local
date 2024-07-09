FROM postgres:14

# # Add db init script to install OSM-specific Postgres user.
# ADD docker/postgres/openstreetmap-postgres-init.sh /docker-entrypoint-initdb.d/

# Add initialization scripts
COPY openstreetmap-postgres-init.sh /docker-entrypoint-initdb.d/openstreetmap-postgres-init.sh

# Set permissions
RUN chmod +x /docker-entrypoint-initdb.d/openstreetmap-postgres-init.sh
