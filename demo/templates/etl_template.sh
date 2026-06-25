#!/bin/sh
source ${hadoop_env}
source ${source_path}
inceptor_beeline() {
 beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password} -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主题: ${target_table_cn}
-- ** 描述: ${func_desc}
-- ** 创建者:auto
-- ** 创建日期:auto
-- ** 修改日志:
-- ** auto，新建
-- ** 目标表：${schema}.${target_table} ${target_table_cn}
-- ** 源表：
${source_tables}
-- **************************************************************************

set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions.pernode=10000;
set hive.exec.max.dynamic.partitions=10000;
set hive.exec.max.created.files=10000;
set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
set hive.exec.reducers.bytes.per.reducer=10240000000;
set mapreduce.job.reduces=2;

INSERT OVERWRITE TABLE ${schema}.${target_table} PARTITION(P_DT = '${partition_value}')
SELECT
${select_columns}
${from_join_clause}
${where_clause}
 ;"