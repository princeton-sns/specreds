#!/bin/bash

set -e

##############################################
###### bar figures for recovery latency ######
##############################################

# assuming calling this as script/fig5-plot.sh
# assuming script/fig5-exp.sh has run successfully and that 
# result file res/recovery.csv is generated

source script/fig5-6-env.sh    # export variables

## plotting bar figure (Figure 5)
echo -e "${CS}plotting recovery latency bar figure (Figure 5)${CE}"
python3 script/plotRecovery.sh res/recovery.csv fig/fig-5-recovery.pdf
echo -e "${CS}****** figure generated to fig/fig-5-recovery.pdf ******${CE}"
