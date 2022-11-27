#!/bin/bash

# exit on error
set -e

source config.sh

echo "Installing legitimate software..."

echo "Downloading nodejs on the users host"
ssh offtech "wget https://deb.nodesource.com/node_16.x/pool/main/n/nodejs/nodejs_16.0.0-1nodesource1_amd64.deb -O nodejs.deb"

for HOST in $HOSTS; do
    echo "Installing nodejs on $HOST"
    ssh -J offtech $USER@$HOST.$EXPERIMENT.$PROJECT "sudo dpkg -i nodejs.deb"
done

echo "Downloading dependencies locally"

npm --prefix ./legitimate install

# echo "Compiling the legitimate software locally"

# npm --prefix ./legitimate run build

echo "Packing the legitimate software"

tar -czvf legitimate.tar.gz legitimate > /dev/null

echo "Copying the legitimate software to the users host"

scp ./legitimate.tar.gz offtech:~

echo "Removing the local copy of the legitimate software"

rm legitimate.tar.gz

echo "Removing possibly existing legitimate software on users host"
ssh offtech "rm -rf legitimate"

echo "Extracting the legitimate software on the users host"

ssh offtech "tar -xzvf legitimate.tar.gz > /dev/null && rm legitimate.tar.gz"

echo "Removing possible old data"
ssh offtech "rm legitimate/db.json"

echo "Done installing legitimate software on $LEGITIMATE"
echo "Start it with 'cd legitimate && npm start'"