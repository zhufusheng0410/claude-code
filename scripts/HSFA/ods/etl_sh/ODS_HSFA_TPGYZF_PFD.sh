#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TPGYZF_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TPGYZF_PFD_TMP(
  L_SCLB  STRING  COMMENT  '市场代码',
  VC_SCZQDM  STRING  COMMENT  '市场证券代码',
  D_SCSJ  STRING  COMMENT  '生成时间',
  L_OPERATORID  DECIMAL(4,0)  COMMENT  '操作人员ID',
  VC_BZ  STRING  COMMENT  '备注',
  L_PGZF  DECIMAL(1,0)  COMMENT  '配股增发',
  D_YWRQ  STRING  COMMENT  '业务日期',
  D_DJRQ  STRING  COMMENT  '登记日期',
  D_JKJZRQ  STRING  COMMENT  '缴款截止日期',
  D_QRRQ  STRING  COMMENT  '确认日期',
  L_ZQNM  DECIMAL(18,2)  COMMENT  '证券内码',
  L_CHECKER  DECIMAL(4,0)  COMMENT  '复核人',
  EN_PRICE  DECIMAL(19,4)  COMMENT  '配股价格',
  EN_QYBL  DECIMAL(23,12)  COMMENT  '权益比例'
)
COMMENT '配股对照表'
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
            "username": "${hsfa_username}",
            "password": "${hsfa_password}",
            "connection": [{
              "querySql": ["SELECT  L_SCLB
                                   , VC_SCZQDM
                                   , D_SCSJ
                                   , L_OPERATORID
                                   , VC_BZ
                                   , L_PGZF
                                   , TO_CHAR(D_YWRQ,'YYYYMMDD') D_YWRQ
                                   , D_DJRQ
                                   , D_JKJZRQ
                                   , D_QRRQ
                                   , L_ZQNM
                                   , L_CHECKER
                                   , EN_PRICE
                                   , EN_QYBL
                                FROM ${hsfa_src_schema}.TPGYZF"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_SCLB", "type": "DOUBLE"}, {"name": "VC_SCZQDM", "type": "STRING"}, {"name": "D_SCSJ", "type": "STRING"}, {"name": "L_OPERATORID", "type": "DOUBLE"}, {"name": "VC_BZ", "type": "STRING"}, {"name": "L_PGZF", "type": "DOUBLE"}, {"name": "D_YWRQ", "type": "STRING"}, {"name": "D_DJRQ", "type": "STRING"}, {"name": "D_JKJZRQ", "type": "STRING"}, {"name": "D_QRRQ", "type": "STRING"}, {"name": "L_ZQNM", "type": "DOUBLE"}, {"name": "L_CHECKER", "type": "DOUBLE"}, {"name": "EN_PRICE", "type": "DOUBLE"}, {"name": "EN_QYBL", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tpgyzf_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tpgyzf_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tpgyzf_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tpgyzf_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TPGYZF_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TPGYZF_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tpgyzf_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TPGYZF_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_SCLB
     , VC_SCZQDM
     , D_SCSJ
     , L_OPERATORID
     , VC_BZ
     , L_PGZF
     , D_YWRQ
     , D_DJRQ
     , D_JKJZRQ
     , D_QRRQ
     , L_ZQNM
     , L_CHECKER
     , EN_PRICE
     , EN_QYBL
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TPGYZF_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TPGYZF_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TPGYZF_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TPGYZF_PFD成功"
      exit 0
   fi
fi
