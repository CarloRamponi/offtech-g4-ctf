#!/bin/bash

# exit on error
set -e

source config.sh

# Remove old files
if [ -d "MHDDoS" ]; then
    rm -rf MHDDoS
fi

if ! [ -f "bundled.tar.bz2" ]; then
    tempdir=$(mktemp -d /tmp/wheelhouse-XXXXX)
    (cd attacker; python3.9 -m pip wheel -r requirements.txt --wheel-dir=$tempdir)
    cwd=`pwd`
    (cd $tempdir; tar -cjvf "$cwd/bundled.tar.bz2" *)
fi

# Copy the bundled tarball to the users host
scp bundled.tar.bz2 offtech:~

# Copy the code to the users host
scp -r attacker offtech:~
ssh offtech "if [ -d 'bundle' ]; then rm -rf bundle; fi; mkdir bundle && cd bundle && tar -xjvf ../bundled.tar.bz2 && rm ../bundled.tar.bz2"

# Uncomment the following lines to recompile python3.9 on the users host
# takes about 30 minutes so you'll probably want to do this before the ctf

# ssh offtech "wget https://www.python.org/ftp/python/3.9.7/Python-3.9.7.tgz && tar -xf Python-3.9.7.tgz"
# COMPILING_HOST=${ATTACKERS[0]}
# ssh -J offtech $USER@$COMPILING_HOST.$EXPERIMENT.$PROJECT "sudo apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev -y"
# ssh -J offtech $USER@$COMPILING_HOST.$EXPERIMENT.$PROJECT "cd Python-3.9.7 && ./configure --enable-optimizations && make -j 8"

# Install the compiled python3.9
for HOST in $HOSTS; do
    ssh -J offtech $USER@$HOST.$EXPERIMENT.$PROJECT "if ! [ -f '/usr/local/bin/python3.9' ]; then cd Python-3.9.7 && sudo make altinstall; fi"
    ssh -J offtech $USER@$HOST.$EXPERIMENT.$PROJECT "for b in \`ls bundle\`; do pip3.9 install --force-reinstall --ignore-installed --upgrade --no-index --no-deps bundle/\$b; done"
done