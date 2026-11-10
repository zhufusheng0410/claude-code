#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_INTERESTRATE_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_INTERESTRATE_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  COMPOUNDMETHOD  DECIMAL(10,0)  COMMENT  '计息方式',
  INTPAYMENTMETHOD  DECIMAL(10,0)  COMMENT  '付息方式',
  PAYINTERESTEFFENCY  DECIMAL(10,0)  COMMENT  '付息频率(次/年)',
  VALUEDATE  STRING  COMMENT  '起息日',
  VALUEDATEPER  STRING  COMMENT  '本期计息起始日',
  VALUEDATENEXTPER  STRING  COMMENT  '本期计息截止日',
  INTERESTTHISYEAR  DECIMAL(18,6)  COMMENT  '本期债券年利率(%)',
  FRNREFRATEPER  DECIMAL(18,6)  COMMENT  '本期浮动利率计息基准利率',
  FRNREFRATETEXT  DECIMAL(10,0)  COMMENT  '浮动利率计息基准',
  FRNREFRATEDATE  STRING  COMMENT  '浮动利率计息基准日',
  FRNREFEXTRAMARGIN  DECIMAL(18,6)  COMMENT  '计息额外利差(%)',
  EFFECTIVERATE  DECIMAL(18,6)  COMMENT  '有效利率(%)',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  PERIODBEGINNING  STRING  COMMENT  '所属计息周期起始日',
  PERIODEND  STRING  COMMENT  '所属计息周期截止日',
  SEGMENTRATE  DECIMAL(18,6)  COMMENT  '本段利率(%)',
  FRNREFRATEADJDATE  STRING  COMMENT  '浮动利率计息基准利率调整日'
)
COMMENT '债券利率变动'
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
                                   , COMPOUNDMETHOD
                                   , INTPAYMENTMETHOD
                                   , PAYINTERESTEFFENCY
                                   , VALUEDATE
                                   , VALUEDATEPER
                                   , VALUEDATENEXTPER
                                   , INTERESTTHISYEAR
                                   , FRNREFRATEPER
                                   , FRNREFRATETEXT
                                   , FRNREFRATEDATE
                                   , FRNREFEXTRAMARGIN
                                   , EFFECTIVERATE
                                   , UPDATETIME
                                   , JSID
                                   , PERIODBEGINNING
                                   , PERIODEND
                                   , SEGMENTRATE
                                   , FRNREFRATEADJDATE
                                FROM ${jy_src_schema}.BOND_INTERESTRATE"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "COMPOUNDMETHOD", "type": "DOUBLE"}, {"name": "INTPAYMENTMETHOD", "type": "DOUBLE"}, {"name": "PAYINTERESTEFFENCY", "type": "DOUBLE"}, {"name": "VALUEDATE", "type": "STRING"}, {"name": "VALUEDATEPER", "type": "STRING"}, {"name": "VALUEDATENEXTPER", "type": "STRING"}, {"name": "INTERESTTHISYEAR", "type": "DOUBLE"}, {"name": "FRNREFRATEPER", "type": "DOUBLE"}, {"name": "FRNREFRATETEXT", "type": "DOUBLE"}, {"name": "FRNREFRATEDATE", "type": "STRING"}, {"name": "FRNREFEXTRAMARGIN", "type": "DOUBLE"}, {"name": "EFFECTIVERATE", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "PERIODBEGINNING", "type": "STRING"}, {"name": "PERIODEND", "type": "STRING"}, {"name": "SEGMENTRATE", "type": "DOUBLE"}, {"name": "FRNREFRATEADJDATE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_interestrate_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_interestrate_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_interestrate_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_interestrate_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_INTERESTRATE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_INTERESTRATE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_interestrate_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_INTERESTRATE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , COMPOUNDMETHOD
     , INTPAYMENTMETHOD
     , PAYINTERESTEFFENCY
     , VALUEDATE
     , VALUEDATEPER
     , VALUEDATENEXTPER
     , INTERESTTHISYEAR
     , FRNREFRATEPER
     , FRNREFRATETEXT
     , FRNREFRATEDATE
     , FRNREFEXTRAMARGIN
     , EFFECTIVERATE
     , UPDATETIME
     , JSID
     , PERIODBEGINNING
     , PERIODEND
     , SEGMENTRATE
     , FRNREFRATEADJDATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_BOND_INTERESTRATE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_INTERESTRATE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_INTERESTRATE_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_INTERESTRATE_PFD成功"
      exit 0
   fi
fi
