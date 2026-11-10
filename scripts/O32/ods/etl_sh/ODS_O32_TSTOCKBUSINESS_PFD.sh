#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TSTOCKBUSINESS_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TSTOCKBUSINESS_PFD_TMP(
  L_BUSIN_NO  DECIMAL(10,0)  COMMENT  '业务序号',
  L_BATCH_NO  DECIMAL(10,0)  COMMENT  '批号',
  L_DATE  DECIMAL(8,0)  COMMENT  '发生日期',
  L_TIME  DECIMAL(6,0)  COMMENT  '发生时间',
  VC_BUSIN_OPFLAG  STRING  COMMENT  '业务操作类型',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  L_BASECOMBI_ID  DECIMAL(12,0)  COMMENT  '投资组合序号',
  VC_STOCKHOLDER_ID  STRING  COMMENT  '股东代码',
  VC_BIND_SEAT  STRING  COMMENT  '托管席位',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  L_TARGET_FUND  DECIMAL(8,0)  COMMENT  '目标基金',
  L_TARGET_COMBI  DECIMAL(10,0)  COMMENT  '目标组合',
  C_TARGET_INVEST_TYPE  STRING  COMMENT  '目标投资类型',
  EN_OCCUR_AMOUNT  DECIMAL(20,4)  COMMENT  '发生数量',
  EN_PRICE  DECIMAL(16,8)  COMMENT  '成本单价',
  VC_ADJUST_INVEST  STRING  COMMENT  '*调整成本类型',
  EN_OCCUR_COST  DECIMAL(16,2)  COMMENT  '发生成本＃',
  EN_OCCUR_PROFIT  DECIMAL(16,2)  COMMENT  '发生收益＃',
  L_OPERATE_ENABLE_DATE  DECIMAL(8,0)  COMMENT  '冻结解冻起始日期',
  L_OPERATE_DISABLE_DATE  DECIMAL(8,0)  COMMENT  '冻结解冻终止日期',
  L_OPERATOR_NO  STRING  COMMENT  '操作员代码',
  VC_MEMO  STRING  COMMENT  '备注',
  L_CHECK_DATE  DECIMAL(8,0)  COMMENT  '复核日期',
  L_CHECK_TIME  DECIMAL(6,0)  COMMENT  '复核时间',
  L_CHECK_OPERATOR  DECIMAL(8,0)  COMMENT  '复核人员',
  C_CHECK_FLAG  STRING  COMMENT  '复核标志',
  VC_CHECK_MEMO  STRING  COMMENT  '复核备注',
  C_DEAL_FLAG  STRING  COMMENT  '处理标志',
  L_FROZEN_NO  DECIMAL(10,0)  COMMENT  '冻结流水序号',
  VC_TARGET_STOCK  STRING  COMMENT  '目标证券',
  C_POSITION_FLAG  STRING  COMMENT  '持仓多空标志',
  D_DATETIME  STRING  COMMENT  '时间戳',
  C_INFLUENCE_STD_AVAILABLE  STRING  COMMENT  '质押券是否可折算成标准券',
  C_DEL_STATUS  STRING  COMMENT  '删除状态',
  L_DEL_OPERATOR  DECIMAL(8,0)  COMMENT  '删除操作员',
  L_DEL_DATE  DECIMAL(8,0)  COMMENT  '删除日期',
  L_DEL_TIME  DECIMAL(6,0)  COMMENT  '删除时间',
  L_DETAIL_ID  DECIMAL(10,0)  COMMENT  '持仓明细序号',
  L_OPEN_DATE  DECIMAL(8,0)  COMMENT  '开仓日期',
  L_OPEN_TIME  DECIMAL(6,0)  COMMENT  '开仓时间',
  L_TRADE_DATE  DECIMAL(8,0)  COMMENT  '交易日期',
  VC_DEAL_NO  STRING  COMMENT  '成交编号',
  VC_ADJUST_PROFIT  STRING  COMMENT  '调整收益类型',
  L_RETURN_DATE  DECIMAL(8,0)  COMMENT  '返还日期',
  C_RETURN_POINT  STRING  COMMENT  '返还时点',
  C_RETURN_DEAL_FLAG  STRING  COMMENT  '返还处理标志',
  EN_OCCUR_COST_HK  DECIMAL(19,2)  COMMENT  '',
  EN_OCCUR_PROFIT_HK  DECIMAL(19,2)  COMMENT  '',
  EN_OCCUR_COST_NEW  DECIMAL(16,2)  COMMENT  '',
  EN_OCCUR_PROFIT_NEW  DECIMAL(16,2)  COMMENT  '',
  EN_OCCUR_INTINVEST  DECIMAL(16,2)  COMMENT  '变动利息成本',
  EN_OCCUR_INTPROFIT  DECIMAL(16,2)  COMMENT  '变动利息收益',
  VC_ADJUST_INTINVEST  STRING  COMMENT  '调整利息成本类型',
  VC_ADJUST_INTPROFIT  STRING  COMMENT  '调整利息收益类型',
  C_INFLUENCE_STK_USE  STRING  COMMENT  '',
  C_INFLUENCE_TODAY  STRING  COMMENT  '',
  C_BONDLEND_FLAG  STRING  COMMENT  '',
  EN_IMPAWN_BALANCE  DECIMAL(18,2)  COMMENT  '',
  C_RESTRICTED_TYPE  STRING  COMMENT  '受限类型',
  C_LOCKRESTRICTED_TYPE  STRING  COMMENT  '锁定受限类型',
  L_RSEND_DATE  DECIMAL(8,0)  COMMENT  '受限结束日期',
  L_STGPLC_FROZEN_AMOUNT  DECIMAL(20,4)  COMMENT  '',
  L_STGPLC_AMOUNT  DECIMAL(20,4)  COMMENT  '',
  C_SOURCE_NO  STRING  COMMENT  '',
  L_TARGET_DETAIL_ID  DECIMAL(10,0)  COMMENT  ''
)
COMMENT '证券类业务表'
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
              "querySql": ["SELECT  L_BUSIN_NO
                                   , L_BATCH_NO
                                   , L_DATE
                                   , L_TIME
                                   , VC_BUSIN_OPFLAG
                                   , L_FUND_ID
                                   , L_BASECOMBI_ID
                                   , VC_STOCKHOLDER_ID
                                   , VC_BIND_SEAT
                                   , C_INVEST_TYPE
                                   , VC_INTER_CODE
                                   , L_TARGET_FUND
                                   , L_TARGET_COMBI
                                   , C_TARGET_INVEST_TYPE
                                   , EN_OCCUR_AMOUNT
                                   , EN_PRICE
                                   , VC_ADJUST_INVEST
                                   , EN_OCCUR_COST
                                   , EN_OCCUR_PROFIT
                                   , L_OPERATE_ENABLE_DATE
                                   , L_OPERATE_DISABLE_DATE
                                   , L_OPERATOR_NO
                                   , VC_MEMO
                                   , L_CHECK_DATE
                                   , L_CHECK_TIME
                                   , L_CHECK_OPERATOR
                                   , C_CHECK_FLAG
                                   , VC_CHECK_MEMO
                                   , C_DEAL_FLAG
                                   , L_FROZEN_NO
                                   , VC_TARGET_STOCK
                                   , C_POSITION_FLAG
                                   , D_DATETIME
                                   , C_INFLUENCE_STD_AVAILABLE
                                   , C_DEL_STATUS
                                   , L_DEL_OPERATOR
                                   , L_DEL_DATE
                                   , L_DEL_TIME
                                   , L_DETAIL_ID
                                   , L_OPEN_DATE
                                   , L_OPEN_TIME
                                   , L_TRADE_DATE
                                   , VC_DEAL_NO
                                   , VC_ADJUST_PROFIT
                                   , L_RETURN_DATE
                                   , C_RETURN_POINT
                                   , C_RETURN_DEAL_FLAG
                                   , EN_OCCUR_COST_HK
                                   , EN_OCCUR_PROFIT_HK
                                   , EN_OCCUR_COST_NEW
                                   , EN_OCCUR_PROFIT_NEW
                                   , EN_OCCUR_INTINVEST
                                   , EN_OCCUR_INTPROFIT
                                   , VC_ADJUST_INTINVEST
                                   , VC_ADJUST_INTPROFIT
                                   , C_INFLUENCE_STK_USE
                                   , C_INFLUENCE_TODAY
                                   , C_BONDLEND_FLAG
                                   , EN_IMPAWN_BALANCE
                                   , C_RESTRICTED_TYPE
                                   , C_LOCKRESTRICTED_TYPE
                                   , L_RSEND_DATE
                                   , L_STGPLC_FROZEN_AMOUNT
                                   , L_STGPLC_AMOUNT
                                   , C_SOURCE_NO
                                   , L_TARGET_DETAIL_ID
                                FROM ${o32_src_schema}.THISSTOCKBUSINESS"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_BUSIN_NO", "type": "DOUBLE"}, {"name": "L_BATCH_NO", "type": "DOUBLE"}, {"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_TIME", "type": "DOUBLE"}, {"name": "VC_BUSIN_OPFLAG", "type": "STRING"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_BASECOMBI_ID", "type": "DOUBLE"}, {"name": "VC_STOCKHOLDER_ID", "type": "STRING"}, {"name": "VC_BIND_SEAT", "type": "STRING"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "L_TARGET_FUND", "type": "DOUBLE"}, {"name": "L_TARGET_COMBI", "type": "DOUBLE"}, {"name": "C_TARGET_INVEST_TYPE", "type": "STRING"}, {"name": "EN_OCCUR_AMOUNT", "type": "DOUBLE"}, {"name": "EN_PRICE", "type": "DOUBLE"}, {"name": "VC_ADJUST_INVEST", "type": "STRING"}, {"name": "EN_OCCUR_COST", "type": "DOUBLE"}, {"name": "EN_OCCUR_PROFIT", "type": "DOUBLE"}, {"name": "L_OPERATE_ENABLE_DATE", "type": "DOUBLE"}, {"name": "L_OPERATE_DISABLE_DATE", "type": "DOUBLE"}, {"name": "L_OPERATOR_NO", "type": "DOUBLE"}, {"name": "VC_MEMO", "type": "STRING"}, {"name": "L_CHECK_DATE", "type": "DOUBLE"}, {"name": "L_CHECK_TIME", "type": "DOUBLE"}, {"name": "L_CHECK_OPERATOR", "type": "DOUBLE"}, {"name": "C_CHECK_FLAG", "type": "STRING"}, {"name": "VC_CHECK_MEMO", "type": "STRING"}, {"name": "C_DEAL_FLAG", "type": "STRING"}, {"name": "L_FROZEN_NO", "type": "DOUBLE"}, {"name": "VC_TARGET_STOCK", "type": "STRING"}, {"name": "C_POSITION_FLAG", "type": "STRING"}, {"name": "D_DATETIME", "type": "STRING"}, {"name": "C_INFLUENCE_STD_AVAILABLE", "type": "STRING"}, {"name": "C_DEL_STATUS", "type": "STRING"}, {"name": "L_DEL_OPERATOR", "type": "DOUBLE"}, {"name": "L_DEL_DATE", "type": "DOUBLE"}, {"name": "L_DEL_TIME", "type": "DOUBLE"}, {"name": "L_DETAIL_ID", "type": "DOUBLE"}, {"name": "L_OPEN_DATE", "type": "DOUBLE"}, {"name": "L_OPEN_TIME", "type": "DOUBLE"}, {"name": "L_TRADE_DATE", "type": "DOUBLE"}, {"name": "VC_DEAL_NO", "type": "STRING"}, {"name": "VC_ADJUST_PROFIT", "type": "STRING"}, {"name": "L_RETURN_DATE", "type": "DOUBLE"}, {"name": "C_RETURN_POINT", "type": "STRING"}, {"name": "C_RETURN_DEAL_FLAG", "type": "STRING"}, {"name": "EN_OCCUR_COST_HK", "type": "DOUBLE"}, {"name": "EN_OCCUR_PROFIT_HK", "type": "DOUBLE"}, {"name": "EN_OCCUR_COST_NEW", "type": "DOUBLE"}, {"name": "EN_OCCUR_PROFIT_NEW", "type": "DOUBLE"}, {"name": "EN_OCCUR_INTINVEST", "type": "DOUBLE"}, {"name": "EN_OCCUR_INTPROFIT", "type": "DOUBLE"}, {"name": "VC_ADJUST_INTINVEST", "type": "STRING"}, {"name": "VC_ADJUST_INTPROFIT", "type": "STRING"}, {"name": "C_INFLUENCE_STK_USE", "type": "STRING"}, {"name": "C_INFLUENCE_TODAY", "type": "STRING"}, {"name": "C_BONDLEND_FLAG", "type": "STRING"}, {"name": "EN_IMPAWN_BALANCE", "type": "DOUBLE"}, {"name": "C_RESTRICTED_TYPE", "type": "STRING"}, {"name": "C_LOCKRESTRICTED_TYPE", "type": "STRING"}, {"name": "L_RSEND_DATE", "type": "DOUBLE"}, {"name": "L_STGPLC_FROZEN_AMOUNT", "type": "DOUBLE"}, {"name": "L_STGPLC_AMOUNT", "type": "DOUBLE"}, {"name": "C_SOURCE_NO", "type": "STRING"}, {"name": "L_TARGET_DETAIL_ID", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tstockbusiness_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tstockbusiness_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tstockbusiness_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tstockbusiness_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TSTOCKBUSINESS_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TSTOCKBUSINESS_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tstockbusiness_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TSTOCKBUSINESS_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_BUSIN_NO
     , L_BATCH_NO
     , L_DATE
     , L_TIME
     , VC_BUSIN_OPFLAG
     , L_FUND_ID
     , L_BASECOMBI_ID
     , VC_STOCKHOLDER_ID
     , VC_BIND_SEAT
     , C_INVEST_TYPE
     , VC_INTER_CODE
     , L_TARGET_FUND
     , L_TARGET_COMBI
     , C_TARGET_INVEST_TYPE
     , EN_OCCUR_AMOUNT
     , EN_PRICE
     , VC_ADJUST_INVEST
     , EN_OCCUR_COST
     , EN_OCCUR_PROFIT
     , L_OPERATE_ENABLE_DATE
     , L_OPERATE_DISABLE_DATE
     , L_OPERATOR_NO
     , VC_MEMO
     , L_CHECK_DATE
     , L_CHECK_TIME
     , L_CHECK_OPERATOR
     , C_CHECK_FLAG
     , VC_CHECK_MEMO
     , C_DEAL_FLAG
     , L_FROZEN_NO
     , VC_TARGET_STOCK
     , C_POSITION_FLAG
     , D_DATETIME
     , C_INFLUENCE_STD_AVAILABLE
     , C_DEL_STATUS
     , L_DEL_OPERATOR
     , L_DEL_DATE
     , L_DEL_TIME
     , L_DETAIL_ID
     , L_OPEN_DATE
     , L_OPEN_TIME
     , L_TRADE_DATE
     , VC_DEAL_NO
     , VC_ADJUST_PROFIT
     , L_RETURN_DATE
     , C_RETURN_POINT
     , C_RETURN_DEAL_FLAG
     , EN_OCCUR_COST_HK
     , EN_OCCUR_PROFIT_HK
     , EN_OCCUR_COST_NEW
     , EN_OCCUR_PROFIT_NEW
     , EN_OCCUR_INTINVEST
     , EN_OCCUR_INTPROFIT
     , VC_ADJUST_INTINVEST
     , VC_ADJUST_INTPROFIT
     , C_INFLUENCE_STK_USE
     , C_INFLUENCE_TODAY
     , C_BONDLEND_FLAG
     , EN_IMPAWN_BALANCE
     , C_RESTRICTED_TYPE
     , C_LOCKRESTRICTED_TYPE
     , L_RSEND_DATE
     , L_STGPLC_FROZEN_AMOUNT
     , L_STGPLC_AMOUNT
     , C_SOURCE_NO
     , L_TARGET_DETAIL_ID
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TSTOCKBUSINESS_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TSTOCKBUSINESS_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TSTOCKBUSINESS_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TSTOCKBUSINESS_PFD成功"
      exit 0
   fi
fi
