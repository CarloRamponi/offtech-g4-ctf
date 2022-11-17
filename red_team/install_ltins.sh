#!/bin/bash

# exit on error
set -e

source config.sh

# Install ltins

scp -r attacker offtech:~

ssh offtech "if ! [ -d 'libtins' ]; then git clone https://github.com/mfontanini/libtins.git; fi"

# for HOST in $HOSTS; do
#     ssh -J offtech $USER@$HOST.$EXPERIMENT.$PROJECT "sudo apt-get install -y libpcap-dev libssl-dev cmake"
# done

# ssh -J offtech $USER@$LEGITIMATE.$EXPERIMENT.$PROJECT "cd libtins && mkdir -p build && cd build && cmake .. && make -j 8"

# for HOST in $HOSTS; do
#     ssh -J offtech $USER@$HOST.$EXPERIMENT.$PROJECT "cd libtins/build && sudo make install && sudo ldconfig"
# done

ssh -J offtech $USER@$LEGITIMATE.$EXPERIMENT.$PROJECT "cd attacker && g++ -o syn_flood syn_flood.cpp -ltins -pthread"