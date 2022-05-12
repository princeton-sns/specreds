#!/bin/bash

../src/vstart.sh --new -x --localhost --bluestore 

sleep 10

bin/ceph osd pool create rbd 
bin/rbd pool init rbd 

