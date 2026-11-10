#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TFEE_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TFEE_PFD_TMP(
  L_FUND_ID  DECIMAL(8,0)  COMMENT  '基金序号',
  VC_SEAT_ID  STRING  COMMENT  '席位代码',
  VC_STOCKHOLDER_ID  STRING  COMMENT  '股东代码',
  C_FEE_TYPE  STRING  COMMENT  '收费类别',
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  C_STOCK_TYPE  STRING  COMMENT  '证券类别',
  C_MARKET_NO  STRING  COMMENT  '交易市场编号',
  EN_BALANCE_RATIO  DECIMAL(9,8)  COMMENT  '成交金额比例',
  EN_FACE_VALUE_RATIO  DECIMAL(9,8)  COMMENT  '成交面值比例',
  EN_MAXIMUM_FEE  DECIMAL(12,2)  COMMENT  '最高费用',
  EN_MINIMUM_FEE  DECIMAL(12,2)  COMMENT  '最低费用',
  C_SHARE_FLAG  STRING  COMMENT  '分合标志',
  L_MODIFY_DATE  DECIMAL(8,0)  COMMENT  '维护日期',
  EN_MIN  DECIMAL(16,2)  COMMENT  '金额区间最小',
  EN_MAX  DECIMAL(16,2)  COMMENT  '金额区间最大',
  C_BUSIN_CLASS  STRING  COMMENT  '业务分类',
  C_STOCK_COUNT  STRING  COMMENT  '抵押券个数',
  C_ENTRUST_DIRECTION  STRING  COMMENT  '委托方向',
  VC_BROKER_NO  STRING  COMMENT  '券商',
  C_LAUNCH_FLAG  STRING  COMMENT  '委托方式',
  C_DMA  STRING  COMMENT  '委托处理方式',
  EN_AMOUNT_RATIO  DECIMAL(16,8)  COMMENT  '成交数量比例',
  C_CALC_MODE  STRING  COMMENT  '费用计算模式',
  L_KIND_NO  DECIMAL(3,0)  COMMENT  '期货品种',
  C_CLOSE_DIRECTION  STRING  COMMENT  '平仓方向',
  EN_PREFERENCE_BALANCE_RATIO  DECIMAL(9,8)  COMMENT  '优惠后成交金额比例',
  EN_PREFERENCE_AMOUNT_RATIO  DECIMAL(16,8)  COMMENT  '优惠后成交数量比例',
  VC_TARGET_TYPE  STRING  COMMENT  '标的券类型',
  L_COMBI_ID  DECIMAL(10,0)  COMMENT  '组合',
  C_STOCK_PROPERTY  STRING  COMMENT  ''
)
COMMENT '费用表'
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
              "querySql": ["SELECT  L_FUND_ID
                                   , VC_SEAT_ID
                                   , VC_STOCKHOLDER_ID
                                   , C_FEE_TYPE
                                   , VC_INTER_CODE
                                   , C_STOCK_TYPE
                                   , C_MARKET_NO
                                   , EN_BALANCE_RATIO
                                   , EN_FACE_VALUE_RATIO
                                   , EN_MAXIMUM_FEE
                                   , EN_MINIMUM_FEE
                                   , C_SHARE_FLAG
                                   , L_MODIFY_DATE
                                   , EN_MIN
                                   , EN_MAX
                                   , C_BUSIN_CLASS
                                   , C_STOCK_COUNT
                                   , C_ENTRUST_DIRECTION
                                   , VC_BROKER_NO
                                   , C_LAUNCH_FLAG
                                   , C_DMA
                                   , EN_AMOUNT_RATIO
                                   , C_CALC_MODE
                                   , L_KIND_NO
                                   , C_CLOSE_DIRECTION
                                   , EN_PREFERENCE_BALANCE_RATIO
                                   , EN_PREFERENCE_AMOUNT_RATIO
                                   , VC_TARGET_TYPE
                                   , L_COMBI_ID
                                   , C_STOCK_PROPERTY
                                FROM ${o32_src_schema}.TFEE"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "VC_SEAT_ID", "type": "STRING"}, {"name": "VC_STOCKHOLDER_ID", "type": "STRING"}, {"name": "C_FEE_TYPE", "type": "STRING"}, {"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "C_STOCK_TYPE", "type": "STRING"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "EN_BALANCE_RATIO", "type": "DOUBLE"}, {"name": "EN_FACE_VALUE_RATIO", "type": "DOUBLE"}, {"name": "EN_MAXIMUM_FEE", "type": "DOUBLE"}, {"name": "EN_MINIMUM_FEE", "type": "DOUBLE"}, {"name": "C_SHARE_FLAG", "type": "STRING"}, {"name": "L_MODIFY_DATE", "type": "DOUBLE"}, {"name": "EN_MIN", "type": "DOUBLE"}, {"name": "EN_MAX", "type": "DOUBLE"}, {"name": "C_BUSIN_CLASS", "type": "STRING"}, {"name": "C_STOCK_COUNT", "type": "STRING"}, {"name": "C_ENTRUST_DIRECTION", "type": "STRING"}, {"name": "VC_BROKER_NO", "type": "STRING"}, {"name": "C_LAUNCH_FLAG", "type": "STRING"}, {"name": "C_DMA", "type": "STRING"}, {"name": "EN_AMOUNT_RATIO", "type": "DOUBLE"}, {"name": "C_CALC_MODE", "type": "STRING"}, {"name": "L_KIND_NO", "type": "DOUBLE"}, {"name": "C_CLOSE_DIRECTION", "type": "STRING"}, {"name": "EN_PREFERENCE_BALANCE_RATIO", "type": "DOUBLE"}, {"name": "EN_PREFERENCE_AMOUNT_RATIO", "type": "DOUBLE"}, {"name": "VC_TARGET_TYPE", "type": "STRING"}, {"name": "L_COMBI_ID", "type": "DOUBLE"}, {"name": "C_STOCK_PROPERTY", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tfee_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tfee_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tfee_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tfee_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TFEE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TFEE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tfee_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TFEE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_FUND_ID
     , VC_SEAT_ID
     , VC_STOCKHOLDER_ID
     , C_FEE_TYPE
     , VC_INTER_CODE
     , C_STOCK_TYPE
     , C_MARKET_NO
     , EN_BALANCE_RATIO
     , EN_FACE_VALUE_RATIO
     , EN_MAXIMUM_FEE
     , EN_MINIMUM_FEE
     , C_SHARE_FLAG
     , L_MODIFY_DATE
     , EN_MIN
     , EN_MAX
     , C_BUSIN_CLASS
     , C_STOCK_COUNT
     , C_ENTRUST_DIRECTION
     , VC_BROKER_NO
     , C_LAUNCH_FLAG
     , C_DMA
     , EN_AMOUNT_RATIO
     , C_CALC_MODE
     , L_KIND_NO
     , C_CLOSE_DIRECTION
     , EN_PREFERENCE_BALANCE_RATIO
     , EN_PREFERENCE_AMOUNT_RATIO
     , VC_TARGET_TYPE
     , L_COMBI_ID
     , C_STOCK_PROPERTY
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TFEE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TFEE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TFEE_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TFEE_PFD成功"
      exit 0
   fi
fi
