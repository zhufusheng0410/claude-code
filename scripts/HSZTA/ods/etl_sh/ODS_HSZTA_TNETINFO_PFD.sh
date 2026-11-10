#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TNETINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TNETINFO_PFD_TMP(
  C_AGENCYNO  STRING  COMMENT  '销售商代码',
  C_NETNO  STRING  COMMENT  '网点代码',
  C_NETNAME  STRING  COMMENT  '网点名称',
  C_CITYNO  STRING  COMMENT  '城市编号(地区)',
  C_NETADDRESS  STRING  COMMENT  '网点地址',
  C_NETZIPCODE  STRING  COMMENT  '邮政编码',
  C_NETCONTACT  STRING  COMMENT  '网点联系人',
  C_NETPHONE  STRING  COMMENT  '网点联系电话',
  C_NETFAXNO  STRING  COMMENT  '网点传真号码',
  D_NETREGDATE  STRING  COMMENT  '网点登记日期',
  C_NETSTATUS  STRING  COMMENT  '网点状态'
)
COMMENT '网点信息'
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
              "querySql": ["SELECT  C_AGENCYNO
                                   , C_NETNO
                                   , C_NETNAME
                                   , C_CITYNO
                                   , C_NETADDRESS
                                   , C_NETZIPCODE
                                   , C_NETCONTACT
                                   , C_NETPHONE
                                   , C_NETFAXNO
                                   , D_NETREGDATE
                                   , C_NETSTATUS
                                FROM ${hszta_src_schema}.TNETINFO"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "C_NETNAME", "type": "STRING"}, {"name": "C_CITYNO", "type": "STRING"}, {"name": "C_NETADDRESS", "type": "STRING"}, {"name": "C_NETZIPCODE", "type": "STRING"}, {"name": "C_NETCONTACT", "type": "STRING"}, {"name": "C_NETPHONE", "type": "STRING"}, {"name": "C_NETFAXNO", "type": "STRING"}, {"name": "D_NETREGDATE", "type": "STRING"}, {"name": "C_NETSTATUS", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tnetinfo_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tnetinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tnetinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tnetinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TNETINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TNETINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tnetinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TNETINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_AGENCYNO
     , C_NETNO
     , C_NETNAME
     , C_CITYNO
     , C_NETADDRESS
     , C_NETZIPCODE
     , C_NETCONTACT
     , C_NETPHONE
     , C_NETFAXNO
     , D_NETREGDATE
     , C_NETSTATUS
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TNETINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TNETINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TNETINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TNETINFO_PFD成功"
      exit 0
   fi
fi
