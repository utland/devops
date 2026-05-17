#!/bin/bash
set -e

apt-get update -y
apt-get install -y docker.io nginx curl

usermod -aG docker vagrant

cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 80;
    server_name _;
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF
systemctl restart nginx
systemctl enable nginx docker

mkdir -p /etc/app-config
touch /etc/app-config/.env
chmod 600 /etc/app-config/.env

docker network create app-network || true
docker volume create pgdata || true

# Creating systemd-unit for PostgreSQL
cat <<EOF > /etc/systemd/system/postgres-db.service
[Unit]
Description=PostgreSQL Database Container
Requires=docker.service
After=docker.service

[Service]
Restart=always
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker stop postgres-db
ExecStartPre=-/usr/bin/docker rm postgres-db

ExecStart=/usr/bin/docker run --name postgres-db --network app-network -p 5432:5432 -v pgdata:/var/lib/postgresql/data --env-file /etc/app-config/.env postgres:15
ExecStop=/usr/bin/docker stop postgres-db

[Install]
WantedBy=multi-user.target
EOF

# Creating systemd-unit for Node.js App
cat <<EOF > /etc/systemd/system/nodejs-app.service
[Unit]
Description=Node.js App Docker Container

Requires=docker.service postgres-db.service
After=docker.service postgres-db.service

[Service]
EnvironmentFile=/etc/app-config/.env
Restart=always
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker stop nodejs-app
ExecStartPre=-/usr/bin/docker rm nodejs-app

ExecStart=/usr/bin/docker run --name nodejs-app --network app-network -p 3000:3000 --env-file /etc/app-config/.env \${APP_IMAGE}
ExecStop=/usr/bin/docker stop nodejs-app

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

systemctl enable postgres-db
systemctl start postgres-db