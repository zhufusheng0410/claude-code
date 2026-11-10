#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_MF_SHARESSPLIT_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_MF_SHARESSPLIT_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  INFOSOURCE  STRING  COMMENT  '信息来源',
  INFOTYPE  DECIMAL(10,0)  COMMENT  '信息类别',
  SPLITDAY  STRING  COMMENT  '拆分折算日_公布',
  SPLITRATIO  DECIMAL(19,10)  COMMENT  '拆分折算比例_公布(1:X)',
  OUTCOMENOTICEISSUEDATE  STRING  COMMENT  '结果公告日',
  CHANGEREGDATE  STRING  COMMENT  '工商变更登记日',
  NV  DECIMAL(19,4)  COMMENT  '净资产值',
  SHARESBEFORE  DECIMAL(19,2)  COMMENT  '拆分折算前份额',
  SHARESAFTER  DECIMAL(19,2)  COMMENT  '拆分折算后份额',
  UNITNVBEFORE  DECIMAL(19,8)  COMMENT  '拆分折算前单位净值',
  UNITNVAFTER  DECIMAL(19,8)  COMMENT  '拆分折算后单位净值',
  ACCUMULATEDUNITNVBEFORE  DECIMAL(19,8)  COMMENT  '拆分折算前累计净值',
  ACCUMULATEDUNITNVAFTER  DECIMAL(19,8)  COMMENT  '拆分折算后累计净值',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  INNERCODEADD  DECIMAL(10,0)  COMMENT  '新增份额对象',
  SPLITRATIOADD  DECIMAL(19,9)  COMMENT  '新增拆分比例(1:X)',
  SHARESADD  DECIMAL(19,6)  COMMENT  '新增份额',
  SHARESADDCOMBINE  DECIMAL(19,6)  COMMENT  '新增份额(合并)',
  REMARK  STRING  COMMENT  '备注',
  ESSPLITRATIO  DECIMAL(19,10)  COMMENT  '拆分折算比例_预估(1:X)',
  SPLITTYPE  DECIMAL(10,0)  COMMENT  '拆分折算方式',
  ACTUALSPLITDAY  STRING  COMMENT  '拆分折算日_实际',
  AFSPLITRATIO  DECIMAL(19,10)  COMMENT  '拆分折算比例_复权(1:X)',
  SPLITDAYEX  STRING  COMMENT  '拆分折算日_场内',
  TRANSCODE  STRING  COMMENT  '基金统一编码'
)
COMMENT '基金拆分折算'
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
                                   , INFOTYPE
                                   , SPLITDAY
                                   , SPLITRATIO
                                   , OUTCOMENOTICEISSUEDATE
                                   , CHANGEREGDATE
                                   , NV
                                   , SHARESBEFORE
                                   , SHARESAFTER
                                   , UNITNVBEFORE
                                   , UNITNVAFTER
                                   , ACCUMULATEDUNITNVBEFORE
                                   , ACCUMULATEDUNITNVAFTER
                                   , XGRQ
                                   , JSID
                                   , INNERCODEADD
                                   , SPLITRATIOADD
                                   , SHARESADD
                                   , SHARESADDCOMBINE
                                   , REMARK
                                   , ESSPLITRATIO
                                   , SPLITTYPE
                                   , ACTUALSPLITDAY
                                   , AFSPLITRATIO
                                   , SPLITDAYEX
                                   , TRANSCODE
                                FROM ${jy_src_schema}.MF_SHARESSPLIT"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "INFOSOURCE", "type": "STRING"}, {"name": "INFOTYPE", "type": "DOUBLE"}, {"name": "SPLITDAY", "type": "STRING"}, {"name": "SPLITRATIO", "type": "DOUBLE"}, {"name": "OUTCOMENOTICEISSUEDATE", "type": "STRING"}, {"name": "CHANGEREGDATE", "type": "STRING"}, {"name": "NV", "type": "DOUBLE"}, {"name": "SHARESBEFORE", "type": "DOUBLE"}, {"name": "SHARESAFTER", "type": "DOUBLE"}, {"name": "UNITNVBEFORE", "type": "DOUBLE"}, {"name": "UNITNVAFTER", "type": "DOUBLE"}, {"name": "ACCUMULATEDUNITNVBEFORE", "type": "DOUBLE"}, {"name": "ACCUMULATEDUNITNVAFTER", "type": "DOUBLE"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "INNERCODEADD", "type": "DOUBLE"}, {"name": "SPLITRATIOADD", "type": "DOUBLE"}, {"name": "SHARESADD", "type": "DOUBLE"}, {"name": "SHARESADDCOMBINE", "type": "DOUBLE"}, {"name": "REMARK", "type": "STRING"}, {"name": "ESSPLITRATIO", "type": "DOUBLE"}, {"name": "SPLITTYPE", "type": "DOUBLE"}, {"name": "ACTUALSPLITDAY", "type": "STRING"}, {"name": "AFSPLITRATIO", "type": "DOUBLE"}, {"name": "SPLITDAYEX", "type": "STRING"}, {"name": "TRANSCODE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_mf_sharessplit_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_mf_sharessplit_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_mf_sharessplit_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_mf_sharessplit_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_MF_SHARESSPLIT_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_MF_SHARESSPLIT_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_mf_sharessplit_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_MF_SHARESSPLIT_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , INFOPUBLDATE
     , INFOSOURCE
     , INFOTYPE
     , SPLITDAY
     , SPLITRATIO
     , OUTCOMENOTICEISSUEDATE
     , CHANGEREGDATE
     , NV
     , SHARESBEFORE
     , SHARESAFTER
     , UNITNVBEFORE
     , UNITNVAFTER
     , ACCUMULATEDUNITNVBEFORE
     , ACCUMULATEDUNITNVAFTER
     , XGRQ
     , JSID
     , INNERCODEADD
     , SPLITRATIOADD
     , SHARESADD
     , SHARESADDCOMBINE
     , REMARK
     , ESSPLITRATIO
     , SPLITTYPE
     , ACTUALSPLITDAY
     , AFSPLITRATIO
     , SPLITDAYEX
     , TRANSCODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_MF_SHARESSPLIT_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_MF_SHARESSPLIT_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_MF_SHARESSPLIT_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_MF_SHARESSPLIT_PFD成功"
      exit 0
   fi
fi
