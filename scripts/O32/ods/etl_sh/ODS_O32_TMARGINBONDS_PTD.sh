#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TMARGINBONDS_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TMARGINBONDS_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  VC_MARKET_INDICATOR  STRING  COMMENT  '市场标识成交类型',
  VC_REPORT_CODE  STRING  COMMENT  '证券代码',
  VC_NAME  STRING  COMMENT  '证券名称',
  VC_DEAL_NO  STRING  COMMENT  '成交编号',
  VC_ORIGINAL_DEAL_NO  STRING  COMMENT  '原始成交编号',
  EN_QTY  DECIMAL(16,2)  COMMENT  '券面总额',
  EN_FIRST_CLEAR_PRICE  DECIMAL(16,8)  COMMENT  '首次净价',
  EN_END_PRICE  DECIMAL(16,8)  COMMENT  '到期净价',
  EN_FIRST_INT  DECIMAL(22,12)  COMMENT  '首次应计利息',
  EN_FIRST_FULL_PRICE  DECIMAL(16,8)  COMMENT  '首次全价',
  EN_END_INT  DECIMAL(22,12)  COMMENT  '到期应计利息',
  EN_END_FULL_PRICE  DECIMAL(16,8)  COMMENT  '到期全价',
  EN_FIRST_YLD  DECIMAL(14,8)  COMMENT  '首次收益率',
  EN_END_YLD  DECIMAL(16,8)  COMMENT  '到期收益率',
  EN_ISSUE_AMT  DECIMAL(16,2)  COMMENT  '发行量',
  EN_INTEREST_AMT  DECIMAL(22,12)  COMMENT  '应计利息',
  EN_RATE  DECIMAL(14,8)  COMMENT  '折算比例',
  EN_COUPON_RATE  DECIMAL(14,8)  COMMENT  '票面利率',
  EN_MARGIN_SUBMIT_DATE  DECIMAL(16,2)  COMMENT  '保证金提交日',
  EN_MARGIN_TOTAL_AMT  DECIMAL(16,2)  COMMENT  '券面总额合计',
  EN_MARGIN_AMT  DECIMAL(16,2)  COMMENT  '保证金金额',
  EN_PAY_DATE  DECIMAL(8,0)  COMMENT  '付息日',
  L_MARGIN_ROLE  STRING  COMMENT  '支付方向',
  C_MARGIN_REPLACEMENT  STRING  COMMENT  '质押债券置换安排',
  C_MARGIN_TYPE  STRING  COMMENT  '类型',
  VC_TERM_DAYS  STRING  COMMENT  '期限',
  VC_CURRENCY_NO  STRING  COMMENT  '币种',
  EN_STRIKE_YLD  DECIMAL(14,8)  COMMENT  '行权收益率',
  C_BOND_SOURCE  STRING  COMMENT  ''
)
COMMENT '银行间交易质押券/保证券/保证金表'
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
                                   , VC_MARKET_INDICATOR
                                   , VC_REPORT_CODE
                                   , VC_NAME
                                   , VC_DEAL_NO
                                   , VC_ORIGINAL_DEAL_NO
                                   , EN_QTY
                                   , EN_FIRST_CLEAR_PRICE
                                   , EN_END_PRICE
                                   , EN_FIRST_INT
                                   , EN_FIRST_FULL_PRICE
                                   , EN_END_INT
                                   , EN_END_FULL_PRICE
                                   , EN_FIRST_YLD
                                   , EN_END_YLD
                                   , EN_ISSUE_AMT
                                   , EN_INTEREST_AMT
                                   , EN_RATE
                                   , EN_COUPON_RATE
                                   , EN_MARGIN_SUBMIT_DATE
                                   , EN_MARGIN_TOTAL_AMT
                                   , EN_MARGIN_AMT
                                   , EN_PAY_DATE
                                   , L_MARGIN_ROLE
                                   , C_MARGIN_REPLACEMENT
                                   , C_MARGIN_TYPE
                                   , VC_TERM_DAYS
                                   , VC_CURRENCY_NO
                                   , EN_STRIKE_YLD
                                   , C_BOND_SOURCE
                                FROM ${o32_src_schema}.THISMARGINBONDS
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "VC_MARKET_INDICATOR", "type": "STRING"}, {"name": "VC_REPORT_CODE", "type": "STRING"}, {"name": "VC_NAME", "type": "STRING"}, {"name": "VC_DEAL_NO", "type": "STRING"}, {"name": "VC_ORIGINAL_DEAL_NO", "type": "STRING"}, {"name": "EN_QTY", "type": "DOUBLE"}, {"name": "EN_FIRST_CLEAR_PRICE", "type": "DOUBLE"}, {"name": "EN_END_PRICE", "type": "DOUBLE"}, {"name": "EN_FIRST_INT", "type": "DOUBLE"}, {"name": "EN_FIRST_FULL_PRICE", "type": "DOUBLE"}, {"name": "EN_END_INT", "type": "DOUBLE"}, {"name": "EN_END_FULL_PRICE", "type": "DOUBLE"}, {"name": "EN_FIRST_YLD", "type": "DOUBLE"}, {"name": "EN_END_YLD", "type": "DOUBLE"}, {"name": "EN_ISSUE_AMT", "type": "DOUBLE"}, {"name": "EN_INTEREST_AMT", "type": "DOUBLE"}, {"name": "EN_RATE", "type": "DOUBLE"}, {"name": "EN_COUPON_RATE", "type": "DOUBLE"}, {"name": "EN_MARGIN_SUBMIT_DATE", "type": "DOUBLE"}, {"name": "EN_MARGIN_TOTAL_AMT", "type": "DOUBLE"}, {"name": "EN_MARGIN_AMT", "type": "DOUBLE"}, {"name": "EN_PAY_DATE", "type": "DOUBLE"}, {"name": "L_MARGIN_ROLE", "type": "DOUBLE"}, {"name": "C_MARGIN_REPLACEMENT", "type": "STRING"}, {"name": "C_MARGIN_TYPE", "type": "STRING"}, {"name": "VC_TERM_DAYS", "type": "STRING"}, {"name": "VC_CURRENCY_NO", "type": "STRING"}, {"name": "EN_STRIKE_YLD", "type": "DOUBLE"}, {"name": "C_BOND_SOURCE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tmarginbonds_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tmarginbonds_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tmarginbonds_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tmarginbonds_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TMARGINBONDS_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TMARGINBONDS_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tmarginbonds_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TMARGINBONDS_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , VC_MARKET_INDICATOR
     , VC_REPORT_CODE
     , VC_NAME
     , VC_DEAL_NO
     , VC_ORIGINAL_DEAL_NO
     , EN_QTY
     , EN_FIRST_CLEAR_PRICE
     , EN_END_PRICE
     , EN_FIRST_INT
     , EN_FIRST_FULL_PRICE
     , EN_END_INT
     , EN_END_FULL_PRICE
     , EN_FIRST_YLD
     , EN_END_YLD
     , EN_ISSUE_AMT
     , EN_INTEREST_AMT
     , EN_RATE
     , EN_COUPON_RATE
     , EN_MARGIN_SUBMIT_DATE
     , EN_MARGIN_TOTAL_AMT
     , EN_MARGIN_AMT
     , EN_PAY_DATE
     , L_MARGIN_ROLE
     , C_MARGIN_REPLACEMENT
     , C_MARGIN_TYPE
     , VC_TERM_DAYS
     , VC_CURRENCY_NO
     , EN_STRIKE_YLD
     , C_BOND_SOURCE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TMARGINBONDS_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TMARGINBONDS_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TMARGINBONDS_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TMARGINBONDS_PTD成功"
      exit 0
   fi
fi
