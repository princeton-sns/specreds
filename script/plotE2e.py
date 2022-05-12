
import sys
import csv
import numpy as np
import matplotlib.pyplot as plt

if len(sys.argv) != 5:
    print('need four arguments', file=sys.stderr)
    exit(1)

long_timeout = sys.argv[1]
short_timeout = sys.argv[2]
input_path = sys.argv[3]
output_path = sys.argv[4]

with open(input_path, 'r') as input_file:
    input_csv = csv.reader(input_file)
    raw_list = []
    for row in input_csv:
        raw_list.append(row)
raw_list = np.array(raw_list)

hatches = ['//', '\\\\', ' ', '*']
colors = ['lime', 'w', 'blue', 'orange']
edge_colors = ['black', 'red', 'black', 'black']
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

for i in range(len(app_list)):
    app_list[i] = '\n'.join(app_list[i].split('&'))
data_list = raw_list[1:, 1:].astype(float)


fig, ax = plt.subplots(figsize=(6.0, 3.0))
ax.tick_params(labelright=True, right=True)
ax.tick_params(axis='y', which='minor', right=True)

base_loc = np.arange(len(app_list))
width = 0.16
num_legends = len(legend_list)
for i in range(num_legends):
    shift = i - num_legends // 2 + 0.5 * ((num_legends + 1) % 2)
    ax.bar(base_loc+width*shift, data_list[i], width, color=colors[i], edgecolor=edge_colors[i], hatch=hatches[i],
           label=legend_list[i])
    ax.bar(base_loc + width * shift, data_list[i], width, color='none', edgecolor='k')

ax.plot((2-.5, 2-.5), (0, ax.get_ylim()[1]*0.95), 'black', linestyle='dashdot')

ax.set_ylabel(y_label)
ax.set_xlabel('Recovery length')
ax.set_xticks(base_loc)
ax.set_xticklabels(app_list)
ax.tick_params(axis='y', which='major')

ax.legend(bbox_to_anchor=(0., 1.24, 1., .099), loc='upper right', ncol=2, borderaxespad=0.)

# ax.set_ylim([0, 160])    # set ylim here to zoom out

txt_height = ax.get_ylim()[1]*0.9
ax.text(0.1, txt_height, 'Timeout='+str(long_timeout)+'s', color='k')
ax.text(2.5, txt_height, 'Timeout='+str(short_timeout)+'s', color='k')

txt_height = ax.get_ylim()[1]*0.8
ax.text(0+.05, txt_height, '(I)', color='k')
ax.text(1+.05, txt_height, '(II)', color='k')
ax.text(2+.05, txt_height, '(III)', color='k')
ax.text(3+.05, txt_height, '(IV)', color='k')
ax.text(4+.05, txt_height, '(V)', color='k')

fig.tight_layout()
# plt.show()
plt.savefig(output_path, format='pdf', bbox_inches='tight')

