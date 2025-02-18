#!/bin/bash
set -e

# Environment setup: use /home/container/data for PostgreSQL data and set passwords
export PGDATA=/home/container/data
export POSTGRES_PASSWORD=your_secure_password    # Set your desired superuser password
export PGPASSWORD=your_secure_password            # For psql to connect without prompting

# Ensure the data directory exists
mkdir -p "$PGDATA"

# Initialize the database if not already initialized
if [ ! -f "$PGDATA/PG_VERSION" ]; then
  echo "Initializing PostgreSQL data directory..."
  initdb -D "$PGDATA"
fi

# Define cleanup function for graceful shutdown
cleanup() {
  echo "Gracefully shutting down PostgreSQL..."
  if [ -n "$PG_PID" ]; then
    kill -SIGTERM "$PG_PID"
    wait "$PG_PID"
  fi
  exit 0
}

# Trap SIGINT and SIGTERM so that cleanup is called on Control+C
trap cleanup SIGINT SIGTERM

echo "Starting PostgreSQL..."
# Start PostgreSQL in the background, specifying a writable Unix socket directory
postgres -D "$PGDATA" -c unix_socket_directories=/home/container &
PG_PID=$!

# Allow a few seconds for PostgreSQL to start up
sleep 3

echo "Entering interactive psql session..."
# Launch an interactive psql session connecting via the custom socket
psql -U postgres -h /home/container

# When psql exits, run cleanup to shutdown PostgreSQL gracefully
cleanup
