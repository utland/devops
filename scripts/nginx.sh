#!/bin/bash

APP_NAME="inventory-app"
DOMAIN="localhost"
APP_PORT=8000

sudo apt update && sudo apt install -y nginx

cat <<EOF > /tmp/$APP_NAME
server {
    listen 80;
    server_name $DOMAIN;

    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;

    location = / {
        proxy_pass http://127.0.0.1:$APP_PORT;
    }

    location /items {
        proxy_pass http://127.0.0.1:$APP_PORT;
    }

    location / {
        return 404;
    }
}
EOF

sudo mv /tmp/$APP_NAME /etc/nginx/sites-available/

if [ ! -L /etc/nginx/sites-enabled/$APP_NAME ]; then
    sudo ln -s /etc/nginx/sites-available/$APP_NAME /etc/nginx/sites-enabled/
fi

sudo rm -f /etc/nginx/sites-enabled/default

sudo nginx -t
if [ $? -eq 0 ]; then
    sudo systemctl restart nginx
fi
