#!/usr/bin/env python
#coding=utf8
import json
import re

def net_stats(interface=None):
    with open('/proc/net/dev') as dev:
        content=dev.read()
    results=[]
    devices=[]
    if interface==None:
        for i in content.splitlines():
            if ':' in i.split()[0]:
                devices.append(i.split()[0].split(':')[0])
    else:
        devices.append(interface)
    def _calc(interface,content):
        for line in content.splitlines():
            if interface in line:
                try:
                    data = line.split('%s:' % interface)[1].split()
                    rx_bits, tx_bits,rx_errs,tx_errs,rx_drop,tx_drop = (int(data[0]), int(data[8]),int(data[1]) and int(data[2])/int(data[1]) or 0,int(data[9]) and int(data[10])/int(data[9]) or 0,int(data[1]) and int(data[3])/int(data[1]) or 0,int(data[9]) and int(data[11])/int(data[9]) or 0)
                    return {interface:{'rx':rx_bits,'tx':tx_bits,'rx_errs_ratio':rx_errs,'tx_errs_ratio':tx_errs,'rx_drop_ratio':rx_drop,'tx_drop_ratio':tx_drop}}
                except Exception as er:
                    return {interface:{'tx':-1,'tx':-1}}
    for interface in devices:
        results.append(_calc(interface,content))
    return results

def mem_stats():
    mem_info = {}
    with open('/proc/meminfo') as f:
        for line in f:
            mem_info.update({line.split(':')[0]:line.split(':')[1].replace('kB','').strip()})
    return mem_info


def parse_cpu_stat(stat_field):
    assert len(stat_field) >= 7
    stat_info = {'user': int(stat_field[0]),
                 'nice': int(stat_field[1]),
                 'sys': int(stat_field[2]),
                 'idle': int(stat_field[3]),
                 'iowait': int(stat_field[4]),
                 'total': sum([int(e) for e in stat_field])}
    return stat_info


def cpu_stat():
    stat_file = open('/proc/stat')
    stat_infos = dict()
    for line in stat_file:
        fields = line.split()
        if len(fields) > 0 and fields[0].startswith('cpu'):
            stat_infos[fields[0]] = parse_cpu_stat(fields[1:])

    return stat_infos

disk_headers = ['major_number', 'minor_number', 'device_name',
           'reads_requests_completed', 'reads_requests_merged', 'reads_sectors', 'reads_wait_time',
           'writes_requests_completed', 'writes_requests_merged', 'writes_sectors', 'writes_wait_time',
           'requests_currently_in_progress', 'io_wait_time', 'io_wait_time_weighted']


def diskstats():
    result = {}
    with open('/proc/diskstats', 'r') as f:
        for line in f.readlines():
            tmp = dict(zip(disk_headers, re.split('\s+', line.strip())))
            if tmp['device_name'].startswith('loop') or tmp['device_name'].startswith('sr') or tmp['device_name'].startswith('ram'):
                continue
            tmp['reads_bytes'] = str(int(tmp['reads_sectors']) * 512)
            tmp['writes_bytes'] = str(int(tmp['writes_sectors']) * 512)
            result[tmp['device_name']] = tmp

    return result

def load_avg():
    with open('/proc/loadavg') as f:
        line = f.readline()
    load_avg1,load_avg5,load_avg15 = float(line.split()[0]),float(line.split()[1]),float(line.split()[2])  # 1 minute load average
    return {'load1':round( load_avg1,2),'load5':round( load_avg5,2),'load15': round(load_avg15,2)}

def main():
    result={}
    stats=[net_stats,load_avg,diskstats,cpu_stat,mem_stats]
    for func in stats:
        result[func.__name__]=func()
    print json.dumps(result)

if __name__ == '__main__':
    main()




