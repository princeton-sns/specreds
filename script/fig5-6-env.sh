
export CS='\033[0;31m'
export CE='\033[0m'

export DISKNAME=foo    # disk image name
export DISKSIZE=10G    # disk size, DO NOT CHANGE!
export OBJSIZE=64K     # object size, DO NOT CHANGE!
# export SEQWFIO=config/seqw_rbd0.fio    # seq write config
export COOLTIME=1      # cool-off time between runs

export LSTRACE=('mysql-sf32-cwal300m-panic' 'pg-sf2-cwal100m-stop' 'pg-sf2-cwal100m-panic' 'pg-sf32-cwal500m-panic')
# export LSTRACE=('pg-sf2-cwal100m-panic')

export HDLINE='Recovery latency (s),P/300M-mysql,S/100M-postgres,P/100M-postgres,P/500M-postgres'

export LONGTO=60
export SHORTTO=5
