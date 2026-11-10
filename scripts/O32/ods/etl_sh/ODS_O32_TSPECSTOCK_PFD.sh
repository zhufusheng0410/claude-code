#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TSPECSTOCK_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TSPECSTOCK_PFD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '发生日期',
  L_UNIT_ID  DECIMAL(12,0)  COMMENT  '投资单元序号',
  EN_TODAY_DIVIDEND  DECIMAL(18,2)  COMMENT  '当日红利金额',
  EN_TOTAL_DIVIDEND  DECIMAL(18,2)  COMMENT  '累计红利金额',
  L_DIVIDEND_RIGHT_AMOUNT  DECIMAL(16,0)  COMMENT  '*红股待上市数量',
  L_SHAREOUT_RIGHT  DECIMAL(16,0)  COMMENT  '配股权益数量',
  EN_SHAREOUT_PRICE  DECIMAL(16,8)  COMMENT  '配股价格',
  L_TODAY_SHAREOUT  DECIMAL(16,0)  COMMENT  '当日配股数量',
  L_TOTAL_SHAREOUT  DECIMAL(16,0)  COMMENT  '*配股待上市数量',
  L_NEW_RIGHT_AMOUNT  DECIMAL(16,0)  COMMENT  '配售权益数量＃',
  L_INCREASE_RIGHT_AMOUNT  DECIMAL(16,0)  COMMENT  '增发权益数量',
  EN_NEW_PRICE  DECIMAL(16,8)  COMMENT  '新股申购价格',
  L_UNCIRCULATED_AMOUNT  DECIMAL(18,2)  COMMENT  '新股待上市数量',
  L_YJUNCIRCULATED_AMOUNT  DECIMAL(18,2)  COMMENT  '一级待上市数量',
  EN_NEW_PROFIT  DECIMAL(18,2)  COMMENT  '新股收益',
  EN_BOND_INTEREST_INVEST  DECIMAL(18,2)  COMMENT  '国债利息成本',
  EN_BOND_INTEREST_PROFIT  DECIMAL(18,2)  COMMENT  '国债利息收益',
  EN_REMARK  DECIMAL(14,8)  COMMENT  '金额备注',
  VC_REMARK  STRING  COMMENT  '字符备注',
  EN_ONTHEWAY_DIVIDEND  DECIMAL(18,2)  COMMENT  '在途红利金额',
  L_TODAY_DIVIDEND_RIGHT_AMOUNT  DECIMAL(16,0)  COMMENT  '当日红股数量',
  L_DISTRIBUTION_LIMIT_AMOUNT  DECIMAL(16,0)  COMMENT  '分销额度'
)
COMMENT '投资单元特殊证券表'
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
                                   , L_UNIT_ID
                                   , EN_TODAY_DIVIDEND
                                   , EN_TOTAL_DIVIDEND
                                   , L_DIVIDEND_RIGHT_AMOUNT
                                   , L_SHAREOUT_RIGHT
                                   , EN_SHAREOUT_PRICE
                                   , L_TODAY_SHAREOUT
                                   , L_TOTAL_SHAREOUT
                                   , L_NEW_RIGHT_AMOUNT
                                   , L_INCREASE_RIGHT_AMOUNT
                                   , EN_NEW_PRICE
                                   , L_UNCIRCULATED_AMOUNT
                                   , L_YJUNCIRCULATED_AMOUNT
                                   , EN_NEW_PROFIT
                                   , EN_BOND_INTEREST_INVEST
                                   , EN_BOND_INTEREST_PROFIT
                                   , EN_REMARK
                                   , VC_REMARK
                                   , EN_ONTHEWAY_DIVIDEND
                                   , L_TODAY_DIVIDEND_RIGHT_AMOUNT
                                   , L_DISTRIBUTION_LIMIT_AMOUNT
                                FROM ${o32_src_schema}.THISSPECSTOCK
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_UNIT_ID", "type": "DOUBLE"}, {"name": "EN_TODAY_DIVIDEND", "type": "DOUBLE"}, {"name": "EN_TOTAL_DIVIDEND", "type": "DOUBLE"}, {"name": "L_DIVIDEND_RIGHT_AMOUNT", "type": "DOUBLE"}, {"name": "L_SHAREOUT_RIGHT", "type": "DOUBLE"}, {"name": "EN_SHAREOUT_PRICE", "type": "DOUBLE"}, {"name": "L_TODAY_SHAREOUT", "type": "DOUBLE"}, {"name": "L_TOTAL_SHAREOUT", "type": "DOUBLE"}, {"name": "L_NEW_RIGHT_AMOUNT", "type": "DOUBLE"}, {"name": "L_INCREASE_RIGHT_AMOUNT", "type": "DOUBLE"}, {"name": "EN_NEW_PRICE", "type": "DOUBLE"}, {"name": "L_UNCIRCULATED_AMOUNT", "type": "DOUBLE"}, {"name": "L_YJUNCIRCULATED_AMOUNT", "type": "DOUBLE"}, {"name": "EN_NEW_PROFIT", "type": "DOUBLE"}, {"name": "EN_BOND_INTEREST_INVEST", "type": "DOUBLE"}, {"name": "EN_BOND_INTEREST_PROFIT", "type": "DOUBLE"}, {"name": "EN_REMARK", "type": "DOUBLE"}, {"name": "VC_REMARK", "type": "STRING"}, {"name": "EN_ONTHEWAY_DIVIDEND", "type": "DOUBLE"}, {"name": "L_TODAY_DIVIDEND_RIGHT_AMOUNT", "type": "DOUBLE"}, {"name": "L_DISTRIBUTION_LIMIT_AMOUNT", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tspecstock_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tspecstock_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tspecstock_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tspecstock_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TSPECSTOCK_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TSPECSTOCK_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tspecstock_pfd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TSPECSTOCK_PFD PARTITION(P_DT)
SELECT
       L_DATE
     , L_UNIT_ID
     , EN_TODAY_DIVIDEND
     , EN_TOTAL_DIVIDEND
     , L_DIVIDEND_RIGHT_AMOUNT
     , L_SHAREOUT_RIGHT
     , EN_SHAREOUT_PRICE
     , L_TODAY_SHAREOUT
     , L_TOTAL_SHAREOUT
     , L_NEW_RIGHT_AMOUNT
     , L_INCREASE_RIGHT_AMOUNT
     , EN_NEW_PRICE
     , L_UNCIRCULATED_AMOUNT
     , L_YJUNCIRCULATED_AMOUNT
     , EN_NEW_PROFIT
     , EN_BOND_INTEREST_INVEST
     , EN_BOND_INTEREST_PROFIT
     , EN_REMARK
     , VC_REMARK
     , EN_ONTHEWAY_DIVIDEND
     , L_TODAY_DIVIDEND_RIGHT_AMOUNT
     , L_DISTRIBUTION_LIMIT_AMOUNT
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TSPECSTOCK_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TSPECSTOCK_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TSPECSTOCK_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TSPECSTOCK_PFD成功"
      exit 0
   fi
fi
