#!/bin/bash

set -e

##############################################
###### CDFs of replaying recovery trace ######
##############################################

# assuming calling this as script/fig4cd-exp.sh
# calling the writer program as ioutil/writer
# using omap file ${OMAPFILE} and trace file ${TRACEFILE} 

source script/fig4-env.sh    # export variables


echo "begin trace replay experiment (Figure 4c,d)"
# create a disk image
cd ceph/build
bin/rbd create ${OMAPNAME} --size=${OMAPSIZE} --object-size=${OBJSIZE}
devpath=$(sudo bin/rbd map ${OMAPNAME}) 
cd ../../

# populate the disk, this could take a while
sudo ioutil/writer --device=${devpath} --omap=${OMAPFILE} --obj=${OBJSIZE}
sleep ${COOLTIME}

# devpath=/dev/rbd0    # for testing
#######################################
# replaying trace on a rbd-clone disk #
#######################################
echo "replaying on a rbd-clone disk"
cd ceph/build
bin/rbd dfork add ${OMAPNAME}@d${OMAPNAME}
clonepath=$(sudo bin/rbd map d${OMAPNAME})
cd ../../

sudo fio --name=replay --filename=${clonepath} --direct=1 \
         --ioengine=libaio --iodepth=64 \
         --read_iolog=${TRACEFILE} \
         --write_lat_log=${LATFILE}

cd ceph/build
sudo bin/rbd unmap d${OMAPNAME}
bin/rbd dfork rm ${OMAPNAME}@d${OMAPNAME}
cd ../../

sudo chown $(id -u):$(id -g) *.log
if [ ! -d res/rbdclone ]; then
	mkdir -p res/rbdclone    # the folder to put all output files
fi
mv -f *.log res/rbdclone     # move output files

sleep ${COOLTIME}


###################################
# replaying trace on a super disk #
###################################
echo "replaying on a super disk"
cd ceph/build
bin/rbd dfork switch ${OMAPNAME} --off 
bin/rbd dfork switch ${OMAPNAME} --on --child  # switch on child mode
cd ../../ 

sudo fio --name=replay --filename=${devpath} --direct=1 \
         --ioengine=libaio --iodepth=64 \
         --read_iolog=${TRACEFILE} \
         --write_lat_log=${LATFILE}

cd ceph/build 
bin/rbd collapse ${OMAPNAME} --abort    # abort the child
bin/rbd dfork switch ${OMAPNAME} --off --child
bin/rbd dfork switch ${OMAPNAME} --on   # switch back to parent mode
cd ../../ 

sudo chown $(id -u):$(id -g) *.log
if [ ! -d res/super ]; then
	mkdir -p res/super    # the folder to put all output files
fi
mv -f *.log res/super     # move output files

sleep ${COOLTIME}


#####################################
# replaying trace on a regular disk #
#####################################
echo "replaying on a regular disk"

sudo fio --name=replay --filename=${devpath} --direct=1 \
         --ioengine=libaio --iodepth=64 \
         --read_iolog=${TRACEFILE} \
         --write_lat_log=${LATFILE}

sudo chown $(id -u):$(id -g) *.log
if [ ! -d res/regular ]; then
	mkdir -p res/regular    # the folder to put all output files
fi
mv -f *.log res/regular     # move output files


# clean-up
cd ceph/build
sudo bin/rbd unmap ${OMAPNAME}
bin/rbd rm ${OMAPNAME}
cd ../../
