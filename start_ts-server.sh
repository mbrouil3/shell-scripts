#!/bin/sh
#
# Simple lil script to start up the teamspeak6 server. Requires screen.
## Currently this sits in the ts6 beta working directory
## Example: /app/ts6server-beta/amd64
#
SCREEN="ts6_server-beta"
BASEDIR="$( cd "$( dirname "$0" )" && pwd )"  ## This returns current working directory

##################
fn_debug () {
echo "Basedir is: " $BASEDIR
}
##################

#fn_debug

### MAIN SCRIPT ###
#set -x
screen -dmS ${SCREEN} ${BASEDIR}/tsserver --accept-license

## End of script
