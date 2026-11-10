#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TSHARECLASS_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TSHARECLASS_PFD_TMP(
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_SHARECLASS  STRING  COMMENT  '份额级别',
  C_CLASSNAME  STRING  COMMENT  '级别名称',
  F_MIN  DECIMAL(16,2)  COMMENT  '区间最小份额',
  F_MAX  DECIMAL(16,2)  COMMENT  '区间最大份额',
  C_GRADEFUND  STRING  COMMENT  '分级基金代码',
  C_CLASSTYPE  STRING  COMMENT  '分级方式',
  C_DEALFLAG  STRING  COMMENT  '分红处理标志',
  F_MINDAY  DECIMAL(10,0)  COMMENT  '最小天数',
  F_MAXDAY  DECIMAL(10,0)  COMMENT  '最大天数',
  C_EXPKJMERGER  STRING  COMMENT  '清算数据是否合并导出',
  C_EXPAGENCYTYPE  STRING  COMMENT  '确认数据导出是否低级别',
  C_ISESHARESFUND  STRING  COMMENT  '',
  C_MERGEACCOUNTMODE  STRING  COMMENT  '清算数据合并模式',
  C_ISCHECKTHRESHOLD  STRING  COMMENT  '',
  F_SHARERATIO  DECIMAL(9,8)  COMMENT  '',
  C_IMPKJSPLIT  STRING  COMMENT  '',
  C_UPDATEBMIN  STRING  COMMENT  '',
  F_DECCLASSMIN  DECIMAL(16,2)  COMMENT  '',
  C_HOLDINTERVALTYPE  STRING  COMMENT  '',
  C_LASTCLASSRDMTYPE  STRING  COMMENT  '',
  C_CLASSDVDPRIOR  STRING  COMMENT  '',
  D_ENDDATE  STRING  COMMENT  '',
  C_HOLDFLAG  STRING  COMMENT  ''
)
COMMENT '基金份额级别定义'
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
                                   , C_SHARECLASS
                                   , C_CLASSNAME
                                   , F_MIN
                                   , F_MAX
                                   , C_GRADEFUND
                                   , C_CLASSTYPE
                                   , C_DEALFLAG
                                   , F_MINDAY
                                   , F_MAXDAY
                                   , C_EXPKJMERGER
                                   , C_EXPAGENCYTYPE
                                   , C_ISESHARESFUND
                                   , C_MERGEACCOUNTMODE
                                   , C_ISCHECKTHRESHOLD
                                   , F_SHARERATIO
                                   , C_IMPKJSPLIT
                                   , C_UPDATEBMIN
                                   , F_DECCLASSMIN
                                   , C_HOLDINTERVALTYPE
                                   , C_LASTCLASSRDMTYPE
                                   , C_CLASSDVDPRIOR
                                   , D_ENDDATE
                                   , C_HOLDFLAG
                                FROM ${hszta_src_schema}.TSHARECLASS"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_SHARECLASS", "type": "STRING"}, {"name": "C_CLASSNAME", "type": "STRING"}, {"name": "F_MIN", "type": "DOUBLE"}, {"name": "F_MAX", "type": "DOUBLE"}, {"name": "C_GRADEFUND", "type": "STRING"}, {"name": "C_CLASSTYPE", "type": "STRING"}, {"name": "C_DEALFLAG", "type": "STRING"}, {"name": "F_MINDAY", "type": "DOUBLE"}, {"name": "F_MAXDAY", "type": "DOUBLE"}, {"name": "C_EXPKJMERGER", "type": "STRING"}, {"name": "C_EXPAGENCYTYPE", "type": "STRING"}, {"name": "C_ISESHARESFUND", "type": "STRING"}, {"name": "C_MERGEACCOUNTMODE", "type": "STRING"}, {"name": "C_ISCHECKTHRESHOLD", "type": "STRING"}, {"name": "F_SHARERATIO", "type": "DOUBLE"}, {"name": "C_IMPKJSPLIT", "type": "STRING"}, {"name": "C_UPDATEBMIN", "type": "STRING"}, {"name": "F_DECCLASSMIN", "type": "DOUBLE"}, {"name": "C_HOLDINTERVALTYPE", "type": "STRING"}, {"name": "C_LASTCLASSRDMTYPE", "type": "STRING"}, {"name": "C_CLASSDVDPRIOR", "type": "STRING"}, {"name": "D_ENDDATE", "type": "STRING"}, {"name": "C_HOLDFLAG", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tshareclass_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tshareclass_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tshareclass_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tshareclass_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TSHARECLASS_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TSHARECLASS_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tshareclass_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TSHARECLASS_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_FUNDCODE
     , C_SHARECLASS
     , C_CLASSNAME
     , F_MIN
     , F_MAX
     , C_GRADEFUND
     , C_CLASSTYPE
     , C_DEALFLAG
     , F_MINDAY
     , F_MAXDAY
     , C_EXPKJMERGER
     , C_EXPAGENCYTYPE
     , C_ISESHARESFUND
     , C_MERGEACCOUNTMODE
     , C_ISCHECKTHRESHOLD
     , F_SHARERATIO
     , C_IMPKJSPLIT
     , C_UPDATEBMIN
     , F_DECCLASSMIN
     , C_HOLDINTERVALTYPE
     , C_LASTCLASSRDMTYPE
     , C_CLASSDVDPRIOR
     , D_ENDDATE
     , C_HOLDFLAG
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TSHARECLASS_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TSHARECLASS_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TSHARECLASS_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TSHARECLASS_PFD成功"
      exit 0
   fi
fi
