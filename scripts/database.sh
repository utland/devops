#!/bin/bash

DB_NAME="inventory"
DB_USER="postgres"
DB_PASS="password"

sudo apt update && sudo apt install -y postgresql postgresql-contrib

sudo -u postgres psql <<EOF
DO \$$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$DB_USER') THEN
        CREATE ROLE $DB_USER WITH LOGIN PASSWORD '$DB_PASS';
    ELSE
        ALTER ROLE $DB_USER WITH PASSWORD '$DB_PASS';
    END IF;
END
\$$;
EOF

DB_EXISTS=$(sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'")
if [ "$DB_EXISTS" != "1" ]; then
    sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER"
else
    sudo -u postgres psql -c "ALTER DATABASE $DB_NAME OWNER TO $DB_USER"
fi

sudo -u postgres psql -d $DB_NAME <<EOF
CREATE TABLE IF NOT EXISTS items (
    item_id SERIAL PRIMARY KEY,
    quantity INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
EOF

sudo systemctl restart postgresql
