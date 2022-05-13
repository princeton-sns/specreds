## Part 1: Preparing the environment

(This part takes around 30 minutes to complete on cloudlab `c220g5`)

As the first step, we need to prepare the software environment necessary to run all experiments. We provide two options, one using cloudlab c220g2 or c220g5 machine, and the other using a VM with our pre-configured disk image.

**_We highly recommend using cloudlab c220g2 or c220g5 machines since it is tested to be reproducible._**


### Option 1: using cloudlab c220g2 or c220g5 machines (RECOMMENDED)

On cloudlab, start an experiment with the `small-lan` profile (this is the standard profile provided by cloudlab. If you don't see this, any profile that does not occupy the machine's SSD drive also work). Then in Step 2 Parameterize, select `UBUNTU 20.04` as the OS image and specify `c220g2` or `c220g5` as the node type (depending on the availability). 

After the experiment is started, wait for it to boot up and then ssh into it. The default shell is `tcsh` but we recommend `bash`. Run the following command to change the shell:

	sudo chsh -s /bin/bash $USER    # change the default shell

Then log out and log back in for this to take effect.

Next, locate the SSD drive using `lsblk`, make a filesystem on it with `mkfs.ext4`, and finally mount it to `/mnt`. Also remember to change the ownership of the mount point so it gives us appropriate file permissions:

	sudo chown $(id -u):$(id -g) /mnt

Next, checkout this artifact in `/mnt` (if needed, you can switch to the tag `atc22ae`) and run the script to prepare the software environment:

	cd /mnt
	git clone https://github.com/princeton-sns/specreds.git
	cd specreds/
	./prepare-env.sh 

This `prepare-env.sh ` script does the following things in order:
- install `oltpbench`
- install docker engine
- install `fio` for trace replay; install `python3` and needed packages such as `pandas` and `matplotlib`
- compile `ioutil`
- checkout the Ceph repository, install dependencies, and configure the build
- extract the provided disk image that contains a postgres docker image

After the prepare script completes, please log out from your shell and log back in for some changes to take effect.

This prepare script does not build Ceph for you. To do so, after the prepare script completes, you need to run:

	cd /mnt/specreds/ceph/build
	./make.sh -j$(nproc)              # c220g2/5 has enough memory to allow high concurrency

Now please be patient, building Ceph takes a long time (i.e., around 20 minutes with `-j36`).

After build successfully completes, please proceed to [Part 2](https://github.com/princeton-sns/specreds/blob/main/p2warmup.md).


### Option 2: pre-configured `qemu` disk image 

If you do not have access to cloudlab, you can use our provided `qcow2` disk image that can be used to boot up a `qemu` VM. This disk image provides a similar environment to Option 1 where the artifact is tested to be reproducible. The requirement for the host machine is similar: amd64/x86-64 architecture with at least 400GB free space on an SSD drive. We also recommend using a machine with at least 16 CPU cores and 64GB memory. Smaller configurations should also work but requires longer to run this artifact.

To start with, please download the disk image [**here**](https://drive.google.com/file/d/1N6AIn4Bs3CyAcDZBLa09HgBaoFQ0dcNw/view?usp=sharing). Then, extract and place the disk image onto an SSD drive on your host machine

Next, on your host machine, install `qemu` (assuming Ubuntu/Debian. if you are using other distros, please search for how to install QEMU, which should be similar):

	sudo apt-get update
	sudo apt-get install qemu-kvm

We provide a script `launch-vm.sh` to launch VM (you can download this one file to your host machine or checkout the entire specreds repo). The script takes in three parameters: the number of CPU cores and the amount of memory (in GB) for the VM, and the path to the `qcow2` disk image. Please use `lscpu` and `grep MemTotal /proc/meminfo` (or other commands) to determine the hardware configuration of your host machine, and you should use slightly less for the VM. for example:

	./launch-vm.sh 16 64 /mnt/u20s.qcow2   # adjust the parameters to fit your host machine

The VM process is daemonized. Now, log into the VM (the password for login is "_qemu_"):

	ssh -p8080 qemu@localhost    # the password is qemu

Once inside the VM, please go to `/mnt`, check out this repository (if needed, you can switch to the tag `atc22ae`), and then run the prepare script:

	cd /mnt
	git clone https://github.com/princeton-sns/specreds.git
	cd specreds/
	./prepare-env.sh 

After the prepare script completes, please log out from your shell and log back in for some changes to take effect.

At this point, the Ceph codebase is only configured but not built. To do so:

	cd /mnt/specreds/ceph/build
	./make.sh -j$(nproc)              # adjust the -j argument to fit your VM

Please note building Ceph with multithreading consumes a lot of memory. Please allow a 4x relation when specifying the `-j` argument. For example, if your VM has 64GB of memory, using at most `-j16` should be fine. 

Now please be patient, building Ceph takes a long time (i.e., around 30 minutes when using `-j36`).

After build successfully completes, please proceed to [Part 2](https://github.com/princeton-sns/specreds/blob/main/p2warmup.md).
