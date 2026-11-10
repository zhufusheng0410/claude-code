#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_MF_DIVIDEND_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_MF_DIVIDEND_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  INFOSOURCE  STRING  COMMENT  '信息来源',
  ENDDATE  STRING  COMMENT  '日期',
  UNITPROFIT  DECIMAL(19,4)  COMMENT  '单位基金收益(元)',
  UNITRETAINEDPROFIT  DECIMAL(19,4)  COMMENT  '单位基金未分配收益(元)',
  IFDISTRIBUTED  DECIMAL(3,0)  COMMENT  '是否分红',
  DIVIDENDRATIOBEFORETAX  DECIMAL(18,6)  COMMENT  '派现比例(含税10派X元)',
  ACTUALRATIOAFTERTAX  DECIMAL(18,6)  COMMENT  '实派比例(税后10派X元)',
  DIVIDENDSUM  DECIMAL(18,2)  COMMENT  '派现金额合计(元)',
  REDATE  STRING  COMMENT  '权益登记日',
  EXRIGHTDATE  STRING  COMMENT  '除权日',
  EXECUTEDATE  STRING  COMMENT  '发放日',
  SCHEMEMODIFICATION  STRING  COMMENT  '方案变更说明',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  REINVESTDAY  STRING  COMMENT  '红利再投资日',
  ACCOUNTDAY  STRING  COMMENT  '红利再投资份额到帐日',
  REDEMPTIONDAY  STRING  COMMENT  '红利再投资份额可赎回日',
  UNITPROFITYTD  DECIMAL(19,4)  COMMENT  '本年单位累计分红(元)',
  DIVIDENDSUMYTD  DECIMAL(19,4)  COMMENT  '本年累计分红总额(元)',
  DIVIDENDTIMESYTD  DECIMAL(10,0)  COMMENT  '本年累计分红次数(次)',
  DIVISUMSINCEINCEPTION  DECIMAL(19,4)  COMMENT  '历史累计分红总额(元)',
  DIVITIMESSINCEINCEPION  DECIMAL(10,0)  COMMENT  '历史累计分红次数(次)',
  EVENTPROCEDURECODE  DECIMAL(10,0)  COMMENT  '事件进程',
  EVENTPROCEDURE  STRING  COMMENT  '事件进程',
  EXRIGHTDATEEX  STRING  COMMENT  '场内除息日',
  EXRIGHTDATECURBEX  STRING  COMMENT  '场外除息日',
  EXECUTEDATEEX  STRING  COMMENT  '场内发放日',
  EXECUTEDATECURBEX  STRING  COMMENT  '场外发放日',
  DISTRIBUTABLEPROFITS  DECIMAL(18,6)  COMMENT  '基准日基金可供分配利润(元)',
  ALLOCATIONVALUE  DECIMAL(18,6)  COMMENT  '基准日应分配金额(元)',
  PROFITDISTDATE  STRING  COMMENT  '收益分配基准日',
  DISTRIBUTEDRANGE  STRING  COMMENT  '发放范围',
  TRANSCODE  STRING  COMMENT  '基金统一编码'
)
COMMENT '公募基金分红'
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
                                   , INFOPUBLDATE
                                   , INFOSOURCE
                                   , ENDDATE
                                   , UNITPROFIT
                                   , UNITRETAINEDPROFIT
                                   , IFDISTRIBUTED
                                   , DIVIDENDRATIOBEFORETAX
                                   , ACTUALRATIOAFTERTAX
                                   , DIVIDENDSUM
                                   , REDATE
                                   , EXRIGHTDATE
                                   , EXECUTEDATE
                                   , SCHEMEMODIFICATION
                                   , XGRQ
                                   , JSID
                                   , REINVESTDAY
                                   , ACCOUNTDAY
                                   , REDEMPTIONDAY
                                   , UNITPROFITYTD
                                   , DIVIDENDSUMYTD
                                   , DIVIDENDTIMESYTD
                                   , DIVISUMSINCEINCEPTION
                                   , DIVITIMESSINCEINCEPION
                                   , EVENTPROCEDURECODE
                                   , EVENTPROCEDURE
                                   , EXRIGHTDATEEX
                                   , EXRIGHTDATECURBEX
                                   , EXECUTEDATEEX
                                   , EXECUTEDATECURBEX
                                   , DISTRIBUTABLEPROFITS
                                   , ALLOCATIONVALUE
                                   , PROFITDISTDATE
                                   , DISTRIBUTEDRANGE
                                   , TRANSCODE
                                FROM ${jy_src_schema}.MF_DIVIDEND"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "INFOSOURCE", "type": "STRING"}, {"name": "ENDDATE", "type": "STRING"}, {"name": "UNITPROFIT", "type": "DOUBLE"}, {"name": "UNITRETAINEDPROFIT", "type": "DOUBLE"}, {"name": "IFDISTRIBUTED", "type": "DOUBLE"}, {"name": "DIVIDENDRATIOBEFORETAX", "type": "DOUBLE"}, {"name": "ACTUALRATIOAFTERTAX", "type": "DOUBLE"}, {"name": "DIVIDENDSUM", "type": "DOUBLE"}, {"name": "REDATE", "type": "STRING"}, {"name": "EXRIGHTDATE", "type": "STRING"}, {"name": "EXECUTEDATE", "type": "STRING"}, {"name": "SCHEMEMODIFICATION", "type": "STRING"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "REINVESTDAY", "type": "STRING"}, {"name": "ACCOUNTDAY", "type": "STRING"}, {"name": "REDEMPTIONDAY", "type": "STRING"}, {"name": "UNITPROFITYTD", "type": "DOUBLE"}, {"name": "DIVIDENDSUMYTD", "type": "DOUBLE"}, {"name": "DIVIDENDTIMESYTD", "type": "DOUBLE"}, {"name": "DIVISUMSINCEINCEPTION", "type": "DOUBLE"}, {"name": "DIVITIMESSINCEINCEPION", "type": "DOUBLE"}, {"name": "EVENTPROCEDURECODE", "type": "DOUBLE"}, {"name": "EVENTPROCEDURE", "type": "STRING"}, {"name": "EXRIGHTDATEEX", "type": "STRING"}, {"name": "EXRIGHTDATECURBEX", "type": "STRING"}, {"name": "EXECUTEDATEEX", "type": "STRING"}, {"name": "EXECUTEDATECURBEX", "type": "STRING"}, {"name": "DISTRIBUTABLEPROFITS", "type": "DOUBLE"}, {"name": "ALLOCATIONVALUE", "type": "DOUBLE"}, {"name": "PROFITDISTDATE", "type": "STRING"}, {"name": "DISTRIBUTEDRANGE", "type": "STRING"}, {"name": "TRANSCODE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_mf_dividend_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_mf_dividend_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_mf_dividend_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_mf_dividend_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_MF_DIVIDEND_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_MF_DIVIDEND_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_mf_dividend_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_MF_DIVIDEND_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , INFOPUBLDATE
     , INFOSOURCE
     , ENDDATE
     , UNITPROFIT
     , UNITRETAINEDPROFIT
     , IFDISTRIBUTED
     , DIVIDENDRATIOBEFORETAX
     , ACTUALRATIOAFTERTAX
     , DIVIDENDSUM
     , REDATE
     , EXRIGHTDATE
     , EXECUTEDATE
     , SCHEMEMODIFICATION
     , XGRQ
     , JSID
     , REINVESTDAY
     , ACCOUNTDAY
     , REDEMPTIONDAY
     , UNITPROFITYTD
     , DIVIDENDSUMYTD
     , DIVIDENDTIMESYTD
     , DIVISUMSINCEINCEPTION
     , DIVITIMESSINCEINCEPION
     , EVENTPROCEDURECODE
     , EVENTPROCEDURE
     , EXRIGHTDATEEX
     , EXRIGHTDATECURBEX
     , EXECUTEDATEEX
     , EXECUTEDATECURBEX
     , DISTRIBUTABLEPROFITS
     , ALLOCATIONVALUE
     , PROFITDISTDATE
     , DISTRIBUTEDRANGE
     , TRANSCODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_MF_DIVIDEND_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_MF_DIVIDEND_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_MF_DIVIDEND_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_MF_DIVIDEND_PFD成功"
      exit 0
   fi
fi
