#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TOUTBUSINESSCONFIG_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TOUTBUSINESSCONFIG_PFD_TMP(
  L_BUSIN_FLAG  DECIMAL(8,0)  COMMENT  '业务类别',
  C_ENTRUST_DIRECTION  STRING  COMMENT  '委托方向',
  C_BUSIN_CLASS  STRING  COMMENT  '业务分类',
  C_BUSIN_PRO_TYPE  STRING  COMMENT  '业务过程分类',
  C_MARKET_NO  STRING  COMMENT  '市场代码',
  C_EXECUTE_TYPE  STRING  COMMENT  '执行方式',
  C_CAPITAL_CHANGE  STRING  COMMENT  '资金变化',
  C_AMOUNT_CHANGE  STRING  COMMENT  '数量变化',
  C_CAHSETTLE_FLAG  STRING  COMMENT  '需要资金交收',
  C_SETTLE_PROCESS  STRING  COMMENT  '资金交收处理',
  L_CASHSETTLE_DAYS  DECIMAL(3,0)  COMMENT  '资金交收天数',
  C_SECRSETTLE_FLAG  STRING  COMMENT  '需要证券交收',
  C_SECRSETTLE_PROCESS  STRING  COMMENT  '证券交收处理',
  L_SECRSETTLE_DAYS  DECIMAL(3,0)  COMMENT  '证券交收天数',
  C_JUDGE_AVAILABLE  STRING  COMMENT  '是否判断可用',
  C_AUTO_LOCK  STRING  COMMENT  '是否分发后自动锁定',
  L_SETTLE_FLAG  DECIMAL(8,0)  COMMENT  '交收业务类别',
  VC_SUBJECT_NO  STRING  COMMENT  '交收科目变化',
  C_AUTO_POSTPONE  STRING  COMMENT  '自动延期',
  C_ADD_POINT  STRING  COMMENT  '交收前计入可用标志',
  C_NEED_REMIND  STRING  COMMENT  '日终自动交收前是否需要提醒',
  L_SETTLE_FAIL_FLAG  DECIMAL(8,0)  COMMENT  '交收失败业务类别',
  C_CAPITAL_CHANGE_T  STRING  COMMENT  't日资金变化',
  C_AMOUNT_CHANGE_T  STRING  COMMENT  't日证券变化',
  VC_BUSIN_OPFLAG  STRING  COMMENT  '财务操作类型',
  C_DVP_SETTLE  STRING  COMMENT  '是否dvp交收',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  L_VIRTUAL_KEY  DECIMAL(16,0)  COMMENT  '虚拟主键',
  VC_NON_BUSIN_FLAG  STRING  COMMENT  '',
  C_ADD_POINT_BOUND  STRING  COMMENT  '',
  C_PROCESSCOSTS_TYPE  STRING  COMMENT  '',
  C_CAHSETTLE_FLAG_BOUND  STRING  COMMENT  '',
  L_EXPAND_NO  DECIMAL(10,0)  COMMENT  '',
  VC_AUTOEXECUTE_FLAG  STRING  COMMENT  '',
  VC_AUTOEXECUTE_FLAG_BOUND  STRING  COMMENT  '',
  C_INITCAPITAL_CHANGE  STRING  COMMENT  '',
  C_INITAMOUNT_CHANGE  STRING  COMMENT  ''
)
COMMENT '场外业务确认配置表'
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
              "querySql": ["SELECT  L_BUSIN_FLAG
                                   , C_ENTRUST_DIRECTION
                                   , C_BUSIN_CLASS
                                   , C_BUSIN_PRO_TYPE
                                   , C_MARKET_NO
                                   , C_EXECUTE_TYPE
                                   , C_CAPITAL_CHANGE
                                   , C_AMOUNT_CHANGE
                                   , C_CAHSETTLE_FLAG
                                   , C_SETTLE_PROCESS
                                   , L_CASHSETTLE_DAYS
                                   , C_SECRSETTLE_FLAG
                                   , C_SECRSETTLE_PROCESS
                                   , L_SECRSETTLE_DAYS
                                   , C_JUDGE_AVAILABLE
                                   , C_AUTO_LOCK
                                   , L_SETTLE_FLAG
                                   , VC_SUBJECT_NO
                                   , C_AUTO_POSTPONE
                                   , C_ADD_POINT
                                   , C_NEED_REMIND
                                   , L_SETTLE_FAIL_FLAG
                                   , C_CAPITAL_CHANGE_T
                                   , C_AMOUNT_CHANGE_T
                                   , VC_BUSIN_OPFLAG
                                   , C_DVP_SETTLE
                                   , VC_TIMESTAMP
                                   , L_VIRTUAL_KEY
                                   , VC_NON_BUSIN_FLAG
                                   , C_ADD_POINT_BOUND
                                   , C_PROCESSCOSTS_TYPE
                                   , C_CAHSETTLE_FLAG_BOUND
                                   , L_EXPAND_NO
                                   , VC_AUTOEXECUTE_FLAG
                                   , VC_AUTOEXECUTE_FLAG_BOUND
                                   , C_INITCAPITAL_CHANGE
                                   , C_INITAMOUNT_CHANGE
                                FROM ${o32_src_schema}.TOUTBUSINESSCONFIG"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_BUSIN_FLAG", "type": "DOUBLE"}, {"name": "C_ENTRUST_DIRECTION", "type": "STRING"}, {"name": "C_BUSIN_CLASS", "type": "STRING"}, {"name": "C_BUSIN_PRO_TYPE", "type": "STRING"}, {"name": "C_MARKET_NO", "type": "STRING"}, {"name": "C_EXECUTE_TYPE", "type": "STRING"}, {"name": "C_CAPITAL_CHANGE", "type": "STRING"}, {"name": "C_AMOUNT_CHANGE", "type": "STRING"}, {"name": "C_CAHSETTLE_FLAG", "type": "STRING"}, {"name": "C_SETTLE_PROCESS", "type": "STRING"}, {"name": "L_CASHSETTLE_DAYS", "type": "DOUBLE"}, {"name": "C_SECRSETTLE_FLAG", "type": "STRING"}, {"name": "C_SECRSETTLE_PROCESS", "type": "STRING"}, {"name": "L_SECRSETTLE_DAYS", "type": "DOUBLE"}, {"name": "C_JUDGE_AVAILABLE", "type": "STRING"}, {"name": "C_AUTO_LOCK", "type": "STRING"}, {"name": "L_SETTLE_FLAG", "type": "DOUBLE"}, {"name": "VC_SUBJECT_NO", "type": "STRING"}, {"name": "C_AUTO_POSTPONE", "type": "STRING"}, {"name": "C_ADD_POINT", "type": "STRING"}, {"name": "C_NEED_REMIND", "type": "STRING"}, {"name": "L_SETTLE_FAIL_FLAG", "type": "DOUBLE"}, {"name": "C_CAPITAL_CHANGE_T", "type": "STRING"}, {"name": "C_AMOUNT_CHANGE_T", "type": "STRING"}, {"name": "VC_BUSIN_OPFLAG", "type": "STRING"}, {"name": "C_DVP_SETTLE", "type": "STRING"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "L_VIRTUAL_KEY", "type": "DOUBLE"}, {"name": "VC_NON_BUSIN_FLAG", "type": "STRING"}, {"name": "C_ADD_POINT_BOUND", "type": "STRING"}, {"name": "C_PROCESSCOSTS_TYPE", "type": "STRING"}, {"name": "C_CAHSETTLE_FLAG_BOUND", "type": "STRING"}, {"name": "L_EXPAND_NO", "type": "DOUBLE"}, {"name": "VC_AUTOEXECUTE_FLAG", "type": "STRING"}, {"name": "VC_AUTOEXECUTE_FLAG_BOUND", "type": "STRING"}, {"name": "C_INITCAPITAL_CHANGE", "type": "STRING"}, {"name": "C_INITAMOUNT_CHANGE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_toutbusinessconfig_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_toutbusinessconfig_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_toutbusinessconfig_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_toutbusinessconfig_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TOUTBUSINESSCONFIG_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TOUTBUSINESSCONFIG_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_toutbusinessconfig_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TOUTBUSINESSCONFIG_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_BUSIN_FLAG
     , C_ENTRUST_DIRECTION
     , C_BUSIN_CLASS
     , C_BUSIN_PRO_TYPE
     , C_MARKET_NO
     , C_EXECUTE_TYPE
     , C_CAPITAL_CHANGE
     , C_AMOUNT_CHANGE
     , C_CAHSETTLE_FLAG
     , C_SETTLE_PROCESS
     , L_CASHSETTLE_DAYS
     , C_SECRSETTLE_FLAG
     , C_SECRSETTLE_PROCESS
     , L_SECRSETTLE_DAYS
     , C_JUDGE_AVAILABLE
     , C_AUTO_LOCK
     , L_SETTLE_FLAG
     , VC_SUBJECT_NO
     , C_AUTO_POSTPONE
     , C_ADD_POINT
     , C_NEED_REMIND
     , L_SETTLE_FAIL_FLAG
     , C_CAPITAL_CHANGE_T
     , C_AMOUNT_CHANGE_T
     , VC_BUSIN_OPFLAG
     , C_DVP_SETTLE
     , VC_TIMESTAMP
     , L_VIRTUAL_KEY
     , VC_NON_BUSIN_FLAG
     , C_ADD_POINT_BOUND
     , C_PROCESSCOSTS_TYPE
     , C_CAHSETTLE_FLAG_BOUND
     , L_EXPAND_NO
     , VC_AUTOEXECUTE_FLAG
     , VC_AUTOEXECUTE_FLAG_BOUND
     , C_INITCAPITAL_CHANGE
     , C_INITAMOUNT_CHANGE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TOUTBUSINESSCONFIG_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TOUTBUSINESSCONFIG_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TOUTBUSINESSCONFIG_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TOUTBUSINESSCONFIG_PFD成功"
      exit 0
   fi
fi
