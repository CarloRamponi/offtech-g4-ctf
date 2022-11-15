#!/bin/bash

# exit on error
set -e

EXPERIMENT="g4ctf-resilient"
PROJECT="g4ctf"

HOSTS="client1 client2"

# Clone the repository
git clone https://github.com/MatrixTM/MHDDoS.git

# Copy the repository to the hosts
for HOST in $HOSTS; do
    scp -J offtech -R ./MHDDoS $HOST.$EXPERIMENT.$PROJECT:~
done

# Install the dependencies
for HOST in $HOSTS; do
    ssh -J offtech $HOST.$EXPERIMENT.$PROJECT "cd MHDDoS && pip install -r requirements.txt"
done

# Remove the repository
rm -rf MHDDoS