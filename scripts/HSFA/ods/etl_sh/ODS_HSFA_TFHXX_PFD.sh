#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TFHXX_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TFHXX_PFD_TMP(
  L_ID  STRING  COMMENT  '编号',
  D_RQ  STRING  COMMENT  '日期',
  VC_JGDM  STRING  COMMENT  '机构代码',
  VC_JGMC  STRING  COMMENT  '机构名称',
  L_ZTBH  STRING  COMMENT  '账套编号',
  EN_FHJE  DECIMAL(19,4)  COMMENT  '分红金额',
  D_QRRQ  STRING  COMMENT  '确认日期',
  VC_BZ  STRING  COMMENT  '备注',
  L_CZRY  DECIMAL(4,0)  COMMENT  '操作人员',
  EN_PXJE  DECIMAL(19,4)  COMMENT  '派现金额',
  VC_JJDM  STRING  COMMENT  '基金代码/分级基金代码',
  VC_SYRBH  STRING  COMMENT  '受益人编号',
  L_SYRLB  DECIMAL(4,0)  COMMENT  '受益人类别',
  L_YTBZ  STRING  COMMENT  '预提标志',
  L_HLLX  STRING  COMMENT  '红利类型',
  L_CLBZ  STRING  COMMENT  '处理标志',
  EN_YJBC  DECIMAL(19,4)  COMMENT  '业绩报酬',
  EN_TQDFWFSY  DECIMAL(19,4)  COMMENT  '',
  L_YTHWHGLBH  DECIMAL(10,0)  COMMENT  '',
  VC_JSBZ  STRING  COMMENT  '',
  EN_EXCH  DECIMAL(14,10)  COMMENT  '',
  VC_FHR  STRING  COMMENT  '',
  VC_LLR  STRING  COMMENT  '',
  D_MODIFY  STRING  COMMENT  '',
  VC_ZY  STRING  COMMENT  '',
  D_HFRQ  STRING  COMMENT  ''
)
COMMENT 'TA分红信息表'
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
              "querySql": ["SELECT  L_ID
                                   , TO_CHAR(D_RQ,'YYYYMMDD') D_RQ
                                   , VC_JGDM
                                   , VC_JGMC
                                   , L_ZTBH
                                   , EN_FHJE
                                   , D_QRRQ
                                   , VC_BZ
                                   , L_CZRY
                                   , EN_PXJE
                                   , VC_JJDM
                                   , VC_SYRBH
                                   , L_SYRLB
                                   , L_YTBZ
                                   , L_HLLX
                                   , L_CLBZ
                                   , EN_YJBC
                                   , EN_TQDFWFSY
                                   , L_YTHWHGLBH
                                   , VC_JSBZ
                                   , EN_EXCH
                                   , VC_FHR
                                   , VC_LLR
                                   , D_MODIFY
                                   , VC_ZY
                                   , D_HFRQ
                                FROM ${hsfa_src_schema}.TFHXX"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ID", "type": "DOUBLE"}, {"name": "D_RQ", "type": "STRING"}, {"name": "VC_JGDM", "type": "STRING"}, {"name": "VC_JGMC", "type": "STRING"}, {"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "EN_FHJE", "type": "DOUBLE"}, {"name": "D_QRRQ", "type": "STRING"}, {"name": "VC_BZ", "type": "STRING"}, {"name": "L_CZRY", "type": "DOUBLE"}, {"name": "EN_PXJE", "type": "DOUBLE"}, {"name": "VC_JJDM", "type": "STRING"}, {"name": "VC_SYRBH", "type": "STRING"}, {"name": "L_SYRLB", "type": "DOUBLE"}, {"name": "L_YTBZ", "type": "DOUBLE"}, {"name": "L_HLLX", "type": "DOUBLE"}, {"name": "L_CLBZ", "type": "DOUBLE"}, {"name": "EN_YJBC", "type": "DOUBLE"}, {"name": "EN_TQDFWFSY", "type": "DOUBLE"}, {"name": "L_YTHWHGLBH", "type": "DOUBLE"}, {"name": "VC_JSBZ", "type": "STRING"}, {"name": "EN_EXCH", "type": "DOUBLE"}, {"name": "VC_FHR", "type": "STRING"}, {"name": "VC_LLR", "type": "STRING"}, {"name": "D_MODIFY", "type": "STRING"}, {"name": "VC_ZY", "type": "STRING"}, {"name": "D_HFRQ", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tfhxx_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tfhxx_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tfhxx_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tfhxx_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TFHXX_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TFHXX_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tfhxx_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TFHXX_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_ID
     , D_RQ
     , VC_JGDM
     , VC_JGMC
     , L_ZTBH
     , EN_FHJE
     , D_QRRQ
     , VC_BZ
     , L_CZRY
     , EN_PXJE
     , VC_JJDM
     , VC_SYRBH
     , L_SYRLB
     , L_YTBZ
     , L_HLLX
     , L_CLBZ
     , EN_YJBC
     , EN_TQDFWFSY
     , L_YTHWHGLBH
     , VC_JSBZ
     , EN_EXCH
     , VC_FHR
     , VC_LLR
     , D_MODIFY
     , VC_ZY
     , D_HFRQ
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TFHXX_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TFHXX_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TFHXX_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TFHXX_PFD成功"
      exit 0
   fi
fi
