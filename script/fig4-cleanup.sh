#!/bin/bash

set -e

##############################################
###### cleaning up for fig4 experiments ######
##############################################

# assuming calling this as script/fig4-cleanup.sh
# assuming all fig4 experiments are finished

source script/fig4-env.sh    # export variables

# remove the disk image
cd ceph/build
bin/rbd rm ${DISKNAME} 
echo -e "${CS}disk image ${DISKNAME} is removed${CE}"
cd ../../
