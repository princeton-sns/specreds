
import sys
import pandas

if len(sys.argv) != 3:
    print('need two arguments', file=sys.stderr)
    exit(1)

input_path = sys.argv[1]
output_path = sys.argv[2]

data = pandas.read_csv(input_path)
tput_list = data[' throughput(req/sec)'].tolist()

with open(output_path, 'w') as output_file:
    output_file.write('\n'.join(str(x) for x in tput_list))

