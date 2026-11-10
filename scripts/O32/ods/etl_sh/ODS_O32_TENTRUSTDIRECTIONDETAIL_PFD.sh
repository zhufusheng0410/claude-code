#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TENTRUSTDIRECTIONDETAIL_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TENTRUSTDIRECTIONDETAIL_PFD_TMP(
  C_MARKET_NO  STRING  COMMENT  '交易市场编号',
  C_ENTRUST_DIRECTION  STRING  COMMENT  '委托方向',
  C_PRICE_TYPE  STRING  COMMENT  '委托价格类型',
  VC_PRICE_NAME  STRING  COMMENT  '价格类型名称',
  VC_REPORT_DIRECTION  STRING  COMMENT  '申报方向',
  VC_REPORT_FLAG  STRING  COMMENT  '申报标志',
  EN_REPORT_PRICE  DECIMAL(16,8)  COMMENT  '申报价格',
  C_BRANCH_PRICE_TYPE  STRING  COMMENT  '分仓价格类型',
  C_LIMIT_PRICE  STRING  COMMENT  '是否限价',
  VC_VALID_TYPE  STRING  COMMENT  '有效类型',
  VC_MSGTYPE  STRING  COMMENT  '消息类型',
  C_TIMEINFORCE  STRING  COMMENT  '有效期类型',
  C_ORDTYPE  STRING  COMMENT  '订单类型',
  L_MAXPRICELEVELS  DECIMAL(10,0)  COMMENT  '最多成交价位数',
  VC_APPLID  STRING  COMMENT  '应用标识',
  C_PLATFORM_TYPE  STRING  COMMENT  '所属平台',
  VC_BINARY_MSGTYPE  STRING  COMMENT  'binary消息类型',
  VC_STOCK_TYPE  STRING  COMMENT  '证券类别'
)
COMMENT '委托方向明细表'
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
              "querySql": ["SELECT  C_MARKET_NO
                                   , C_ENTRUST_DIRECTION
                                   , C_PRICE_TYPE
                                   , VC_PRICE_NAME
                                   , VC_REPORT_DIRECTION
                                   , VC_REPORT_FLAG
                                   , EN_REPORT_PRICE
                                   , C_BRANCH_PRICE_TYPE
                                   , C_LIMIT_PRICE
                                   , VC_VALID_TYPE
                                   , VC_MSGTYPE
                                   , C_TIMEINFORCE
                                   , C_ORDTYPE
                                   , L_MAXPRICELEVELS
                                   , VC_APPLID
                                   , C_PLATFORM_TYPE
                                   , VC_BINARY_MSGTYPE
                                   , VC_STOCK_TYPE
                                FROM ${o32_src_schema}.TENTRUSTDIRECTIONDETAIL"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_MARKET_NO", "type": "STRING"}, {"name": "C_ENTRUST_DIRECTION", "type": "STRING"}, {"name": "C_PRICE_TYPE", "type": "STRING"}, {"name": "VC_PRICE_NAME", "type": "STRING"}, {"name": "VC_REPORT_DIRECTION", "type": "STRING"}, {"name": "VC_REPORT_FLAG", "type": "STRING"}, {"name": "EN_REPORT_PRICE", "type": "DOUBLE"}, {"name": "C_BRANCH_PRICE_TYPE", "type": "STRING"}, {"name": "C_LIMIT_PRICE", "type": "STRING"}, {"name": "VC_VALID_TYPE", "type": "STRING"}, {"name": "VC_MSGTYPE", "type": "STRING"}, {"name": "C_TIMEINFORCE", "type": "STRING"}, {"name": "C_ORDTYPE", "type": "STRING"}, {"name": "L_MAXPRICELEVELS", "type": "DOUBLE"}, {"name": "VC_APPLID", "type": "STRING"}, {"name": "C_PLATFORM_TYPE", "type": "STRING"}, {"name": "VC_BINARY_MSGTYPE", "type": "STRING"}, {"name": "VC_STOCK_TYPE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tentrustdirectiondetail_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tentrustdirectiondetail_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tentrustdirectiondetail_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tentrustdirectiondetail_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TENTRUSTDIRECTIONDETAIL_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TENTRUSTDIRECTIONDETAIL_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tentrustdirectiondetail_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TENTRUSTDIRECTIONDETAIL_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_MARKET_NO
     , C_ENTRUST_DIRECTION
     , C_PRICE_TYPE
     , VC_PRICE_NAME
     , VC_REPORT_DIRECTION
     , VC_REPORT_FLAG
     , EN_REPORT_PRICE
     , C_BRANCH_PRICE_TYPE
     , C_LIMIT_PRICE
     , VC_VALID_TYPE
     , VC_MSGTYPE
     , C_TIMEINFORCE
     , C_ORDTYPE
     , L_MAXPRICELEVELS
     , VC_APPLID
     , C_PLATFORM_TYPE
     , VC_BINARY_MSGTYPE
     , VC_STOCK_TYPE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TENTRUSTDIRECTIONDETAIL_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TENTRUSTDIRECTIONDETAIL_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TENTRUSTDIRECTIONDETAIL_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TENTRUSTDIRECTIONDETAIL_PFD成功"
      exit 0
   fi
fi
