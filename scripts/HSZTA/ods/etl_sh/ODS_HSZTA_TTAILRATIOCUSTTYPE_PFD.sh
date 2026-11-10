#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TTAILRATIOCUSTTYPE_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TTAILRATIOCUSTTYPE_PFD_TMP(
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_AGENCYNO  STRING  COMMENT  '销售商代码',
  C_CUSTTYPE  STRING  COMMENT  '客户类型',
  C_FLAG  STRING  COMMENT  '是否已经发起',
  D_BEGINDATE  STRING  COMMENT  '启用日期',
  F_HOLDMIN  DECIMAL(20,6)  COMMENT  '最小保有金额',
  F_HOLDMAX  DECIMAL(20,6)  COMMENT  '最大保有金额',
  F_RATIO  DECIMAL(9,8)  COMMENT  '尾随佣金比例',
  C_CALCULATETYPE  STRING  COMMENT  '尾随佣金计算方式',
  F_MINTAILFARE  DECIMAL(16,2)  COMMENT  '尾随佣金起付金额',
  L_YEARDAYS  DECIMAL(4,0)  COMMENT  '尾随佣金年天数',
  C_TAILSEGMENT  STRING  COMMENT  '是否累进计算',
  C_UPDATEFLAG  STRING  COMMENT  '是否更新标志',
  F_AGENCYFEERATIO  DECIMAL(8,7)  COMMENT  '销售费用比例',
  C_FOFEXTERNALRATIOFLAG  STRING  COMMENT  '',
  D_ENDDATE  STRING  COMMENT  '失效日期',
  C_TAILRATIONTYPE  STRING  COMMENT  '尾随佣金比例类型',
  F_MANAGERRATIO  DECIMAL(9,8)  COMMENT  '管理人比例'
)
COMMENT ''
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
            "username": "${hszta_username}",
            "password": "${hszta_password}",
            "connection": [{
              "querySql": ["SELECT  C_FUNDCODE
                                   , C_AGENCYNO
                                   , C_CUSTTYPE
                                   , C_FLAG
                                   , D_BEGINDATE
                                   , F_HOLDMIN
                                   , F_HOLDMAX
                                   , F_RATIO
                                   , C_CALCULATETYPE
                                   , F_MINTAILFARE
                                   , L_YEARDAYS
                                   , C_TAILSEGMENT
                                   , C_UPDATEFLAG
                                   , F_AGENCYFEERATIO
                                   , C_FOFEXTERNALRATIOFLAG
                                   , D_ENDDATE
                                   , C_TAILRATIONTYPE
                                   , F_MANAGERRATIO
                                FROM ${hszta_src_schema}.TTAILRATIOCUSTTYPE"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_CUSTTYPE", "type": "STRING"}, {"name": "C_FLAG", "type": "STRING"}, {"name": "D_BEGINDATE", "type": "STRING"}, {"name": "F_HOLDMIN", "type": "DOUBLE"}, {"name": "F_HOLDMAX", "type": "DOUBLE"}, {"name": "F_RATIO", "type": "DOUBLE"}, {"name": "C_CALCULATETYPE", "type": "STRING"}, {"name": "F_MINTAILFARE", "type": "DOUBLE"}, {"name": "L_YEARDAYS", "type": "DOUBLE"}, {"name": "C_TAILSEGMENT", "type": "STRING"}, {"name": "C_UPDATEFLAG", "type": "STRING"}, {"name": "F_AGENCYFEERATIO", "type": "DOUBLE"}, {"name": "C_FOFEXTERNALRATIOFLAG", "type": "STRING"}, {"name": "D_ENDDATE", "type": "STRING"}, {"name": "C_TAILRATIONTYPE", "type": "STRING"}, {"name": "F_MANAGERRATIO", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_ttailratiocusttype_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_ttailratiocusttype_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_ttailratiocusttype_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_ttailratiocusttype_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TTAILRATIOCUSTTYPE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TTAILRATIOCUSTTYPE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_ttailratiocusttype_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TTAILRATIOCUSTTYPE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_FUNDCODE
     , C_AGENCYNO
     , C_CUSTTYPE
     , C_FLAG
     , D_BEGINDATE
     , F_HOLDMIN
     , F_HOLDMAX
     , F_RATIO
     , C_CALCULATETYPE
     , F_MINTAILFARE
     , L_YEARDAYS
     , C_TAILSEGMENT
     , C_UPDATEFLAG
     , F_AGENCYFEERATIO
     , C_FOFEXTERNALRATIOFLAG
     , D_ENDDATE
     , C_TAILRATIONTYPE
     , F_MANAGERRATIO
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TTAILRATIOCUSTTYPE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TTAILRATIOCUSTTYPE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TTAILRATIOCUSTTYPE_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TTAILRATIOCUSTTYPE_PFD成功"
      exit 0
   fi
fi
