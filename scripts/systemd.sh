#!/bin/bash

APP_NAME="inventory-app"
DEPLOY_DIR="/opt/$APP_NAME"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)"
REAL_USER=${SUDO_USER:-$USER}

sudo mkdir -p $DEPLOY_DIR
sudo cp -a $PROJECT_DIR/. $DEPLOY_DIR/
sudo chown -R app:app $DEPLOY_DIR

NODE_BIN=$(find /home/$REAL_USER/.nvm/versions/node -name "node" -type f -executable | head -n 1)
NODE_DIR=$(dirname $(dirname "$NODE_BIN"))

sudo cp -r "$NODE_DIR" /opt/node

sudo ln -sf /opt/node/bin/node /usr/local/bin/node
sudo ln -sf /opt/node/bin/npm /usr/local/bin/npm

cat <<EOF > /tmp/$APP_NAME.service
[Unit]
Description=Inventory Backend System
After=network.target

[Service]
WorkingDirectory=$DEPLOY_DIR
ExecStart=/usr/local/bin/npm run start

Restart=always
RestartSec=3

User=app

Environment=NODE_ENV=production
Environment=PATH=/opt/node/bin:/usr/local/bin:/usr/bin:/bin
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=$APP_NAME

[Install]
WantedBy=multi-user.target
EOF

sudo mv /tmp/$APP_NAME.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable $APP_NAME
sudo systemctl restart $APP_NAME
