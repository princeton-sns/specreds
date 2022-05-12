#!/bin/bash

set -e

####################################################
###### Application performance after recovery ######
####################################################

# assuming calling this as script/fig7-exp.sh
# assuming the provided disk image file is at ${IMGPATH}
# assuming the provided postgres config file is at config/postgresql.conf 
# assuming the mount point is /srv/pg/
# assuming docker access without root 

source script/fig7-env.sh    # export variables


echo -e "${CS}begin experiment to measure application performance (Figure 7)${CE}"

# prepare the disk image
echo -e "${CS}importing the postgres docker disk image${CE}"
cd ceph/build/
bin/rbd import ${IMGPATH} ${DISKNAME} --object-size=${OBJSIZE} 
devpath=$(sudo bin/rbd map ${DISKNAME})
cd ../../
sleep ${COOLTIME}


##################################################
# measuring application performance on rbd-clone #
##################################################
echo -e "${CS}measuring application performance on rbd-clone${CE}"
# create a clone
cd ceph/build/
bin/rbd dfork add ${DISKNAME}@d${DISKNAME}
clonepath=$(sudo bin/rbd map d${DISKNAME})
cd ../../
sudo mount ${clonepath} ${MNTPOINT}    # mount the disk
# start up the docker image 
sudo docker run --name pg-sf2 -p 52005:5432 -e POSTGRES_PASSWORD=hi \
 -v $(pwd)/config/postgresql.conf:/etc/postgresql/postgresql.conf \
 --mount type=bind,src=/srv/pg/data,dst=/var/lib/postgresql/data \
 -d postgres -c config_file=/etc/postgresql/postgresql.conf
# check docker container status
while sudo docker logs -t pg-sf2 2>&1 | grep "database system is ready to accept connections" ; [ $? -ne 0 ]; do
    sleep 1
done
# move to oltpbench directory and start measuring
cd oltpbench/
./oltpbenchmark -b tpcc -c config/pg-sf2.xml --execute=true -s 1 -o oltp 
cd ../
if [ ! -d res/rbdclone ]; then
	mkdir -p res/rbdclone
fi
mv -f oltpbench/results/oltp.res res/rbdclone/
rm -f oltpbench/results/* 
# clean-up
sudo docker stop pg-sf2
sudo docker rm pg-sf2
sudo umount ${MNTPOINT}
cd ceph/build/
sudo bin/rbd unmap d${DISKNAME}
bin/rbd dfork rm ${DISKNAME}@d${DISKNAME}
cd ../../
sleep ${COOLTIME}


##############################################
# measuring application performance on super #
##############################################
echo -e "${CS}measuring application performance on super${CE}"
cd ceph/build/
bin/rbd dfork switch ${DISKNAME} --off
bin/rbd dfork switch ${DISKNAME} --on --child     # change to child mode
cd ../../
sudo mount ${devpath} ${MNTPOINT}    # mount the disk
# start up the docker image 
sudo docker run --name pg-sf2 -p 52005:5432 -e POSTGRES_PASSWORD=hi \
 -v $(pwd)/config/postgresql.conf:/etc/postgresql/postgresql.conf \
 --mount type=bind,src=/srv/pg/data,dst=/var/lib/postgresql/data \
 -d postgres -c config_file=/etc/postgresql/postgresql.conf
# check docker container status
while sudo docker logs -t pg-sf2 2>&1 | grep "database system is ready to accept connections" ; [ $? -ne 0 ]; do
    sleep 1
done
# move to oltpbench directory and start measuring
cd oltpbench/
./oltpbenchmark -b tpcc -c config/pg-sf2.xml --execute=true -s 1 -o test   # pre-run 
./oltpbenchmark -b tpcc -c config/pg-sf2.xml --execute=true -s 1 -o oltp & # run this in the background 
cd ../
# now do promotion
cd ceph/build/
bin/rbd collapse ${DISKNAME} --promote  # promote the child while oltpbench is running
cd ../../
wait   # wait for oltpbench to finish
if [ ! -d res/super ]; then
	mkdir -p res/super
fi
mv -f oltpbench/results/oltp.res res/super/
rm -f oltpbench/results/* 
# no clean-up needed 
sleep ${COOLTIME}


################################################
# measuring application performance on regular #
################################################
echo -e "${CS}measuring application performance on regular${CE}"
cd oltpbench/
./oltpbenchmark -b tpcc -c config/pg-sf2.xml --execute=true -s 1 -o oltp 
cd ../
if [ ! -d res/regular ]; then
	mkdir -p res/regular
fi
mv -f oltpbench/results/oltp.res res/regular/
rm -f oltpbench/results/* 


# cleanup
sudo docker stop pg-sf2
sudo docker rm pg-sf2
sudo umount ${MNTPOINT}
cd ceph/build/
sudo bin/rbd unmap ${DISKNAME} 
bin/rbd rm ${DISKNAME} 
cd ../../
