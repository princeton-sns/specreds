
export DISKNAME=foo    # disk image name
export DISKSIZE=10M    # disk size
export OBJSIZE=64K     # object size, DO NOT CHANGE!
# export SEQWFIO=config/seqw_rbd0.fio    # seq write config
export COOLTIME=1      # cool-off time between runs
export SINITER=100     # number of iterations for single cow

# for concurrent COW
export LSJOBS=(1 2 4 8 16 32)
export LSITER=(100 50 25 12 6 3)

# for trace replay
export OMAPNAME=bar 
export OMAPSIZE=10G    # DO NOT CHANGE!
export OMAPFILE=trace/pg-sf32-cwal500m-panic.omap
export TRACEFILE=trace/pg-sf32-cwal500m-panic.blktrace.fio
export LATFILE=fig4cd
export LSPERC=(80   90   95   98   99   99.9 99.99)
export LSLPOS=(8001 9001 9501 9801 9901 9991 10000)
