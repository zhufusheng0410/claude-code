#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TACCOUNT_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TACCOUNT_PFD_TMP(
  L_ACCOUNT_ID  DECIMAL(10,0)  COMMENT  '账户序号',
  L_FUND_ID  DECIMAL(10,0)  COMMENT  '基金序号',
  VC_ACCOUNT_NAME  STRING  COMMENT  '主账户名称',
  C_ACCOUNT_STATUS  STRING  COMMENT  '主账户状态',
  VC_REMARKS  STRING  COMMENT  '备注',
  L_SECURITIES_BRANCH  DECIMAL(10,0)  COMMENT  '分仓营业部',
  VC_CAPITAL_ACCOUNT  STRING  COMMENT  '资金账号',
  VC_CAPITAL_PASSWORD  STRING  COMMENT  '资金账号密码',
  L_DEFAULT_ASSET  DECIMAL(10,0)  COMMENT  '主账户缺省资产单元',
  L_DEFAULT_COMBI  DECIMAL(10,0)  COMMENT  '主账户缺省组合',
  L_GROUP_ID  DECIMAL(10,0)  COMMENT  '风控管理组序号',
  C_DISTRIBUTION  STRING  COMMENT  '资金账号类型',
  VC_STOCKTYPE_RIGHT  STRING  COMMENT  '证券类别权限',
  VC_PERMIT_MARKET  STRING  COMMENT  '市场权限',
  VC_PERMIT_BUSIN_CLASS  STRING  COMMENT  '允许投资的业务类别权限',
  C_STATUS  STRING  COMMENT  '同步状态',
  L_MAXASSET_NUM  DECIMAL(6,0)  COMMENT  '允许的最大单元数',
  L_SET_ID  DECIMAL(4,0)  COMMENT  '费用套序号',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  VC_ENTRDIRE_RIGHT  STRING  COMMENT  '委托方向权限',
  C_AUTOCASHDEAL  STRING  COMMENT  '流水自动处理'
)
COMMENT '主账户表'
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
              "querySql": ["SELECT  L_ACCOUNT_ID
                                   , L_FUND_ID
                                   , VC_ACCOUNT_NAME
                                   , C_ACCOUNT_STATUS
                                   , VC_REMARKS
                                   , L_SECURITIES_BRANCH
                                   , VC_CAPITAL_ACCOUNT
                                   , VC_CAPITAL_PASSWORD
                                   , L_DEFAULT_ASSET
                                   , L_DEFAULT_COMBI
                                   , L_GROUP_ID
                                   , C_DISTRIBUTION
                                   , VC_STOCKTYPE_RIGHT
                                   , VC_PERMIT_MARKET
                                   , VC_PERMIT_BUSIN_CLASS
                                   , C_STATUS
                                   , L_MAXASSET_NUM
                                   , L_SET_ID
                                   , VC_TIMESTAMP
                                   , VC_ENTRDIRE_RIGHT
                                   , C_AUTOCASHDEAL
                                FROM ${o32_src_schema}.TACCOUNT"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ACCOUNT_ID", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "VC_ACCOUNT_NAME", "type": "STRING"}, {"name": "C_ACCOUNT_STATUS", "type": "STRING"}, {"name": "VC_REMARKS", "type": "STRING"}, {"name": "L_SECURITIES_BRANCH", "type": "DOUBLE"}, {"name": "VC_CAPITAL_ACCOUNT", "type": "STRING"}, {"name": "VC_CAPITAL_PASSWORD", "type": "STRING"}, {"name": "L_DEFAULT_ASSET", "type": "DOUBLE"}, {"name": "L_DEFAULT_COMBI", "type": "DOUBLE"}, {"name": "L_GROUP_ID", "type": "DOUBLE"}, {"name": "C_DISTRIBUTION", "type": "STRING"}, {"name": "VC_STOCKTYPE_RIGHT", "type": "STRING"}, {"name": "VC_PERMIT_MARKET", "type": "STRING"}, {"name": "VC_PERMIT_BUSIN_CLASS", "type": "STRING"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "L_MAXASSET_NUM", "type": "DOUBLE"}, {"name": "L_SET_ID", "type": "DOUBLE"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "VC_ENTRDIRE_RIGHT", "type": "STRING"}, {"name": "C_AUTOCASHDEAL", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_taccount_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_taccount_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_taccount_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_taccount_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TACCOUNT_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TACCOUNT_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_taccount_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TACCOUNT_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_ACCOUNT_ID
     , L_FUND_ID
     , VC_ACCOUNT_NAME
     , C_ACCOUNT_STATUS
     , VC_REMARKS
     , L_SECURITIES_BRANCH
     , VC_CAPITAL_ACCOUNT
     , VC_CAPITAL_PASSWORD
     , L_DEFAULT_ASSET
     , L_DEFAULT_COMBI
     , L_GROUP_ID
     , C_DISTRIBUTION
     , VC_STOCKTYPE_RIGHT
     , VC_PERMIT_MARKET
     , VC_PERMIT_BUSIN_CLASS
     , C_STATUS
     , L_MAXASSET_NUM
     , L_SET_ID
     , VC_TIMESTAMP
     , VC_ENTRDIRE_RIGHT
     , C_AUTOCASHDEAL
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TACCOUNT_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TACCOUNT_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TACCOUNT_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TACCOUNT_PFD成功"
      exit 0
   fi
fi
