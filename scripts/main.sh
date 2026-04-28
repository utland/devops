#!/bin/bash

cd "$(dirname "$0")" || { echo "Failed to cd to script directory"; exit 1; }

if [ -z "$NVM_DIR" ] && [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
else
    [ -s "$HOME/.nvm/nvm.sh" ] && \. "$HOME/.nvm/nvm.sh"
fi

nvm install 24
nvm use 24

npm i
npm i -g typescript

./database.sh

npm run start


