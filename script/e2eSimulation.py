
import sys
import csv
import numpy as np

if len(sys.argv) != 5:
    print('need four arguments', file=sys.stderr)
    exit(1)

long_timeout = float(sys.argv[1])
short_timeout = float(sys.argv[2])
input_path = sys.argv[3]
output_path = sys.argv[4]

with open(input_path, 'r') as input_file:
    input_csv = csv.reader(input_file)
    next(input_csv)
    raw_list = []
    for row in input_csv:
        raw_list.append(row)
raw_list = np.array(raw_list)

long_rec_list = raw_list[:, 4].astype(float)
short_rec_list = raw_list[:, 2].astype(float)
RBD = 0
SUPER = 1
RBDCLONE = 2

with open(output_path, 'w') as output_file:
    output_file.write('Application unavailability (s),long,short,long,long (FP),short\n')

    reds_line = ','.join(['REDS', str(long_timeout+long_rec_list[RBD]), str(long_timeout+short_rec_list[RBD]),
                          str(short_timeout + long_rec_list[RBD]), str(short_timeout + long_rec_list[RBD]),
                          str(short_timeout + short_rec_list[RBD])])
    spec_clone_line = ','.join(['SpecREDS (rbd-clone)', str(long_rec_list[RBDCLONE]), str(short_rec_list[RBDCLONE]),
                                str(long_rec_list[RBDCLONE]), str(short_timeout+5),
                                str(short_rec_list[RBDCLONE])])
    spec_super_line = ','.join(['SpecREDS', str(long_rec_list[SUPER]), str(short_rec_list[SUPER]),
                                str(long_rec_list[SUPER]), str(short_timeout+5),
                                str(short_rec_list[SUPER])])
    oracle_line = ','.join(['Oracle', str(long_rec_list[RBD]), str(short_rec_list[RBD]),
                            str(long_rec_list[RBD]), str(short_timeout+5),
                            str(short_rec_list[RBD])])

    output_file.write('\n'.join([reds_line, spec_clone_line, spec_super_line, oracle_line]))

