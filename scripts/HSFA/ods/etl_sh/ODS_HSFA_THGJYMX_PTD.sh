#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_THGJYMX_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_THGJYMX_PTD_TMP(
  L_BH  DECIMAL(8,0)  COMMENT  '',
  L_ZTBH  DECIMAL(9,0)  COMMENT  '',
  L_ZQNM  DECIMAL(8,0)  COMMENT  '',
  VC_GDDM  STRING  COMMENT  '',
  VC_XWDM  STRING  COMMENT  '',
  VC_ZQDM  STRING  COMMENT  '',
  D_CJRQ  STRING  COMMENT  '',
  D_JGRI  STRING  COMMENT  '',
  L_HGSL  DECIMAL(19,4)  COMMENT  '',
  EN_HGJG  DECIMAL(20,10)  COMMENT  '',
  EN_HGJE  DECIMAL(20,4)  COMMENT  '',
  EN_HGFY  DECIMAL(19,4)  COMMENT  '',
  EN_HGLX  DECIMAL(19,4)  COMMENT  '',
  L_YJXTS  DECIMAL(4,0)  COMMENT  '',
  L_YWLB  DECIMAL(4,0)  COMMENT  '',
  L_SCLB  DECIMAL(4,0)  COMMENT  '',
  EN_FKJE  DECIMAL(20,4)  COMMENT  '',
  EN_JSSXF  DECIMAL(19,4)  COMMENT  '',
  VC_FLBH  STRING  COMMENT  '',
  L_QSSD  DECIMAL(2,0)  COMMENT  '',
  VC_BFZH  STRING  COMMENT  '',
  VC_DQBFZH  STRING  COMMENT  '',
  EN_NLL  DECIMAL(14,8)  COMMENT  '',
  EN_YJ  DECIMAL(19,4)  COMMENT  '',
  L_DZJYBZ  DECIMAL(1,0)  COMMENT  '',
  VC_SQBH  STRING  COMMENT  '',
  VC_JYDS  STRING  COMMENT  '',
  L_GLBH  DECIMAL(8,0)  COMMENT  ''
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
                                   , L_ZQNM
                                   , VC_GDDM
                                   , VC_XWDM
                                   , VC_ZQDM
                                   , TO_CHAR(D_CJRQ,'YYYYMMDD') D_CJRQ
                                   , D_JGRI
                                   , L_HGSL
                                   , EN_HGJG
                                   , EN_HGJE
                                   , EN_HGFY
                                   , EN_HGLX
                                   , L_YJXTS
                                   , L_YWLB
                                   , L_SCLB
                                   , EN_FKJE
                                   , EN_JSSXF
                                   , VC_FLBH
                                   , L_QSSD
                                   , VC_BFZH
                                   , VC_DQBFZH
                                   , EN_NLL
                                   , EN_YJ
                                   , L_DZJYBZ
                                   , VC_SQBH
                                   , VC_JYDS
                                   , L_GLBH
                                FROM ${hsfa_src_schema}.THGJYMX
                                WHERE D_CJRQ between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_BH", "type": "DOUBLE"}, {"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "L_ZQNM", "type": "DOUBLE"}, {"name": "VC_GDDM", "type": "STRING"}, {"name": "VC_XWDM", "type": "STRING"}, {"name": "VC_ZQDM", "type": "STRING"}, {"name": "D_CJRQ", "type": "STRING"}, {"name": "D_JGRI", "type": "STRING"}, {"name": "L_HGSL", "type": "DOUBLE"}, {"name": "EN_HGJG", "type": "DOUBLE"}, {"name": "EN_HGJE", "type": "DOUBLE"}, {"name": "EN_HGFY", "type": "DOUBLE"}, {"name": "EN_HGLX", "type": "DOUBLE"}, {"name": "L_YJXTS", "type": "DOUBLE"}, {"name": "L_YWLB", "type": "DOUBLE"}, {"name": "L_SCLB", "type": "DOUBLE"}, {"name": "EN_FKJE", "type": "DOUBLE"}, {"name": "EN_JSSXF", "type": "DOUBLE"}, {"name": "VC_FLBH", "type": "STRING"}, {"name": "L_QSSD", "type": "DOUBLE"}, {"name": "VC_BFZH", "type": "STRING"}, {"name": "VC_DQBFZH", "type": "STRING"}, {"name": "EN_NLL", "type": "DOUBLE"}, {"name": "EN_YJ", "type": "DOUBLE"}, {"name": "L_DZJYBZ", "type": "DOUBLE"}, {"name": "VC_SQBH", "type": "STRING"}, {"name": "VC_JYDS", "type": "STRING"}, {"name": "L_GLBH", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_thgjymx_ptd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_thgjymx_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_thgjymx_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_thgjymx_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_THGJYMX_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_THGJYMX_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_thgjymx_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_THGJYMX_PTD PARTITION(P_DT)
SELECT
       L_BH
     , L_ZTBH
     , L_ZQNM
     , VC_GDDM
     , VC_XWDM
     , VC_ZQDM
     , D_CJRQ
     , D_JGRI
     , L_HGSL
     , EN_HGJG
     , EN_HGJE
     , EN_HGFY
     , EN_HGLX
     , L_YJXTS
     , L_YWLB
     , L_SCLB
     , EN_FKJE
     , EN_JSSXF
     , VC_FLBH
     , L_QSSD
     , VC_BFZH
     , VC_DQBFZH
     , EN_NLL
     , EN_YJ
     , L_DZJYBZ
     , VC_SQBH
     , VC_JYDS
     , L_GLBH
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_CJRQ,'-','') P_DT
  FROM ODS_XDAY_HSFA.ODS_HSFA_THGJYMX_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_THGJYMX_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_THGJYMX_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_THGJYMX_PTD成功"
      exit 0
   fi
fi
