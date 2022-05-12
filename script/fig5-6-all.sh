#!/bin/bash

set -e

# assuming calling this as script/fig5-6-all.sh
# this script is a wrap-up for all fig5 and fig6 related experiments and figures
# after this script is successfully executed, fig5 and fig6 will be generated in fig/

# doing fig5 recovery trace replaying experiments
./script/fig5-exp.sh
./script/fig5-plot.sh

# doing fig6 simulated e2e failover experiments
./script/fig6-plot.sh
