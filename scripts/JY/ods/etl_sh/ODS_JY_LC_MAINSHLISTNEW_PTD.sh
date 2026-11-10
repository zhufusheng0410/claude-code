#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_MAINSHLISTNEW_PTD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_MAINSHLISTNEW_PTD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  COMPANYCODE  STRING  COMMENT  '公司代码',
  ENDDATE  STRING  COMMENT  '日期',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  INFOSOURCE  STRING  COMMENT  '信息来源',
  INFOTYPECODE  STRING  COMMENT  '信息类别编码',
  SHNO  DECIMAL(10,0)  COMMENT  '股东序号',
  SHSERIAL  DECIMAL(10,0)  COMMENT  '股东序号',
  SHLIST  STRING  COMMENT  '股东名单',
  SHKIND  STRING  COMMENT  '股东性质',
  SHTYPECODE  STRING  COMMENT  '股东类别编码',
  SHTYPE  STRING  COMMENT  '股东类别',
  SECUCOBELONGEDCODE  STRING  COMMENT  '所属券商编号',
  SECUCOBELONGEDNAME  STRING  COMMENT  '归属机构名称',
  SECUCODE  STRING  COMMENT  '证券代码',
  SECUABBR  STRING  COMMENT  '证券简称',
  HOLDSUM  DECIMAL(16,0)  COMMENT  '持股数(股)',
  PCTOFTOTALSHARES  DECIMAL(10,6)  COMMENT  '占总股本比例',
  RESTRAINEDTSHARE  DECIMAL(16,0)  COMMENT  '其中：有限售股数(股)',
  UNSTINTEDTSHARE  DECIMAL(16,0)  COMMENT  '其中：无限售股数(股)',
  HOLDSUMCHANGE  DECIMAL(16,0)  COMMENT  '持股数量增减(股)',
  HOLDSUMCHANGERATE  DECIMAL(16,6)  COMMENT  '持股数量增减幅度(%)',
  HOLDASHARESUM  DECIMAL(16,0)  COMMENT  '持有A股数量(股)',
  PCTOFFLOATSHARES  DECIMAL(10,6)  COMMENT  '占流通A股比例(%)',
  HOLDBSHARESUM  DECIMAL(16,0)  COMMENT  '持有B股数量(股)',
  HOLDHSHARESUM  DECIMAL(16,0)  COMMENT  '持有H股数量(股)',
  HOLDOTHTERSHARESUM  DECIMAL(16,0)  COMMENT  '持有其他股数量(股)',
  SHARECHARACTERSTATEMENT  STRING  COMMENT  '股本性质描述',
  PLEDGEINVOLVEDSUM  DECIMAL(16,0)  COMMENT  '股权质押涉及股数(股)',
  FREEZEINVOLVEDSUM  DECIMAL(16,0)  COMMENT  '股权冻结涉及股数(股)',
  PFSTATEMENT  STRING  COMMENT  '股权质押冻结情况说明',
  CONNECTIONRELATION  STRING  COMMENT  '股东关联关系',
  CONNECTIONSTATEMENT  STRING  COMMENT  '与其他股东关联关系说明',
  ACTINCONCERTSTATEMENT  STRING  COMMENT  '与其他股东同属一致行动人说明',
  NOTES  STRING  COMMENT  '备注说明',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  SECUINNERCODE  STRING  COMMENT  '证券代码',
  SHKINDCODE  STRING  COMMENT  '股东性质编码',
  GDID  DECIMAL(10,0)  COMMENT  '股东ID',
  SHATTRIBUTE  DECIMAL(10,0)  COMMENT  '股东属性',
  RESTRAINEDASHARE  DECIMAL(16,0)  COMMENT  '其中:有限售A股数(股)',
  UNSTINTEDASHARE  DECIMAL(16,0)  COMMENT  '其中:无限售A股数(股)',
  HOLDSHAREASUM  DECIMAL(16,0)  COMMENT  '持有A类普通股数量(股)',
  RESTRAINEDSHAREA  DECIMAL(16,0)  COMMENT  '其中:有限售A类普通股数量(股)',
  UNSTINTEDSHAREA  DECIMAL(16,0)  COMMENT  '其中:无限售A类普通股数量(股)',
  HOLDSHAREBSUM  DECIMAL(16,0)  COMMENT  '持有B类普通股数量(股)',
  RESTRAINEDSHAREB  DECIMAL(16,0)  COMMENT  '其中:有限售B类普通股数量(股)',
  UNSTINTEDSHAREB  DECIMAL(16,0)  COMMENT  '其中:无限售B类普通股数量(股)',
  HOLDSHARECSUM  DECIMAL(16,0)  COMMENT  '持有C类普通股数量(股)',
  HOLDSHAREDSUM  DECIMAL(16,0)  COMMENT  '持有D类普通股数量(股)',
  HOLDOTHERCOMSHARESUM  DECIMAL(16,0)  COMMENT  '持有其他类普通股数量(股)1',
  REFINANCELOANSHARE  DECIMAL(16,0)  COMMENT  '',
  INSERTTIME  STRING  COMMENT  '发布时间',
  HOLDCHANGETYPE  STRING  COMMENT  '持股变动类型',
  PREFSHAREWITHVOTRIGHT  DECIMAL(16,0)  COMMENT  '有投票权的优先股数量(股)',
  VOTINGRIGHTSVOL  DECIMAL(16,0)  COMMENT  '表决权总数(票)',
  VOTINGRIGHTSRATIO  DECIMAL(10,6)  COMMENT  '表决权比例(%)',
  SPECIALVOTINGRIGHTSVOL  DECIMAL(16,0)  COMMENT  '特别表决权数量(票)',
  PCTOFNRSHARES  DECIMAL(10,6)  COMMENT  '占无限售股份比例(%)'
)
COMMENT '主要股东名单(新)'
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
                                   , COMPANYCODE
                                   , TO_CHAR(ENDDATE,'YYYYMMDD') ENDDATE
                                   , INFOPUBLDATE
                                   , INFOSOURCE
                                   , INFOTYPECODE
                                   , SHNO
                                   , SHSERIAL
                                   , SHLIST
                                   , SHKIND
                                   , SHTYPECODE
                                   , SHTYPE
                                   , SECUCOBELONGEDCODE
                                   , SECUCOBELONGEDNAME
                                   , SECUCODE
                                   , SECUABBR
                                   , HOLDSUM
                                   , PCTOFTOTALSHARES
                                   , RESTRAINEDTSHARE
                                   , UNSTINTEDTSHARE
                                   , HOLDSUMCHANGE
                                   , HOLDSUMCHANGERATE
                                   , HOLDASHARESUM
                                   , PCTOFFLOATSHARES
                                   , HOLDBSHARESUM
                                   , HOLDHSHARESUM
                                   , HOLDOTHTERSHARESUM
                                   , SHARECHARACTERSTATEMENT
                                   , PLEDGEINVOLVEDSUM
                                   , FREEZEINVOLVEDSUM
                                   , PFSTATEMENT
                                   , CONNECTIONRELATION
                                   , CONNECTIONSTATEMENT
                                   , ACTINCONCERTSTATEMENT
                                   , NOTES
                                   , XGRQ
                                   , JSID
                                   , SECUINNERCODE
                                   , SHKINDCODE
                                   , GDID
                                   , SHATTRIBUTE
                                   , RESTRAINEDASHARE
                                   , UNSTINTEDASHARE
                                   , HOLDSHAREASUM
                                   , RESTRAINEDSHAREA
                                   , UNSTINTEDSHAREA
                                   , HOLDSHAREBSUM
                                   , RESTRAINEDSHAREB
                                   , UNSTINTEDSHAREB
                                   , HOLDSHARECSUM
                                   , HOLDSHAREDSUM
                                   , HOLDOTHERCOMSHARESUM
                                   , REFINANCELOANSHARE
                                   , INSERTTIME
                                   , HOLDCHANGETYPE
                                   , PREFSHAREWITHVOTRIGHT
                                   , VOTINGRIGHTSVOL
                                   , VOTINGRIGHTSRATIO
                                   , SPECIALVOTINGRIGHTSVOL
                                   , PCTOFNRSHARES
                                FROM ${jy_src_schema}.LC_MAINSHLISTNEW
                                WHERE ENDDATE between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "COMPANYCODE", "type": "DOUBLE"}, {"name": "ENDDATE", "type": "STRING"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "INFOSOURCE", "type": "STRING"}, {"name": "INFOTYPECODE", "type": "DOUBLE"}, {"name": "SHNO", "type": "DOUBLE"}, {"name": "SHSERIAL", "type": "DOUBLE"}, {"name": "SHLIST", "type": "STRING"}, {"name": "SHKIND", "type": "STRING"}, {"name": "SHTYPECODE", "type": "DOUBLE"}, {"name": "SHTYPE", "type": "STRING"}, {"name": "SECUCOBELONGEDCODE", "type": "DOUBLE"}, {"name": "SECUCOBELONGEDNAME", "type": "STRING"}, {"name": "SECUCODE", "type": "STRING"}, {"name": "SECUABBR", "type": "STRING"}, {"name": "HOLDSUM", "type": "DOUBLE"}, {"name": "PCTOFTOTALSHARES", "type": "DOUBLE"}, {"name": "RESTRAINEDTSHARE", "type": "DOUBLE"}, {"name": "UNSTINTEDTSHARE", "type": "DOUBLE"}, {"name": "HOLDSUMCHANGE", "type": "DOUBLE"}, {"name": "HOLDSUMCHANGERATE", "type": "DOUBLE"}, {"name": "HOLDASHARESUM", "type": "DOUBLE"}, {"name": "PCTOFFLOATSHARES", "type": "DOUBLE"}, {"name": "HOLDBSHARESUM", "type": "DOUBLE"}, {"name": "HOLDHSHARESUM", "type": "DOUBLE"}, {"name": "HOLDOTHTERSHARESUM", "type": "DOUBLE"}, {"name": "SHARECHARACTERSTATEMENT", "type": "STRING"}, {"name": "PLEDGEINVOLVEDSUM", "type": "DOUBLE"}, {"name": "FREEZEINVOLVEDSUM", "type": "DOUBLE"}, {"name": "PFSTATEMENT", "type": "STRING"}, {"name": "CONNECTIONRELATION", "type": "STRING"}, {"name": "CONNECTIONSTATEMENT", "type": "STRING"}, {"name": "ACTINCONCERTSTATEMENT", "type": "STRING"}, {"name": "NOTES", "type": "STRING"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "SECUINNERCODE", "type": "DOUBLE"}, {"name": "SHKINDCODE", "type": "DOUBLE"}, {"name": "GDID", "type": "DOUBLE"}, {"name": "SHATTRIBUTE", "type": "DOUBLE"}, {"name": "RESTRAINEDASHARE", "type": "DOUBLE"}, {"name": "UNSTINTEDASHARE", "type": "DOUBLE"}, {"name": "HOLDSHAREASUM", "type": "DOUBLE"}, {"name": "RESTRAINEDSHAREA", "type": "DOUBLE"}, {"name": "UNSTINTEDSHAREA", "type": "DOUBLE"}, {"name": "HOLDSHAREBSUM", "type": "DOUBLE"}, {"name": "RESTRAINEDSHAREB", "type": "DOUBLE"}, {"name": "UNSTINTEDSHAREB", "type": "DOUBLE"}, {"name": "HOLDSHARECSUM", "type": "DOUBLE"}, {"name": "HOLDSHAREDSUM", "type": "DOUBLE"}, {"name": "HOLDOTHERCOMSHARESUM", "type": "DOUBLE"}, {"name": "REFINANCELOANSHARE", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}, {"name": "HOLDCHANGETYPE", "type": "DOUBLE"}, {"name": "PREFSHAREWITHVOTRIGHT", "type": "DOUBLE"}, {"name": "VOTINGRIGHTSVOL", "type": "DOUBLE"}, {"name": "VOTINGRIGHTSRATIO", "type": "DOUBLE"}, {"name": "SPECIALVOTINGRIGHTSVOL", "type": "DOUBLE"}, {"name": "PCTOFNRSHARES", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_mainshlistnew_ptd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_mainshlistnew_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_mainshlistnew_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_mainshlistnew_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_MAINSHLISTNEW_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_MAINSHLISTNEW_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_mainshlistnew_ptd_tmp.json

inceptor_beeline "
set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions.pernode=10000;
set hive.exec.max.dynamic.partitions=10000;
set hive.exec.max.created.files=10000;
set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_MAINSHLISTNEW_PTD PARTITION(P_DT)
SELECT
       ID
     , COMPANYCODE
     , ENDDATE
     , INFOPUBLDATE
     , INFOSOURCE
     , INFOTYPECODE
     , SHNO
     , SHSERIAL
     , SHLIST
     , SHKIND
     , SHTYPECODE
     , SHTYPE
     , SECUCOBELONGEDCODE
     , SECUCOBELONGEDNAME
     , SECUCODE
     , SECUABBR
     , HOLDSUM
     , PCTOFTOTALSHARES
     , RESTRAINEDTSHARE
     , UNSTINTEDTSHARE
     , HOLDSUMCHANGE
     , HOLDSUMCHANGERATE
     , HOLDASHARESUM
     , PCTOFFLOATSHARES
     , HOLDBSHARESUM
     , HOLDHSHARESUM
     , HOLDOTHTERSHARESUM
     , SHARECHARACTERSTATEMENT
     , PLEDGEINVOLVEDSUM
     , FREEZEINVOLVEDSUM
     , PFSTATEMENT
     , CONNECTIONRELATION
     , CONNECTIONSTATEMENT
     , ACTINCONCERTSTATEMENT
     , NOTES
     , XGRQ
     , JSID
     , SECUINNERCODE
     , SHKINDCODE
     , GDID
     , SHATTRIBUTE
     , RESTRAINEDASHARE
     , UNSTINTEDASHARE
     , HOLDSHAREASUM
     , RESTRAINEDSHAREA
     , UNSTINTEDSHAREA
     , HOLDSHAREBSUM
     , RESTRAINEDSHAREB
     , UNSTINTEDSHAREB
     , HOLDSHARECSUM
     , HOLDSHAREDSUM
     , HOLDOTHERCOMSHARESUM
     , REFINANCELOANSHARE
     , INSERTTIME
     , HOLDCHANGETYPE
     , PREFSHAREWITHVOTRIGHT
     , VOTINGRIGHTSVOL
     , VOTINGRIGHTSRATIO
     , SPECIALVOTINGRIGHTSVOL
     , PCTOFNRSHARES
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(ENDDATE,'-','') P_DT
  FROM ODS_XDAY_JY.ODS_JY_LC_MAINSHLISTNEW_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_MAINSHLISTNEW_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_MAINSHLISTNEW_PTD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_MAINSHLISTNEW_PTD成功"
      exit 0
   fi
fi
