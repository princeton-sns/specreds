#!/bin/bash

set -e

#########################################
###### single COW write experiment ######
#########################################

# assuming calling this as script/fig4a-exp.sh
# assuming a disk image named ${DISKNAME} is already created and fully seq written

source script/fig4-env.sh    # export variables

# map the disk image
cd ceph/build
devpath=$(sudo bin/rbd map ${DISKNAME}) 
cd ../../


echo -e "${CS}beginning single COW write experiment${CE}"
echo -e "${CS}    1. writing to a regular disk${CE}"
if [ ! -d res/regular ]; then
	mkdir -p res/regular    # the folder to put all output files
fi
for wsize in 4K 8K 16K 32K 48K 64K
do
	echo -e "${CS}Single COW, regular disk, write_size=${wsize}"

	sudo ioutil/singleCOW --device=${devpath} --obj=${OBJSIZE} --iter=${SINITER} --size=${wsize}

	sleep ${COOLTIME}
done
sudo chown $(id -u):$(id -g) *.csv
mv -f *.csv res/regular   # move output files

## writing to rbd clone
echo -e "${CS}    2. writing to a rbd clone disk${CE}"
if [ ! -d res/rbdclone ]; then
	mkdir -p res/rbdclone    # the folder to put all output files
fi
for wsize in 4K 8K 16K 32K 48K 64K
do
	echo -e "${CS}Single COW, rbd-clone disk, write_size=${wsize}${CE}"

	# create the disk clone
	cd ceph/build
	bin/rbd dfork add ${DISKNAME}@d${DISKNAME}
	clonepath=$(sudo bin/rbd map d${DISKNAME})
	cd ../../

	sudo ioutil/singleCOW --device=${clonepath} --obj=${OBJSIZE} --iter=${SINITER} --size=${wsize}

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
for wsize in 4K 8K 16K 32K 48K 64K
do
	echo -e "${CS}Single COW, super disk, write_size=${wsize}${CE}"

	sudo ioutil/singleCOW --device=${devpath} --obj=${OBJSIZE} --iter=${SINITER} --size=${wsize}

	cd ceph/build 
	bin/rbd collapse ${DISKNAME} --abort    # abort the child
	cd ../../ 

	sleep ${COOLTIME}
done
cd ceph/build 
bin/rbd dfork switch ${DISKNAME} --off --child
bin/rbd dfork switch ${DISKNAME} --on   # switch back to mode
cd ../../ 
sudo chown $(id -u):$(id -g) *.csv
mv -f *.csv res/super   # move output files


# unmap the disk image
cd ceph/build
sudo bin/rbd unmap ${DISKNAME}
cd ../../
