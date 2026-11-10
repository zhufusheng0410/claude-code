#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_THGREGISTER_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_THGREGISTER_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  L_OPERATOR_NO  STRING  COMMENT  '交易员代码',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  L_REDEEM_DAYS  DECIMAL(10,0)  COMMENT  '回购天数',
  L_REDEEM_LAWDATE  DECIMAL(8,0)  COMMENT  '法定购回日期',
  L_REDEEM_LIQUIDATE  DECIMAL(8,0)  COMMENT  '实际购回日期',
  C_MARKET_NO  STRING  COMMENT  '市场编号',
  VC_SEAT_ID  STRING  COMMENT  '席位代码',
  VC_STOCKHOLDER_ID  STRING  COMMENT  '股东代码',
  VC_INTER_CODE  STRING  COMMENT  '证券代码',
  C_STOCK_TYPE  STRING  COMMENT  '证券类别',
  C_ENTRUST_DIRECTION  STRING  COMMENT  '委托方向',
  L_DEAL_AMOUNT  DECIMAL(12,0)  COMMENT  '成交数量',
  EN_DEAL_PRICE  DECIMAL(20,12)  COMMENT  '成交价格',
  EN_DEAL_BALANCE  DECIMAL(16,2)  COMMENT  '成交金额',
  EN_REDEEM_INTEREST  DECIMAL(16,2)  COMMENT  '回购利息',
  L_REPORT_TIME  DECIMAL(6,0)  COMMENT  '申报时间',
  EN_FEE  DECIMAL(12,2)  COMMENT  '回购费用',
  L_SETTLE_DATE  DECIMAL(8,0)  COMMENT  '购回交割日期',
  L_SETTLE_SPEED  DECIMAL(10,0)  COMMENT  '清算速度',
  C_FROZEN_FLAG  STRING  COMMENT  '购回冻结标志',
  L_BASECOMBI_ID  DECIMAL(10,0)  COMMENT  '投资组合序号',
  C_REDEAL_FLAG  STRING  COMMENT  '购回处理标志',
  L_SERIAL_NO  DECIMAL(10,0)  COMMENT  '流水序号',
  L_REDEAL_DATE  DECIMAL(8,0)  COMMENT  '购回处理日期',
  L_ENTRUST_SERIAL_NO  DECIMAL(10,0)  COMMENT  '委托序号',
  L_HG_DATE  DECIMAL(8,0)  COMMENT  '回购日期',
  C_PURPOSE_TYPE  STRING  COMMENT  '回购用途类别',
  C_REDEAL_AVAILABLE_FLAG  STRING  COMMENT  '购回可用处理标志',
  EN_FIRST_PRICE  DECIMAL(20,12)  COMMENT  '#首次交易价格',
  EN_FIRST_BOND_INTEREST  DECIMAL(18,12)  COMMENT  '#首次交易百元债券利息',
  EN_MATURE_PRICE  DECIMAL(20,12)  COMMENT  '到期交易价格',
  EN_MATURE_BOND_INTEREST  DECIMAL(18,12)  COMMENT  '到期应计百元债券利息',
  EN_INTEREST_PAYMENT_BALANCE  DECIMAL(16,2)  COMMENT  '中途付息金额',
  L_BUSIN_AMOUNT  DECIMAL(18,4)  COMMENT  '标的券成交数量',
  EN_NOW_INTEREST  DECIMAL(16,2)  COMMENT  '当前已计利息',
  VC_CONTRACT_NO  STRING  COMMENT  '合同序号',
  L_YEAR_DAYS  DECIMAL(10,0)  COMMENT  '计息天数',
  EN_GH_BALANCE  DECIMAL(16,2)  COMMENT  '购回金额',
  EN_EXTRA_PAY_INTEREST  DECIMAL(16,2)  COMMENT  '追加付息金额',
  EN_NEW_RATE  DECIMAL(16,8)  COMMENT  '延期利率',
  L_NEW_REDEEM_DATE  DECIMAL(8,0)  COMMENT  '延期购回日期',
  C_TRUSTEE  STRING  COMMENT  '托管机构',
  VC_TARGET_INTER_CODE  STRING  COMMENT  '目标代码',
  VC_TARGET_STOCKHOLDER_ID  STRING  COMMENT  '目标股东',
  VC_TARGET_SEAT_ID  STRING  COMMENT  '目标席位',
  VC_SUMMARY  STRING  COMMENT  '备注',
  VC_RIVAL_SEAT  STRING  COMMENT  '对手席位',
  L_RIVAL_ID  DECIMAL(10,0)  COMMENT  '交易对手',
  EN_MORTGAGE_BALANCE  DECIMAL(16,2)  COMMENT  '质押金额',
  VC_RIVALTRADER_ID  STRING  COMMENT  '对手交易员id',
  L_HG_TRADE_DATE  DECIMAL(8,0)  COMMENT  '成交时回购日期',
  VC_BASKET_NO  STRING  COMMENT  '质押券篮子编号',
  L_ADD_DATE  DECIMAL(8,0)  COMMENT  '最后补充质押日期',
  L_BACK_DATE  DECIMAL(8,0)  COMMENT  '最后提前购回日期',
  EN_PENALTY_INTEREST  DECIMAL(16,2)  COMMENT  '罚息',
  L_ADD_AMOUNT  DECIMAL(18,4)  COMMENT  '补充质押数量',
  L_ORIGINAL_AMOUNT  DECIMAL(18,4)  COMMENT  '原质押数量',
  L_BACK_AMOUNT  DECIMAL(18,4)  COMMENT  '提前购回数量',
  EN_BACK_BALANCE  DECIMAL(16,2)  COMMENT  '提前购回金额',
  EN_ORIGINAL_BALANCE  DECIMAL(16,2)  COMMENT  '原合同金额',
  VC_DEAL_NO  STRING  COMMENT  '成交编号',
  C_CLEAR_TYPE  STRING  COMMENT  '清算类型',
  C_ACCOUNT_MODE  STRING  COMMENT  '做账模式',
  C_STATUS  STRING  COMMENT  '同步状态',
  VC_UNIQUE_DEAL_SERIAL_NO  STRING  COMMENT  '对接外部系统唯一成交标识',
  VC_SOURCE_NO  STRING  COMMENT  '',
  C_INTEREST_PAYMENT_FLAG  STRING  COMMENT  '',
  VC_REPORT_ID  STRING  COMMENT  '',
  C_DISPUTE_RESOLUTIO  STRING  COMMENT  '',
  C_PLEDGED_REPLACE_TYPE  STRING  COMMENT  '',
  EN_LIQUIDATED_BALANCE  DECIMAL(16,2)  COMMENT  '',
  C_FIRST_REDEAL_FLAG  STRING  COMMENT  '',
  C_HGOCCUPYDAYS_FLAG  STRING  COMMENT  '',
  L_GRACE_DATE  DECIMAL(8,0)  COMMENT  '',
  C_FROZEN_STATUS  STRING  COMMENT  '',
  L_HG_SETTLE_DATE  DECIMAL(8,0)  COMMENT  '',
  VC_MEMBER_ID  STRING  COMMENT  '',
  VC_INVESTOR_ID  STRING  COMMENT  '上期经济公司代码',
  VC_RIVALMEMBER_ID  STRING  COMMENT  '',
  VC_RIVALINVESTOR_ID  STRING  COMMENT  '',
  L_ORIGINAL_SERIAL_NO  DECIMAL(10,0)  COMMENT  '原报价序号'
)
COMMENT '在途回购表'
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
                                   , L_OPERATOR_NO
                                   , L_FUND_ID
                                   , L_REDEEM_DAYS
                                   , L_REDEEM_LAWDATE
                                   , L_REDEEM_LIQUIDATE
                                   , C_MARKET_NO
                                   , VC_SEAT_ID
                                   , VC_STOCKHOLDER_ID
                                   , VC_INTER_CODE
                                   , C_STOCK_TYPE
                                   , C_ENTRUST_DIRECTION
                                   , L_DEAL_AMOUNT
                                   , EN_DEAL_PRICE
                                   , EN_DEAL_BALANCE
                                   , EN_REDEEM_INTEREST
                                   , L_REPORT_TIME
                                   , EN_FEE
                                   , L_SETTLE_DATE
                                   , L_SETTLE_SPEED
                                   , C_FROZEN_FLAG
                                   , L_BASECOMBI_ID
                                   , C_REDEAL_FLAG
                                   , L_SERIAL_NO
                                   , L_REDEAL_DATE
                                   , L_ENTRUST_SERIAL_NO
                                   , L_HG_DATE
                                   , C_PURPOSE_TYPE
                                   , C_REDEAL_AVAILABLE_FLAG
                                   , EN_FIRST_PRICE
                                   , EN_FIRST_BOND_INTEREST
                                   , EN_MATURE_PRICE
                                   , EN_MATURE_BOND_INTEREST
                                   , EN_INTEREST_PAYMENT_BALANCE
                                   , L_BUSIN_AMOUNT
                                   , EN_NOW_INTEREST
                                   , VC_CONTRACT_NO
                                   , L_YEAR_DAYS
                                   , EN_GH_BALANCE
                                   , EN_EXTRA_PAY_INTEREST
                                   , EN_NEW_RATE
                                   , L_NEW_REDEEM_DATE
                                   , C_TRUSTEE
                                   , VC_TARGET_INTER_CODE
                                   , VC_TARGET_STOCKHOLDER_ID
                                   , VC_TARGET_SEAT_ID
                                   , VC_SUMMARY
                                   , VC_RIVAL_SEAT
                                   , L_RIVAL_ID
                                   , EN_MORTGAGE_BALANCE
                                   , VC_RIVALTRADER_ID
                                   , L_HG_TRADE_DATE
                                   , VC_BASKET_NO
                                   , L_ADD_DATE
                                   , L_BACK_DATE
                                   , EN_PENALTY_INTEREST
                                   , L_ADD_AMOUNT
                                   , L_ORIGINAL_AMOUNT
                                   , L_BACK_AMOUNT
                                   , EN_BACK_BALANCE
                                   , EN_ORIGINAL_BALANCE
                                   , VC_DEAL_NO
                                   , C_CLEAR_TYPE
                                   , C_ACCOUNT_MODE
                                   , C_STATUS
                                   , VC_UNIQUE_DEAL_SERIAL_NO
                                   , VC_SOURCE_NO
                                   , C_INTEREST_PAYMENT_FLAG
                                   , VC_REPORT_ID
                                   , C_DISPUTE_RESOLUTIO
                                   , C_PLEDGED_REPLACE_TYPE
                                   , EN_LIQUIDATED_BALANCE
                                   , C_FIRST_REDEAL_FLAG
                                   , C_HGOCCUPYDAYS_FLAG
                                   , L_GRACE_DATE
                                   , C_FROZEN_STATUS
                                   , L_HG_SETTLE_DATE
                                   , VC_MEMBER_ID
                                   , VC_INVESTOR_ID
                                   , VC_RIVALMEMBER_ID
                                   , VC_RIVALINVESTOR_ID
                                   , L_ORIGINAL_SERIAL_NO
                                FROM ${o32_src_schema}.THISHGREGISTER
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_OPERATOR_NO", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_REDEEM_DAYS", "type": "DOUBLE"}, {"name": "L_REDEEM_LAWDATE", "type": "DOUBLE"}, {"name": "L_REDEEM_LIQUIDATE", "type": "DOUBLE"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "VC_SEAT_ID", "type": "STRING"}, {"name": "VC_STOCKHOLDER_ID", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "C_STOCK_TYPE", "type": "STRING"}, {"name": "C_ENTRUST_DIRECTION", "type": "STRING"}, {"name": "L_DEAL_AMOUNT", "type": "DOUBLE"}, {"name": "EN_DEAL_PRICE", "type": "DOUBLE"}, {"name": "EN_DEAL_BALANCE", "type": "DOUBLE"}, {"name": "EN_REDEEM_INTEREST", "type": "DOUBLE"}, {"name": "L_REPORT_TIME", "type": "DOUBLE"}, {"name": "EN_FEE", "type": "DOUBLE"}, {"name": "L_SETTLE_DATE", "type": "DOUBLE"}, {"name": "L_SETTLE_SPEED", "type": "DOUBLE"}, {"name": "C_FROZEN_FLAG", "type": "STRING"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "C_REDEAL_FLAG", "type": "STRING"}, {"name": "L_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_REDEAL_DATE", "type": "DOUBLE"}, {"name": "L_ENTRUST_SERIAL_NO", "type": "DOUBLE"}, {"name": "L_HG_DATE", "type": "DOUBLE"}, {"name": "C_PURPOSE_TYPE", "type": "STRING"}, {"name": "C_REDEAL_AVAILABLE_FLAG", "type": "STRING"}, {"name": "EN_FIRST_PRICE", "type": "DOUBLE"}, {"name": "EN_FIRST_BOND_INTEREST", "type": "DOUBLE"}, {"name": "EN_MATURE_PRICE", "type": "DOUBLE"}, {"name": "EN_MATURE_BOND_INTEREST", "type": "DOUBLE"}, {"name": "EN_INTEREST_PAYMENT_BALANCE", "type": "DOUBLE"}, {"name": "L_BUSIN_AMOUNT", "type": "DOUBLE"}, {"name": "EN_NOW_INTEREST", "type": "DOUBLE"}, {"name": "VC_CONTRACT_NO", "type": "STRING"}, {"name": "L_YEAR_DAYS", "type": "DOUBLE"}, {"name": "EN_GH_BALANCE", "type": "DOUBLE"}, {"name": "EN_EXTRA_PAY_INTEREST", "type": "DOUBLE"}, {"name": "EN_NEW_RATE", "type": "DOUBLE"}, {"name": "L_NEW_REDEEM_DATE", "type": "DOUBLE"}, {"name": "C_TRUSTEE", "type": "STRING"}, {"name": "VC_TARGET_INTER_CODE", "type": "STRING"}, {"name": "VC_TARGET_STOCKHOLDER_ID", "type": "STRING"}, {"name": "VC_TARGET_SEAT_ID", "type": "STRING"}, {"name": "VC_SUMMARY", "type": "STRING"}, {"name": "VC_RIVAL_SEAT", "type": "STRING"}, {"name": "L_RIVAL_ID", "type": "DOUBLE"}, {"name": "EN_MORTGAGE_BALANCE", "type": "DOUBLE"}, {"name": "VC_RIVALTRADER_ID", "type": "STRING"}, {"name": "L_HG_TRADE_DATE", "type": "DOUBLE"}, {"name": "VC_BASKET_NO", "type": "STRING"}, {"name": "L_ADD_DATE", "type": "DOUBLE"}, {"name": "L_BACK_DATE", "type": "DOUBLE"}, {"name": "EN_PENALTY_INTEREST", "type": "DOUBLE"}, {"name": "L_ADD_AMOUNT", "type": "DOUBLE"}, {"name": "L_ORIGINAL_AMOUNT", "type": "DOUBLE"}, {"name": "L_BACK_AMOUNT", "type": "DOUBLE"}, {"name": "EN_BACK_BALANCE", "type": "DOUBLE"}, {"name": "EN_ORIGINAL_BALANCE", "type": "DOUBLE"}, {"name": "VC_DEAL_NO", "type": "STRING"}, {"name": "C_CLEAR_TYPE", "type": "STRING"}, {"name": "C_ACCOUNT_MODE", "type": "STRING"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "VC_UNIQUE_DEAL_SERIAL_NO", "type": "STRING"}, {"name": "VC_SOURCE_NO", "type": "STRING"}, {"name": "C_INTEREST_PAYMENT_FLAG", "type": "STRING"}, {"name": "VC_REPORT_ID", "type": "STRING"}, {"name": "C_DISPUTE_RESOLUTIO", "type": "STRING"}, {"name": "C_PLEDGED_REPLACE_TYPE", "type": "STRING"}, {"name": "EN_LIQUIDATED_BALANCE", "type": "DOUBLE"}, {"name": "C_FIRST_REDEAL_FLAG", "type": "STRING"}, {"name": "C_HGOCCUPYDAYS_FLAG", "type": "STRING"}, {"name": "L_GRACE_DATE", "type": "DOUBLE"}, {"name": "C_FROZEN_STATUS", "type": "STRING"}, {"name": "L_HG_SETTLE_DATE", "type": "DOUBLE"}, {"name": "VC_MEMBER_ID", "type": "STRING"}, {"name": "VC_INVESTOR_ID", "type": "STRING"}, {"name": "VC_RIVALMEMBER_ID", "type": "STRING"}, {"name": "VC_RIVALINVESTOR_ID", "type": "STRING"}, {"name": "L_ORIGINAL_SERIAL_NO", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_thgregister_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_thgregister_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_thgregister_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_thgregister_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_THGREGISTER_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_THGREGISTER_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_thgregister_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_THGREGISTER_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , L_OPERATOR_NO
     , L_FUND_ID
     , L_REDEEM_DAYS
     , L_REDEEM_LAWDATE
     , L_REDEEM_LIQUIDATE
     , C_MARKET_NO
     , VC_SEAT_ID
     , VC_STOCKHOLDER_ID
     , VC_INTER_CODE
     , C_STOCK_TYPE
     , C_ENTRUST_DIRECTION
     , L_DEAL_AMOUNT
     , EN_DEAL_PRICE
     , EN_DEAL_BALANCE
     , EN_REDEEM_INTEREST
     , L_REPORT_TIME
     , EN_FEE
     , L_SETTLE_DATE
     , L_SETTLE_SPEED
     , C_FROZEN_FLAG
     , L_BASECOMBI_ID
     , C_REDEAL_FLAG
     , L_SERIAL_NO
     , L_REDEAL_DATE
     , L_ENTRUST_SERIAL_NO
     , L_HG_DATE
     , C_PURPOSE_TYPE
     , C_REDEAL_AVAILABLE_FLAG
     , EN_FIRST_PRICE
     , EN_FIRST_BOND_INTEREST
     , EN_MATURE_PRICE
     , EN_MATURE_BOND_INTEREST
     , EN_INTEREST_PAYMENT_BALANCE
     , L_BUSIN_AMOUNT
     , EN_NOW_INTEREST
     , VC_CONTRACT_NO
     , L_YEAR_DAYS
     , EN_GH_BALANCE
     , EN_EXTRA_PAY_INTEREST
     , EN_NEW_RATE
     , L_NEW_REDEEM_DATE
     , C_TRUSTEE
     , VC_TARGET_INTER_CODE
     , VC_TARGET_STOCKHOLDER_ID
     , VC_TARGET_SEAT_ID
     , VC_SUMMARY
     , VC_RIVAL_SEAT
     , L_RIVAL_ID
     , EN_MORTGAGE_BALANCE
     , VC_RIVALTRADER_ID
     , L_HG_TRADE_DATE
     , VC_BASKET_NO
     , L_ADD_DATE
     , L_BACK_DATE
     , EN_PENALTY_INTEREST
     , L_ADD_AMOUNT
     , L_ORIGINAL_AMOUNT
     , L_BACK_AMOUNT
     , EN_BACK_BALANCE
     , EN_ORIGINAL_BALANCE
     , VC_DEAL_NO
     , C_CLEAR_TYPE
     , C_ACCOUNT_MODE
     , C_STATUS
     , VC_UNIQUE_DEAL_SERIAL_NO
     , VC_SOURCE_NO
     , C_INTEREST_PAYMENT_FLAG
     , VC_REPORT_ID
     , C_DISPUTE_RESOLUTIO
     , C_PLEDGED_REPLACE_TYPE
     , EN_LIQUIDATED_BALANCE
     , C_FIRST_REDEAL_FLAG
     , C_HGOCCUPYDAYS_FLAG
     , L_GRACE_DATE
     , C_FROZEN_STATUS
     , L_HG_SETTLE_DATE
     , VC_MEMBER_ID
     , VC_INVESTOR_ID
     , VC_RIVALMEMBER_ID
     , VC_RIVALINVESTOR_ID
     , L_ORIGINAL_SERIAL_NO
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_THGREGISTER_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_THGREGISTER_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_THGREGISTER_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_THGREGISTER_PTD成功"
      exit 0
   fi
fi
