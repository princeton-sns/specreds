
import sys
import csv
import matplotlib.pyplot as plt

# plt.rcParams.update({'font.size': 8.5})
# plt.rcParams.update({'font.family': 'Times New Roman'})

if len(sys.argv) != 3:
    print('need two arguments', file=sys.stderr)

input_path = sys.argv[1]
output_path = sys.argv[2]

target_perc = ['80', '90', '95', '99', '99.9', '99.99']

X = []
base = []
dfork = []
rbd = []
with open(input_path, 'r') as input_file:
    input_csv = csv.reader(input_file)
    next(input_csv)
    for row in input_csv:
        if row[0] in target_perc:
            X.append(row[0])
            base.append(float(row[1])/1000/1000)
            dfork.append(float(row[2])/1000/1000)
            rbd.append(float(row[3])/1000/1000)

a = range(1, len(X)+1)

# fig, ax = plt.subplots(figsize=(1.836, 2.0))
fig, ax = plt.subplots(figsize=(3.2, 3.0))

linestyle = 'solid'
ax.plot(a, base, color='lime', marker='|', linestyle=linestyle, markersize=5, linewidth=0.7,
        label='rbd')
ax.plot(a, dfork, color='blue', marker='D', linestyle=linestyle, markersize=3, linewidth=0.7,
        label='super')
ax.plot(a, rbd, color='r', marker='x', linestyle=linestyle, linewidth=0.7,
        label='rbd-clone')

# ax.legend(bbox_to_anchor=(0., 1.13, 1., .099), loc='upper left', ncol=1, borderaxespad=0.)
ax.legend()
ax.xaxis.set_ticks(a)
ax.xaxis.set_ticklabels(X, rotation=20)

# ax.set_ylim([0, 100])
# ax.yaxis.set_minor_locator(tck.MultipleLocator(10))
# ax.yaxis.set_ticks([0, 20, 40, 60, 80, 100])
# ax.yaxis.set_ticklabels([0, 20, 40, 60, 80, 100])

ax.grid(axis='y', alpha=0.5)
plt.xlabel('Percentile')
plt.ylabel('Latency (ms)')

fig.tight_layout()
# plt.show()
plt.savefig(output_path, format='pdf', bbox_inches='tight')

