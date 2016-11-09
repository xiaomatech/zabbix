#!/usr/bin/env python
"""
Zabbix Monitoring template for etcd node stats.

Examples:
$ ./etcd-stats.py --metric leader:followers/node.domain.tld/counts/fail
$ ./etcd-stats.py --metric self:recvAppendRequestCnt
$ ./etcd-stats.py --metric store:watchers

"""
import json
import os
import urllib2
import time

from base64 import b16encode
from optparse import OptionParser
from sys import exit, stderr

stats_cache_file_tmpl = '/tmp/zbx_etcd_stats_{type}_{url}.txt'


def get_stats(url, stats, timeout=60):
    '''Get the specified stats from the etcd (or from cached data) and return JSON.'''

    # generate path for cache file
    cache_file = stats_cache_file_tmpl.format(type=stats, url=b16encode(url))

    # get the age of the cache file
    if os.path.exists(cache_file):
        cache_age = int(time.time() - os.path.getmtime(cache_file))
    else:
        cache_age = timeout

    # read stats from cache if it's still valid
    if cache_age < timeout:
        with open(cache_file, 'r') as c:
            raw_json = c.read()

    # if not get, get the fresh stats from the etcd server
    else:
        try:
            raw_json = urllib2.urlopen('%s/v2/stats/%s' % (url, stats)).read()
        except (urllib2.URLError, ValueError) as e:
            print >> stderr, '%s (%s)' % (e, url)
            return None

        try:
            # save the contents to cache_file
            cache_file_tmp = open(cache_file + '.tmp', "w")
            cache_file_tmp.write(raw_json)
            cache_file_tmp.flush()
            cache_file_tmp.close()
            os.rename(cache_file + '.tmp', cache_file)
        except:
            pass

    # finally return the parsed response
    try:
        response = json.loads(raw_json)
    except Exception as e:  # improve this...
        print >> stderr, e
        return None

    return response


def get_metric(url, metric, timeout=60):
    '''Get the specified metric from the stats dict and return it's value.'''

    parsed_metric = metric.split(':')

    if len(parsed_metric) != 2:
        print >> stderr, "Wrong metric syntax (%s)" % metric
        return None

    mtype = parsed_metric[0].lower()
    mlookup = parsed_metric[1].split('/')

    # get fresh stats
    stats = get_stats(url, mtype, timeout)
    if type(stats) is not dict:
        return None

    # leaders can't have counts/latency metrics,
    # return -1 if stats for leader were requested
    if mtype == 'leader':
        h = mlookup[1]
        l = stats['leader']
        if h == l:
            return None

    # get metric value and return it
    return reduce(lambda parent, child: parent.get(child, None), mlookup,
                  stats)


if __name__ == "__main__":
    parser = OptionParser(
        usage='usage: %prog --metric <type:metric> [--url http://localhost:4001] [--timeout 60]'
    )
    parser.add_option("--metric", dest="metric")
    parser.add_option("--timeout", dest="timeout", default=30, type="int")
    parser.add_option("--url", dest="url", default="http://localhost:4001")

    options, args = parser.parse_args()

    if not options.metric:
        parser.error('Metric (--metric) must be provided')
    elif options.metric.endswith(".RAW"):
        result = get_stats(options.url,
                           options.metric.split(':')[0], options.timeout)
        result = json.dumps(
            result, sort_keys=True, indent=4) if result else None
    else:
        result = get_metric(options.url, options.metric, options.timeout)

    if result is not None:
        print result
    else:
        print "ZBX_NOTSUPPORTED"
        exit(1)
