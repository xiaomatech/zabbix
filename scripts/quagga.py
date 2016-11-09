#!/usr/bin/env python

import re

from subprocess import Popen, PIPE


def exec_cmd(cmd):

    p = Popen(cmd, shell=True, stdout=PIPE, stderr=PIPE)

    txt = p.stdout.read()

    p.stdout.close()

    p.stderr.close()

    return txt


def show_running_info(cmd):

    return exec_cmd('/bin/vtysh -c "%s"' % cmd)

# get stats

# show_running_info('show bgp ipv4 unicast summary')

# show_running_info('show bgp ipv4 multicast summary')

# show_running_info('show bgp summary')

# show_running_info('show bgp neighbors')

# show_running_info('show ip bgp neighbors')

# show_running_info('show ip bgp summary')

# show_running_info('show bgp ipv4 vpnv4 statistics')

# show_running_info('show bgp ipv4 unicast statistics')

# show_running_info('show bgp ipv4 multicast statistics')

# show_running_info('show ip ospf')

# show_running_info('show ip ospf neighbor detail all')

# show_running_info('show ip ospf route')

# show_running_info('show ip prefix-list detail')

# show_running_info('show ip route')

# show_running_info('show ip route summary')

# show_running_info('show interface description')


def get_running_config():

    running_config = exec_cmd('/bin/vtysh -c "show run"')

    got_global_config = False

    got_interface_config = False

    interface_config = {}

    global_config = []

    for line in running_config:

        line = line.lower().strip()

        # ignore the '!' lines or blank lines

        if len(line.strip()) <= 1:

            if got_global_config:

                got_global_config = False

            if got_interface_config:

                got_interface_config = False

            continue

        # begin capturing global config

        m0 = re.match('router\s+ospf', line)

        if m0:

            got_global_config = True

            continue

        m1 = re.match('^interface\s+(\w+)', line)

        if m1:

            ifacename = m1.group(1)

            interface_config[ifacename] = []

            got_interface_config = True

            continue

        if got_interface_config:

            interface_config[ifacename].append(line)

            continue

        if got_global_config:

            m3 = re.match('\s*passive-interface\s+(\w+)', line)

            if m3:

                ifaceconfig = interface_config.get(m3.group(1))

                if ifaceconfig:

                    ifaceconfig.append('passive-interface')

            else:

                global_config.append(line)

            continue
