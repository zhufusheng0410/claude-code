#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_GUARANTOR_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_GUARANTOR_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  MAINCODE  STRING  COMMENT  '基金主代码',
  INITIALINFOPUBLDATE  STRING  COMMENT  '首次信息发布日期',
  PUBLISHDATE  STRING  COMMENT  '公告日期',
  GUARANTEETYPE  STRING  COMMENT  '担保类型',
  GUARANTORCODE  STRING  COMMENT  '担保人代码',
  GUARANTORNAME  STRING  COMMENT  '担保人',
  GUARANTORNATURE  DECIMAL(10,0)  COMMENT  '担保人性质',
  GUARANTORINFO  STRING  COMMENT  '担保人介绍',
  GUARANTEERANGE  STRING  COMMENT  '担保范围与对象',
  GUARANTEEMETHOD  DECIMAL(10,0)  COMMENT  '担保方式',
  ASSUREGUATYPE  DECIMAL(10,0)  COMMENT  '保证担保方式',
  GUAMATURITY  DECIMAL(18,8)  COMMENT  '担保期限',
  BEGINDATE  STRING  COMMENT  '起始日期',
  ENDDATE  STRING  COMMENT  '日期',
  GUACONTENT  STRING  COMMENT  '担保函内容',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  GUAMATURITYDESC  STRING  COMMENT  '担保期限描述',
  GUARANTEEFEE  DECIMAL(19,8)  COMMENT  '担保费用(亿元)',
  GUARANTEERATIO  DECIMAL(19,8)  COMMENT  '担保比例(%)',
  TLOWMORATIO  DECIMAL(19,8)  COMMENT  '理论最低抵质押比率',
  MORATIODESC  STRING  COMMENT  '抵质押比率描述',
  GUARANTEESUM  DECIMAL(19,8)  COMMENT  '担保金额(亿元)'
)
COMMENT '债券担保人'
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
                                   , INITIALINFOPUBLDATE
                                   , PUBLISHDATE
                                   , GUARANTEETYPE
                                   , GUARANTORCODE
                                   , GUARANTORNAME
                                   , GUARANTORNATURE
                                   , GUARANTORINFO
                                   , GUARANTEERANGE
                                   , GUARANTEEMETHOD
                                   , ASSUREGUATYPE
                                   , GUAMATURITY
                                   , BEGINDATE
                                   , ENDDATE
                                   , GUACONTENT
                                   , UPDATETIME
                                   , JSID
                                   , GUAMATURITYDESC
                                   , GUARANTEEFEE
                                   , GUARANTEERATIO
                                   , TLOWMORATIO
                                   , MORATIODESC
                                   , GUARANTEESUM
                                FROM ${jy_src_schema}.BOND_GUARANTOR"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "MAINCODE", "type": "DOUBLE"}, {"name": "INITIALINFOPUBLDATE", "type": "STRING"}, {"name": "PUBLISHDATE", "type": "STRING"}, {"name": "GUARANTEETYPE", "type": "DOUBLE"}, {"name": "GUARANTORCODE", "type": "DOUBLE"}, {"name": "GUARANTORNAME", "type": "STRING"}, {"name": "GUARANTORNATURE", "type": "DOUBLE"}, {"name": "GUARANTORINFO", "type": "STRING"}, {"name": "GUARANTEERANGE", "type": "STRING"}, {"name": "GUARANTEEMETHOD", "type": "DOUBLE"}, {"name": "ASSUREGUATYPE", "type": "DOUBLE"}, {"name": "GUAMATURITY", "type": "DOUBLE"}, {"name": "BEGINDATE", "type": "STRING"}, {"name": "ENDDATE", "type": "STRING"}, {"name": "GUACONTENT", "type": "STRING"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "GUAMATURITYDESC", "type": "STRING"}, {"name": "GUARANTEEFEE", "type": "DOUBLE"}, {"name": "GUARANTEERATIO", "type": "DOUBLE"}, {"name": "TLOWMORATIO", "type": "DOUBLE"}, {"name": "MORATIODESC", "type": "STRING"}, {"name": "GUARANTEESUM", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_guarantor_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_guarantor_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_guarantor_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_guarantor_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_GUARANTOR_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_GUARANTOR_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_guarantor_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_GUARANTOR_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , MAINCODE
     , INITIALINFOPUBLDATE
     , PUBLISHDATE
     , GUARANTEETYPE
     , GUARANTORCODE
     , GUARANTORNAME
     , GUARANTORNATURE
     , GUARANTORINFO
     , GUARANTEERANGE
     , GUARANTEEMETHOD
     , ASSUREGUATYPE
     , GUAMATURITY
     , BEGINDATE
     , ENDDATE
     , GUACONTENT
     , UPDATETIME
     , JSID
     , GUAMATURITYDESC
     , GUARANTEEFEE
     , GUARANTEERATIO
     , TLOWMORATIO
     , MORATIODESC
     , GUARANTEESUM
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_BOND_GUARANTOR_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_GUARANTOR_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_GUARANTOR_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_GUARANTOR_PFD成功"
      exit 0
   fi
fi
