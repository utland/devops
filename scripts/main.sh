#!/bin/bash

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)" || exit 1

source "./logger.sh"

log_info "Installing packages..."

export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    curl -s -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash >/dev/null 2>&1
fi

if [ -s "$NVM_DIR/nvm.sh" ]; then
    \. "$NVM_DIR/nvm.sh"
else
    log_error "Critical: NVM installation failed or file is missing!"
fi

nvm install 24
nvm use 24
npm i
npm i -g typescript

log_success "Packages installed."

log_info "Configuring database..."
./database.sh
log_success "Database configured."

log_info "Configuring systemd service..."
./systemd.sh
log_success "Systemd service installed."

log_info "Nginx server is installing..."
./nginx.sh
log_success "Nginx configured."

log_info "Starting app..."
sudo systemctl restart inventory-app
log_success "App started."


