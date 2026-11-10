#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TQYXX_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TQYXX_PTD_TMP(
  D_DJRQ  STRING  COMMENT  '登记日期',
  L_YWLB  DECIMAL(4,0)  COMMENT  '业务类别',
  L_ZQNM  DECIMAL(10,0)  COMMENT  '证券内码',
  VC_ZQDM  STRING  COMMENT  '证券代码',
  EN_SYBL  DECIMAL(23,12)  COMMENT  '收益比例',
  L_CLBZ  STRING  COMMENT  '处理标志',
  VC_BZ  STRING  COMMENT  '备注',
  D_YWRQ  STRING  COMMENT  '业务日期',
  D_CXRQ  STRING  COMMENT  '除息日期',
  D_DZRQ  STRING  COMMENT  '到账日期',
  VC_DJBZ  STRING  COMMENT  '登记币种',
  VC_DZBZ  STRING  COMMENT  '到账币种',
  EN_SHBL  DECIMAL(23,12)  COMMENT  '税后比例',
  L_OPERATORID  DECIMAL(4,0)  COMMENT  '操作人员',
  L_CHECKER  DECIMAL(4,0)  COMMENT  '复核人',
  L_QYZQNM  DECIMAL(10,0)  COMMENT  '',
  VC_FZDM1  STRING  COMMENT  '',
  L_BH  DECIMAL(38,0)  COMMENT  '',
  EN_BL  DECIMAL(23,12)  COMMENT  '',
  D_XQJSRQ  STRING  COMMENT  '',
  EN_PGJG  DECIMAL(19,4)  COMMENT  '',
  D_MODIFY  STRING  COMMENT  '',
  EN_YGDXJG  DECIMAL(18,10)  COMMENT  '',
  L_FHFS  DECIMAL(1,0)  COMMENT  '',
  VC_QYBH  STRING  COMMENT  '',
  D_HSSBQSR  STRING  COMMENT  '',
  D_HSSBJZR  STRING  COMMENT  '',
  D_HSCXQSR  STRING  COMMENT  '',
  D_HSCXJZR  STRING  COMMENT  '',
  D_ZQHSXQR  STRING  COMMENT  '',
  D_ZQHSDZR  STRING  COMMENT  ''
)
COMMENT '权益信息表'
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
              "querySql": ["SELECT  TO_CHAR(D_DJRQ,'YYYYMMDD') D_DJRQ
                                   , L_YWLB
                                   , L_ZQNM
                                   , VC_ZQDM
                                   , EN_SYBL
                                   , L_CLBZ
                                   , VC_BZ
                                   , D_YWRQ
                                   , D_CXRQ
                                   , D_DZRQ
                                   , VC_DJBZ
                                   , VC_DZBZ
                                   , EN_SHBL
                                   , L_OPERATORID
                                   , L_CHECKER
                                   , L_QYZQNM
                                   , VC_FZDM1
                                   , L_BH
                                   , EN_BL
                                   , D_XQJSRQ
                                   , EN_PGJG
                                   , D_MODIFY
                                   , EN_YGDXJG
                                   , L_FHFS
                                   , VC_QYBH
                                   , D_HSSBQSR
                                   , D_HSSBJZR
                                   , D_HSCXQSR
                                   , D_HSCXJZR
                                   , D_ZQHSXQR
                                   , D_ZQHSDZR
                                FROM ${hsfa_src_schema}.TQYXX
                                WHERE D_DJRQ between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "D_DJRQ", "type": "STRING"}, {"name": "L_YWLB", "type": "DOUBLE"}, {"name": "L_ZQNM", "type": "DOUBLE"}, {"name": "VC_ZQDM", "type": "STRING"}, {"name": "EN_SYBL", "type": "DOUBLE"}, {"name": "L_CLBZ", "type": "DOUBLE"}, {"name": "VC_BZ", "type": "STRING"}, {"name": "D_YWRQ", "type": "STRING"}, {"name": "D_CXRQ", "type": "STRING"}, {"name": "D_DZRQ", "type": "STRING"}, {"name": "VC_DJBZ", "type": "STRING"}, {"name": "VC_DZBZ", "type": "STRING"}, {"name": "EN_SHBL", "type": "DOUBLE"}, {"name": "L_OPERATORID", "type": "DOUBLE"}, {"name": "L_CHECKER", "type": "DOUBLE"}, {"name": "L_QYZQNM", "type": "DOUBLE"}, {"name": "VC_FZDM1", "type": "STRING"}, {"name": "L_BH", "type": "DOUBLE"}, {"name": "EN_BL", "type": "DOUBLE"}, {"name": "D_XQJSRQ", "type": "STRING"}, {"name": "EN_PGJG", "type": "DOUBLE"}, {"name": "D_MODIFY", "type": "STRING"}, {"name": "EN_YGDXJG", "type": "DOUBLE"}, {"name": "L_FHFS", "type": "DOUBLE"}, {"name": "VC_QYBH", "type": "STRING"}, {"name": "D_HSSBQSR", "type": "STRING"}, {"name": "D_HSSBJZR", "type": "STRING"}, {"name": "D_HSCXQSR", "type": "STRING"}, {"name": "D_HSCXJZR", "type": "STRING"}, {"name": "D_ZQHSXQR", "type": "STRING"}, {"name": "D_ZQHSDZR", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tqyxx_ptd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tqyxx_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tqyxx_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tqyxx_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TQYXX_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TQYXX_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tqyxx_ptd_tmp.json

inceptor_beeline "
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
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TQYXX_PTD PARTITION(P_DT)
SELECT
       D_DJRQ
     , L_YWLB
     , L_ZQNM
     , VC_ZQDM
     , EN_SYBL
     , L_CLBZ
     , VC_BZ
     , D_YWRQ
     , D_CXRQ
     , D_DZRQ
     , VC_DJBZ
     , VC_DZBZ
     , EN_SHBL
     , L_OPERATORID
     , L_CHECKER
     , L_QYZQNM
     , VC_FZDM1
     , L_BH
     , EN_BL
     , D_XQJSRQ
     , EN_PGJG
     , D_MODIFY
     , EN_YGDXJG
     , L_FHFS
     , VC_QYBH
     , D_HSSBQSR
     , D_HSSBJZR
     , D_HSCXQSR
     , D_HSCXJZR
     , D_ZQHSXQR
     , D_ZQHSDZR
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_DJRQ,'-','') P_DT
  FROM ODS_XDAY_HSFA.ODS_HSFA_TQYXX_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TQYXX_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TQYXX_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TQYXX_PTD成功"
      exit 0
   fi
fi
