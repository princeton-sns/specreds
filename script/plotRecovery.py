
import sys
import csv
import numpy as np
import matplotlib.pyplot as plt

# plt.rcParams.update({'font.size': 17})
# plt.rcParams.update({'font.family': 'Times New Roman'})

if len(sys.argv) != 3:
    print('need two arguments', file=sys.stderr)

input_path = sys.argv[1]
output_path = sys.argv[2]

with open(input_path, 'r') as input_file:
    input_csv = csv.reader(input_file)
    raw_list = []
    for row in input_csv:
        raw_list.append(row)
raw_list = np.array(raw_list)

hatches = ['//', ' ', '\\\\']
colors = ['lime', 'blue', 'white']
edge_colors = ['black', 'black', 'red']
y_label = raw_list[0][0]
legend_list = raw_list[1:, 0]
app_list = raw_list[0, 1:]
lang_list = []
for app in app_list:
    lang = app.split('-')[-1]
    if lang not in lang_list:
        lang_list.append(lang)
lang_count = [0]*len(lang_list)
for app in app_list:
    lang_count[lang_list.index(app.split('-')[-1])] += 1

app_list = ['-'.join(item.split('-')[:-1])+'\n'+item.split('-')[-1] for item in app_list]
for i in range(len(app_list)):
    app_list[i] = '\n'.join(app_list[i].split('&'))

data_list = raw_list[1:, 1:].astype(float)

fig, ax = plt.subplots(figsize=(4.8, 3.0))
ax.tick_params(labelright=True, right=True)
ax.tick_params(axis='y', which='minor', right=True)

base_loc = np.arange(len(app_list))
width = 0.2
num_legends = len(legend_list)
for i in range(num_legends):
    shift = i - num_legends // 2 + 0.5 * ((num_legends + 1) % 2)
    ax.bar(base_loc+width*shift, data_list[i], width, color=colors[i], edgecolor=edge_colors[i], hatch=hatches[i],
           label=legend_list[i])
    ax.bar(base_loc + width * shift, data_list[i], width, color='none', edgecolor='k')

ax.set_ylabel(y_label)
ax.set_xticks(base_loc)
ax.set_xticklabels(app_list)
ax.tick_params(axis='y', which='major')
ax.legend()

# ax.set_ylim([0, 160])     # set ylim here to enlarge

fig.tight_layout()
# plt.show()
plt.savefig(output_path, format='pdf', bbox_inches='tight')

