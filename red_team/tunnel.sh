#!/bin/bash

source config.sh

LOCAL_PORT=3000
REMOTE_PORT=3000

echo "Visit http://localhost:3000"

ssh -N -L 3000:$LEGITIMATE.$EXPERIMENT.$PROJECT:3000 offtech