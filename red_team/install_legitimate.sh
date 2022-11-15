#!/bin/bash

# exit on error
set -e

EXPERIMENT="g4ctf-resilient"
PROJECT="g4ctf"

# If the host is passed as an argument, use it
if [ -n "$1" ]; then
    HOST=$1
else
    # Otherwise, select a random host among client1, client2, client3
    HOST="client$(shuf -i 1-3 -n 1)"
fi


echo "Installing legitimate software on $HOST"

ssh -J offtech $HOST.$EXPERIMENT.$PROJECT "curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash - && sudo apt-get install -y nodejs"

# Temporary remove node_modules
mv legitimate/node_modules /tmp/node_modules

scp -J offtech -R ./legitimate $HOST.$EXPERIMENT.$PROJECT:~

# Restore node_modules
mv /tmp/node_modules legitimate/node_modules

ssh -J offtech $HOST.$EXPERIMENT.$PROJECT "cd legitimate && npm install"

echo "Done installing legitimate software on $HOST"