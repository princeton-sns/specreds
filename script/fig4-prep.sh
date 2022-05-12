#!/bin/bash

set -e

############################################
###### preparing for fig4 experiments ######
############################################

# assuming calling this as script/fig4-prep.sh
# assuming a Ceph cluster is up and the rbd pool is created and initialized

source script/fig4-env.sh    # export variables

# create the disk image
cd ceph/build
bin/rbd create ${DISKNAME} --size=${DISKSIZE} --object-size=${OBJSIZE}
devpath=$(sudo bin/rbd map ${DISKNAME}) 
echo -e "${CS}a disk image ${DISKNAME} is created${CE}"
cd ../../

# perform a full seq write
echo -e "${CS}performing full sequential write${CE}"
# sudo fio --name=seqw ${SEQWFIO} || true
sudo fio --filename=${devpath} --direct=1 --offset=0 --size=100% \
		 --randrepeat=0 --norandommap=1 --thread --rw=write --bs=256k \
		 --ioengine=psync --iodepth=16 --numjobs=1 --group_reporting --name=seqw-job 


## unmap the disk
cd ceph/build
sudo bin/rbd unmap ${DISKNAME}
cd ../../
