#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TSTOCKHOLDER_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TSTOCKHOLDER_PFD_TMP(
  VC_STOCKHOLDER_ID  STRING  COMMENT  '股东代码',
  C_MARKET_NO  STRING  COMMENT  '交易市场编号',
  L_OPEN_DATE  DECIMAL(8,0)  COMMENT  '开户日期',
  C_STOCKHOLDER_STATUS  STRING  COMMENT  '股东状态',
  C_BIND_STATUS  STRING  COMMENT  '股东指定状态',
  VC_BIND_SEAT  STRING  COMMENT  '指定席位',
  VC_STOCKHOLDER_NAME  STRING  COMMENT  '股东名称',
  VC_PERMIT_STOCK_TYPES  STRING  COMMENT  '允许操作证券类别',
  VC_REMARKS  STRING  COMMENT  '备注',
  VC_FUND_IDS  STRING  COMMENT  '使用的基金',
  VC_APPLY_QUALITY  STRING  COMMENT  '申购资格',
  C_INVEST_TYPE  STRING  COMMENT  '投资类型',
  C_APPLY_MODE  STRING  COMMENT  '申购模式',
  C_CREDIT_STOCKHOLDER  STRING  COMMENT  '股东类型',
  VC_EQU_STOCKHOLDER  STRING  COMMENT  '专户账户对应的普通账户',
  EN_CREDITLIMIT_RZ  DECIMAL(16,2)  COMMENT  '融资信用额度',
  EN_CREDITLIMIT_RQ  DECIMAL(16,2)  COMMENT  '融券信用额度',
  EN_CREDITLIMIT  DECIMAL(16,2)  COMMENT  '总信用额度',
  VC_RQ_STOCKHOLDER  STRING  COMMENT  '融券股东',
  VC_OWNER_TYPE  STRING  COMMENT  '股东属性',
  VC_BPQZ  STRING  COMMENT  '报盘前缀',
  L_DEFAULT_COMBI  DECIMAL(12,0)  COMMENT  '缺省组合',
  L_OPTION_DEFAULT_COMBI  DECIMAL(12,0)  COMMENT  '个股期权缺省组合',
  L_VIRTUAL_KEY  DECIMAL(16,0)  COMMENT  '虚拟主键',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  L_ORG_ID  DECIMAL(10,0)  COMMENT  '公司序号',
  VC_MARKET_REMARK  STRING  COMMENT  '营业部标识',
  C_ALLOW_MULTI_APPLY  STRING  COMMENT  '允许网下多次申购',
  VC_OLD_BIND_SEAT  STRING  COMMENT  '原指定席位',
  EN_AGAIN_COEFFICIENT  DECIMAL(15,8)  COMMENT  '标准券再折算率',
  C_REDUCE_LIMIT  STRING  COMMENT  '是否减持受限',
  L_MODIFY_DATE  DECIMAL(8,0)  COMMENT  '修改日期',
  C_COMBI_FEE_TYPE  STRING  COMMENT  '',
  L_BINDSTATUS_DATE  DECIMAL(8,0)  COMMENT  '',
  C_INTERCONNECTION_FLAG  STRING  COMMENT  ''
)
COMMENT '股东信息表'
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
              "querySql": ["SELECT  VC_STOCKHOLDER_ID
                                   , C_MARKET_NO
                                   , L_OPEN_DATE
                                   , C_STOCKHOLDER_STATUS
                                   , C_BIND_STATUS
                                   , VC_BIND_SEAT
                                   , VC_STOCKHOLDER_NAME
                                   , VC_PERMIT_STOCK_TYPES
                                   , VC_REMARKS
                                   , VC_FUND_IDS
                                   , VC_APPLY_QUALITY
                                   , C_INVEST_TYPE
                                   , C_APPLY_MODE
                                   , C_CREDIT_STOCKHOLDER
                                   , VC_EQU_STOCKHOLDER
                                   , EN_CREDITLIMIT_RZ
                                   , EN_CREDITLIMIT_RQ
                                   , EN_CREDITLIMIT
                                   , VC_RQ_STOCKHOLDER
                                   , VC_OWNER_TYPE
                                   , VC_BPQZ
                                   , L_DEFAULT_COMBI
                                   , L_OPTION_DEFAULT_COMBI
                                   , L_VIRTUAL_KEY
                                   , VC_TIMESTAMP
                                   , L_ORG_ID
                                   , VC_MARKET_REMARK
                                   , C_ALLOW_MULTI_APPLY
                                   , VC_OLD_BIND_SEAT
                                   , EN_AGAIN_COEFFICIENT
                                   , C_REDUCE_LIMIT
                                   , L_MODIFY_DATE
                                   , C_COMBI_FEE_TYPE
                                   , L_BINDSTATUS_DATE
                                   , C_INTERCONNECTION_FLAG
                                FROM ${o32_src_schema}.TSTOCKHOLDER"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "VC_STOCKHOLDER_ID", "type": "STRING"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "L_OPEN_DATE", "type": "DOUBLE"}, {"name": "C_STOCKHOLDER_STATUS", "type": "STRING"}, {"name": "C_BIND_STATUS", "type": "STRING"}, {"name": "VC_BIND_SEAT", "type": "STRING"}, {"name": "VC_STOCKHOLDER_NAME", "type": "STRING"}, {"name": "VC_PERMIT_STOCK_TYPES", "type": "STRING"}, {"name": "VC_REMARKS", "type": "STRING"}, {"name": "VC_FUND_IDS", "type": "STRING"}, {"name": "VC_APPLY_QUALITY", "type": "STRING"}, {"name": "C_INVEST_TYPE", "type": "STRING"}, {"name": "C_APPLY_MODE", "type": "STRING"}, {"name": "C_CREDIT_STOCKHOLDER", "type": "STRING"}, {"name": "VC_EQU_STOCKHOLDER", "type": "STRING"}, {"name": "EN_CREDITLIMIT_RZ", "type": "DOUBLE"}, {"name": "EN_CREDITLIMIT_RQ", "type": "DOUBLE"}, {"name": "EN_CREDITLIMIT", "type": "DOUBLE"}, {"name": "VC_RQ_STOCKHOLDER", "type": "STRING"}, {"name": "VC_OWNER_TYPE", "type": "STRING"}, {"name": "VC_BPQZ", "type": "STRING"}, {"name": "L_DEFAULT_COMBI", "type": "DOUBLE"}, {"name": "L_OPTION_DEFAULT_COMBI", "type": "DOUBLE"}, {"name": "L_VIRTUAL_KEY", "type": "DOUBLE"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "L_ORG_ID", "type": "DOUBLE"}, {"name": "VC_MARKET_REMARK", "type": "STRING"}, {"name": "C_ALLOW_MULTI_APPLY", "type": "STRING"}, {"name": "VC_OLD_BIND_SEAT", "type": "STRING"}, {"name": "EN_AGAIN_COEFFICIENT", "type": "DOUBLE"}, {"name": "C_REDUCE_LIMIT", "type": "STRING"}, {"name": "L_MODIFY_DATE", "type": "DOUBLE"}, {"name": "C_COMBI_FEE_TYPE", "type": "STRING"}, {"name": "L_BINDSTATUS_DATE", "type": "DOUBLE"}, {"name": "C_INTERCONNECTION_FLAG", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tstockholder_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tstockholder_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tstockholder_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tstockholder_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TSTOCKHOLDER_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TSTOCKHOLDER_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tstockholder_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TSTOCKHOLDER_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       VC_STOCKHOLDER_ID
     , C_MARKET_NO
     , L_OPEN_DATE
     , C_STOCKHOLDER_STATUS
     , C_BIND_STATUS
     , VC_BIND_SEAT
     , VC_STOCKHOLDER_NAME
     , VC_PERMIT_STOCK_TYPES
     , VC_REMARKS
     , VC_FUND_IDS
     , VC_APPLY_QUALITY
     , C_INVEST_TYPE
     , C_APPLY_MODE
     , C_CREDIT_STOCKHOLDER
     , VC_EQU_STOCKHOLDER
     , EN_CREDITLIMIT_RZ
     , EN_CREDITLIMIT_RQ
     , EN_CREDITLIMIT
     , VC_RQ_STOCKHOLDER
     , VC_OWNER_TYPE
     , VC_BPQZ
     , L_DEFAULT_COMBI
     , L_OPTION_DEFAULT_COMBI
     , L_VIRTUAL_KEY
     , VC_TIMESTAMP
     , L_ORG_ID
     , VC_MARKET_REMARK
     , C_ALLOW_MULTI_APPLY
     , VC_OLD_BIND_SEAT
     , EN_AGAIN_COEFFICIENT
     , C_REDUCE_LIMIT
     , L_MODIFY_DATE
     , C_COMBI_FEE_TYPE
     , L_BINDSTATUS_DATE
     , C_INTERCONNECTION_FLAG
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TSTOCKHOLDER_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TSTOCKHOLDER_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TSTOCKHOLDER_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TSTOCKHOLDER_PFD成功"
      exit 0
   fi
fi
