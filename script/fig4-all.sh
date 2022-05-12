#!/bin/bash

set -e

# assuming calling this as script/fig4-all.sh
# this script is a wrap-up for all fig4 related experiments and figures
# after this script is successfully executed, fig4a,b,c,d will be generated in fig/

# preparing the envrionment
./script/fig4-prep.sh

# doing fig4a single cow experiments
./script/fig4a-exp.sh
./script/fig4a-plot.sh

# doing fig4b concurrent cow experiments
./script/fig4b-exp.sh
./script/fig4b-plot.sh

# clean-up
./script/fig4-cleanup.sh

# doing fig4cd r/w CDFs
./script/fig4cd-exp.sh
./script/fig4cd-plot.sh
