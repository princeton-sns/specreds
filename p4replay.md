## Part 4: replaying recovery traces and e2e simulation (Figures 5 and 6)

(This part takes around 40 minutes to complete)

In part 4, we will reproduce Figures 5 and 6 (bar figures in Section 5.3 and 5.4) in the paper. These two sections measures the latency of running application recovery workloads on the three types of disks (`rbd`, `super`, and `rbd-clone`)

Section 5.3 evaluates the recovery latency with various failure situations on the three types of disks: `rbd`), `super`, and `rbd-clone`. We prepared block-level traces (in `trace/`) that capture the application recovery workload for various failure situations. The naming of these trace files (`trace/*.blktrace.fio`) includes four parts: the application (pg for postgres), the database scale factor (namely, the database size), the size of WAL when failure occurred, and the type of failure (stop for docker stop, panic for kernel panic). Due to time limitation, we were only able to prepare four traces, one for mysql and three for postgres.

Each trace file also has a corresponding `omap` file that records the disk state at time of failure (i.e., which blocks have data). The complete workflow of replaying these traces is as follows:
- create an empty disk image
- populate the disk image with information recorded in the corresponding `omap` file
- replay the trace file with `fio` and record the time (latency)
- put together the latency numbers and plot the figures

Section 5.4 (Figure 6) is a simulation of end-to-end failover latency where there are five situations depending on the lengths of timeout and recovery (i.e., long vs short). The simulation picks 60 seconds and 5 seconds as long and short timeout, respectively. The numbers for recovery are picked from Figure 5. Specifically, `P/500M-postgres` as long (around 30 seconds on `rbd`) and `S/100M-postgres` as short (around 3 seconds on `rbd`) (Note: these numbers are from cloudlab `c220g5`). Then, the failover latency is determined by adding these numbers together based on how each mechanism would react in a certain scenario (i.e., SpecREDS and Oracle do not use timeout).

This part also provides a one-click script `script/fig5-6-all.sh`

To begin with, change to the Ceph build directory and make sure that the Ceph cluster is running:

	cd /mnt/specreds/ceph/build    # assuming specreds checked out under /mnt
	bin/ceph -s                    # check the cluster status


(Optionally, if the cluster is currently offline, i.e., a call to `ceph -s` hangs, start up the cluster)

	./start-keep.sh                # this keeps all previous cluster data


Next, change back to the working directory

	cd /mnt/specreds/


To run the experiments and generate Figures 5 and 6, simply run

	./script/fig5-6-all.sh           # run all experiments for figures 5&6

After it finishes, you would see the two figures generated as `fig/fig-5-recovery.pdf` and `fig/fig-6-e2e.pdf`


### Interpreting the figures

Now, please proceed to [Part 5](https://github.com/princeton-sns/specreds/blob/main/p5perfafter.md).
