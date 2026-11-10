#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_7PERCENTCHANGE_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_7PERCENTCHANGE_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  INFOSOURCE  STRING  COMMENT  '信息来源',
  ABNORMALTYPE  STRING  COMMENT  '异动类型',
  TRADINGSTARTDATE  STRING  COMMENT  '交易起始日期',
  TRADINGDAY  STRING  COMMENT  '交易日',
  SERIALNUM  DECIMAL(3,0)  COMMENT  '序号',
  SALESDEPARTMENTNAME  STRING  COMMENT  '营业部名称',
  SECUCOBELONGEDCODE  STRING  COMMENT  '所属券商编号',
  SECUCOBELONGED  STRING  COMMENT  '所属券商名称',
  TURNOVERVOLUME  DECIMAL(16,0)  COMMENT  '成交量(股)',
  TURNOVERVALUE  DECIMAL(19,4)  COMMENT  '成交金额(元)',
  CHANGEPCT  DECIMAL(9,6)  COMMENT  '涨跌幅',
  CHANGEPCTOFFSET  DECIMAL(9,6)  COMMENT  '涨跌幅偏离值',
  FLUCTUATINGAMPTITUDE  DECIMAL(9,6)  COMMENT  '振幅',
  TURNOVERRATE  DECIMAL(9,6)  COMMENT  '换手率(%)',
  TOTALBUYSALESUM  DECIMAL(19,4)  COMMENT  '买卖合计金额(元)',
  BUYSUM  DECIMAL(19,4)  COMMENT  '#买入金额(元)',
  SALESUM  DECIMAL(19,4)  COMMENT  '#卖出金额(元)',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  STATTYPE  STRING  COMMENT  '算法类型',
  TURNOVERPROP  DECIMAL(7,4)  COMMENT  '成交占比(%)',
  BOCODE  STRING  COMMENT  '营业部编号',
  INVESTORTYPE  STRING  COMMENT  '投资者类型',
  ACCUBUYSUM  DECIMAL(19,4)  COMMENT  '',
  ACCUSALESUM  DECIMAL(19,4)  COMMENT  '',
  BUYINGRATIO  DECIMAL(7,4)  COMMENT  '',
  SELLINGRATIO  DECIMAL(7,4)  COMMENT  '',
  INSERTTIME  STRING  COMMENT  '发布时间'
)
COMMENT '交易所日公开信息'
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
                                   , TRADINGSTARTDATE
                                   , TRADINGDAY
                                   , SERIALNUM
                                   , SALESDEPARTMENTNAME
                                   , SECUCOBELONGEDCODE
                                   , SECUCOBELONGED
                                   , TURNOVERVOLUME
                                   , TURNOVERVALUE
                                   , CHANGEPCT
                                   , CHANGEPCTOFFSET
                                   , FLUCTUATINGAMPTITUDE
                                   , TURNOVERRATE
                                   , TOTALBUYSALESUM
                                   , BUYSUM
                                   , SALESUM
                                   , XGRQ
                                   , JSID
                                   , STATTYPE
                                   , TURNOVERPROP
                                   , BOCODE
                                   , INVESTORTYPE
                                   , ACCUBUYSUM
                                   , ACCUSALESUM
                                   , BUYINGRATIO
                                   , SELLINGRATIO
                                   , INSERTTIME
                                FROM ${jy_src_schema}.LC_7PERCENTCHANGE"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "INFOSOURCE", "type": "STRING"}, {"name": "ABNORMALTYPE", "type": "DOUBLE"}, {"name": "TRADINGSTARTDATE", "type": "STRING"}, {"name": "TRADINGDAY", "type": "STRING"}, {"name": "SERIALNUM", "type": "DOUBLE"}, {"name": "SALESDEPARTMENTNAME", "type": "STRING"}, {"name": "SECUCOBELONGEDCODE", "type": "DOUBLE"}, {"name": "SECUCOBELONGED", "type": "STRING"}, {"name": "TURNOVERVOLUME", "type": "DOUBLE"}, {"name": "TURNOVERVALUE", "type": "DOUBLE"}, {"name": "CHANGEPCT", "type": "DOUBLE"}, {"name": "CHANGEPCTOFFSET", "type": "DOUBLE"}, {"name": "FLUCTUATINGAMPTITUDE", "type": "DOUBLE"}, {"name": "TURNOVERRATE", "type": "DOUBLE"}, {"name": "TOTALBUYSALESUM", "type": "DOUBLE"}, {"name": "BUYSUM", "type": "DOUBLE"}, {"name": "SALESUM", "type": "DOUBLE"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "STATTYPE", "type": "DOUBLE"}, {"name": "TURNOVERPROP", "type": "DOUBLE"}, {"name": "BOCODE", "type": "DOUBLE"}, {"name": "INVESTORTYPE", "type": "DOUBLE"}, {"name": "ACCUBUYSUM", "type": "DOUBLE"}, {"name": "ACCUSALESUM", "type": "DOUBLE"}, {"name": "BUYINGRATIO", "type": "DOUBLE"}, {"name": "SELLINGRATIO", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_7percentchange_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_7percentchange_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_7percentchange_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_7percentchange_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_7PERCENTCHANGE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_7PERCENTCHANGE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_7percentchange_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_7PERCENTCHANGE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , INFOSOURCE
     , ABNORMALTYPE
     , TRADINGSTARTDATE
     , TRADINGDAY
     , SERIALNUM
     , SALESDEPARTMENTNAME
     , SECUCOBELONGEDCODE
     , SECUCOBELONGED
     , TURNOVERVOLUME
     , TURNOVERVALUE
     , CHANGEPCT
     , CHANGEPCTOFFSET
     , FLUCTUATINGAMPTITUDE
     , TURNOVERRATE
     , TOTALBUYSALESUM
     , BUYSUM
     , SALESUM
     , XGRQ
     , JSID
     , STATTYPE
     , TURNOVERPROP
     , BOCODE
     , INVESTORTYPE
     , ACCUBUYSUM
     , ACCUSALESUM
     , BUYINGRATIO
     , SELLINGRATIO
     , INSERTTIME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_LC_7PERCENTCHANGE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_7PERCENTCHANGE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_7PERCENTCHANGE_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_7PERCENTCHANGE_PFD成功"
      exit 0
   fi
fi
