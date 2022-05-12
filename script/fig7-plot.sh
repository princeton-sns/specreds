#!/bin/bash

set -e

####################################################
###### Application performance after recovery ######
####################################################

# assuming calling this as script/fig7-plot.sh
# assuming script/fig7-exp.sh has run successfully and that 
# all needed result files are placed in res/ 

source script/fig7-env.sh    # export variables


echo -e "${CS}plotting application performance curve (Figure 7)${CE}"
# extracting throughput numbers 
echo -e "${CS}extracting throughput numbers${CE}"
python3 script/extractTput.py res/regular/oltp.res res/regular/tput.csv
python3 script/extractTput.py res/super/oltp.res res/super/tput.csv
python3 script/extractTput.py res/rbdclone/oltp.res res/rbdclone/tput.csv

echo -e "${CS}plotting throughput figure${CE}"
python3 script/plotTput.py res/regular/tput.csv res/super/tput.csv res/rbdclone/tput.csv fig/fig-7-tput.pdf 
echo -e "${CS}****** figure generated to fig/fig-7-tput.pdf ******${CE}"
