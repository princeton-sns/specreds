
import sys
import csv
import matplotlib.pyplot as plt

# plt.rcParams.update({'font.size': 8.5})
# plt.rcParams.update({'font.family': 'Times New Roman'})

if len(sys.argv) != 3:
    print('need two arguments', file=sys.stderr)

input_path = sys.argv[1]
output_path = sys.argv[2]

X = []
base_avg = []
dfork_avg = []
rbd_avg = []
with open(input_path, 'r') as input_file:
    input_csv = csv.reader(input_file)
    next(input_csv)
    for row in input_csv:
        X.append(int(row[0]))
        base_avg.append((float(row[1]) / 1000))
        dfork_avg.append((float(row[2]) / 1000))
        rbd_avg.append((float(row[3]) / 1000))

a = range(1, len(X)+1)

fig, ax = plt.subplots(figsize=(3.2, 3.0))

linestyle_max = 'solid'
# linestyle_avg = (0, (5, 5))
linestyle_avg = 'solid'
ax.plot(a, base_avg, color='lime', marker='|', linestyle=linestyle_avg, markersize=5, linewidth=0.7,
        label='rbd')
ax.plot(a, dfork_avg, color='blue', marker='D', linestyle=linestyle_avg, markersize=3, linewidth=0.7,
        label='super')
ax.plot(a, rbd_avg, color='r', marker='x', linestyle=linestyle_avg, linewidth=0.7, label='rbd-clone')

ax.legend()
ax.xaxis.set_ticks(a)
ax.xaxis.set_ticklabels(X)

ax.grid(axis='y', alpha=0.5)
plt.xlabel('# of concurrent writes')
plt.ylabel('Mean latency (ms)')

fig.tight_layout()
# plt.show()
plt.savefig(output_path, format='pdf', bbox_inches='tight')

