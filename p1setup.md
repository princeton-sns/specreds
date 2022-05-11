## Part 1: Preparing the environment

(note to self: need to install python3-pandas for the script)

As the first step, we need to prepare the software environment necessary to run all experiments. We provide two options, one using a VM with our pre-configured disk image, and the one works on any machine with ubuntu 20.04 on amd64, if option 1 is not right for you.

In short, the job for this part is to compile and install Ceph as well as other needed software such as `fio` and `oltpbench`.

### Option 1: pre-configured `QEMU` disk image (RECOMMENDED)

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

Inside the VM you will find this artifact located at `/mnt/specreds`, and the Ceph repository checked out and configured at `/mnt/specreds/ceph/build`. oltpbench is installed at `/mnt/oltpbench`.

The Ceph codebase is only configured but not yet built since the compiled binaries and libraries amount to more than 20GB, which makes the VM disk image not so conveniently portable. Thus, the only thing left to do with our prepared VM is compiling Ceph:

	cd /mnt/specreds/ceph/build
	./make.sh -j$(nproc)              # adjust the -j argument to fit your VM

Please note building Ceph with multithreading consumes a lot of memory. Please allow a 4x relation when specifying the `-j` argument. For example, if your VM has 64GB of memory, using at most `-j16` should be fine. 

Now please be patient, building Ceph takes a long time (i.e., around 30 minutes when using `-j36`).

After build successfully completes, please proceed to part 2.

### Option 2: prepare the environment from scratch 

If using our pre-configured disk image is not plausible for you, we also provide a one-click script `script/prepare-env.sh` that does all compilation and installation work. This script should work on any machine running ubuntu 20.04 on amd64/x86-64. This script does the following things in order:

- install `fio` for trace replay and other use cases
- install `oltpbench`
- install docker engine
- install `python3` and needed packages such as `pandas` and `matplotlib`
- checkout the Ceph repository, install dependencies, and configure the build

To begin with, checkout the SpecREDS artifact (assuming you have 400GB+ space at location `/mnt`)

	cd /mnt
	git clone https://github.com/princeton-sns/specreds.git

Next, run the prepare script

	cd /mnt/specreds
	./script/prepare-env.sh  # this script assumes being called from /mnt/specreds/

Similar to option 1, this prepare script also does not build Ceph for you. To do so, after the prepare script completes, you need to run:

	cd /mnt/specreds/ceph/build
	./make.sh -j$(nproc)              # adjust the -j argument to fit your VM

Please note building Ceph with multithreading consumes a lot of memory. Please allow a 4x relation when specifying the `-j` argument. For example, if your VM has 64GB of memory, using at most `-j16` should be fine. 

Now please be patient, building Ceph takes a long time (i.e., around 30 minutes with `-j36`).

After build successfully completes, please proceed to part 2.

