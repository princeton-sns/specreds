#!/bin/bash

set -e

##############################################
###### CDFs of replaying recovery trace ######
##############################################

# assuming calling this as script/fig4cd-plot.sh
# assuming script/fig4cd-exp.sh has run successfully and that 
# all needed experiment output files are placed in res/

source script/fig4-env.sh    # export variables

## extracting percentile data
echo 'extracting percentile data'

python3 script/fioLatLog2percentiles.py res/regular/${LATFILE}_lat.1.log
python3 script/fioLatLog2percentiles.py res/super/${LATFILE}_lat.1.log
python3 script/fioLatLog2percentiles.py res/rbdclone/${LATFILE}_lat.1.log

echo 'percentile,regular,super,rbd-clone' > rperc.csv
for ((i=0; i<${#LSPERC[@]}; i++))
do
	percline="${LSPERC[i]}"
	perc=$(sed -n "${LSLPOS[i]}p" res/regular/${LATFILE}_lat.1.rperc)
	percline="${percline},${perc}"
	perc=$(sed -n "${LSLPOS[i]}p" res/super/${LATFILE}_lat.1.rperc)
	percline="${percline},${perc}"
	perc=$(sed -n "${LSLPOS[i]}p" res/rbdclone/${LATFILE}_lat.1.rperc)
	percline="${percline},${perc}"
	echo "${percline}" >> rperc.csv
done

echo 'percentile,regular,super,rbd-clone' > wperc.csv
for ((i=0; i<${#LSPERC[@]}; i++))
do
	percline="${LSPERC[i]}"
	perc=$(sed -n "${LSLPOS[i]}p" res/regular/${LATFILE}_lat.1.wperc)
	percline="${percline},${perc}"
	perc=$(sed -n "${LSLPOS[i]}p" res/super/${LATFILE}_lat.1.wperc)
	percline="${percline},${perc}"
	perc=$(sed -n "${LSLPOS[i]}p" res/rbdclone/${LATFILE}_lat.1.wperc)
	percline="${percline},${perc}"
	echo "${percline}" >> wperc.csv
done

## generating the CDF figures
echo 'generating the CDF figures'
python3 script/plotCDF.py rperc.csv fig-4c-rcdf.pdf
python3 script/plotCDF.py wperc.csv fig-4d-wcdf.pdf
mv -f *.csv res/
if [ ! -d fig ]; then
	mkdir fig
fi
mv -f *.pdf fig/
echo "****** figure generated to fig/fig-4c-rcdf.pdf,fig-4d-wcdf.pdf ******"
