# SpecREDS

This repository gathers the artifact for SpecREDS (Speculative Recovery from Disaggregated Storage), a framework for achieving highly available fault tolerance with Speculative recovery and disaggregated storage. The key idea of Speculative Recovery is parallelizing the primary instance and the backup instance to reduce failover latency. For full details of Speculative Recovery, please refer to our ATC '22 paper.

The artifact of SpecREDS consists of three main parts: (1) the storage layer that provides disaggregated block-level disks to the applications, as well as the super and collapse APIs for coordinating speculative recovery; (2) the instance pool where application instances are running; (3) the clients that generates traffic to the applications. For simplicity, the failure monitor is not included in this artifact. This artifact provides block-level traces of application recovery workload that capture certain failure situations. No need to inject failures in this artifact.

The implementation of the storage layer is based on the Ceph codebase v16.2.4. This artifact uses `Docker` as the instance pool, where applications will be running inside a docker container. This artifact uses `oltpbench` benchmark framework as the clients, with the `TPC-C` workload to load up the applications.

The goal of this artifact is to reproduce the figures in the evaluation section of our ATC paper. Specifically, Figures 4, 5, 6, and 7, and to serve as a starting point for readers interested in applying speculative recovery.

## Contents of this repository

- `ceph/` - The storage layer that provides disaggregated block-level disks and implements super and collapse for speculative recovery.
- `config/` - This folder contains config files for oltpbench and docker 
- `image/` - This folder contains a pre-built disk image containing a postgres docker image for reproducing Figure 7.
- `ioutil/` - This folder contains the source code of our simple I/O benchmarking tool.
- `script/` - This folder contains one-click scripts for running experiments and generating figures in the paper.
- `trace/` - This folder contains prepared block-level traces of application recovery workload.
- `prepare-env.sh` - This script sets up the software environment (on cloudlab) for the experiments.
- `launch-vm.sh` - This script launches a VM for the experiments (if cloudlab not available).


## Recommended hardware setup

This artifact requires only one host machine to run all the experiments. We highly recommend using cloudlab `c220g2` or `c220g5` machines where this artifact is tested to be reproducible. If not available, we recommend using a machine with at least 16 CPU cores, 64GB memory, and access to local SSDs (with at least 400GB of free space). Smaller setup should work as well but would take _significantly longer_ to finish running the entire artifact. 

The below setup of your host machine is highly recommended:
- Ubuntu 20.04 with Linux kernel 5.10+ and the amd64/x86-64 architecture
- A Local SSD with at least 400GB of space 


## Table of content

This artifact is organized linearly into five parts. Please go through each section below and follow the instructions step-by-step to reproduce Figures 4,5,6,7 in the evaluation section of the paper.

- [Part 1: preparing the environment](https://github.com/princeton-sns/specreds/blob/main/p1setup.md)
- [Part 2: warming up](https://github.com/princeton-sns/specreds/blob/main/p2warmup.md)
- [Part 3: disk-level I/O performance benchmark (Figure 4)](https://github.com/princeton-sns/specreds/blob/main/p3diskbench.md)
- [Part 4: replaying recovery traces and end-to-end simulation (Figures 5&6)](https://github.com/princeton-sns/specreds/blob/main/p4replay.md)
- [Part 5: performance after recovery (Figure 7)](https://github.com/princeton-sns/specreds/blob/main/p5perfafter.md)

On a cloudlab `c220g5` machine, running the entire artifact takes about 2 hours.

Authors:

Nanqinqin Li and Anja Kalaba
