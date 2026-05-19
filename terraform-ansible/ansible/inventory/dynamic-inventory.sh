#!/bin/bash

TERRAFORM_DIR="../terraform"

cd "$TERRAFORM_DIR" >/dev/null 2>&1 || { echo "{}" ; exit 1; }

WORKER_IP=$(terraform output -json worker_hosts | jq -r '.[0]')
DB_IP=$(terraform output -json db_hosts | jq -r '.[0]')

if [ "$WORKER_IP" == "null" ] || [ "$DB_IP" == "null" ] || [ -z "$WORKER_IP" ]; then
  echo "{}"
  exit 1
fi

cat <<EOF
{
  "workers": {
    "hosts": ["worker"]
  },
  "db": {
    "hosts": ["db"]
  },
  "_meta": {
    "hostvars": {
      "worker": {
        "ansible_host": "$WORKER_IP"
      },
      "db": {
        "ansible_host": "$DB_IP"
      }
    }
  },
  "all": {
    "vars": {
      "ansible_user": "ansible",
      "ansible_ssh_common_args": "-o StrictHostKeyChecking=no",
      "ansible_ssh_private_key_file": "./ansible_key.pem"
    }
  }
}
EOF