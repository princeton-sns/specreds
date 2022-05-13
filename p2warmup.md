## Part 2: Warming up

(This part takes around 10 minutes to complete)

Let us first go through some warm-up examples to get familiar with the Ceph storage layer as well as the super and collapse APIs. In this section, we will be learning the following commands (You do not need to remember how to use these APIs correctly, the remaining parts of this artifact all provide one-click scripts to run the experiments): 

	ceph -s         # display the ceph cluster status
	rbd create      # creates a disk image
	rbd ls          # lists all disk images
	rbd map         # maps a disk image as a block device with parent mode
	rbd super       # creates a disk clone and maps it as a block device with child mode
	rbd collapse    # deallocates one version of the disk (parent or child)

To do so, we will be using a simple example to go through the workflow in speculative recovery. We will first start a Ceph cluster and create a disk image. Then, we will map the parent version of this disk image as a block device and do some file operations (pretending to be the primary application instance). Next, we will switch to the child version of the disk by using super and do some more file operations (pretending to be the backup instance). Finally, we will use collapse to deallocate one of the versions.

Now let us begin. First, change to the Ceph build directory:

	cd /mnt/specreds/ceph/build

### 2.1. start a test cluster

Ceph provides a script to start up a test cluster locally: 

	./start-new.sh 

This starts up a cluster with three OSDs (the storage servers) each of which manages a 100GB device. This means that the total storage capacity of the test cluster is 300GB (the effective capacity is still 100GB given three-way replication). This will be enough for our experiments. Then, populate some system environment:

	source vstart_environment.sh 

Now, you can check the system status by typing:
	
	bin/ceph -s 

If the `health` field shows `HEALTH_ERR` with `Module 'dashboard' has failed: No module named 'routes'` as the only error, this is expected and it does not impact the system's normal operations. If you see other errors, then the cluster may be truly unhealthy (this could happen at the cluster start-up time). Please wait a bit and the cluster shold clean up just fine.

After you are done with the experiments, you can shutdown the cluster with

	./reset.sh 

The next time you wish to resume, use the startup script again to restart the cluster, but remember to use the `start-keep.sh` so that the cluster will reuse the previous setup (including the data). Otherwise, a brand new cluster will be created and all previous data will be lost.
	
	./start-keep.sh  

(If you see the cluster is in an unhealthy state during normal operation, you can start up a new cluster by `reset.sh` then `start-new.sh`)

### 2.2. create a disk

Ceph's block device interface is called `rbd`. We will be using this interface to create a disk as well as calling super and collapse.

<!-- First, create and initialize a pool where the disks should reside

	bin/ceph osd pool create rbd    # create a pool
	bin/rbd pool init rbd           # init the pool

(You will be seeing some WARNING messages printed, please ignore them) -->

Now, let us create a disk image named `foo` with 1GB of size

	bin/rbd create foo --size=1G    # create disk foo, 1GB in size

(You will be seeing some WARNING messages printed, please ignore them)

Then, you can check the the created disk image with

	bin/rbd ls -l                   # list all disk images

### 2.3. do some file operations as the parent

Now let's mount a filesystem on foo and do some file operations.

First, map the disk image as a block device. By default, this maps the disk image in the parent mode, meaning that the all access to the disk is treated as the parent. In speculative recovery, this is the mode the primary instance should use.

	sudo bin/rbd map foo            # map a block device

It should be mapped as `/dev/rbd0` on the system (you can use `lsblk` to check). Next, make a filesystem

	sudo mkfs.ext4 /dev/rbd0        # make the ext4 fs

Next, mount the filesystem

	sudo mount /dev/rbd0 /srv           # mount to /srv  
	sudo chown $(id -u):$(id -g) /srv   # change the ownership

Now, write a file (in parent mode)

	echo "I am the parent" > /srv/parent

Finally, unmount the filesystem and unmap the disk

	sudo umount /srv
	sudo bin/rbd unmap /dev/rbd0    # can pass foo here as well

### 2.4. do moro file operations as the child

Now, we will use super to clone a child disk and do some file operations on the child as well. 

First, call super

	sudo bin/rbd super foo          # creates and maps the child disk

This command creates a child disk and maps it as a block device `/dev/rbd0`. Now all access to this disk will be treated as the child. In speculative recovery, this is the mode the backup instance should use. 

Next, mount the filesystem
	
	sudo mount /dev/rbd0 /srv 

We should be seeing the `parent` file written while in parent mode, as well as its content "I am the parent"

	cat /srv/parent                 # I am the parent

Now, create a another file as the child

	echo "I am the child" > /srv/child

Finally, unmount the filesystem and unmap the disk

	sudo umount /srv
	sudo bin/rbd unmap /dev/rbd0    # can pass foo here as well

### 2.5. switch back to parent mode

Now we have two disk versions, one with the `parent` file one with an additional `child` file. Let us switch back to the parent mode and check whether the content of the parent is still there. This is testing the basic isolation requirement for disk clones.

Again, map the disk and mount the filesystem 

	sudo bin/rbd map foo            # map as the parent
	sudo mount /dev/rbd0 /srv

Inside `/srv`, we should only be seeing the `parent` file with content "I am the parent" (please use `ls` and `cat` to verify)!

Finally, unmount the filesystem and unmap the disk 

	sudo umount /srv
	sudo bin/rbd unmap /dev/rbd0

### 2.5. use collapse to deallocate the parent

Now we have two independent versions of the disk. To clarify, when doing `rbd ls -l` we will only be seeing one disk `foo`. The parent and child versions of `foo` does not exist "explicitly" but only show up when mapped as a block device depending on your access mode. If you map the disk image using `rbd map`, you are in parent mode; if you map the image using `rbd super`, you are in child mode.

Next, assume that we decide to promote the child version and deallocate the parent by calling collapse:

	bin/rbd collapse foo --promote   # collapse by promoting the child

A progress bar would show up indicating the progress of the asynchronous garbage collection that is deallocating the parent. The call to collapse is a blocking operation, but the disk is not being blocked from normal I/O operations. To deallocate the child instead, use the `--abort` option. If no option specified, collapse simply returns the dirty bit value of the parent disk.

After the call to collapse returns, the disk image now has only one version, which is the newly promoted parent (previously the child). And now let us see its content:

	sudo bin/rbd map foo            # map as the parent
	sudo mount /dev/rbd0 /srv

Inside `/srv`, we should see both files `parent` and `child` with their corresponding content (please use `ls` and `cat` to verify)!

Finally, clean up:

	sudo umount /srv
	sudo bin/rbd unmap /dev/rbd0
	bin/rbd rm foo                  # remove the disk image

(Optionally, you can shut down the cluster)

	./reset.sh                      # shut down the cluster

Now, please proceed to [Part 3](https://github.com/princeton-sns/specreds/blob/main/p3diskbench.md).
