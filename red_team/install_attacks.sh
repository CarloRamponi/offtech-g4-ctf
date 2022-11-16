#!/bin/bash

# exit on error
set -e

USER="otech2ab"
EXPERIMENT="flagctf1"
PROJECT="offtech"

HOSTS="client1 client3"

if ! [ -d "MHDDoS" ];
then
    # Clone the repository
    git clone https://github.com/MatrixTM/MHDDoS.git
    
fi

tar -czvf MHDDoS.tar.gz MHDDoS

# Copy the repository to the hosts
for HOST in $HOSTS; do
    scp -J offtech MHDDoS.tar.gz $USER@$HOST.$EXPERIMENT.$PROJECT:~
done

rm MHDDoS.tar.gz

# Install the dependencies
for HOST in $HOSTS; do
    ssh -J offtech $USER@$HOST.$EXPERIMENT.$PROJECT "sudo apt-get install -y python3-pip && tar -xzvf MHDDoS.tar.gz && cd MHDDoS && pip3 install -r requirements.txt"
done

# Remove the repository
rm -rf MHDDoS