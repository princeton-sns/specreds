#!/bin/bash

set -e

#############################################
###### concurrent COW write experiment ######
#############################################

# assuming calling this as script/fig4b-exp.sh
# assuming a disk image named ${DISKNAME} is already created and fully seq written

source script/fig4-env.sh    # export variables

# map the disk image
cd ceph/build
devpath=$(sudo bin/rbd map ${DISKNAME}) 
cd ../../


echo -e "${CS}begin concurrent COW write experiment${CE}"
echo -e "${CS}    1. writing to a regular disk${CE}"
if [ ! -d res/regular ]; then
	mkdir -p res/regular    # the folder to put all output files
fi
for ((i=0; i<${#LSJOBS[@]}; i++))
do
	echo -e "${CS}Concurrent COW, regular disk, num_jobs=${LSJOBS[i]}${CE}"

	sudo ioutil/conCOW --device=${devpath} --obj=${OBJSIZE} --size=4K --iter=${LSITER[i]} --jobs=${LSJOBS[i]}

	sleep ${COOLTIME}
done
sudo chown $(id -u):$(id -g) *.csv
mv -f *.csv res/regular   # move output files

## writing to rbd clone
echo -e "${CS}    2. writing to a rbd clone disk${CE}"
if [ ! -d res/rbdclone ]; then
	mkdir -p res/rbdclone    # the folder to put all output files
fi
for ((i=0; i<${#LSJOBS[@]}; i++))
do
	echo -e "${CS}Concurrent COW, rbd-clone disk, num_jobs=${LSJOBS[i]}${CE}"

	# create the disk clone
	cd ceph/build
	bin/rbd dfork add ${DISKNAME}@d${DISKNAME}
	clonepath=$(sudo bin/rbd map d${DISKNAME})
	cd ../../

	sudo ioutil/conCOW --device=${clonepath} --obj=${OBJSIZE} --size=4K --iter=${LSITER[i]} --jobs=${LSJOBS[i]}

	cd ceph/build
	sudo bin/rbd unmap d${DISKNAME}
	bin/rbd dfork rm ${DISKNAME}@d${DISKNAME}
	cd ../../

	sleep ${COOLTIME}
done
sudo chown $(id -u):$(id -g) *.csv
mv -f *.csv res/rbdclone   # move output files

## writing to super
echo -e "${CS}    3. writing to a super disk${CE}"
if [ ! -d res/super ]; then
	mkdir -p res/super    # the folder to put all output files
fi
cd ceph/build
bin/rbd dfork switch ${DISKNAME} --off 
bin/rbd dfork switch ${DISKNAME} --on --child  # switch on child mode
cd ../../ 
for ((i=0; i<${#LSJOBS[@]}; i++))
do
	echo -e "${CS}Concurrent COW, super disk, num_jobs=${LSJOBS[i]}${CE}"

	sudo ioutil/conCOW --device=${devpath} --obj=${OBJSIZE} --size=4K --iter=${LSITER[i]} --jobs=${LSJOBS[i]}

	cd ceph/build 
	bin/rbd collapse ${DISKNAME} --abort    # abort the child
	cd ../../ 

	sleep ${COOLTIME}
done
cd ceph/build 
bin/rbd dfork switch ${DISKNAME} --off --child
bin/rbd dfork switch ${DISKNAME} --on   # switch back to parent mode
cd ../../ 
sudo chown $(id -u):$(id -g) *.csv
mv -f *.csv res/super   # move output files


# unmap the disk image
cd ceph/build
sudo bin/rbd unmap ${DISKNAME}
cd ../../
