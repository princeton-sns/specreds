#!/bin/bash

set -e

##################################################
###### bar figures for e2e failover latency ######
##################################################

# assuming calling this as script/fig6-plot.sh
# assuming script/fig5-exp.sh has run successfully and that 
# result file res/recovery.csv is generated

source script/fig5-6-env.sh    # export variables

# run simulation 
echo -e "${CS}running e2e failover latency simulation${CE}"
python3 script/e2eSimulation.py ${LONGTO} ${SHORTTO} res/recovery.csv res/e2e.csv

# generate e2e bar figures (Figure 6)
# using pg-sf32-cwal500m-panic as long recovery and 
# pg-sf2-cwal100m-stop as short recovery
echo -e "${CS}plotting e2e failover latency bar figure (Figure 6)${CE}"
python3 script/plotE2e.py ${LONGTO} ${SHORTTO} res/e2e.csv fig/fig-6-e2e.pdf 
echo -e "${CS}****** figure generated to fig/fig-6-e2e.pdf ******${CE}"
