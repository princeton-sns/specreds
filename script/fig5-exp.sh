#!/bin/bash

set -e

##############################
###### Recovery latency ######
##############################

# assuming calling this as script/fig5-exp.sh
# calling the writer program as ioutil/writer
# using omap and trace files in trace/ 

source script/fig5-6-env.sh    # export variables


echo -e "${CS}begin trace replay experiment (Figure 5)${CE}"
regularline='rbd'
superline='super'
rbdcloneline='rbd-clone'
for ((i=0; i<${#LSTRACE[@]}; i++))
do
	echo -e "${CS}replaying trace ${LSTRACE[i]}${CE}"

	# create the disk
	cd ceph/build
	bin/rbd create ${DISKNAME} --size=${DISKSIZE} --object-size=${OBJSIZE}
	devpath=$(sudo bin/rbd map ${DISKNAME})
	cd ../../
	echo -e "${CS}disk image created${CE}"

	# populate the disk
	echo -e "${CS}populating the disk...${CE}"
	sudo ioutil/writer --device=${devpath} --omap=trace/${LSTRACE[i]}.omap --obj=${OBJSIZE}
	sleep ${COOLTIME}

	#######################
	# on a rbd-clone disk #
	#######################
	cd ceph/build
	bin/rbd dfork add ${DISKNAME}@d${DISKNAME}
	clonepath=$(sudo bin/rbd map d${DISKNAME})
	cd ../../

	tstart=$(date +%s.%N)
	sudo fio --name=replay --filename=${clonepath} --direct=1 \
         --ioengine=libaio --iodepth=64 \
         --read_iolog=trace/${LSTRACE[i]}.blktrace.fio 
    tend=$(date +%s.%N)
    tdiff=$(echo "$tend - $tstart" | bc)
    rbdcloneline="${rbdcloneline},${tdiff}"
    echo -e "${CS}trace ${LSTRACE[i]} replayed in ${tdiff} seconds on rbd-clone${CE}"

    cd ceph/build
    sudo bin/rbd unmap d${DISKNAME}
    bin/rbd dfork rm ${DISKNAME}@d${DISKNAME}
    cd ../../
    sleep ${COOLTIME}

    ###################
	# on a super disk #
	###################
	cd ceph/build
	bin/rbd dfork switch ${DISKNAME} --off
	bin/rbd dfork switch ${DISKNAME} --on --child   # switch to child mode
	cd ../../

	tstart=$(date +%s.%N)
	sudo fio --name=replay --filename=${devpath} --direct=1 \
         --ioengine=libaio --iodepth=64 \
         --read_iolog=trace/${LSTRACE[i]}.blktrace.fio 
    tend=$(date +%s.%N)
    tdiff=$(echo "$tend - $tstart" | bc)
    superline="${superline},${tdiff}"
    echo -e "${CS}trace ${LSTRACE[i]} replayed in ${tdiff} seconds on super${CE}"

    cd ceph/build
    bin/rbd collapse ${DISKNAME} --abort    # deallocate the child
	bin/rbd dfork switch ${DISKNAME} --off --child
	bin/rbd dfork switch ${DISKNAME} --on   # switch back to parent mode
    cd ../../
    sleep ${COOLTIME}

    #####################
	# on a regular disk #
	#####################
	tstart=$(date +%s.%N)
	sudo fio --name=replay --filename=${devpath} --direct=1 \
         --ioengine=libaio --iodepth=64 \
         --read_iolog=trace/${LSTRACE[i]}.blktrace.fio 
    tend=$(date +%s.%N)
    tdiff=$(echo "$tend - $tstart" | bc)
    regularline="${regularline},${tdiff}"
    echo -e "${CS}trace ${LSTRACE[i]} replayed in ${tdiff} seconds on regular${CE}"

    # clean-up
    cd ceph/build
	sudo bin/rbd unmap ${DISKNAME}
	bin/rbd rm ${DISKNAME} 
	cd ../../
	echo -e "${CS}disk image removed${CE}"
done

# record output
echo "${HDLINE}" > recovery.csv
echo "${regularline}" >> recovery.csv
echo "${superline}" >> recovery.csv
echo "${rbdcloneline}" >> recovery.csv
if [ ! -d res ]; then
	mkdir res
fi
mv -f recovery.csv res/
echo -e "${CS}****** output is in res/recovery.csv ******${CE}"
