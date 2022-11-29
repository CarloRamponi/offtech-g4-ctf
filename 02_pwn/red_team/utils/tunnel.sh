#!/bin/bash

source ./config.sh

# SOCKS5 proxy:
# ssh -Nnf -J offtech -D 4444 $USER@$PROXY_HOST.$EXPERIMENT.$PROJECT

# Port forwarding:
ssh -Nnf -J offtech -L 4444:$SERVER_IP:$SERVER_PORT $USER@$PROXY_HOST.$EXPERIMENT.$PROJECT