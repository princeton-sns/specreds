#!/bin/bash

set -e

# This script prepares the software environment for all experiments (except for building Ceph)
# must have sudo privilege without password!

# update apt repository
sudo apt-get update


#########################
### install oltpbench ###
#########################
sudo apt-get install default-jdk -yy    # get java
sudo apt-get install ant -yy            # get apache ant
# GET OLTPBENCH
git clone https://github.com/oltpbenchmark/oltpbench.git
cd oltpbench/
ant bootstrap
ant resolve
ant build
cd ../
cp config/*.xml oltpbench/config/

#############################
### install docker engine ###
#############################
sudo apt-get remove docker docker-engine docker.io containerd runc || true    # remove old versions
sudo apt-get install ca-certificates curl gnupg lsb-release                   
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg 
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null 
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -yy


##########################################
### install python3 and other packages ###
##########################################
sudo apt-get install python3 -yy 
sudo apt-get install python3-numpy python3-matplotlib python3-pandas -yy 
sudo apt-get install bc -yy 


######################
### compile ioutil ###
######################
cd ioutil/
make all 
cd ../


######################
### pre-build Ceph ###
######################
git clone https://github.com/linanqinqin/ceph.git
cd ceph/
git submodule update --init --recursive
./install-deps.sh
ARGS="-DCMAKE_BUILD_TYPE=RelWithDebInfo" ./do_cmake.sh
cd ../
cp script/start-*.sh ceph/build/


echo -e "\033[0;31m****** Preparation completed ******\033[0m"
