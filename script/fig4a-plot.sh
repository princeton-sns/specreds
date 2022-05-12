#!/bin/bash

set -e

##############################################
###### single COW write experiment plot ######
##############################################

# assuming calling this as script/fig4a-plot.sh
# assuming script/fig4a-exp.sh has run successfully and that 
# all needed experiment output files are placed in res/

source script/fig4-env.sh    # export variables

## calculating average latency and generate figure 4a
echo -e "${CS}calculating average latency...${CE}"
echo 'Write size (KB),regular,super,rbd-clone' > singlecow.csv
for wsize in 4 8 16 32 48 64
do
	latline="${wsize}"
	avglat=$(python3 script/avgLat.py res/regular/singleCOW*size_${wsize}K*iter_${SINITER}*exp_0*.csv)
	latline="${latline},${avglat}"
	avglat=$(python3 script/avgLat.py res/super/singleCOW*size_${wsize}K*iter_${SINITER}*exp_0*.csv)
	latline="${latline},${avglat}"
	avglat=$(python3 script/avgLat.py res/rbdclone/singleCOW*size_${wsize}K*iter_${SINITER}*exp_0*.csv)
	latline="${latline},${avglat}"
	echo "${latline}" >> singlecow.csv
done

## generating figure 4a
echo -e "${CS}generating figure 4a...${CE}"
python3 script/plotSingleCOW.py singlecow.csv fig-4a-singlecow.pdf
mv -f singlecow.csv res/
if [ ! -d fig ]; then
	mkdir fig
fi
mv -f fig-4a-singlecow.pdf fig/
echo -e "${CS}****** figure generated to fig/fig-4a-singlecow.pdf ******${CE}"

