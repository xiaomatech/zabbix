#!/usr/bin/python
# -*- coding:utf8 -*-
stat = '/tmp/fdfs.stat'

from subprocess import Popen, PIPE
p = Popen('/usr/bin/fdfs_monitor /etc/fdfs/client.conf',
          shell=True,
          stdout=PIPE,
          stderr=PIPE)
txt = p.stdout.read()
p.stdout.close()
p.stderr.close()

groups = []

line_list = txt.split('group name = ')
for item in line_list:
    groups.append(item)

group2 = groups[1:]
fdfs = {}

fp = open(stat, 'wb+')

for tmp2 in group2:
    group = tmp2.split('\n')
    group_name = group[0]
    tmp3 = []
    for tmp in group[1:]:
        item = tmp.split('=')
        if len(item) >= 2:
            fp.write(group_name + ' ' + item[0].strip('\t\t') + ' ' + item[
                1].strip('\n') + '\n')

fp.close()
