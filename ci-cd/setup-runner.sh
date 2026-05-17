#!/bin/bash
set -e

apt-get update -y
apt-get install -y curl jq build-essential tar

sudo -u vagrant mkdir -p /home/vagrant/actions-runner
cd /home/vagrant/actions-runner

RUNNER_VERSION="2.316.1"
sudo -u vagrant curl -o actions-runner-linux-x64.tar.gz -L "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"

sudo -u vagrant tar xzf ./actions-runner-linux-x64.tar.gz

./bin/installdependencies.sh

echo "Virtual Machine for runner has successfully started"
