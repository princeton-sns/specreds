#!/usr/bin/python3
import sys
import csv
import numpy as np

LABEL_READ = ' 0'
LABEL_WRITE = ' 1'

if len(sys.argv) != 2:
    print('please specify the input file', file=sys.stderr)
    exit(1)

rlat_list = []
wlat_list = []

with open(sys.argv[1], 'r') as input_file:
    log = csv.reader(input_file)
    for row in log:
        ts = int(row[0])
        lat = int(row[1])
        
        if row[2] == LABEL_READ:
            rlat_list.append(lat)
        elif row[2] == LABEL_WRITE:
            wlat_list.append(lat)

print('nr_reads:', len(rlat_list))
print('nr_writes:', len(wlat_list))

rlat_list.sort()
wlat_list.sort()

y_axis_array = []
for i in range(0, 100*10**2+1):
    percent = i/(10**2)
    y_axis_array.append(percent)

rlat_perc = np.percentile(rlat_list, y_axis_array)
wlat_perc = np.percentile(wlat_list, y_axis_array)

output_name = '.'.join(x for x in sys.argv[1].split('.')[:-1])
with open(output_name+'.rperc', 'w') as rout, open(output_name+'.wperc', 'w') as wout:
    for percent, latency in zip(y_axis_array, rlat_perc):
        rout.write(str(latency) + '\n')
    for percent, latency in zip(y_axis_array, wlat_perc):
        wout.write(str(latency) + '\n')

