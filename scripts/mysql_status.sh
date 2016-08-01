#!/bin/sh

ZABBIX_SENDER='/usr/bin/env zabbix_sender'
ZABBIX_CONFIG='/etc/zabbix/zabbix_agentd.conf'

#
# REQUIRED binaries: mysqladmin, awk, zabbix_sender.
#
mysqladmin ping | grep -c alive && mysqladmin extended-status | awk -v ct=$1 '
		/Uptime/{print ct, "mysql.status[Uptime]", $4}

		/Bytes_sent/{print ct, "mysql.status[Bytes_sent]", $4}
		/Bytes_received/{print ct, "mysql.status[Bytes_received]", $4}

		/Threads_cached/{print ct, "mysql.status[Threads_cached]", $4}
		/Threads_running/{print ct, "mysql.status[Threads_running]", $4}
		/Threads_created/{print ct, "mysql.status[Threads_created]", $4}
		/Threads_connected/{print ct, "mysql.status[Threads_connected]", $4}

		/Key_reads/{print ct, "mysql.status[Key_reads]", $4}
		/Key_writes/{print ct, "mysql.status[Key_writes]", $4}
		/Key_read_requests/{print ct, "mysql.status[Key_read_requests]", $4}
		/Key_write_requests/{print ct, "mysql.status[Key_write_requests]", $4}

		/Com_begin/{print ct, "mysql.status[Com_begin]", $4}
		/Com_insert/{print ct, "mysql.status[Com_insert]", $4}
		/Com_update/{print ct, "mysql.status[Com_update]", $4}
		/Com_select/{print ct, "mysql.status[Com_select]", $4}
		/Com_commit/{print ct, "mysql.status[Com_commit]", $4}
		/Com_delete/{print ct, "mysql.status[Com_delete]", $4}
		/Com_replace/{print ct, "mysql.status[Com_replace]", $4}
		/Com_rollback/{print ct, "mysql.status[Com_rollback]", $4}

		/Created_tmp_files/{print ct, "mysql.status[Created_tmp_files]", $4}
		/Created_tmp_tables/{print ct, "mysql.status[Created_tmp_tables]", $4}
		/Created_tmp_disk_tables/{print ct, "mysql.status[Created_tmp_disk_tables]", $4}

		/Qcache_hits/{print ct, "mysql.status[Qcache_hits]", $4}
		/Qcache_inserts/{print ct, "mysql.status[Qcache_inserts]", $4}
		/Qcache_not_cached/{print ct, "mysql.status[Qcache_not_cached]", $4}
		/Qcache_free_memory/{print ct, "mysql.status[Qcache_free_memory]", $4}
		/Qcache_lowmem_prunes/{print ct, "mysql.status[Qcache_lowmem_prunes]", $4}
		/Qcache_queries_in_cache/{print ct, "mysql.status[Qcache_queries_in_cache]", $4}

		/Questions/{print ct, "mysql.status[Questions]", $4}
		/Connections/{print ct, "mysql.status[Connections]", $4}
		/Slow_queries/{print ct, "mysql.status[Slow_queries]", $4}
		/Aborted_connects/{print ct, "mysql.status[Aborted_connects]", $4}
		/Max_used_connections/{print ct, "mysql.status[Max_used_connections]", $4}
	' | $ZABBIX_SENDER --config $ZABBIX_CONFIG \
		--input-file - >/dev/null 2>&1
# For debug:
#		-vv --input-file - >>/var/log/zabbix-agent/$(basename $0).log 2>&1
