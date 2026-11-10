#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_STIBOPTRADINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_STIBOPTRADINFO_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部代码',
  INFOSOURCE  STRING  COMMENT  '信息来源',
  ABNORMALTYPE  STRING  COMMENT  '异动类型',
  ABNORMALTYPEDES  STRING  COMMENT  '异动类型描述',
  TRADINGDAY  STRING  COMMENT  '交易日期',
  TURNOVERVOLUME  DECIMAL(16,0)  COMMENT  '成交量11',
  TURNOVERVALUE  DECIMAL(19,4)  COMMENT  '成交金额(元)',
  ABNORMALVALUE  DECIMAL(9,6)  COMMENT  '异动值(%)',
  NETBUYSUM  DECIMAL(19,4)  COMMENT  '净买入金额(元)',
  TOTALBUYSUM  DECIMAL(19,4)  COMMENT  '买入金额合计(元)',
  TOTALSALESUM  DECIMAL(19,4)  COMMENT  '卖出金额合计(元)',
  UPDATETIME  STRING  COMMENT  '更新时间',
  INSERTTIME  STRING  COMMENT  '发布时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  TRADINGSTARTDATE  STRING  COMMENT  '交易起始日期'
)
COMMENT '科创板交易所日公开信息'
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
            "username": "${jy_username}",
            "password": "${jy_password}",
            "connection": [{
              "querySql": ["SELECT  ID
                                   , INNERCODE
                                   , INFOSOURCE
                                   , ABNORMALTYPE
                                   , ABNORMALTYPEDES
                                   , TRADINGDAY
                                   , TURNOVERVOLUME
                                   , TURNOVERVALUE
                                   , ABNORMALVALUE
                                   , NETBUYSUM
                                   , TOTALBUYSUM
                                   , TOTALSALESUM
                                   , UPDATETIME
                                   , INSERTTIME
                                   , JSID
                                   , TRADINGSTARTDATE
                                FROM ${jy_src_schema}.LC_STIBOPTRADINFO"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "INFOSOURCE", "type": "STRING"}, {"name": "ABNORMALTYPE", "type": "DOUBLE"}, {"name": "ABNORMALTYPEDES", "type": "STRING"}, {"name": "TRADINGDAY", "type": "STRING"}, {"name": "TURNOVERVOLUME", "type": "DOUBLE"}, {"name": "TURNOVERVALUE", "type": "DOUBLE"}, {"name": "ABNORMALVALUE", "type": "DOUBLE"}, {"name": "NETBUYSUM", "type": "DOUBLE"}, {"name": "TOTALBUYSUM", "type": "DOUBLE"}, {"name": "TOTALSALESUM", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "INSERTTIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "TRADINGSTARTDATE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_stiboptradinfo_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_stiboptradinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_stiboptradinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_stiboptradinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_STIBOPTRADINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_STIBOPTRADINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_stiboptradinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_STIBOPTRADINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , INFOSOURCE
     , ABNORMALTYPE
     , ABNORMALTYPEDES
     , TRADINGDAY
     , TURNOVERVOLUME
     , TURNOVERVALUE
     , ABNORMALVALUE
     , NETBUYSUM
     , TOTALBUYSUM
     , TOTALSALESUM
     , UPDATETIME
     , INSERTTIME
     , JSID
     , TRADINGSTARTDATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_LC_STIBOPTRADINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_STIBOPTRADINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_STIBOPTRADINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_STIBOPTRADINFO_PFD成功"
      exit 0
   fi
fi
