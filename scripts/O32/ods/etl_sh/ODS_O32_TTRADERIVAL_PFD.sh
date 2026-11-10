#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TTRADERIVAL_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TTRADERIVAL_PFD_TMP(
  L_RIVAL_ID  DECIMAL(10,0)  COMMENT  '对手序号',
  VC_RIVAL_CODE  STRING  COMMENT  '对手编号',
  VC_NAME  STRING  COMMENT  '对手名称',
  VC_ALL_NAME  STRING  COMMENT  '对手全称',
  C_RIVAL_TYPE  STRING  COMMENT  '对手类型',
  C_OUTER_APPRAISE  STRING  COMMENT  '外部评级',
  C_INSIDE_APPRAISE  STRING  COMMENT  '内部评级',
  C_APPRAISE  STRING  COMMENT  '综合评级',
  VC_ADDRESS  STRING  COMMENT  '地址',
  VC_LINKMAN  STRING  COMMENT  '联系人',
  VC_PHONE  STRING  COMMENT  '电话',
  VC_FAX  STRING  COMMENT  '传真',
  VC_SUMMARY  STRING  COMMENT  '备注',
  L_BANK_ID  DECIMAL(10,0)  COMMENT  '在银行间的id',
  C_BUY_SETTLEMENT  STRING  COMMENT  '',
  C_SALE_SETTLEMENT  STRING  COMMENT  '',
  VC_ENTRUST_RIGHT  STRING  COMMENT  '委托方向权限',
  VC_FUND_IDS  STRING  COMMENT  '基金序号',
  VC_CONTROL_RIGHT  STRING  COMMENT  '',
  VC_MARKET_TYPES  STRING  COMMENT  '＃市场类型',
  C_STATUS  STRING  COMMENT  '状态',
  EN_CAPITAL  DECIMAL(16,2)  COMMENT  '资本金',
  EN_TOTAL_ASSET  DECIMAL(16,2)  COMMENT  '总资产',
  EN_NET_ASSET  DECIMAL(16,2)  COMMENT  '净资产',
  L_BANKHEAD_ID  DECIMAL(10,0)  COMMENT  '银行总行id',
  VC_BANK_ACCOUNT  STRING  COMMENT  '银行间托管帐号',
  C_TRADE_CLASS  STRING  COMMENT  '对手分类',
  VC_SHCLEARING_ACCOUNT  STRING  COMMENT  '上海清算所托管账号字段',
  C_CHINABOND_DVP  STRING  COMMENT  '中债登dvp资格',
  C_SHCLEARING_DVP  STRING  COMMENT  '上清所dvp资格',
  VC_PARTY_CODE  STRING  COMMENT  '机构代码',
  VC_BANK_NAME  STRING  COMMENT  '中债登托管帐号简称',
  VC_SHCLEARING_NAME  STRING  COMMENT  '上清所托管帐号简称',
  L_ISSUER_ID  DECIMAL(10,0)  COMMENT  '关联发行人',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  VC_FIXED_ID  STRING  COMMENT  '固定收益交易商代码',
  C_ORGMASTERORSLAVE  STRING  COMMENT  '机构主从类型',
  L_MASTERORG_RIVAL_ID  DECIMAL(10,0)  COMMENT  '主机构序号',
  EN_ASSET_SCALE  DECIMAL(16,2)  COMMENT  '资金管理规模',
  L_ORG_ID  DECIMAL(8,0)  COMMENT  '公司序号',
  VC_HIS_NAME  STRING  COMMENT  '历史对手名称',
  C_MARKET_MAKER  STRING  COMMENT  '做市商类型',
  L_UPPER_BANK_ID  DECIMAL(10,0)  COMMENT  '',
  VC_UPPER_BANK_NAME  STRING  COMMENT  '',
  C_RIVAL_PROPERTY  STRING  COMMENT  '',
  VC_SPV_CODE  STRING  COMMENT  '',
  VC_DIRECT_RIVAL_TYPE  STRING  COMMENT  '',
  C_IS_RELATEDPARTY  STRING  COMMENT  '',
  C_ABROAD_ORG  STRING  COMMENT  '',
  VC_SUBORTRELA_TYPE  STRING  COMMENT  '',
  C_FB_INSIDE_APPRAISE  STRING  COMMENT  '',
  C_PRODUCT_RIVAL_TYPE  STRING  COMMENT  '',
  VC_MEMBER_ID  STRING  COMMENT  '',
  VC_INVESTOR_TYPE  STRING  COMMENT  '',
  VC_INVESTOR_NAME  STRING  COMMENT  '',
  VC_INVESTOR_ID  STRING  COMMENT  '上期经济公司代码'
)
COMMENT '交易对手表'
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
              "querySql": ["SELECT  L_RIVAL_ID
                                   , VC_RIVAL_CODE
                                   , VC_NAME
                                   , VC_ALL_NAME
                                   , C_RIVAL_TYPE
                                   , C_OUTER_APPRAISE
                                   , C_INSIDE_APPRAISE
                                   , C_APPRAISE
                                   , VC_ADDRESS
                                   , VC_LINKMAN
                                   , VC_PHONE
                                   , VC_FAX
                                   , VC_SUMMARY
                                   , L_BANK_ID
                                   , C_BUY_SETTLEMENT
                                   , C_SALE_SETTLEMENT
                                   , VC_ENTRUST_RIGHT
                                   , VC_FUND_IDS
                                   , VC_CONTROL_RIGHT
                                   , VC_MARKET_TYPES
                                   , C_STATUS
                                   , EN_CAPITAL
                                   , EN_TOTAL_ASSET
                                   , EN_NET_ASSET
                                   , L_BANKHEAD_ID
                                   , VC_BANK_ACCOUNT
                                   , C_TRADE_CLASS
                                   , VC_SHCLEARING_ACCOUNT
                                   , C_CHINABOND_DVP
                                   , C_SHCLEARING_DVP
                                   , VC_PARTY_CODE
                                   , VC_BANK_NAME
                                   , VC_SHCLEARING_NAME
                                   , L_ISSUER_ID
                                   , VC_TIMESTAMP
                                   , VC_FIXED_ID
                                   , C_ORGMASTERORSLAVE
                                   , L_MASTERORG_RIVAL_ID
                                   , EN_ASSET_SCALE
                                   , L_ORG_ID
                                   , VC_HIS_NAME
                                   , C_MARKET_MAKER
                                   , L_UPPER_BANK_ID
                                   , VC_UPPER_BANK_NAME
                                   , C_RIVAL_PROPERTY
                                   , VC_SPV_CODE
                                   , VC_DIRECT_RIVAL_TYPE
                                   , C_IS_RELATEDPARTY
                                   , C_ABROAD_ORG
                                   , VC_SUBORTRELA_TYPE
                                   , C_FB_INSIDE_APPRAISE
                                   , C_PRODUCT_RIVAL_TYPE
                                   , VC_MEMBER_ID
                                   , VC_INVESTOR_TYPE
                                   , VC_INVESTOR_NAME
                                   , VC_INVESTOR_ID
                                FROM ${o32_src_schema}.TTRADERIVAL"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_RIVAL_ID", "type": "DOUBLE"}, {"name": "VC_RIVAL_CODE", "type": "STRING"}, {"name": "VC_NAME", "type": "STRING"}, {"name": "VC_ALL_NAME", "type": "STRING"}, {"name": "C_RIVAL_TYPE", "type": "STRING"}, {"name": "C_OUTER_APPRAISE", "type": "STRING"}, {"name": "C_INSIDE_APPRAISE", "type": "STRING"}, {"name": "C_APPRAISE", "type": "STRING"}, {"name": "VC_ADDRESS", "type": "STRING"}, {"name": "VC_LINKMAN", "type": "STRING"}, {"name": "VC_PHONE", "type": "STRING"}, {"name": "VC_FAX", "type": "STRING"}, {"name": "VC_SUMMARY", "type": "STRING"}, {"name": "L_BANK_ID", "type": "DOUBLE"}, {"name": "C_BUY_SETTLEMENT", "type": "STRING"}, {"name": "C_SALE_SETTLEMENT", "type": "STRING"}, {"name": "VC_ENTRUST_RIGHT", "type": "STRING"}, {"name": "VC_FUND_IDS", "type": "STRING"}, {"name": "VC_CONTROL_RIGHT", "type": "STRING"}, {"name": "VC_MARKET_TYPES", "type": "STRING"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "EN_CAPITAL", "type": "DOUBLE"}, {"name": "EN_TOTAL_ASSET", "type": "DOUBLE"}, {"name": "EN_NET_ASSET", "type": "DOUBLE"}, {"name": "L_BANKHEAD_ID", "type": "DOUBLE"}, {"name": "VC_BANK_ACCOUNT", "type": "STRING"}, {"name": "C_TRADE_CLASS", "type": "STRING"}, {"name": "VC_SHCLEARING_ACCOUNT", "type": "STRING"}, {"name": "C_CHINABOND_DVP", "type": "STRING"}, {"name": "C_SHCLEARING_DVP", "type": "STRING"}, {"name": "VC_PARTY_CODE", "type": "STRING"}, {"name": "VC_BANK_NAME", "type": "STRING"}, {"name": "VC_SHCLEARING_NAME", "type": "STRING"}, {"name": "L_ISSUER_ID", "type": "DOUBLE"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "VC_FIXED_ID", "type": "STRING"}, {"name": "C_ORGMASTERORSLAVE", "type": "STRING"}, {"name": "L_MASTERORG_RIVAL_ID", "type": "DOUBLE"}, {"name": "EN_ASSET_SCALE", "type": "DOUBLE"}, {"name": "L_ORG_ID", "type": "DOUBLE"}, {"name": "VC_HIS_NAME", "type": "STRING"}, {"name": "C_MARKET_MAKER", "type": "STRING"}, {"name": "L_UPPER_BANK_ID", "type": "DOUBLE"}, {"name": "VC_UPPER_BANK_NAME", "type": "STRING"}, {"name": "C_RIVAL_PROPERTY", "type": "STRING"}, {"name": "VC_SPV_CODE", "type": "STRING"}, {"name": "VC_DIRECT_RIVAL_TYPE", "type": "STRING"}, {"name": "C_IS_RELATEDPARTY", "type": "STRING"}, {"name": "C_ABROAD_ORG", "type": "STRING"}, {"name": "VC_SUBORTRELA_TYPE", "type": "STRING"}, {"name": "C_FB_INSIDE_APPRAISE", "type": "STRING"}, {"name": "C_PRODUCT_RIVAL_TYPE", "type": "STRING"}, {"name": "VC_MEMBER_ID", "type": "STRING"}, {"name": "VC_INVESTOR_TYPE", "type": "STRING"}, {"name": "VC_INVESTOR_NAME", "type": "STRING"}, {"name": "VC_INVESTOR_ID", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_ttraderival_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_ttraderival_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_ttraderival_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_ttraderival_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TTRADERIVAL_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TTRADERIVAL_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_ttraderival_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TTRADERIVAL_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_RIVAL_ID
     , VC_RIVAL_CODE
     , VC_NAME
     , VC_ALL_NAME
     , C_RIVAL_TYPE
     , C_OUTER_APPRAISE
     , C_INSIDE_APPRAISE
     , C_APPRAISE
     , VC_ADDRESS
     , VC_LINKMAN
     , VC_PHONE
     , VC_FAX
     , VC_SUMMARY
     , L_BANK_ID
     , C_BUY_SETTLEMENT
     , C_SALE_SETTLEMENT
     , VC_ENTRUST_RIGHT
     , VC_FUND_IDS
     , VC_CONTROL_RIGHT
     , VC_MARKET_TYPES
     , C_STATUS
     , EN_CAPITAL
     , EN_TOTAL_ASSET
     , EN_NET_ASSET
     , L_BANKHEAD_ID
     , VC_BANK_ACCOUNT
     , C_TRADE_CLASS
     , VC_SHCLEARING_ACCOUNT
     , C_CHINABOND_DVP
     , C_SHCLEARING_DVP
     , VC_PARTY_CODE
     , VC_BANK_NAME
     , VC_SHCLEARING_NAME
     , L_ISSUER_ID
     , VC_TIMESTAMP
     , VC_FIXED_ID
     , C_ORGMASTERORSLAVE
     , L_MASTERORG_RIVAL_ID
     , EN_ASSET_SCALE
     , L_ORG_ID
     , VC_HIS_NAME
     , C_MARKET_MAKER
     , L_UPPER_BANK_ID
     , VC_UPPER_BANK_NAME
     , C_RIVAL_PROPERTY
     , VC_SPV_CODE
     , VC_DIRECT_RIVAL_TYPE
     , C_IS_RELATEDPARTY
     , C_ABROAD_ORG
     , VC_SUBORTRELA_TYPE
     , C_FB_INSIDE_APPRAISE
     , C_PRODUCT_RIVAL_TYPE
     , VC_MEMBER_ID
     , VC_INVESTOR_TYPE
     , VC_INVESTOR_NAME
     , VC_INVESTOR_ID
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TTRADERIVAL_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TTRADERIVAL_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TTRADERIVAL_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TTRADERIVAL_PFD成功"
      exit 0
   fi
fi
