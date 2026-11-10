#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_MF_FUNDMANAGER_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_MF_FUNDMANAGER_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  INFOSOURCE  STRING  COMMENT  '信息来源',
  POSTNAME  DECIMAL(10,0)  COMMENT  '职位名称',
  NAME  STRING  COMMENT  '无形资产名称',
  GENDER  STRING  COMMENT  '性别',
  BIRTHDATE  STRING  COMMENT  '出生日期',
  ACCESSIONDATE  STRING  COMMENT  '任期开始日期',
  DIMISSIONDATE  STRING  COMMENT  '任期结束日期',
  PERFORMANCE  DECIMAL(18,6)  COMMENT  '任职期间基金净值增长率',
  EDUCATIONLEVEL  DECIMAL(10,0)  COMMENT  '学历',
  EXPERIENCETIME  DECIMAL(18,1)  COMMENT  '证券从业经历(年)',
  PRACTICEDATE  STRING  COMMENT  '证券从业日期',
  BACKGROUND  STRING  COMMENT  '简历',
  INCUMBENT  DECIMAL(3,0)  COMMENT  '在任与否',
  NOTES  STRING  COMMENT  '备注说明',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  PERSONALDATA  STRING  COMMENT  '个人资料',
  FILETYPE  DECIMAL(10,0)  COMMENT  '报告原文文件格式',
  BIRTHYMINFO  STRING  COMMENT  '出生年月(文本)',
  PERSONALCODE  STRING  COMMENT  '人员编码',
  OTHERNAME  STRING  COMMENT  '别名称',
  ENGLISHNAME  STRING  COMMENT  '英文名',
  NATIONALITY  DECIMAL(10,0)  COMMENT  '国籍',
  IDCARDNUM  STRING  COMMENT  '身份证',
  PASSPORTNUM  STRING  COMMENT  '护照',
  MANAGEMENTTIME  DECIMAL(10,0)  COMMENT  '任职天数',
  PROQUALIFI  STRING  COMMENT  '专业资格'
)
COMMENT '基金经理'
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
                                   , POSTNAME
                                   , NAME
                                   , GENDER
                                   , BIRTHDATE
                                   , ACCESSIONDATE
                                   , DIMISSIONDATE
                                   , PERFORMANCE
                                   , EDUCATIONLEVEL
                                   , EXPERIENCETIME
                                   , PRACTICEDATE
                                   , BACKGROUND
                                   , INCUMBENT
                                   , NOTES
                                   , XGRQ
                                   , JSID
                                   , PERSONALDATA
                                   , FILETYPE
                                   , BIRTHYMINFO
                                   , PERSONALCODE
                                   , OTHERNAME
                                   , ENGLISHNAME
                                   , NATIONALITY
                                   , IDCARDNUM
                                   , PASSPORTNUM
                                   , MANAGEMENTTIME
                                   , PROQUALIFI
                                FROM ${jy_src_schema}.MF_FUNDMANAGER"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "INFOSOURCE", "type": "STRING"}, {"name": "POSTNAME", "type": "DOUBLE"}, {"name": "NAME", "type": "STRING"}, {"name": "GENDER", "type": "STRING"}, {"name": "BIRTHDATE", "type": "STRING"}, {"name": "ACCESSIONDATE", "type": "STRING"}, {"name": "DIMISSIONDATE", "type": "STRING"}, {"name": "PERFORMANCE", "type": "DOUBLE"}, {"name": "EDUCATIONLEVEL", "type": "DOUBLE"}, {"name": "EXPERIENCETIME", "type": "DOUBLE"}, {"name": "PRACTICEDATE", "type": "STRING"}, {"name": "BACKGROUND", "type": "STRING"}, {"name": "INCUMBENT", "type": "DOUBLE"}, {"name": "NOTES", "type": "STRING"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "PERSONALDATA", "type": "STRING"}, {"name": "FILETYPE", "type": "DOUBLE"}, {"name": "BIRTHYMINFO", "type": "STRING"}, {"name": "PERSONALCODE", "type": "DOUBLE"}, {"name": "OTHERNAME", "type": "STRING"}, {"name": "ENGLISHNAME", "type": "STRING"}, {"name": "NATIONALITY", "type": "DOUBLE"}, {"name": "IDCARDNUM", "type": "STRING"}, {"name": "PASSPORTNUM", "type": "STRING"}, {"name": "MANAGEMENTTIME", "type": "DOUBLE"}, {"name": "PROQUALIFI", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_mf_fundmanager_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_mf_fundmanager_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_mf_fundmanager_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_mf_fundmanager_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_MF_FUNDMANAGER_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_MF_FUNDMANAGER_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_mf_fundmanager_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_MF_FUNDMANAGER_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , INFOPUBLDATE
     , INFOSOURCE
     , POSTNAME
     , NAME
     , GENDER
     , BIRTHDATE
     , ACCESSIONDATE
     , DIMISSIONDATE
     , PERFORMANCE
     , EDUCATIONLEVEL
     , EXPERIENCETIME
     , PRACTICEDATE
     , BACKGROUND
     , INCUMBENT
     , NOTES
     , XGRQ
     , JSID
     , PERSONALDATA
     , FILETYPE
     , BIRTHYMINFO
     , PERSONALCODE
     , OTHERNAME
     , ENGLISHNAME
     , NATIONALITY
     , IDCARDNUM
     , PASSPORTNUM
     , MANAGEMENTTIME
     , PROQUALIFI
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_MF_FUNDMANAGER_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_MF_FUNDMANAGER_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_MF_FUNDMANAGER_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_MF_FUNDMANAGER_PFD成功"
      exit 0
   fi
fi
