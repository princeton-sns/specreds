#!/bin/bash

set -e

# assuming calling this as script/fig7-all.sh
# this script is a wrap-up for fig7 related experiments and figure
# after this script is successfully executed, fig7 will be generated in fig/

# doing fig7 experiments measuring application throughput after recovery
./script/fig7-exp.sh
./script/fig7-plot.sh
