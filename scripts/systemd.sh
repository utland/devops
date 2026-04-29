#!/bin/bash

APP_NAME="inventory-app"
APP_PORT=8000 

DEPLOY_DIR="/opt/$APP_NAME"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)"
DEFAULT_USER=${SUDO_USER:-$USER}

sudo mkdir -p $DEPLOY_DIR
sudo cp -a $PROJECT_DIR/. $DEPLOY_DIR/
sudo chown -R app:app $DEPLOY_DIR

NODE_BIN=$(find /home/$DEFAULT_USER/.nvm/versions/node -name "node" -type f -executable | head -n 1)
NODE_DIR=$(dirname $(dirname "$NODE_BIN"))

sudo cp -r "$NODE_DIR" /opt/node

sudo ln -sf /opt/node/bin/node /usr/local/bin/node
sudo ln -sf /opt/node/bin/npm /usr/local/bin/npm

cat <<EOF > /tmp/$APP_NAME.socket
[Unit]
Description=Socket for Inventory Backend System

[Socket]
ListenStream=$APP_PORT

[Install]
WantedBy=sockets.target
EOF

cat <<EOF > /tmp/$APP_NAME.service
[Unit]
Description=Inventory Backend System
Requires=$APP_NAME.socket
After=network.target $APP_NAME.socket

[Service]
WorkingDirectory=$DEPLOY_DIR
ExecStartPre=/usr/local/bin/npm run build
ExecStart=/usr/local/bin/node $DEPLOY_DIR/dist/main.js

Restart=always
RestartSec=3

User=app

Environment=NODE_ENV=production
Environment=PATH=/opt/node/bin:/usr/local/bin:/usr/bin:/bin

StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=$APP_NAME
EOF

sudo mv /tmp/$APP_NAME.socket /etc/systemd/system/
sudo mv /tmp/$APP_NAME.service /etc/systemd/system/

sudo systemctl daemon-reload

sudo systemctl enable --now $APP_NAME.socket