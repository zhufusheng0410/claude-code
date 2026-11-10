#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TBROKER_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TBROKER_PFD_TMP(
  VC_BROKER_NO  STRING  COMMENT  'broker编号',
  VC_PARENT_BROKER_NO  STRING  COMMENT  '上层broker编号',
  VC_BROKER_NAME  STRING  COMMENT  'broker名称',
  VC_COUNTRY_NO  STRING  COMMENT  '国家',
  VC_BIC_CODE  STRING  COMMENT  'bic代码',
  C_FIX_ALLOCATION  STRING  COMMENT  '是否支持成交分配通过fix发送',
  VC_OMGEO_BROKER_TYPE  STRING  COMMENT  'omgeo编码类型',
  VC_OMGEO_BROKER_CODE  STRING  COMMENT  'omgeo编号',
  VC_OMGEO_BRMG  STRING  COMMENT  'omgeo券商组编号',
  VC_TRADE_MEMBER  STRING  COMMENT  '交易会员号',
  C_TYPE  STRING  COMMENT  '类型',
  C_PROFIT_AVAILABLE  STRING  COMMENT  '期货盈亏可用模式',
  VC_EXTERNAL_BROKER_NO  STRING  COMMENT  '券商外部系统编号',
  C_RIGHT_CONFIRM  STRING  COMMENT  '是否能返回正确的确认号',
  C_ACCOUNTCHECK_TYPE  STRING  COMMENT  '同一证券多业务分类汇总方式',
  VC_SIGN_FUNDS  STRING  COMMENT  '签约的基金',
  VC_REPORTCODE_TYPE  STRING  COMMENT  '申报代码类型',
  C_ENTRUSTS_COMBI  STRING  COMMENT  '支持合笔委托',
  VC_CLIENT_ID  STRING  COMMENT  '客户号',
  VC_TRADE_MEMBER_SQ  STRING  COMMENT  '上海期货交易所交易会员编号',
  VC_TRADE_MEMBER_ZZ  STRING  COMMENT  '郑州商品交易所交易会员编号',
  VC_TRADE_MEMBER_DL  STRING  COMMENT  '大连商品交易所交易会员编号',
  VC_PRICE_TYPE  STRING  COMMENT  '支持的价格模式',
  VC_TRADE_MEMBER_NY  STRING  COMMENT  '',
  L_SH_REPORT_NUMBER_DIGITS  STRING  COMMENT  '上交所业务分仓申报编号位数',
  L_SZ_REPORT_NUMBER_DIGITS  STRING  COMMENT  '深圳业务分仓申报编号位数',
  L_GZ_REPORT_NUMBER_DIGITS  STRING  COMMENT  '股转市场业务分仓申报编号位数',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  L_VIRTUAL_KEY  DECIMAL(16,0)  COMMENT  '虚拟主键',
  VC_LIQCOMPANY_NAME  STRING  COMMENT  '',
  VC_SELLTE_MEMBER  STRING  COMMENT  '',
  C_SPECIAL_QUOTA_MODE  STRING  COMMENT  '专项额度模式仅pb有',
  L_HG_REPORT_NUMBER_DIGITS  DECIMAL(4,0)  COMMENT  '',
  L_SG_REPORT_NUMBER_DIGITS  DECIMAL(4,0)  COMMENT  '',
  VC_TRADE_MEMBER_GQ  STRING  COMMENT  ''
)
COMMENT '券商表'
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
              "querySql": ["SELECT  VC_BROKER_NO
                                   , VC_PARENT_BROKER_NO
                                   , VC_BROKER_NAME
                                   , VC_COUNTRY_NO
                                   , VC_BIC_CODE
                                   , C_FIX_ALLOCATION
                                   , VC_OMGEO_BROKER_TYPE
                                   , VC_OMGEO_BROKER_CODE
                                   , VC_OMGEO_BRMG
                                   , VC_TRADE_MEMBER
                                   , C_TYPE
                                   , C_PROFIT_AVAILABLE
                                   , VC_EXTERNAL_BROKER_NO
                                   , C_RIGHT_CONFIRM
                                   , C_ACCOUNTCHECK_TYPE
                                   , VC_SIGN_FUNDS
                                   , VC_REPORTCODE_TYPE
                                   , C_ENTRUSTS_COMBI
                                   , VC_CLIENT_ID
                                   , VC_TRADE_MEMBER_SQ
                                   , VC_TRADE_MEMBER_ZZ
                                   , VC_TRADE_MEMBER_DL
                                   , VC_PRICE_TYPE
                                   , VC_TRADE_MEMBER_NY
                                   , L_SH_REPORT_NUMBER_DIGITS
                                   , L_SZ_REPORT_NUMBER_DIGITS
                                   , L_GZ_REPORT_NUMBER_DIGITS
                                   , VC_TIMESTAMP
                                   , L_VIRTUAL_KEY
                                   , VC_LIQCOMPANY_NAME
                                   , VC_SELLTE_MEMBER
                                   , C_SPECIAL_QUOTA_MODE
                                   , L_HG_REPORT_NUMBER_DIGITS
                                   , L_SG_REPORT_NUMBER_DIGITS
                                   , VC_TRADE_MEMBER_GQ
                                FROM ${o32_src_schema}.TBROKER"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "VC_BROKER_NO", "type": "STRING"}, {"name": "VC_PARENT_BROKER_NO", "type": "STRING"}, {"name": "VC_BROKER_NAME", "type": "STRING"}, {"name": "VC_COUNTRY_NO", "type": "STRING"}, {"name": "VC_BIC_CODE", "type": "STRING"}, {"name": "C_FIX_ALLOCATION", "type": "STRING"}, {"name": "VC_OMGEO_BROKER_TYPE", "type": "STRING"}, {"name": "VC_OMGEO_BROKER_CODE", "type": "STRING"}, {"name": "VC_OMGEO_BRMG", "type": "STRING"}, {"name": "VC_TRADE_MEMBER", "type": "STRING"}, {"name": "C_TYPE", "type": "STRING"}, {"name": "C_PROFIT_AVAILABLE", "type": "STRING"}, {"name": "VC_EXTERNAL_BROKER_NO", "type": "STRING"}, {"name": "C_RIGHT_CONFIRM", "type": "STRING"}, {"name": "C_ACCOUNTCHECK_TYPE", "type": "STRING"}, {"name": "VC_SIGN_FUNDS", "type": "STRING"}, {"name": "VC_REPORTCODE_TYPE", "type": "STRING"}, {"name": "C_ENTRUSTS_COMBI", "type": "STRING"}, {"name": "VC_CLIENT_ID", "type": "STRING"}, {"name": "VC_TRADE_MEMBER_SQ", "type": "STRING"}, {"name": "VC_TRADE_MEMBER_ZZ", "type": "STRING"}, {"name": "VC_TRADE_MEMBER_DL", "type": "STRING"}, {"name": "VC_PRICE_TYPE", "type": "STRING"}, {"name": "VC_TRADE_MEMBER_NY", "type": "STRING"}, {"name": "L_SH_REPORT_NUMBER_DIGITS", "type": "DOUBLE"}, {"name": "L_SZ_REPORT_NUMBER_DIGITS", "type": "DOUBLE"}, {"name": "L_GZ_REPORT_NUMBER_DIGITS", "type": "DOUBLE"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "L_VIRTUAL_KEY", "type": "DOUBLE"}, {"name": "VC_LIQCOMPANY_NAME", "type": "STRING"}, {"name": "VC_SELLTE_MEMBER", "type": "STRING"}, {"name": "C_SPECIAL_QUOTA_MODE", "type": "STRING"}, {"name": "L_HG_REPORT_NUMBER_DIGITS", "type": "DOUBLE"}, {"name": "L_SG_REPORT_NUMBER_DIGITS", "type": "DOUBLE"}, {"name": "VC_TRADE_MEMBER_GQ", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tbroker_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tbroker_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tbroker_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tbroker_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TBROKER_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TBROKER_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tbroker_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TBROKER_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       VC_BROKER_NO
     , VC_PARENT_BROKER_NO
     , VC_BROKER_NAME
     , VC_COUNTRY_NO
     , VC_BIC_CODE
     , C_FIX_ALLOCATION
     , VC_OMGEO_BROKER_TYPE
     , VC_OMGEO_BROKER_CODE
     , VC_OMGEO_BRMG
     , VC_TRADE_MEMBER
     , C_TYPE
     , C_PROFIT_AVAILABLE
     , VC_EXTERNAL_BROKER_NO
     , C_RIGHT_CONFIRM
     , C_ACCOUNTCHECK_TYPE
     , VC_SIGN_FUNDS
     , VC_REPORTCODE_TYPE
     , C_ENTRUSTS_COMBI
     , VC_CLIENT_ID
     , VC_TRADE_MEMBER_SQ
     , VC_TRADE_MEMBER_ZZ
     , VC_TRADE_MEMBER_DL
     , VC_PRICE_TYPE
     , VC_TRADE_MEMBER_NY
     , L_SH_REPORT_NUMBER_DIGITS
     , L_SZ_REPORT_NUMBER_DIGITS
     , L_GZ_REPORT_NUMBER_DIGITS
     , VC_TIMESTAMP
     , L_VIRTUAL_KEY
     , VC_LIQCOMPANY_NAME
     , VC_SELLTE_MEMBER
     , C_SPECIAL_QUOTA_MODE
     , L_HG_REPORT_NUMBER_DIGITS
     , L_SG_REPORT_NUMBER_DIGITS
     , VC_TRADE_MEMBER_GQ
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TBROKER_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TBROKER_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TBROKER_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TBROKER_PFD成功"
      exit 0
   fi
fi
