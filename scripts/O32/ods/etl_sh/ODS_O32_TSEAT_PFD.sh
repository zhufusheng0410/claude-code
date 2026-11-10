#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TSEAT_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TSEAT_PFD_TMP(
  VC_SEAT_ID  STRING  COMMENT  '席位代码',
  C_MARKET_NO  STRING  COMMENT  '交易市场编号',
  VC_SEAT_NAME  STRING  COMMENT  '席位名称',
  VC_MAIN_SEAT  STRING  COMMENT  '主席位',
  VC_COMPANY_NO  STRING  COMMENT  '所属公司编号',
  VC_LINK_MAN  STRING  COMMENT  '联系人',
  VC_LINK_TYPE  STRING  COMMENT  '联系方式',
  VC_REMARK  STRING  COMMENT  '备注',
  VC_FUND_IDS  STRING  COMMENT  '使用的基金',
  C_STATUS  STRING  COMMENT  '状态',
  VC_MARKET_REMARK  STRING  COMMENT  '交易所识别码',
  C_TRADE_ATTRIBUTE  STRING  COMMENT  '交易属性',
  L_LOGOFF_DATE  DECIMAL(8,0)  COMMENT  '注销日期',
  VC_BUSINESS_CLASS  STRING  COMMENT  '固收大宗业务支持',
  VC_PASSWORD  STRING  COMMENT  '密码',
  VC_CYRJSZH  STRING  COMMENT  '参与人结算账户',
  L_SECURITIES_BRANCH  STRING  COMMENT  '分仓营业部del',
  L_VIRTUAL_KEY  DECIMAL(16,0)  COMMENT  '虚拟主键',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  C_DISTRIBUTION  STRING  COMMENT  '分仓标志',
  L_MODIFY_DATE  DECIMAL(8,0)  COMMENT  '修改日期',
  C_ALLOW_TRADESEAT  STRING  COMMENT  '',
  VC_FILLSTOCK_FUND_IDS  STRING  COMMENT  ''
)
COMMENT '席位信息表'
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
              "querySql": ["SELECT  VC_SEAT_ID
                                   , C_MARKET_NO
                                   , VC_SEAT_NAME
                                   , VC_MAIN_SEAT
                                   , VC_COMPANY_NO
                                   , VC_LINK_MAN
                                   , VC_LINK_TYPE
                                   , VC_REMARK
                                   , VC_FUND_IDS
                                   , C_STATUS
                                   , VC_MARKET_REMARK
                                   , C_TRADE_ATTRIBUTE
                                   , L_LOGOFF_DATE
                                   , VC_BUSINESS_CLASS
                                   , VC_PASSWORD
                                   , VC_CYRJSZH
                                   , L_SECURITIES_BRANCH
                                   , L_VIRTUAL_KEY
                                   , VC_TIMESTAMP
                                   , C_DISTRIBUTION
                                   , L_MODIFY_DATE
                                   , C_ALLOW_TRADESEAT
                                   , VC_FILLSTOCK_FUND_IDS
                                FROM ${o32_src_schema}.TSEAT"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "VC_SEAT_ID", "type": "STRING"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "VC_SEAT_NAME", "type": "STRING"}, {"name": "VC_MAIN_SEAT", "type": "STRING"}, {"name": "VC_COMPANY_NO", "type": "STRING"}, {"name": "VC_LINK_MAN", "type": "STRING"}, {"name": "VC_LINK_TYPE", "type": "STRING"}, {"name": "VC_REMARK", "type": "STRING"}, {"name": "VC_FUND_IDS", "type": "STRING"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "VC_MARKET_REMARK", "type": "STRING"}, {"name": "C_TRADE_ATTRIBUTE", "type": "STRING"}, {"name": "L_LOGOFF_DATE", "type": "DOUBLE"}, {"name": "VC_BUSINESS_CLASS", "type": "STRING"}, {"name": "VC_PASSWORD", "type": "STRING"}, {"name": "VC_CYRJSZH", "type": "STRING"}, {"name": "L_SECURITIES_BRANCH", "type": "STRING"}, {"name": "L_VIRTUAL_KEY", "type": "DOUBLE"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "C_DISTRIBUTION", "type": "STRING"}, {"name": "L_MODIFY_DATE", "type": "DOUBLE"}, {"name": "C_ALLOW_TRADESEAT", "type": "STRING"}, {"name": "VC_FILLSTOCK_FUND_IDS", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tseat_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tseat_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tseat_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tseat_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TSEAT_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TSEAT_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tseat_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TSEAT_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       VC_SEAT_ID
     , C_MARKET_NO
     , VC_SEAT_NAME
     , VC_MAIN_SEAT
     , VC_COMPANY_NO
     , VC_LINK_MAN
     , VC_LINK_TYPE
     , VC_REMARK
     , VC_FUND_IDS
     , C_STATUS
     , VC_MARKET_REMARK
     , C_TRADE_ATTRIBUTE
     , L_LOGOFF_DATE
     , VC_BUSINESS_CLASS
     , VC_PASSWORD
     , VC_CYRJSZH
     , L_SECURITIES_BRANCH
     , L_VIRTUAL_KEY
     , VC_TIMESTAMP
     , C_DISTRIBUTION
     , L_MODIFY_DATE
     , C_ALLOW_TRADESEAT
     , VC_FILLSTOCK_FUND_IDS
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TSEAT_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TSEAT_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TSEAT_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TSEAT_PFD成功"
      exit 0
   fi
fi
