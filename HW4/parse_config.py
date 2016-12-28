#! /usr/local/bin/python3

import time
import calendar

start_time=int(int(input())/60)
# a fucking start time

dataset_list = {}
tmp_dataset = ""
enable_flag = 1


with open("/usr/local/etc/zbackup_copy.conf") as f:
    content = f.readlines()

cur_time = int(calendar.timegm(time.gmtime())/60)

for x in content:
    if x[0] == '[':
        #print(x[1:-2])
        tmp_dataset = x[1:-2]
        dataset_list[tmp_dataset] = ""
    elif x[0] == 'e':
        #print(x[x.index('=')+1:-1])
        if x[x.index('=') + 1: -1] == "no":
            #print(tmp_dataset,"not enable!!!!")
            del dataset_list[tmp_dataset]
            enable_flag = 0
    elif x[0] == 'p':
        if enable_flag == 0:
            pass
        else:
            policy = x[x.index('=')+1: -1]
            rotation_count = policy[0: policy.index('x')]
            dataset_list[tmp_dataset] = rotation_count + " "
            if policy[-1] == 'm':
                dataset_list[tmp_dataset] += str((-1*(start_time - cur_time))% \
                    int(policy[policy.index('x') + 1: -1]))
            elif policy[-1] == 'h':
                dataset_list[tmp_dataset] += str((-1*(start_time - cur_time))% \
                    (int(policy[policy.index('x') + 1: -1]) * 60) )
            elif policy[-1] == 'd':
                dataset_list[tmp_dataset] += str((-1*(start_time - cur_time))% \
                    (int(policy[policy.index('x') + 1: -1]) * 1440) )
            elif policy[-1] == 'w':
                dataset_list[tmp_dataset] += str((-1*(start_time - cur_time))% \
                    (int(policy[policy.index('x') + 1: -1]) * 10080) )
    enable_flag = 1


output_dataset_list = {}

smallest_time = 1000000000

for x in dataset_list:
    val = dataset_list[x]
    wait_time = int(val[dataset_list[x].index(' '): ])
    if wait_time < smallest_time:
        output_dataset_list = {}
        output_dataset_list[x] = dataset_list[x]
        smallest_time = wait_time
    elif wait_time == smallest_time:
        output_dataset_list[x] = dataset_list[x]

for x in output_dataset_list:
    print(x + " " + output_dataset_list[x])