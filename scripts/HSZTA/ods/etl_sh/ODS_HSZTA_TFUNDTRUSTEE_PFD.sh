#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDTRUSTEE_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDTRUSTEE_PFD_TMP(
  C_TRUSTEECODE  STRING  COMMENT  '托管人代码',
  C_TRUSTEENAME  STRING  COMMENT  '托管人名称',
  C_IVERSION  STRING  COMMENT  '会计接口版本',
  C_FORMAT  STRING  COMMENT  '会计接口文件名格式',
  C_TRUSTEEFAXNO  STRING  COMMENT  '传真号码',
  C_NOREXPNOLIQDATA  STRING  COMMENT  '',
  C_MULTIMANAGER  STRING  COMMENT  '',
  C_NEEDLIQFILE  STRING  COMMENT  '',
  C_TRUSTMAIL  STRING  COMMENT  '',
  C_CUSTODIANCODE  STRING  COMMENT  '',
  C_TRUSTEEEXPLIQFILE  STRING  COMMENT  '',
  C_EXPINTERESTFARE  STRING  COMMENT  ''
)
COMMENT '托管行信息'
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
              "querySql": ["SELECT  C_TRUSTEECODE
                                   , C_TRUSTEENAME
                                   , C_IVERSION
                                   , C_FORMAT
                                   , C_TRUSTEEFAXNO
                                   , C_NOREXPNOLIQDATA
                                   , C_MULTIMANAGER
                                   , C_NEEDLIQFILE
                                   , C_TRUSTMAIL
                                   , C_CUSTODIANCODE
                                   , C_TRUSTEEEXPLIQFILE
                                   , C_EXPINTERESTFARE
                                FROM ${hszta_src_schema}.TFUNDTRUSTEE"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_TRUSTEECODE", "type": "STRING"}, {"name": "C_TRUSTEENAME", "type": "STRING"}, {"name": "C_IVERSION", "type": "STRING"}, {"name": "C_FORMAT", "type": "STRING"}, {"name": "C_TRUSTEEFAXNO", "type": "STRING"}, {"name": "C_NOREXPNOLIQDATA", "type": "STRING"}, {"name": "C_MULTIMANAGER", "type": "STRING"}, {"name": "C_NEEDLIQFILE", "type": "STRING"}, {"name": "C_TRUSTMAIL", "type": "STRING"}, {"name": "C_CUSTODIANCODE", "type": "STRING"}, {"name": "C_TRUSTEEEXPLIQFILE", "type": "STRING"}, {"name": "C_EXPINTERESTFARE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tfundtrustee_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tfundtrustee_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tfundtrustee_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tfundtrustee_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TFUNDTRUSTEE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TFUNDTRUSTEE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tfundtrustee_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDTRUSTEE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_TRUSTEECODE
     , C_TRUSTEENAME
     , C_IVERSION
     , C_FORMAT
     , C_TRUSTEEFAXNO
     , C_NOREXPNOLIQDATA
     , C_MULTIMANAGER
     , C_NEEDLIQFILE
     , C_TRUSTMAIL
     , C_CUSTODIANCODE
     , C_TRUSTEEEXPLIQFILE
     , C_EXPINTERESTFARE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDTRUSTEE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TFUNDTRUSTEE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TFUNDTRUSTEE_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TFUNDTRUSTEE_PFD成功"
      exit 0
   fi
fi
