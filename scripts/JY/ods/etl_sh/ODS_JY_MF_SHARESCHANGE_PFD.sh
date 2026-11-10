#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_MF_SHARESCHANGE_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_MF_SHARESCHANGE_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  INFOSOURCE  STRING  COMMENT  '信息来源',
  STARTDATE  STRING  COMMENT  '起始日期',
  ENDDATE  STRING  COMMENT  '日期',
  STATPERIOD  STRING  COMMENT  '统计区间',
  STARTSHARES  DECIMAL(18,4)  COMMENT  '期初份额(份)',
  APPLYINGSHARES  DECIMAL(18,4)  COMMENT  '加:本期申购(份)',
  REDEEMSHARES  DECIMAL(18,4)  COMMENT  '减:本期赎回(份)',
  ENDSHARES  DECIMAL(18,4)  COMMENT  '期末份额(份)',
  FLOATSHARES  DECIMAL(18,4)  COMMENT  '流通份额(份)',
  DIVIDENDREINVESTMENT  DECIMAL(18,4)  COMMENT  '红利再投资(份)',
  SHGIFTIN  DECIMAL(18,4)  COMMENT  '同系基金转入(份)',
  SHIFTOUT  DECIMAL(18,4)  COMMENT  '同系基金转出(份)',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  SHARESCHANGE  DECIMAL(18,4)  COMMENT  '基金份额变化(申购赎回净额)(份)',
  RATEOFSHARESCHANGE  DECIMAL(18,6)  COMMENT  '基金份额变化率(%)',
  IFCOMBINE  DECIMAL(10,0)  COMMENT  '是否合并披露',
  SPLITSHARES  DECIMAL(18,4)  COMMENT  '拆分折算份额变动',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  TRANSCODE  STRING  COMMENT  '基金转型统一编码',
  INSERTTIME  STRING  COMMENT  '插入时间'
)
COMMENT '基金份额变动'
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
                                   , STARTDATE
                                   , ENDDATE
                                   , STATPERIOD
                                   , STARTSHARES
                                   , APPLYINGSHARES
                                   , REDEEMSHARES
                                   , ENDSHARES
                                   , FLOATSHARES
                                   , DIVIDENDREINVESTMENT
                                   , SHGIFTIN
                                   , SHIFTOUT
                                   , XGRQ
                                   , JSID
                                   , SHARESCHANGE
                                   , RATEOFSHARESCHANGE
                                   , IFCOMBINE
                                   , SPLITSHARES
                                   , INFOPUBLDATE
                                   , TRANSCODE
                                   , INSERTTIME
                                FROM ${jy_src_schema}.MF_SHARESCHANGE"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "INFOSOURCE", "type": "STRING"}, {"name": "STARTDATE", "type": "STRING"}, {"name": "ENDDATE", "type": "STRING"}, {"name": "STATPERIOD", "type": "STRING"}, {"name": "STARTSHARES", "type": "DOUBLE"}, {"name": "APPLYINGSHARES", "type": "DOUBLE"}, {"name": "REDEEMSHARES", "type": "DOUBLE"}, {"name": "ENDSHARES", "type": "DOUBLE"}, {"name": "FLOATSHARES", "type": "DOUBLE"}, {"name": "DIVIDENDREINVESTMENT", "type": "DOUBLE"}, {"name": "SHGIFTIN", "type": "DOUBLE"}, {"name": "SHIFTOUT", "type": "DOUBLE"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "SHARESCHANGE", "type": "DOUBLE"}, {"name": "RATEOFSHARESCHANGE", "type": "DOUBLE"}, {"name": "IFCOMBINE", "type": "DOUBLE"}, {"name": "SPLITSHARES", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "TRANSCODE", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_mf_shareschange_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_mf_shareschange_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_mf_shareschange_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_mf_shareschange_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_MF_SHARESCHANGE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_MF_SHARESCHANGE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_mf_shareschange_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_MF_SHARESCHANGE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , INFOSOURCE
     , STARTDATE
     , ENDDATE
     , STATPERIOD
     , STARTSHARES
     , APPLYINGSHARES
     , REDEEMSHARES
     , ENDSHARES
     , FLOATSHARES
     , DIVIDENDREINVESTMENT
     , SHGIFTIN
     , SHIFTOUT
     , XGRQ
     , JSID
     , SHARESCHANGE
     , RATEOFSHARESCHANGE
     , IFCOMBINE
     , SPLITSHARES
     , INFOPUBLDATE
     , TRANSCODE
     , INSERTTIME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_MF_SHARESCHANGE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_MF_SHARESCHANGE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_MF_SHARESCHANGE_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_MF_SHARESCHANGE_PFD成功"
      exit 0
   fi
fi
