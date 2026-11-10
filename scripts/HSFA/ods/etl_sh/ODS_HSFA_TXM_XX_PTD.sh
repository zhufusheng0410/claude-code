#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TXM_XX_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TXM_XX_PTD_TMP(
  L_BH  DECIMAL(8,0)  COMMENT  '',
  L_ZTBH  DECIMAL(9,0)  COMMENT  '',
  VC_XMBH  STRING  COMMENT  '',
  L_YWLB  DECIMAL(4,0)  COMMENT  '',
  L_SCLB  DECIMAL(4,0)  COMMENT  '',
  D_SDATE  STRING  COMMENT  '',
  D_EDATE  STRING  COMMENT  '',
  VC_JSBZ  STRING  COMMENT  '',
  D_QXR  STRING  COMMENT  '',
  D_SCFXR  STRING  COMMENT  '',
  L_FXPL  DECIMAL(4,0)  COMMENT  '',
  L_LXJSFF  DECIMAL(4,0)  COMMENT  '',
  L_JXFF  DECIMAL(4,0)  COMMENT  '',
  VC_JYDS  STRING  COMMENT  '',
  VC_MXKM  STRING  COMMENT  '',
  VC_LLR  STRING  COMMENT  '',
  VC_FHR  STRING  COMMENT  '',
  L_CLBZ  DECIMAL(4,0)  COMMENT  '',
  D_SCSJ  STRING  COMMENT  '',
  VC_XMMC  STRING  COMMENT  '',
  VC_CJBH  STRING  COMMENT  '',
  L_XZBZ  DECIMAL(4,0)  COMMENT  '',
  D_TQGHR  STRING  COMMENT  '',
  VC_XWDM  STRING  COMMENT  '',
  VC_QSBH  STRING  COMMENT  '',
  L_SFJRJG  DECIMAL(1,0)  COMMENT  '',
  VC_JSBH  STRING  COMMENT  '',
  VC_HGDM  STRING  COMMENT  '',
  EN_NLL  DECIMAL(14,8)  COMMENT  '',
  VC_GDDM  STRING  COMMENT  ''
)
COMMENT ''
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
            "username": "${hsfa_username}",
            "password": "${hsfa_password}",
            "connection": [{
              "querySql": ["SELECT  L_BH
                                   , L_ZTBH
                                   , VC_XMBH
                                   , L_YWLB
                                   , L_SCLB
                                   , TO_CHAR(D_SDATE,'YYYYMMDD') D_SDATE
                                   , D_EDATE
                                   , VC_JSBZ
                                   , D_QXR
                                   , D_SCFXR
                                   , L_FXPL
                                   , L_LXJSFF
                                   , L_JXFF
                                   , VC_JYDS
                                   , VC_MXKM
                                   , VC_LLR
                                   , VC_FHR
                                   , L_CLBZ
                                   , D_SCSJ
                                   , VC_XMMC
                                   , VC_CJBH
                                   , L_XZBZ
                                   , D_TQGHR
                                   , VC_XWDM
                                   , VC_QSBH
                                   , L_SFJRJG
                                   , VC_JSBH
                                   , VC_HGDM
                                   , EN_NLL
                                   , VC_GDDM
                                FROM ${hsfa_src_schema}.TXM_XX
                                WHERE D_SDATE between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_BH", "type": "DOUBLE"}, {"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "VC_XMBH", "type": "STRING"}, {"name": "L_YWLB", "type": "DOUBLE"}, {"name": "L_SCLB", "type": "DOUBLE"}, {"name": "D_SDATE", "type": "STRING"}, {"name": "D_EDATE", "type": "STRING"}, {"name": "VC_JSBZ", "type": "STRING"}, {"name": "D_QXR", "type": "STRING"}, {"name": "D_SCFXR", "type": "STRING"}, {"name": "L_FXPL", "type": "DOUBLE"}, {"name": "L_LXJSFF", "type": "DOUBLE"}, {"name": "L_JXFF", "type": "DOUBLE"}, {"name": "VC_JYDS", "type": "STRING"}, {"name": "VC_MXKM", "type": "STRING"}, {"name": "VC_LLR", "type": "STRING"}, {"name": "VC_FHR", "type": "STRING"}, {"name": "L_CLBZ", "type": "DOUBLE"}, {"name": "D_SCSJ", "type": "STRING"}, {"name": "VC_XMMC", "type": "STRING"}, {"name": "VC_CJBH", "type": "STRING"}, {"name": "L_XZBZ", "type": "DOUBLE"}, {"name": "D_TQGHR", "type": "STRING"}, {"name": "VC_XWDM", "type": "STRING"}, {"name": "VC_QSBH", "type": "STRING"}, {"name": "L_SFJRJG", "type": "DOUBLE"}, {"name": "VC_JSBH", "type": "STRING"}, {"name": "VC_HGDM", "type": "STRING"}, {"name": "EN_NLL", "type": "DOUBLE"}, {"name": "VC_GDDM", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_txm_xx_ptd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_txm_xx_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_txm_xx_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_txm_xx_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TXM_XX_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TXM_XX_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_txm_xx_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TXM_XX_PTD PARTITION(P_DT)
SELECT
       L_BH
     , L_ZTBH
     , VC_XMBH
     , L_YWLB
     , L_SCLB
     , D_SDATE
     , D_EDATE
     , VC_JSBZ
     , D_QXR
     , D_SCFXR
     , L_FXPL
     , L_LXJSFF
     , L_JXFF
     , VC_JYDS
     , VC_MXKM
     , VC_LLR
     , VC_FHR
     , L_CLBZ
     , D_SCSJ
     , VC_XMMC
     , VC_CJBH
     , L_XZBZ
     , D_TQGHR
     , VC_XWDM
     , VC_QSBH
     , L_SFJRJG
     , VC_JSBH
     , VC_HGDM
     , EN_NLL
     , VC_GDDM
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_SDATE,'-','') P_DT
  FROM ODS_XDAY_HSFA.ODS_HSFA_TXM_XX_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TXM_XX_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TXM_XX_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TXM_XX_PTD成功"
      exit 0
   fi
fi
