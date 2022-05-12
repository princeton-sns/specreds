#!/bin/bash

set -e

##################################################
###### concurrent COW write experiment plot ######
##################################################

# assuming calling this as script/fig4b-plot.sh
# assuming script/fig4b-exp.sh has run successfully and that 
# all needed experiment output files are placed in res/

source script/fig4-env.sh    # export variables

## calculating average latency and generate figure 4b
echo 'calculating average latency...'
echo 'batch size,regular,super,rbd-clone' > concow.csv
for ((i=0; i<${#LSJOBS[@]}; i++))
do
	latline="${LSJOBS[i]}"
	avglat=$(python3 script/avgLat.py res/regular/conCOW*jobs_${LSJOBS[i]}*iter_${LSITER[i]}*exp_0*.csv)
	latline="${latline},${avglat}"
	avglat=$(python3 script/avgLat.py res/super/conCOW*jobs_${LSJOBS[i]}*iter_${LSITER[i]}*exp_0*.csv)
	latline="${latline},${avglat}"
	avglat=$(python3 script/avgLat.py res/rbdclone/conCOW*jobs_${LSJOBS[i]}*iter_${LSITER[i]}*exp_0*.csv)
	latline="${latline},${avglat}"
	echo "${latline}" >> concow.csv
done

## generating figure 4b
echo 'generating figure 4b...'
python3 script/plotConCOW.py concow.csv fig-4b-concow.pdf
mv -f concow.csv res/
if [ ! -d fig ]; then
	mkdir fig
fi
mv -f fig-4b-concow.pdf fig/
echo "****** figure generated to fig/fig-4b-concow.pdf ******"
