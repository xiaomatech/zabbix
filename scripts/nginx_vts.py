#!/usr/bin/env python

#coding=utf8

import json

import re

import urllib

req_status_url = 'http://127.0.0.1:80/_req_status'

req_status_headers = [
    'server_name', 'server_socket', 'bytes_in', 'bytes_out', 'conn_total',
    'req_total', 'http_2xx', 'http_3xx', 'http_4xx', 'http_5xx',
    'http_other_status', 'rt', 'ups_req', 'ups_rt', 'ups_tries', 'http_200',
    'http_206', 'http_302', 'http_304', 'http_403', 'http_404', 'http_416',
    'http_499', 'http_500', 'http_502', 'http_503', 'http_504', 'http_508',
    'http_other_detail_status', 'http_ups_4xx', 'http_ups_5x'
]


def fetch(url):

    conn = urllib.urlopen(url)

    try:

        data = conn.read()

    finally:

        conn.close()

    return data


def server_status():

    res = {}

    req_datas = fetch(req_status_url).split('\n')

    for req_data in req_datas:

        if req_data:

            req_status = dict(
                zip(req_status_headers, re.split(',', req_data.strip())))

            res.update({req_status['server_name']: req_status})

    return json.dumps(res)


if __name__ == '__main__':

    print server_status()
