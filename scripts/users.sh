#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  exit 1
fi

APP_SERVICE="inventory-app"

# student
useradd -m -s /bin/bash student
usermod -aG sudo student
echo "student:student123" | chpasswd

# teacher
useradd -m -s /bin/bash teacher
usermod -aG sudo teacher
echo "teacher:12345678" | chpasswd
chage -d 0 teacher

# app
if ! id "app" &>/dev/null; then
    useradd -r -s /usr/sbin/nologin app
fi

# operator
useradd -m -s /bin/bash operator
echo "operator:12345678" | chpasswd
chage -d 0 operator

cat <<EOF > /etc/sudoers.d/operator-rules
operator ALL=(root) NOPASSWD: /usr/bin/systemctl start $APP_SERVICE, /usr/bin/systemctl stop $APP_SERVICE, /usr/bin/systemctl restart $APP_SERVICE, /usr/bin/systemctl status $APP_SERVICE, /usr/bin/systemctl reload nginx
EOF
chmod 0440 /etc/sudoers.d/operator-rules
