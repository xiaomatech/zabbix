#!/usr/bin/python
# vim: set expandtab:
import boto
import boto.ec2.elb
import argparse


def main():

    cmd_parser = argparse.ArgumentParser(description='Send ELB Info To Zabbix')
    cmd_parser.add_argument(
        '-k',
        '--aws_access_key_id',
        dest='key',
        help='AWS Access Key ID',
        required=True)
    cmd_parser.add_argument(
        '-s',
        '--aws_secret_key_id',
        dest='secret',
        help='AWS Secret Access Key',
        required=True)
    cmd_parser.add_argument(
        '-r', '--region', dest='region', help='AWS Region', required=True)
    cmd_parser.add_argument(
        '-n', '--name', dest='name', help='Zabbix Name', required=True)
    args = cmd_parser.parse_args()
    conn = boto.ec2.elb.connect_to_region(
        args.region,
        aws_access_key_id=args.key,
        aws_secret_access_key=args.secret)
    elbs = conn.get_all_load_balancers()
    total_elbs = len(elbs)
    outofservice = 0
    outofservice_elbs = []
    outofservice_instance = []
    for elb in elbs:
        inst_health = conn.describe_instance_health(elb.name)
        for inst_h in inst_health:
            if inst_h.state != 'InService':
                outofservice = outofservice + 1
                outofservice_elbs.append(elb.name)
                outofservice_instance.append(inst_h.instance_id)

    if not outofservice_elbs:
        outofservice_elbs = 'none'
    if not outofservice_instance:
        outofservice_instance = 'none'

    outofservice = str(outofservice)
    total_elbs = str(total_elbs)
    outofservice_elbs = str(outofservice_elbs).strip('[]').strip('u')
    outofservice_instance = str(outofservice_instance).strip('[]').strip('u')

    print(args.name + ' total_elbs ' + total_elbs)
    print(args.name + ' num_out_of_service ' + outofservice)
    print(args.name + ' elbs_with_out_of_service_instances ' +
          outofservice_elbs)
    print(args.name + ' instance_id ' + outofservice_instance)


if __name__ == "__main__":
    main()
