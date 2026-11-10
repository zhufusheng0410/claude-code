#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_CONBDPUTINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_CONBDPUTINFO_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  DATATYPE  DECIMAL(3,0)  COMMENT  '数据类别',
  PAYMENTYEAR  DECIMAL(3,0)  COMMENT  '付息年度',
  IFUNIQUE  DECIMAL(3,0)  COMMENT  '回售价格是否唯一',
  PUTPRICE  DECIMAL(19,4)  COMMENT  '回售价',
  PUTTYPE  DECIMAL(3,0)  COMMENT  '行使权力次数',
  PUTTYPENAME  STRING  COMMENT  '行使权力次数名称',
  PUTSTARTDATE  STRING  COMMENT  '修正开始日期',
  PUTENDDATE  STRING  COMMENT  '修正结束日期',
  PUTLEVEL  DECIMAL(9,4)  COMMENT  '修正触发转股价比例',
  TRIGGERDAYS  DECIMAL(10,0)  COMMENT  '触发所需天数(日)',
  REACHDAYS  DECIMAL(10,0)  COMMENT  '回售条件满足天数',
  IFINTEREST  DECIMAL(3,0)  COMMENT  '是否包含应记利息',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  MULTILEVEL  DECIMAL(10,0)  COMMENT  '多个触发比例筛选'
)
COMMENT '可转债券回售信息'
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\\u0001';"

json_obj=$(cat <<'EOF'
{
  "job": {
    "setting": {
      "speed": {
        "channel": 1
      },
      "errorLimit": {
        "record": 0,
        "percentage": 0.02
      }
    },
    "content": [
      {
        "reader": {
          "name": "oraclereader",
          "parameter": {
            "username": "${jy_username}",
            "password": "${jy_password}",
            "connection": [{
              "querySql": ["SELECT  ID
                                   , INNERCODE
                                   , DATATYPE
                                   , PAYMENTYEAR
                                   , IFUNIQUE
                                   , PUTPRICE
                                   , PUTTYPE
                                   , PUTTYPENAME
                                   , PUTSTARTDATE
                                   , PUTENDDATE
                                   , PUTLEVEL
                                   , TRIGGERDAYS
                                   , REACHDAYS
                                   , IFINTEREST
                                   , UPDATETIME
                                   , JSID
                                   , MULTILEVEL
                                FROM ${jy_src_schema}.BOND_CONBDPUTINFO"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "DATATYPE", "type": "DOUBLE"}, {"name": "PAYMENTYEAR", "type": "DOUBLE"}, {"name": "IFUNIQUE", "type": "DOUBLE"}, {"name": "PUTPRICE", "type": "DOUBLE"}, {"name": "PUTTYPE", "type": "DOUBLE"}, {"name": "PUTTYPENAME", "type": "STRING"}, {"name": "PUTSTARTDATE", "type": "STRING"}, {"name": "PUTENDDATE", "type": "STRING"}, {"name": "PUTLEVEL", "type": "DOUBLE"}, {"name": "TRIGGERDAYS", "type": "DOUBLE"}, {"name": "REACHDAYS", "type": "DOUBLE"}, {"name": "IFINTEREST", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "MULTILEVEL", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_conbdputinfo_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_conbdputinfo_pfd_tmp",
            "writeMode": "append",
            "encoding": "utf-8",
            "haveKerberos": "${haveKerberos}",
            "kerberosKeytabFilePath": "${kerberosKeytabFilePath}",
            "kerberosPrincipal": "${kerberosPrincipal}"
          }
        }
      }
    ]
  }
}
EOF
)

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_conbdputinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_conbdputinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_CONBDPUTINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_CONBDPUTINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_conbdputinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_CONBDPUTINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , DATATYPE
     , PAYMENTYEAR
     , IFUNIQUE
     , PUTPRICE
     , PUTTYPE
     , PUTTYPENAME
     , PUTSTARTDATE
     , PUTENDDATE
     , PUTLEVEL
     , TRIGGERDAYS
     , REACHDAYS
     , IFINTEREST
     , UPDATETIME
     , JSID
     , MULTILEVEL
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_BOND_CONBDPUTINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_CONBDPUTINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_CONBDPUTINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_CONBDPUTINFO_PFD成功"
      exit 0
   fi
fi
