#!/bin/bash

source config.sh

LOCAL_PORT=3000
REMOTE_PORT=3000

echo "Visit http://localhost:$LOCAL_PORT"

ssh -N -L $LOCAL_PORT:$LEGITIMATE.$EXPERIMENT.$PROJECT:$REMOTE_PORT offtech