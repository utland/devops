#!/bin/bash

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)"
APP_NAME="inventory-app" 

NODE_PATH=$(find /root/.nvm/versions/node -name "node" -type f | head -n 1)

cat <<EOF > /tmp/$APP_NAME.service
[Unit]
Description=Inventory Backend System
After=network.target

[Service]
WorkingDirectory=$PROJECT_DIR 
ExecStart=/bin/bash -c 'source ~/.nvm/nvm.sh && nvm use 24 && npm run start'

Restart=always
RestartSec=3

User=$USER
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=$APP_NAME

[Install]
WantedBy=multi-user.target
EOF

sudo mv /tmp/$APP_NAME.service /etc/systemd/system/

sudo systemctl daemon-reload

sudo systemctl enable $APP_NAME
sudo systemctl start $APP_NAME
