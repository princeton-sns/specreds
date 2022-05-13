## Part 5: performance after recovery (Figure 7)

(This part takes around 10 minutes to complete on cloudlab `c220g5`)

The final part generates Figure 7 to show application throughput after failover (the backup becomes the new primary). To measure this, this part runs a small postgres database in a docker container on the three disk types (`rbd` for REDS, `super` for SpecREDS, and `rbd-clone` for SpecREDS with rbd-clone). The application is provided as a disk image in `image/`, and it will be bind to a docker container. We use `oltpbench` to issue client loads and measure the throughput.

For REDS, the application continues running on a regular `rbd` disk after failover with no performance penalty. For SpecREDS, the application runs on a disk clone with continued copy-on-write performance impact. If using `super`, this impact disappears after the asynchronous garbage collection completes (when measuring the throughput for SpecREDS with `super`, the garbage collection process is also in the background). Following that, SpecREDS operates on a regular disk just like REDS. If using `rbd-clone`, SpecREDS continues suffering from copy-on-write (almost indefinitely) since the parent disk cannot be removed unless the child disk is removed first (because the child depends on the parent).

This part also provides a one-click script `script/fig7-all.sh`

To begin with, change to the Ceph build directory and make sure that the Ceph cluster is running:

	cd /mnt/specreds/ceph/build    # assuming specreds checked out under /mnt
	bin/ceph -s                    # check the cluster status


(Optionally, if the cluster is currently offline, i.e., a call to `ceph -s` hangs, start up the cluster)

	./start-keep.sh                # this keeps all previous cluster data


Next, change back to the working directory

	cd /mnt/specreds/


To run the experiments and generate Figures 7, simply run

	./script/fig7-all.sh           # run all experiments for figures 5&6

After it finishes, you should be able to see the figure generated as `fig/fig-7-tput.pdf`.


### Interpreting the figures

In Figure 7, we should be seeing that the curve for REDS (green) is the highest, while SpecREDS (blue) is very close to it. This indicates the minor performance impact of the asynchronous garbage collection from `collapse`. The curve for SpecREDS with `rbd-clone` (red), on the other hand, is significantly lower because of continued copy-on-write. Though starting at 30 seconds, you may be able to observe that the red line gradually catches up with the green and blue lines. This is because the experiments use a very small database (less than 300MB user data), and at time 30 seconds is when copy-on-write have touched on most of these data blocks used by the small database.

Figure 6 along with Figure 7 show that SpecREDS with `super` can bring practical availability improvements: it significantly reduces failover latency over REDS and it does not slow down the application after failover completes. We want to note again that these experiments in this artifact are run on low-end SSDs, whereas in public clouds like AWS, more powerful hardware can enable even more appealing improvements for SpecREDS with `super`.
