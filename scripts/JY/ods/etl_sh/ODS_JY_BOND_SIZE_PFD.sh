#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_SIZE_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_SIZE_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  MAINCODE  STRING  COMMENT  '基金主代码',
  ENDDATE  STRING  COMMENT  '日期',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  INFORSOURCE  STRING  COMMENT  '信息来源',
  TOTALSIZE  DECIMAL(19,8)  COMMENT  '总规模(百万元)',
  EXCHANGEANDIBSIZE  DECIMAL(19,8)  COMMENT  '1、交易所及银行间规模(百万元)',
  EXCHANGESIZE  DECIMAL(19,8)  COMMENT  '#交易所规模(百万元)',
  IBSIZE  DECIMAL(19,8)  COMMENT  '#银行间规模(百万元)',
  OTCSIZE  DECIMAL(19,8)  COMMENT  '2、柜台规模(百万元)',
  OTHERSIZE  DECIMAL(19,8)  COMMENT  '3、其他规模(百万元)',
  CURRENTSIZECHANGE  DECIMAL(19,8)  COMMENT  '本次规模增减(百万元)',
  ALTERATIONREMARK  STRING  COMMENT  '变动原因说明',
  ALTERATIONTYPE  DECIMAL(10,0)  COMMENT  '变动原因类别',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID'
)
COMMENT '债券规模'
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
                                   , MAINCODE
                                   , ENDDATE
                                   , INFOPUBLDATE
                                   , INFORSOURCE
                                   , TOTALSIZE
                                   , EXCHANGEANDIBSIZE
                                   , EXCHANGESIZE
                                   , IBSIZE
                                   , OTCSIZE
                                   , OTHERSIZE
                                   , CURRENTSIZECHANGE
                                   , ALTERATIONREMARK
                                   , ALTERATIONTYPE
                                   , UPDATETIME
                                   , JSID
                                FROM ${jy_src_schema}.BOND_SIZE"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "MAINCODE", "type": "DOUBLE"}, {"name": "ENDDATE", "type": "STRING"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "INFORSOURCE", "type": "STRING"}, {"name": "TOTALSIZE", "type": "DOUBLE"}, {"name": "EXCHANGEANDIBSIZE", "type": "DOUBLE"}, {"name": "EXCHANGESIZE", "type": "DOUBLE"}, {"name": "IBSIZE", "type": "DOUBLE"}, {"name": "OTCSIZE", "type": "DOUBLE"}, {"name": "OTHERSIZE", "type": "DOUBLE"}, {"name": "CURRENTSIZECHANGE", "type": "DOUBLE"}, {"name": "ALTERATIONREMARK", "type": "STRING"}, {"name": "ALTERATIONTYPE", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_size_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_size_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_size_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_size_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_SIZE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_SIZE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_size_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_SIZE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , MAINCODE
     , ENDDATE
     , INFOPUBLDATE
     , INFORSOURCE
     , TOTALSIZE
     , EXCHANGEANDIBSIZE
     , EXCHANGESIZE
     , IBSIZE
     , OTCSIZE
     , OTHERSIZE
     , CURRENTSIZECHANGE
     , ALTERATIONREMARK
     , ALTERATIONTYPE
     , UPDATETIME
     , JSID
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_BOND_SIZE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_SIZE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_SIZE_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_SIZE_PFD成功"
      exit 0
   fi
fi
