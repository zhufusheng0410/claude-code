#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_CONBDCALLPUTINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_CONBDCALLPUTINFO_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  CBTYPE  STRING  COMMENT  '可转债类型',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  OPTYPE  STRING  COMMENT  '行权类型',
  OPPROGRESS  DECIMAL(10,0)  COMMENT  '行权进程',
  OPREMARK  STRING  COMMENT  '权利描述',
  ENFORCEREASON  STRING  COMMENT  '执行原因',
  CALLPROTECTION  DECIMAL(18,2)  COMMENT  '赎回保护期(年)',
  LASTCOVERTDAY  STRING  COMMENT  '强制转股日',
  LASTCOVERTPRICE  DECIMAL(19,4)  COMMENT  '强制转股价(元)',
  CALLTERMSTARTDATE  STRING  COMMENT  '可赎回期起始日',
  CALLTERMENDDATE  STRING  COMMENT  '可赎回期截止日',
  COMMOPTIONDATE  STRING  COMMENT  '行权操作日',
  CALLPRICE  DECIMAL(19,4)  COMMENT  '赎回/回售价格(含税，元/张)',
  CALLPRICETAXED  DECIMAL(19,4)  COMMENT  '赎回/回售价格(扣税，元/张)',
  IFINCLUDEINTEREST  DECIMAL(10,0)  COMMENT  '是否包含利息',
  INTEREST  DECIMAL(19,4)  COMMENT  '每百元面值本期利息额(元)(含税)',
  LEASTOPVOL  DECIMAL(19,4)  COMMENT  '最低操作金额(元)',
  IFOPTION  DECIMAL(10,0)  COMMENT  '是否行权',
  CALLPIECES  DECIMAL(19,4)  COMMENT  '赎回/回售债券张数(张)',
  CALLVOL  DECIMAL(19,4)  COMMENT  '赎回/回售金额(元)',
  ALLOCATINGCALLMONDAY  STRING  COMMENT  '行权后款项到账日',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  EXPECTEDEXERCISEDATE  STRING  COMMENT  '权利可能行使日',
  CALLCODE  STRING  COMMENT  '回售/赎回代码',
  CALLNAME  STRING  COMMENT  '回售/赎回简称',
  COMMOPAPPLSTTIME  STRING  COMMENT  '行权申请受理开始时间',
  COMMOPAPPLEDTIME  STRING  COMMENT  '行权申请受理截止时间',
  OPTYPESECOND  STRING  COMMENT  '行权类型二级',
  CALLREGDATE  STRING  COMMENT  '赎回登记日',
  OUTSTANDINGBDVOL  DECIMAL(19,4)  COMMENT  '债券剩余金额(元)',
  OPTIONMARK  STRING  COMMENT  '权利标识',
  REVOKESTARTDATE  STRING  COMMENT  '撤销起始日',
  REVOKEENDDATE  STRING  COMMENT  '撤销截止日',
  STOPEXESTARTDATE  STRING  COMMENT  '触发不行权区间起始日',
  STOPEXEENDDATE  STRING  COMMENT  '触发不行权区间截止日',
  TRIGGERRECOUNTDAY  STRING  COMMENT  '触发条件重新计算日',
  CALLNOTICEDATE  STRING  COMMENT  '强制赎回公告日',
  EXEREACHSTARTDATE  STRING  COMMENT  '触发条件满足区间起始日',
  EXEREACHENDDATE  STRING  COMMENT  '触发条件满足区间截止日'
)
COMMENT '可转债赎回和回售'
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
                                   , CBTYPE
                                   , INFOPUBLDATE
                                   , OPTYPE
                                   , OPPROGRESS
                                   , OPREMARK
                                   , ENFORCEREASON
                                   , CALLPROTECTION
                                   , LASTCOVERTDAY
                                   , LASTCOVERTPRICE
                                   , CALLTERMSTARTDATE
                                   , CALLTERMENDDATE
                                   , COMMOPTIONDATE
                                   , CALLPRICE
                                   , CALLPRICETAXED
                                   , IFINCLUDEINTEREST
                                   , INTEREST
                                   , LEASTOPVOL
                                   , IFOPTION
                                   , CALLPIECES
                                   , CALLVOL
                                   , ALLOCATINGCALLMONDAY
                                   , UPDATETIME
                                   , JSID
                                   , EXPECTEDEXERCISEDATE
                                   , CALLCODE
                                   , CALLNAME
                                   , COMMOPAPPLSTTIME
                                   , COMMOPAPPLEDTIME
                                   , OPTYPESECOND
                                   , CALLREGDATE
                                   , OUTSTANDINGBDVOL
                                   , OPTIONMARK
                                   , REVOKESTARTDATE
                                   , REVOKEENDDATE
                                   , STOPEXESTARTDATE
                                   , STOPEXEENDDATE
                                   , TRIGGERRECOUNTDAY
                                   , CALLNOTICEDATE
                                   , EXEREACHSTARTDATE
                                   , EXEREACHENDDATE
                                FROM ${jy_src_schema}.BOND_CONBDCALLPUTINFO"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "CBTYPE", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "OPTYPE", "type": "DOUBLE"}, {"name": "OPPROGRESS", "type": "DOUBLE"}, {"name": "OPREMARK", "type": "STRING"}, {"name": "ENFORCEREASON", "type": "STRING"}, {"name": "CALLPROTECTION", "type": "DOUBLE"}, {"name": "LASTCOVERTDAY", "type": "STRING"}, {"name": "LASTCOVERTPRICE", "type": "DOUBLE"}, {"name": "CALLTERMSTARTDATE", "type": "STRING"}, {"name": "CALLTERMENDDATE", "type": "STRING"}, {"name": "COMMOPTIONDATE", "type": "STRING"}, {"name": "CALLPRICE", "type": "DOUBLE"}, {"name": "CALLPRICETAXED", "type": "DOUBLE"}, {"name": "IFINCLUDEINTEREST", "type": "DOUBLE"}, {"name": "INTEREST", "type": "DOUBLE"}, {"name": "LEASTOPVOL", "type": "DOUBLE"}, {"name": "IFOPTION", "type": "DOUBLE"}, {"name": "CALLPIECES", "type": "DOUBLE"}, {"name": "CALLVOL", "type": "DOUBLE"}, {"name": "ALLOCATINGCALLMONDAY", "type": "STRING"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "EXPECTEDEXERCISEDATE", "type": "STRING"}, {"name": "CALLCODE", "type": "STRING"}, {"name": "CALLNAME", "type": "STRING"}, {"name": "COMMOPAPPLSTTIME", "type": "STRING"}, {"name": "COMMOPAPPLEDTIME", "type": "STRING"}, {"name": "OPTYPESECOND", "type": "DOUBLE"}, {"name": "CALLREGDATE", "type": "STRING"}, {"name": "OUTSTANDINGBDVOL", "type": "DOUBLE"}, {"name": "OPTIONMARK", "type": "DOUBLE"}, {"name": "REVOKESTARTDATE", "type": "STRING"}, {"name": "REVOKEENDDATE", "type": "STRING"}, {"name": "STOPEXESTARTDATE", "type": "STRING"}, {"name": "STOPEXEENDDATE", "type": "STRING"}, {"name": "TRIGGERRECOUNTDAY", "type": "STRING"}, {"name": "CALLNOTICEDATE", "type": "STRING"}, {"name": "EXEREACHSTARTDATE", "type": "STRING"}, {"name": "EXEREACHENDDATE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_conbdcallputinfo_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_conbdcallputinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_conbdcallputinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_conbdcallputinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_CONBDCALLPUTINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_CONBDCALLPUTINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_conbdcallputinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_CONBDCALLPUTINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , CBTYPE
     , INFOPUBLDATE
     , OPTYPE
     , OPPROGRESS
     , OPREMARK
     , ENFORCEREASON
     , CALLPROTECTION
     , LASTCOVERTDAY
     , LASTCOVERTPRICE
     , CALLTERMSTARTDATE
     , CALLTERMENDDATE
     , COMMOPTIONDATE
     , CALLPRICE
     , CALLPRICETAXED
     , IFINCLUDEINTEREST
     , INTEREST
     , LEASTOPVOL
     , IFOPTION
     , CALLPIECES
     , CALLVOL
     , ALLOCATINGCALLMONDAY
     , UPDATETIME
     , JSID
     , EXPECTEDEXERCISEDATE
     , CALLCODE
     , CALLNAME
     , COMMOPAPPLSTTIME
     , COMMOPAPPLEDTIME
     , OPTYPESECOND
     , CALLREGDATE
     , OUTSTANDINGBDVOL
     , OPTIONMARK
     , REVOKESTARTDATE
     , REVOKEENDDATE
     , STOPEXESTARTDATE
     , STOPEXEENDDATE
     , TRIGGERRECOUNTDAY
     , CALLNOTICEDATE
     , EXEREACHSTARTDATE
     , EXEREACHENDDATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_BOND_CONBDCALLPUTINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_CONBDCALLPUTINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_CONBDCALLPUTINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_CONBDCALLPUTINFO_PFD成功"
      exit 0
   fi
fi
