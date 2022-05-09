# SpecREDS

This repository gathers the artifact for SpecREDS (Speculative Recovery from Disaggregated Storage), a framework for achieving highly available fault tolerance with Speculative recovery and disaggregated storage. The key idea of Speculative Recovery is parallelizing the primary instance and the backup instance to reduce failover latency. For full details of Speculative Recovery, please refer to our [ATC '22 paper]().

The artifact of SpecREDS consists of three main parts: (1) the storage layer that provides disaggregated block-level disks to the applications, as well as the super and collapse APIs for coordinating speculative recovery; (2) the instance pool where application instances are running; (3) the clients that generates traffic to the applications. For simplicity, the failure monitor is not included in this artifact. Failovers will be initiated and coordinated directly by the users using our provided one-click scripts.

The implementation of the storage layer is based on the Ceph codebase v16.2.4. We will be first compiling and installing the storage layer and then start a test storage cluster.

This artifact uses Docker as the instance pool, where applications will be running inside a docker container. 

This artifact uses `oltpbench` benchmarking framework as the clients, with the `TPC-C` workload to load up the applications.

This artifact is organized linearly. Please follow the instructions below step by step to reproduce Figures 4,5,6,7 in the evaluation section of the paper.

## Contents of this repository

- `ceph/` - The storage layer that provides disaggregated block-level disks and implements super and collapse for speculative recovery.
- `traces/` - This folder contains prepared block-level traces of application recovery workload.
- `scripts/` - This folder contains one-click scripts for running experiments and generating figures in the paper.

## Recommended 

This artifact requires only one host machine to run all the experiments. We recommend using a machine with at least 16 CPU cores, 64GB memory, and access to local SSDs (with at least 500GB of free space). Smaller setup should work as well but would take much longer to finish running the entire artifact. 

The below setup of your host machine is highly recommended (and tested):
- Ubuntu 20.04 with Linux kernel 5.10+ and the amd64/x86-64 architecture
- Local SSDs with at least 500GB of space 

We recommend running this artifact using CloudLab c220g2 or c220g5 machines. 

## Step 1: Preparing the environment

As the first step, we need to install the storage layer Ceph, the docker engine, and the oltpbench framework.

### 1.1 Pre-configured `QEMU` disk images 

Given that compiling the Ceph codebase along can take tens of minutes to even several hours (depending on the CPU and memory of your machine), we provide disk images that have the software environment all prepared. The images are in the `qcow2` format compatible with `QEMU` VMs.

**_We highly recommend using our prepared VM images, which are tested to be reproducible, to minimize variance and uncertainty._** 

To start with, please download the disk images here: (TBC a link)

Next, on your host machine, install qemu (if you are using a distro other than Ubuntu/Debian, please search for how to install QEMU, which should be similar):

	sudo apt update
	sudo apt install qemu-kvm

We provide a script to launch VM. The script takes in two parameters, the number of cores and the amount of memory (in GB) for the VM. Please use `lscpu` and `grep MemTotal /proc/meminfo` (or other commands) to determine the hardware configuration of your host machine, and you should use slightly less for your VM. If using a cloudlab c220g2 machine, run the following command:

	./launch-vm.sh 36 160    # adjust the parameters to fit your host machine

The VM process is daemonized. Now, log into the VM (the password for login is "_qemu_"):

	ssh -p8080 qemu@localhost    # the password is qemu

(TBC, what's inside the VM?)

### 1.2. compiling and installing the storage layer Ceph



## Warming up


Authors:

Nanqinqin Li and Anja Kalaba
