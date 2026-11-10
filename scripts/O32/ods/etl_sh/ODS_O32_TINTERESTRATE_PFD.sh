#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TINTERESTRATE_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TINTERESTRATE_PFD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  L_RATE_NO  DECIMAL(8,0)  COMMENT  '利率参数序号',
  VC_CURRENCY_NO  STRING  COMMENT  '币种',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  L_ASSET_ID  DECIMAL(8,0)  COMMENT  '资产单元序号＃',
  L_RATE_TYPE  DECIMAL(4,0)  COMMENT  '利率类别',
  VC_RATE_NAME  STRING  COMMENT  '利率名称',
  EN_YEAR_RATE  DECIMAL(9,8)  COMMENT  '年利率',
  L_DAYS  DECIMAL(3,0)  COMMENT  '年利率计算天数',
  EN_DAY_RATE  DECIMAL(9,8)  COMMENT  '日利率',
  EN_RATE_TAX_RATE  DECIMAL(9,8)  COMMENT  '利息税比率',
  EN_MIN_RESERVE_BALANCE  DECIMAL(16,2)  COMMENT  '最低保留额',
  EN_FLOATING_BALANCE  DECIMAL(16,2)  COMMENT  '浮动额度',
  C_RATE_STATUS  STRING  COMMENT  '利率状态',
  C_YEAR_DAY_TYPE  STRING  COMMENT  '年计算天数类型',
  C_BASIC  STRING  COMMENT  '基准',
  EN_FIXED_AMOUNT  DECIMAL(20,4)  COMMENT  '固定值',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  L_VIRTUAL_KEY  DECIMAL(16,0)  COMMENT  '虚拟主键'
)
COMMENT '利率参数表'
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
            "username": "${o32_username}",
            "password": "${o32_password}",
            "connection": [{
              "querySql": ["SELECT  L_DATE
                                   , L_RATE_NO
                                   , VC_CURRENCY_NO
                                   , L_FUND_ID
                                   , L_ASSET_ID
                                   , L_RATE_TYPE
                                   , VC_RATE_NAME
                                   , EN_YEAR_RATE
                                   , L_DAYS
                                   , EN_DAY_RATE
                                   , EN_RATE_TAX_RATE
                                   , EN_MIN_RESERVE_BALANCE
                                   , EN_FLOATING_BALANCE
                                   , C_RATE_STATUS
                                   , C_YEAR_DAY_TYPE
                                   , C_BASIC
                                   , EN_FIXED_AMOUNT
                                   , VC_TIMESTAMP
                                   , L_VIRTUAL_KEY
                                FROM ${o32_src_schema}.TINTERESTRATE"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_RATE_NO", "type": "DOUBLE"}, {"name": "VC_CURRENCY_NO", "type": "STRING"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_ASSET_ID", "type": "DOUBLE"}, {"name": "L_RATE_TYPE", "type": "DOUBLE"}, {"name": "VC_RATE_NAME", "type": "STRING"}, {"name": "EN_YEAR_RATE", "type": "DOUBLE"}, {"name": "L_DAYS", "type": "DOUBLE"}, {"name": "EN_DAY_RATE", "type": "DOUBLE"}, {"name": "EN_RATE_TAX_RATE", "type": "DOUBLE"}, {"name": "EN_MIN_RESERVE_BALANCE", "type": "DOUBLE"}, {"name": "EN_FLOATING_BALANCE", "type": "DOUBLE"}, {"name": "C_RATE_STATUS", "type": "STRING"}, {"name": "C_YEAR_DAY_TYPE", "type": "STRING"}, {"name": "C_BASIC", "type": "STRING"}, {"name": "EN_FIXED_AMOUNT", "type": "DOUBLE"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "L_VIRTUAL_KEY", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tinterestrate_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tinterestrate_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tinterestrate_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tinterestrate_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TINTERESTRATE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TINTERESTRATE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tinterestrate_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TINTERESTRATE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_DATE
     , L_RATE_NO
     , VC_CURRENCY_NO
     , L_FUND_ID
     , L_ASSET_ID
     , L_RATE_TYPE
     , VC_RATE_NAME
     , EN_YEAR_RATE
     , L_DAYS
     , EN_DAY_RATE
     , EN_RATE_TAX_RATE
     , EN_MIN_RESERVE_BALANCE
     , EN_FLOATING_BALANCE
     , C_RATE_STATUS
     , C_YEAR_DAY_TYPE
     , C_BASIC
     , EN_FIXED_AMOUNT
     , VC_TIMESTAMP
     , L_VIRTUAL_KEY
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TINTERESTRATE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TINTERESTRATE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TINTERESTRATE_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TINTERESTRATE_PFD成功"
      exit 0
   fi
fi
