## Part 3: disk-level I/O performance benchmark (Figure 4)

(This part takes around 30 minutes to complete)

Now that we have gotten familiar with the system and the APIs, the first part of the evaluation to reproduce is Figure 4 in "Section 5.2 Disk-level Performance." 

Section 5.2 evaluates the disk-level I/O performance for three disk types: a regular disaggregated disk (`rbd`), a disk clone with existing Ceph clone implementation (`rbd-clone`), and a disk clone with super (`super`).

First, change to the Ceph build directory and make sure that the Ceph cluster is running:

	cd /mnt/specreds/ceph/build    # assuming specreds checked out under /mnt
	bin/ceph -s                    # check the cluster status


(Optionally, if the cluster is currently offline, i.e., a call to `ceph -s` hangs, start up the cluster)

	./start-keep.sh                # this keeps all previous cluster data


Next, change back to the working directory

	cd /mnt/specreds/

In `script/`, you will see a bunch of scripts used to reproduce Figure 4

	ls script/fig4*                # display scripts related to figure 4

To run all experiments and generate all sub-figures of figure 4, simply run

	./script/fig4-all.sh           # run all experiments for figure 4

On cloudlab c220g2 with the local SSD, this takes around 30 minutes. After it finishes, you would see the 4 sub-figures of figure 4 generated as `fig/fig-4*.pdf`

(These scripts can be executed alone to run part of figure 4, but each of them assumes some preconditions to be met. Please read the comments in the scripts to see what are needed before running the scripts individually. Though you do not need to do this since `script/fig4-all.sh` takes care of all figure 4)

### Interpreting the figures

The generated 4 sub-figures `fig/fig-4*.pdf` correspond to the 4 sub-figures in figure 4 of the paper. The main argument of figure 4 is to show that `super` achieves close-to-normal (`rbd`) I/O performance, while significantly outperforming Ceph's existing clone implementation (`rbd-clone`). 

You should be able to see that in these 4 sub-figures, the line for super is very close to the line for rbd, while rbd-clone is way off, confirming the above statement. Though we note that, depending on the hardware configuration of the host machine and the SSD you run the experiments with, the line for super is not going to be always "very close" to the line for rbd as shown in the paper. In general, the more powerful the supporting storage devices are, the closer the lines for super and rbd would be. The reason is that the major overhead of super over rbd is local data-copying, and powerful storage devices help reduce this overhead.

The figures in the paper are generated with experiments running on high-end NVMe SSDs (on AWS EC2), thus showing a very small gap between super and rbd. The SSDs that cloudlab have are only consumer-level low-end SSDs, thus the gap is expected to larger. But regardless, you should be albe to observe the general trend that super is much closer to super than rbd-clone is.

Now, please proceed to [Part 4](https://github.com/princeton-sns/specreds/blob/main/p4replay.md).
