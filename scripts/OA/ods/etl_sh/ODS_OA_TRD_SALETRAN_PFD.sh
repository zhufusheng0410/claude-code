#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_OA.ODS_OA_TRD_SALETRAN_PFD_TMP;
CREATE TABLE ODS_XDAY_OA.ODS_OA_TRD_SALETRAN_PFD_TMP(
  TRD_ST_TRX_SERIALNO  DECIMAL(30,0)  COMMENT  '交易流水号',
  SK_INVPTY  DECIMAL(12,0)  COMMENT  '客户参与者代理键',
  SK_ACCOUNT  DECIMAL(12,0)  COMMENT  '基金账户代理键',
  SK_TRADEACCO_REG  DECIMAL(12,0)  COMMENT  'ta登记交易账户代理键',
  SK_AGENCY  DECIMAL(12,0)  COMMENT  '销售渠道代理键',
  SK_PRODUCT  DECIMAL(12,0)  COMMENT  '产品代理键',
  DK_SHARE_TYPE  STRING  COMMENT  '收费模式',
  SK_CURRENCY  DECIMAL(12,0)  COMMENT  '结算币种',
  SK_AGREEMENT  DECIMAL(12,0)  COMMENT  '定投协议代理键',
  SK_MKT_TRADE_TYPE  STRING  COMMENT  '基金销售交易类型代理键',
  BK_FUNDACCOUNT  STRING  COMMENT  '基金帐号',
  BK_TRADEACCOUNT  STRING  COMMENT  '交易账号',
  CSERIALNO  STRING  COMMENT  '交易确认流水号',
  DK_TANO  STRING  COMMENT  'ta代码',
  AGENCYNO  STRING  COMMENT  '销售机构代码',
  NETNO  STRING  COMMENT  '托管网点号码',
  REQUEST_DATE  DECIMAL(8,0)  COMMENT  '申请日期',
  SK_DATE  DECIMAL(8,0)  COMMENT  '确认日期',
  REQ_BALANCE  DECIMAL(17,2)  COMMENT  '申请金额',
  REQ_SHARES  DECIMAL(17,2)  COMMENT  '申请份额',
  CONFIRM_BALANCE  DECIMAL(17,2)  COMMENT  '确认金额',
  CONFIRM_SHARES  DECIMAL(17,2)  COMMENT  '确认份额',
  INTEREST  DECIMAL(17,2)  COMMENT  '利息',
  INTEREST_TAX  DECIMAL(17,2)  COMMENT  '利息税',
  TOTAL_FARE  DECIMAL(17,2)  COMMENT  '总费用',
  TRADE_FARE  DECIMAL(17,2)  COMMENT  '手续费',
  TA_FARE  DECIMAL(17,2)  COMMENT  '过户费',
  AGENCY_FARE  DECIMAL(17,2)  COMMENT  '代销费',
  REGIST_FARE  DECIMAL(17,2)  COMMENT  '注册登记人费',
  FUND_FARE  DECIMAL(17,2)  COMMENT  '归基金资产费',
  STAMP_TAX  DECIMAL(17,2)  COMMENT  '印花税',
  BACK_FARE  DECIMAL(17,2)  COMMENT  '后收费用',
  OTHER_FARE  DECIMAL(17,2)  COMMENT  '其他费用',
  RETURN_FARE  DECIMAL(17,2)  COMMENT  'returnfare',
  INTEREST_SHARE  DECIMAL(17,2)  COMMENT  '认购期利息转份额',
  NETVALUE  DECIMAL(7,4)  COMMENT  '成交价',
  DK_SALETRAN_STATUS  STRING  COMMENT  '交易处理返回代码',
  DK_RETCODE  STRING  COMMENT  '失败原因代码',
  DK_TAFLAG  STRING  COMMENT  'ta发起标志',
  REQUESTNO  STRING  COMMENT  '销售商申请编号',
  AGIO  DECIMAL(6,4)  COMMENT  '实际折扣率',
  DK_BONUS_TYPE  STRING  COMMENT  '分红方式',
  DK_EXCEEDFLAG  STRING  COMMENT  '巨额赎回处理标志',
  CHILDNETNO  STRING  COMMENT  '交易网点号码',
  DK_FREEZE_CAUSE  STRING  COMMENT  '冻结原因',
  FREEZE_END_DATE  DECIMAL(8,0)  COMMENT  '冻结截止日期',
  PROTOCOLNO  STRING  COMMENT  '销售机构定投协议号',
  DK_BOURSEFLAG  STRING  COMMENT  '交易来源',
  BACK_FARE_AGIO  DECIMAL(6,4)  COMMENT  '后端申购费折扣',
  FARE_RATIO  DECIMAL(6,4)  COMMENT  '交易费率',
  DK_SYSTEM_OF_UPD  STRING  COMMENT  '记录更新系统',
  BATCHNO  DECIMAL(16,0)  COMMENT  '批次号',
  INSERTTIME  STRING  COMMENT  '插入时间戳',
  UPDATETIME  STRING  COMMENT  '更新时间戳',
  PARTITION_GROUP  STRING  COMMENT  '0',
  AG_SPLIT_RULENO  DECIMAL(12,0)  COMMENT  '渠道拆分规则序号',
  SELF_TRADE_FEE  DECIMAL(17,2)  COMMENT  '交易手续费收入-归基金公司'
)
COMMENT '交易数据'
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
            "username": "${oa_username}",
            "password": "${oa_password}",
            "connection": [{
              "querySql": ["SELECT  TRD_ST_TRX_SERIALNO
                                   , SK_INVPTY
                                   , SK_ACCOUNT
                                   , SK_TRADEACCO_REG
                                   , SK_AGENCY
                                   , SK_PRODUCT
                                   , DK_SHARE_TYPE
                                   , SK_CURRENCY
                                   , SK_AGREEMENT
                                   , SK_MKT_TRADE_TYPE
                                   , BK_FUNDACCOUNT
                                   , BK_TRADEACCOUNT
                                   , CSERIALNO
                                   , DK_TANO
                                   , AGENCYNO
                                   , NETNO
                                   , REQUEST_DATE
                                   , SK_DATE
                                   , REQ_BALANCE
                                   , REQ_SHARES
                                   , CONFIRM_BALANCE
                                   , CONFIRM_SHARES
                                   , INTEREST
                                   , INTEREST_TAX
                                   , TOTAL_FARE
                                   , TRADE_FARE
                                   , TA_FARE
                                   , AGENCY_FARE
                                   , REGIST_FARE
                                   , FUND_FARE
                                   , STAMP_TAX
                                   , BACK_FARE
                                   , OTHER_FARE
                                   , RETURN_FARE
                                   , INTEREST_SHARE
                                   , NETVALUE
                                   , DK_SALETRAN_STATUS
                                   , DK_RETCODE
                                   , DK_TAFLAG
                                   , REQUESTNO
                                   , AGIO
                                   , DK_BONUS_TYPE
                                   , DK_EXCEEDFLAG
                                   , CHILDNETNO
                                   , DK_FREEZE_CAUSE
                                   , FREEZE_END_DATE
                                   , PROTOCOLNO
                                   , DK_BOURSEFLAG
                                   , BACK_FARE_AGIO
                                   , FARE_RATIO
                                   , DK_SYSTEM_OF_UPD
                                   , BATCHNO
                                   , INSERTTIME
                                   , UPDATETIME
                                   , PARTITION_GROUP
                                   , AG_SPLIT_RULENO
                                   , SELF_TRADE_FEE
                                FROM ${oa_src_schema}.TRD_SALETRAN"],
              "jdbcUrl": ["${oa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "TRD_ST_TRX_SERIALNO", "type": "DOUBLE"}, {"name": "SK_INVPTY", "type": "DOUBLE"}, {"name": "SK_ACCOUNT", "type": "DOUBLE"}, {"name": "SK_TRADEACCO_REG", "type": "DOUBLE"}, {"name": "SK_AGENCY", "type": "DOUBLE"}, {"name": "SK_PRODUCT", "type": "DOUBLE"}, {"name": "DK_SHARE_TYPE", "type": "STRING"}, {"name": "SK_CURRENCY", "type": "DOUBLE"}, {"name": "SK_AGREEMENT", "type": "DOUBLE"}, {"name": "SK_MKT_TRADE_TYPE", "type": "DOUBLE"}, {"name": "BK_FUNDACCOUNT", "type": "STRING"}, {"name": "BK_TRADEACCOUNT", "type": "STRING"}, {"name": "CSERIALNO", "type": "STRING"}, {"name": "DK_TANO", "type": "STRING"}, {"name": "AGENCYNO", "type": "STRING"}, {"name": "NETNO", "type": "STRING"}, {"name": "REQUEST_DATE", "type": "DOUBLE"}, {"name": "SK_DATE", "type": "DOUBLE"}, {"name": "REQ_BALANCE", "type": "DOUBLE"}, {"name": "REQ_SHARES", "type": "DOUBLE"}, {"name": "CONFIRM_BALANCE", "type": "DOUBLE"}, {"name": "CONFIRM_SHARES", "type": "DOUBLE"}, {"name": "INTEREST", "type": "DOUBLE"}, {"name": "INTEREST_TAX", "type": "DOUBLE"}, {"name": "TOTAL_FARE", "type": "DOUBLE"}, {"name": "TRADE_FARE", "type": "DOUBLE"}, {"name": "TA_FARE", "type": "DOUBLE"}, {"name": "AGENCY_FARE", "type": "DOUBLE"}, {"name": "REGIST_FARE", "type": "DOUBLE"}, {"name": "FUND_FARE", "type": "DOUBLE"}, {"name": "STAMP_TAX", "type": "DOUBLE"}, {"name": "BACK_FARE", "type": "DOUBLE"}, {"name": "OTHER_FARE", "type": "DOUBLE"}, {"name": "RETURN_FARE", "type": "DOUBLE"}, {"name": "INTEREST_SHARE", "type": "DOUBLE"}, {"name": "NETVALUE", "type": "DOUBLE"}, {"name": "DK_SALETRAN_STATUS", "type": "STRING"}, {"name": "DK_RETCODE", "type": "STRING"}, {"name": "DK_TAFLAG", "type": "STRING"}, {"name": "REQUESTNO", "type": "STRING"}, {"name": "AGIO", "type": "DOUBLE"}, {"name": "DK_BONUS_TYPE", "type": "STRING"}, {"name": "DK_EXCEEDFLAG", "type": "STRING"}, {"name": "CHILDNETNO", "type": "STRING"}, {"name": "DK_FREEZE_CAUSE", "type": "STRING"}, {"name": "FREEZE_END_DATE", "type": "DOUBLE"}, {"name": "PROTOCOLNO", "type": "STRING"}, {"name": "DK_BOURSEFLAG", "type": "STRING"}, {"name": "BACK_FARE_AGIO", "type": "DOUBLE"}, {"name": "FARE_RATIO", "type": "DOUBLE"}, {"name": "DK_SYSTEM_OF_UPD", "type": "STRING"}, {"name": "BATCHNO", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "PARTITION_GROUP", "type": "STRING"}, {"name": "AG_SPLIT_RULENO", "type": "DOUBLE"}, {"name": "SELF_TRADE_FEE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_oa_trd_saletran_pfd_tmp",
            "fileType": "text",
            "path": "${oa_path}/ods_oa_trd_saletran_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_oa_trd_saletran_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_oa_trd_saletran_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_OA_TRD_SALETRAN_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_OA_TRD_SALETRAN_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_oa_trd_saletran_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_OA.ODS_OA_TRD_SALETRAN_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       TRD_ST_TRX_SERIALNO
     , SK_INVPTY
     , SK_ACCOUNT
     , SK_TRADEACCO_REG
     , SK_AGENCY
     , SK_PRODUCT
     , DK_SHARE_TYPE
     , SK_CURRENCY
     , SK_AGREEMENT
     , SK_MKT_TRADE_TYPE
     , BK_FUNDACCOUNT
     , BK_TRADEACCOUNT
     , CSERIALNO
     , DK_TANO
     , AGENCYNO
     , NETNO
     , REQUEST_DATE
     , SK_DATE
     , REQ_BALANCE
     , REQ_SHARES
     , CONFIRM_BALANCE
     , CONFIRM_SHARES
     , INTEREST
     , INTEREST_TAX
     , TOTAL_FARE
     , TRADE_FARE
     , TA_FARE
     , AGENCY_FARE
     , REGIST_FARE
     , FUND_FARE
     , STAMP_TAX
     , BACK_FARE
     , OTHER_FARE
     , RETURN_FARE
     , INTEREST_SHARE
     , NETVALUE
     , DK_SALETRAN_STATUS
     , DK_RETCODE
     , DK_TAFLAG
     , REQUESTNO
     , AGIO
     , DK_BONUS_TYPE
     , DK_EXCEEDFLAG
     , CHILDNETNO
     , DK_FREEZE_CAUSE
     , FREEZE_END_DATE
     , PROTOCOLNO
     , DK_BOURSEFLAG
     , BACK_FARE_AGIO
     , FARE_RATIO
     , DK_SYSTEM_OF_UPD
     , BATCHNO
     , INSERTTIME
     , UPDATETIME
     , PARTITION_GROUP
     , AG_SPLIT_RULENO
     , SELF_TRADE_FEE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_OA.ODS_OA_TRD_SALETRAN_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_OA.ODS_OA_TRD_SALETRAN_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_OA_TRD_SALETRAN_PFD失败"
      exit 1
   else
      echo "插入到ODS_OA_TRD_SALETRAN_PFD成功"
      exit 0
   fi
fi
