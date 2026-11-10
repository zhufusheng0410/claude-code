#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TCOMBI_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TCOMBI_PFD_TMP(
  L_COMBI_ID  DECIMAL(12,0)  COMMENT  '投资组合序号',
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  VC_COMBI_NO  STRING  COMMENT  '投资组合编号',
  VC_COMBI_NAME  STRING  COMMENT  '投资组合名称',
  C_COMBI_CLASS  STRING  COMMENT  '*组合类型',
  L_ASSET_ID  DECIMAL(8,0)  COMMENT  '资产单元序号',
  L_SETUP_DATE  DECIMAL(8,0)  COMMENT  '创建日期',
  L_END_DATE  DECIMAL(8,0)  COMMENT  '结束日期',
  C_COMBI_STATUS  STRING  COMMENT  '组合状态',
  EN_REMARK  DECIMAL(14,8)  COMMENT  '金额备用＃',
  VC_REMARK  STRING  COMMENT  '字符备注',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  VC_STOCKTYPE_RIGHT  STRING  COMMENT  '证券类别权限',
  VC_ENTRDIRE_RIGHT  STRING  COMMENT  '委托方向权限',
  L_PARAM_ID  DECIMAL(10,0)  COMMENT  '组合模板序号',
  C_JOIN_DISTRIBUTE  STRING  COMMENT  '参与指令分配',
  EN_FUND_VALUE_RATIO  DECIMAL(9,8)  COMMENT  '基金净值比例',
  EN_TARGET_BALANCE  DECIMAL(16,2)  COMMENT  '目标金额',
  VC_COMBI_IDENTIFIER  STRING  COMMENT  '组合分类标识',
  VC_PERMIT_MARKET  STRING  COMMENT  '允许投资的交易市场',
  VC_PERMIT_BUSIN_CLASS  STRING  COMMENT  '允许投资的业务分类',
  L_EXPONENT_ID  DECIMAL(8,0)  COMMENT  '对应指数',
  C_INVEST_TYPE_PA  STRING  COMMENT  'pa投资类型',
  C_FUTURES_INVEST_TYPE  STRING  COMMENT  '股指期货投资类型',
  C_APPEND_ENTRUST  STRING  COMMENT  '是否补委托单元del',
  C_APPEND_ENTRUST_QH  STRING  COMMENT  '是否补委托单元del',
  VC_WS_TRADELEVEL  STRING  COMMENT  '网上申购允许投资的维度',
  VC_WX_TRADELEVEL  STRING  COMMENT  '网下申购允许投资的维度',
  VC_APPLY_BUSIN_CLASS  STRING  COMMENT  '允许的申购业务',
  C_FAIR_TRADE  STRING  COMMENT  '是否参与公平交易',
  L_BID_COMBI_ID  DECIMAL(8,0)  COMMENT  '标的组合',
  L_BAIL_COMBI_ID  DECIMAL(8,0)  COMMENT  '转融通担保品组合',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  C_ASSET_TYPE  STRING  COMMENT  '资产类型',
  VC_OTC_FUND_ACCOUNT  STRING  COMMENT  '',
  VC_OTC_PARTICIPANT_CODE  STRING  COMMENT  '',
  VC_STORMCOMPANY_IDS  STRING  COMMENT  '',
  VC_STRATEGY_NAME  STRING  COMMENT  '部署名称'
)
COMMENT '投资组合表'
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
              "querySql": ["SELECT  L_COMBI_ID
                                   , L_FUND_ID
                                   , VC_COMBI_NO
                                   , VC_COMBI_NAME
                                   , C_COMBI_CLASS
                                   , L_ASSET_ID
                                   , L_SETUP_DATE
                                   , L_END_DATE
                                   , C_COMBI_STATUS
                                   , EN_REMARK
                                   , VC_REMARK
                                   , C_INVEST_TYPE
                                   , VC_STOCKTYPE_RIGHT
                                   , VC_ENTRDIRE_RIGHT
                                   , L_PARAM_ID
                                   , C_JOIN_DISTRIBUTE
                                   , EN_FUND_VALUE_RATIO
                                   , EN_TARGET_BALANCE
                                   , VC_COMBI_IDENTIFIER
                                   , VC_PERMIT_MARKET
                                   , VC_PERMIT_BUSIN_CLASS
                                   , L_EXPONENT_ID
                                   , C_INVEST_TYPE_PA
                                   , C_FUTURES_INVEST_TYPE
                                   , C_APPEND_ENTRUST
                                   , C_APPEND_ENTRUST_QH
                                   , VC_WS_TRADELEVEL
                                   , VC_WX_TRADELEVEL
                                   , VC_APPLY_BUSIN_CLASS
                                   , C_FAIR_TRADE
                                   , L_BID_COMBI_ID
                                   , L_BAIL_COMBI_ID
                                   , VC_TIMESTAMP
                                   , C_ASSET_TYPE
                                   , VC_OTC_FUND_ACCOUNT
                                   , VC_OTC_PARTICIPANT_CODE
                                   , VC_STORMCOMPANY_IDS
                                   , VC_STRATEGY_NAME
                                FROM ${o32_src_schema}.TCOMBI"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_COMBI_ID", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "VC_COMBI_NO", "type": "STRING"}, {"name": "VC_COMBI_NAME", "type": "STRING"}, {"name": "C_COMBI_CLASS", "type": "STRING"}, {"name": "L_ASSET_ID", "type": "DOUBLE"}, {"name": "L_SETUP_DATE", "type": "DOUBLE"}, {"name": "L_END_DATE", "type": "DOUBLE"}, {"name": "C_COMBI_STATUS", "type": "STRING"}, {"name": "EN_REMARK", "type": "DOUBLE"}, {"name": "VC_REMARK", "type": "STRING"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "VC_STOCKTYPE_RIGHT", "type": "STRING"}, {"name": "VC_ENTRDIRE_RIGHT", "type": "STRING"}, {"name": "L_PARAM_ID", "type": "DOUBLE"}, {"name": "C_JOIN_DISTRIBUTE", "type": "STRING"}, {"name": "EN_FUND_VALUE_RATIO", "type": "DOUBLE"}, {"name": "EN_TARGET_BALANCE", "type": "DOUBLE"}, {"name": "VC_COMBI_IDENTIFIER", "type": "STRING"}, {"name": "VC_PERMIT_MARKET", "type": "STRING"}, {"name": "VC_PERMIT_BUSIN_CLASS", "type": "STRING"}, {"name": "L_EXPONENT_ID", "type": "DOUBLE"}, {"name": "C_INVEST_TYPE_PA", "type": "STRING"}, {"name": "C_FUTURES_INVEST_TYPE", "type": "STRING"}, {"name": "C_APPEND_ENTRUST", "type": "STRING"}, {"name": "C_APPEND_ENTRUST_QH", "type": "STRING"}, {"name": "VC_WS_TRADELEVEL", "type": "STRING"}, {"name": "VC_WX_TRADELEVEL", "type": "STRING"}, {"name": "VC_APPLY_BUSIN_CLASS", "type": "STRING"}, {"name": "C_FAIR_TRADE", "type": "STRING"}, {"name": "L_BID_COMBI_ID", "type": "DOUBLE"}, {"name": "L_BAIL_COMBI_ID", "type": "DOUBLE"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "C_ASSET_TYPE", "type": "STRING"}, {"name": "VC_OTC_FUND_ACCOUNT", "type": "STRING"}, {"name": "VC_OTC_PARTICIPANT_CODE", "type": "STRING"}, {"name": "VC_STORMCOMPANY_IDS", "type": "STRING"}, {"name": "VC_STRATEGY_NAME", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tcombi_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tcombi_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tcombi_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tcombi_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TCOMBI_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TCOMBI_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tcombi_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TCOMBI_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_COMBI_ID
     , L_FUND_ID
     , VC_COMBI_NO
     , VC_COMBI_NAME
     , C_COMBI_CLASS
     , L_ASSET_ID
     , L_SETUP_DATE
     , L_END_DATE
     , C_COMBI_STATUS
     , EN_REMARK
     , VC_REMARK
     , C_INVEST_TYPE
     , VC_STOCKTYPE_RIGHT
     , VC_ENTRDIRE_RIGHT
     , L_PARAM_ID
     , C_JOIN_DISTRIBUTE
     , EN_FUND_VALUE_RATIO
     , EN_TARGET_BALANCE
     , VC_COMBI_IDENTIFIER
     , VC_PERMIT_MARKET
     , VC_PERMIT_BUSIN_CLASS
     , L_EXPONENT_ID
     , C_INVEST_TYPE_PA
     , C_FUTURES_INVEST_TYPE
     , C_APPEND_ENTRUST
     , C_APPEND_ENTRUST_QH
     , VC_WS_TRADELEVEL
     , VC_WX_TRADELEVEL
     , VC_APPLY_BUSIN_CLASS
     , C_FAIR_TRADE
     , L_BID_COMBI_ID
     , L_BAIL_COMBI_ID
     , VC_TIMESTAMP
     , C_ASSET_TYPE
     , VC_OTC_FUND_ACCOUNT
     , VC_OTC_PARTICIPANT_CODE
     , VC_STORMCOMPANY_IDS
     , VC_STRATEGY_NAME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TCOMBI_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TCOMBI_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TCOMBI_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TCOMBI_PFD成功"
      exit 0
   fi
fi
