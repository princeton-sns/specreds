
import sys
import csv
import numpy as np
import matplotlib.pyplot as plt
# import matplotlib.ticker as tck

# plt.rcParams.update({'font.size': 8.5})
# plt.rcParams.update({'font.family': 'Times New Roman'})

if len(sys.argv) != 3:
    print('need two arguments', file=sys.stderr)

input_path = sys.argv[1]
output_path = sys.argv[2]

X = []
Y = []
with open(input_path, 'r') as input_file:
    input_csv = csv.reader(input_file)
    next(input_csv)
    for row in input_csv:
        X.append(int(row[0]))
        Y.append([float(row[1]), float(row[2]), float(row[3])])
X = np.array(X)
Y = np.array(Y)
Y_base = [x/1000 for x in Y[:, 0]]
Y_dfork = [x/1000 for x in Y[:, 1]]
Y_rbd = [x/1000 for x in Y[:, 2]]
a = range(1, len(X)+1)

fig, ax = plt.subplots(figsize=(3.2, 3.0))

ax.plot(a, Y_base, color='lime', marker='|', linestyle='solid', markersize=5, linewidth=0.7,
        label='rbd')
ax.plot(a, Y_dfork, color='blue', marker='D', linestyle='solid', markersize=3, linewidth=0.7,
        label='super')
ax.plot(a, Y_rbd, 'rx-', linewidth=0.7, label='rbd-clone')

ax.legend()
# ax.legend(bbox_to_anchor=(0., 1.10, 1., .099), loc='upper left', ncol=1, borderaxespad=0.)
ax.xaxis.set_ticks(a)
ax.xaxis.set_ticklabels(X)
# ax.set_ylim([0, 7])
# ax.yaxis.set_minor_locator(tck.MultipleLocator(1))
# ax.set_yticks([0, 2, 4, 6])

ax.grid(axis='y', alpha=0.5)
plt.xlabel('Write size (KB)')
plt.ylabel('Mean latency (ms)')

fig.tight_layout()
# plt.show()
plt.savefig(output_path, format='pdf', bbox_inches='tight')

