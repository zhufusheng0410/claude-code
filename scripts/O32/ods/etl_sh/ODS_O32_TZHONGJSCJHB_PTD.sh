#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TZHONGJSCJHB_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TZHONGJSCJHB_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  VC_TRADE_MEMBER  STRING  COMMENT  '交易会员号',
  VC_STOCKHOLDER_ID  STRING  COMMENT  '客户编码',
  VC_INTER_CODE  STRING  COMMENT  '合约代码',
  L_DEAL_AMOUNT  DECIMAL(10,0)  COMMENT  '成交数量',
  EN_DEAL_PRICE  DECIMAL(16,8)  COMMENT  '成交价格',
  EN_DEAL_BALANCE  DECIMAL(16,2)  COMMENT  '成交金额',
  L_TIME  DECIMAL(6,0)  COMMENT  '成交时间',
  C_DIRECTION_FLAG  STRING  COMMENT  '买卖标志',
  C_OPENCLOSE_FLAG  STRING  COMMENT  '开平标志',
  VC_CONFIRM_NO  STRING  COMMENT  '报单号',
  VC_SEAT_ID  STRING  COMMENT  '席位代码',
  C_DEAL_FLAG  STRING  COMMENT  '处理标志',
  L_SECURITIES_BRANCH  DECIMAL(10,0)  COMMENT  '分仓营业部',
  VC_DEAL_ID  STRING  COMMENT  '成交编号',
  EN_FEE  DECIMAL(14,2)  COMMENT  '费用',
  VC_ZHBH  STRING  COMMENT  '',
  C_DEAL_TYPE  STRING  COMMENT  '成交类型',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型'
)
COMMENT '中金所成交回报表'
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
                                   , VC_TRADE_MEMBER
                                   , VC_STOCKHOLDER_ID
                                   , VC_INTER_CODE
                                   , L_DEAL_AMOUNT
                                   , EN_DEAL_PRICE
                                   , EN_DEAL_BALANCE
                                   , L_TIME
                                   , C_DIRECTION_FLAG
                                   , C_OPENCLOSE_FLAG
                                   , VC_CONFIRM_NO
                                   , VC_SEAT_ID
                                   , C_DEAL_FLAG
                                   , L_SECURITIES_BRANCH
                                   , VC_DEAL_ID
                                   , EN_FEE
                                   , VC_ZHBH
                                   , C_DEAL_TYPE
                                   , C_INVEST_TYPE
                                FROM ${o32_src_schema}.THISZHONGJSCJHB
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "VC_TRADE_MEMBER", "type": "STRING"}, {"name": "VC_STOCKHOLDER_ID", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "L_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "EN_DEAL_PRICE", "type": "DOUBLE"}, {"name": "EN_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "L_TIME", "type": "DOUBLE"}, {"name": "C_DIRECTION_FLAG", "type": "STRING"}, {"name": "C_OPENCLOSE_FLAG", "type": "STRING"}, {"name": "VC_CONFIRM_NO", "type": "STRING"}, {"name": "VC_SEAT_ID", "type": "STRING"}, {"name": "C_DEAL_FLAG", "type": "STRING"}, {"name": "L_SECURITIES_BRANCH", "type": "DOUBLE"}, {"name": "VC_DEAL_ID", "type": "STRING"}, {"name": "EN_FEE", "type": "DOUBLE"}, {"name": "VC_ZHBH", "type": "STRING"}, {"name": "C_DEAL_TYPE", "type": "STRING"}, {"name": "C_INVEST_TYPE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tzhongjscjhb_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tzhongjscjhb_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tzhongjscjhb_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tzhongjscjhb_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TZHONGJSCJHB_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TZHONGJSCJHB_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tzhongjscjhb_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TZHONGJSCJHB_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , VC_TRADE_MEMBER
     , VC_STOCKHOLDER_ID
     , VC_INTER_CODE
     , L_DEAL_AMOUNT
     , EN_DEAL_PRICE
     , EN_DEAL_BALANCE
     , L_TIME
     , C_DIRECTION_FLAG
     , C_OPENCLOSE_FLAG
     , VC_CONFIRM_NO
     , VC_SEAT_ID
     , C_DEAL_FLAG
     , L_SECURITIES_BRANCH
     , VC_DEAL_ID
     , EN_FEE
     , VC_ZHBH
     , C_DEAL_TYPE
     , C_INVEST_TYPE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TZHONGJSCJHB_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TZHONGJSCJHB_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TZHONGJSCJHB_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TZHONGJSCJHB_PTD成功"
      exit 0
   fi
fi
