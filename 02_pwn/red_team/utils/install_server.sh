#!/bin/bash

source ./config.sh

ssh -q offtech [[ -f ~/server.tar.gz ]] && echo "File exists" || (echo "File does not exist, uploading"; scp ../../common/server.tar.gz offtech:~/server.tar.gz; ssh offtech tar -xzf server.tar.gz);
ssh -J offtech $USER@server.$EXPERIMENT.$PROJECT "cd server; sudo bash install_server"
