#!/usr/bin/python3
import pandas
import sys

if len(sys.argv) != 2:
    print('please specify the input file', file=sys.stderr)
    exit(1)

data = pandas.read_csv(sys.argv[1])

lat_list = data['write latency(ns)'].tolist()

print(sum(lat_list)/len(lat_list)/1000)


