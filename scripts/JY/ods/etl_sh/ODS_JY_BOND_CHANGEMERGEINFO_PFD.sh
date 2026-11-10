#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_CHANGEMERGEINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_CHANGEMERGEINFO_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  MAINCODE  STRING  COMMENT  '基金主代码',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  OPTYPE  STRING  COMMENT  '行权类型',
  OPPROGRESS  DECIMAL(10,0)  COMMENT  '行权进程',
  OPREMARK  STRING  COMMENT  '权利描述',
  COMMOPAPPLSTDATE  STRING  COMMENT  '行权申请起始日',
  COMMOPAPPLEDDATE  STRING  COMMENT  '行权申请截止日',
  COMMOPTIONDATE  STRING  COMMENT  '行权操作日',
  LEASTOPVOL  DECIMAL(19,4)  COMMENT  '最低操作金额(元)',
  TARGETBDCODE  STRING  COMMENT  '换/并入目标券代码',
  CHANGERATIO  DECIMAL(19,8)  COMMENT  '调换比例',
  ROOTBDOUTVOL  DECIMAL(19,4)  COMMENT  '本券换/并出金额(元)',
  ROOTBDOUTSTANDING  DECIMAL(19,4)  COMMENT  '本券换/并出后余额(元)',
  TARGETBDINVOL  DECIMAL(19,4)  COMMENT  '目标券换/并入金额(元)',
  TARGETBDSUM  DECIMAL(19,4)  COMMENT  '目标券换/并入后总金额(元)',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  EXPECTEDEXERCISEDATE  STRING  COMMENT  '权利可能行使日',
  IFOPTION  DECIMAL(10,0)  COMMENT  '是否行权',
  OPTIONREASON  STRING  COMMENT  '行权原因说明'
)
COMMENT '债券调换与合并'
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
                                   , MAINCODE
                                   , INFOPUBLDATE
                                   , OPTYPE
                                   , OPPROGRESS
                                   , OPREMARK
                                   , COMMOPAPPLSTDATE
                                   , COMMOPAPPLEDDATE
                                   , COMMOPTIONDATE
                                   , LEASTOPVOL
                                   , TARGETBDCODE
                                   , CHANGERATIO
                                   , ROOTBDOUTVOL
                                   , ROOTBDOUTSTANDING
                                   , TARGETBDINVOL
                                   , TARGETBDSUM
                                   , UPDATETIME
                                   , JSID
                                   , EXPECTEDEXERCISEDATE
                                   , IFOPTION
                                   , OPTIONREASON
                                FROM ${jy_src_schema}.BOND_CHANGEMERGEINFO"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "MAINCODE", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "OPTYPE", "type": "DOUBLE"}, {"name": "OPPROGRESS", "type": "DOUBLE"}, {"name": "OPREMARK", "type": "STRING"}, {"name": "COMMOPAPPLSTDATE", "type": "STRING"}, {"name": "COMMOPAPPLEDDATE", "type": "STRING"}, {"name": "COMMOPTIONDATE", "type": "STRING"}, {"name": "LEASTOPVOL", "type": "DOUBLE"}, {"name": "TARGETBDCODE", "type": "DOUBLE"}, {"name": "CHANGERATIO", "type": "DOUBLE"}, {"name": "ROOTBDOUTVOL", "type": "DOUBLE"}, {"name": "ROOTBDOUTSTANDING", "type": "DOUBLE"}, {"name": "TARGETBDINVOL", "type": "DOUBLE"}, {"name": "TARGETBDSUM", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "EXPECTEDEXERCISEDATE", "type": "STRING"}, {"name": "IFOPTION", "type": "DOUBLE"}, {"name": "OPTIONREASON", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_changemergeinfo_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_changemergeinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_changemergeinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_changemergeinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_CHANGEMERGEINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_CHANGEMERGEINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_changemergeinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_CHANGEMERGEINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , MAINCODE
     , INFOPUBLDATE
     , OPTYPE
     , OPPROGRESS
     , OPREMARK
     , COMMOPAPPLSTDATE
     , COMMOPAPPLEDDATE
     , COMMOPTIONDATE
     , LEASTOPVOL
     , TARGETBDCODE
     , CHANGERATIO
     , ROOTBDOUTVOL
     , ROOTBDOUTSTANDING
     , TARGETBDINVOL
     , TARGETBDSUM
     , UPDATETIME
     , JSID
     , EXPECTEDEXERCISEDATE
     , IFOPTION
     , OPTIONREASON
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_BOND_CHANGEMERGEINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_CHANGEMERGEINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_CHANGEMERGEINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_CHANGEMERGEINFO_PFD成功"
      exit 0
   fi
fi
