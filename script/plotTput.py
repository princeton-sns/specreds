
import sys
import csv
import numpy as np
import matplotlib.pyplot as plt

if len(sys.argv) != 5:
    print('need four arguments', file=sys.stderr)
    exit(1)

naive_path = sys.argv[1]
dfork_path = sys.argv[2]
nceph_path = sys.argv[3]

output_path = sys.argv[4]

naive_list = []
with open(naive_path, 'r') as input_file:
    input_csv = csv.reader(input_file)
    for row in input_csv:
        naive_list.append(float(row[0]))
dfork_list = []
with open(dfork_path, 'r') as input_file:
    input_csv = csv.reader(input_file)
    for row in input_csv:
        dfork_list.append(float(row[0]))
nceph_list = []
with open(nceph_path, 'r') as input_file:
    input_csv = csv.reader(input_file)
    for row in input_csv:
        nceph_list.append(float(row[0]))

fig, ax = plt.subplots(figsize=(4.8, 3.0))

ax.plot(np.array(range(len(naive_list))), naive_list, color='lime', linestyle='solid', linewidth=0.7, label='REDS')
ax.plot(np.array(range(len(dfork_list))), dfork_list, color='blue', linestyle='solid', linewidth=0.7, label='SpecREDS')
ax.plot(np.array(range(len(nceph_list))), nceph_list, color='r', linestyle='solid', linewidth=0.7, label='SpecREDS(rbd-clone)')

ax.legend()
plt.xlabel('Time after recovery (s)')
plt.ylabel('Throughput (req/s)')

fig.tight_layout()
# plt.show()
plt.savefig(output_path, format='pdf', bbox_inches='tight')

