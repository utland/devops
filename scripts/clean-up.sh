#!/bin/bash

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)" || exit 1

source "./logger.sh"

APP_NAME="inventory-app"

log_warn "This script fully purge PostgreSQl, Nginx, NVM, users of app and systemd-service $APP_NAME"
read -p "Are you sure (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Cancel operation"
    exit 1
fi

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)" || exit 1

log_info "Deleting systemd-service..."
sudo systemctl stop $APP_NAME.socket $APP_NAME.service >/dev/null 2>&1 || true
sudo systemctl disable $APP_NAME.socket $APP_NAME.service >/dev/null 2>&1 || true
sudo rm -f /etc/systemd/system/$APP_NAME.service
sudo rm -f /etc/systemd/system/$APP_NAME.socket
sudo systemctl daemon-reload >/dev/null 2>&1
sudo systemctl reset-failed $APP_NAME.service $APP_NAME.socket >/dev/null 2>&1 || true
log_success "Service is deleted"

log_info "Deleting users..."
for user in "teacher" "student" "operator" "app"; do
    sudo pkill -KILL -u $user
    sudo userdel -r $user
done
login_success "Users are deleted"

log_info "Deleting Nginx server with configs..."
sudo systemctl stop nginx
sudo rm -f /etc/nginx/sites-enabled/$APP_NAME
sudo rm -f /etc/nginx/sites-available/$APP_NAME
sudo apt purge -y nginx nginx-common 
sudo rm -rf /etc/nginx/ /var/log/nginx/
log_success "Nginx is purged"

log_info "Deleting cluster of PostgreSQL..."
sudo systemctl stop postgresql 
sudo apt purge -y postgresql postgresql-contrib postgresql-common
sudo rm -rf /etc/postgresql/ /var/lib/postgresql/ /var/log/postgresql/
sudo deluser postgres
sudo delgroup postgres
log_success "Database and user are deleted"

log_info "Deleting Node.js packages..."
rm -rf "$HOME/.nvm"
log_success "Node.js environment is clear"

log_info "Clearing apt..."
sudo apt autoremove -y 
sudo apt clean
log_success "Dependencies is deleted"

echo -e "\n${GREEN}✨ Rollback is completed"
