#!/bin/bash

DB_NAME="inventory"
DB_USER="postgres"

# 1. Удаляем базу и пользователя (нужно делать под юзером postgres)
sudo -u postgres psql -c "DROP DATABASE IF EXISTS $DB_NAME;"
sudo -u postgres psql -c "DROP USER IF EXISTS $DB_USER;"

# 2. Останавливаем и удаляем пакеты PostgreSQL
sudo systemctl stop postgresql
sudo apt purge -y postgresql postgresql-contrib postgresql-common

# 3. Удаляем конфигурационные файлы и данные (ВАЖНО: это удалит ВСЕ базы)
sudo rm -rf /etc/postgresql/
sudo rm -rf /var/lib/postgresql/
sudo rm -rf /var/log/postgresql/

# 4. Удаляем системного пользователя postgres (если нужно полностью «под ноль»)
sudo deluser postgres

echo "✨ Система очищена от PostgreSQL."
