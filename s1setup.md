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

Inside the VM you will find this artifact located at `/mnt/specreds`, and Ceph compiled and installed at `/mnt/specreds/ceph/build`. oltpbench is installed at `/mnt/oltpbench`

Most experiments in this artifact will use `/mnt/specreds/ceph/build/` as the working directory.

Now, please skip the rest of Step 1 and go directly to Step 2. 

### 1.2. compiling and installing the storage layer Ceph
