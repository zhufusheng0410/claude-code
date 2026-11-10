#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TACCOUNT_HS_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TACCOUNT_HS_PFD_TMP(
  VC_CODE  STRING  COMMENT  '',
  VC_NAME_HS  STRING  COMMENT  '',
  L_SCLB  DECIMAL(4,0)  COMMENT  '',
  L_ZQLB  DECIMAL(4,0)  COMMENT  '',
  L_ZQLBMX1  DECIMAL(2,0)  COMMENT  '',
  L_ZQLBMX2  DECIMAL(10,0)  COMMENT  '',
  L_ZTBH  DECIMAL(9,0)  COMMENT  '',
  L_MXBZ  DECIMAL(1,0)  COMMENT  '',
  VC_MXFS  STRING  COMMENT  '',
  L_ZDZJ  DECIMAL(1,0)  COMMENT  '',
  VC_CBDYGZ  STRING  COMMENT  '',
  VC_BZW  STRING  COMMENT  '',
  VC_JSBZ  STRING  COMMENT  '',
  C_DYJYRLX  STRING  COMMENT  '',
  L_DKFX  DECIMAL(1,0)  COMMENT  '',
  L_CBBZ  DECIMAL(1,0)  COMMENT  '',
  VC_SJCODE  STRING  COMMENT  '',
  VC_CBDYLX  STRING  COMMENT  '',
  VC_CBDYGL  STRING  COMMENT  '',
  VC_YWMS  STRING  COMMENT  '',
  VC_CBDYZYJ  STRING  COMMENT  '',
  L_QSSD  DECIMAL(2,0)  COMMENT  '',
  L_TZLX  DECIMAL(4,0)  COMMENT  '',
  VC_FZHS  STRING  COMMENT  '',
  VC_CBDYJZZB  STRING  COMMENT  '',
  VC_CPLXBZW  STRING  COMMENT  '',
  VC_JDFX  STRING  COMMENT  '',
  VC_CBDYLXSDS  STRING  COMMENT  '',
  VC_CBDYGZSDS  STRING  COMMENT  '',
  L_CCFL  DECIMAL(4,0)  COMMENT  '',
  VC_SXDM  STRING  COMMENT  ''
)
COMMENT '会计科目属性表'
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
              "querySql": ["SELECT  VC_CODE
                                   , VC_NAME_HS
                                   , L_SCLB
                                   , L_ZQLB
                                   , L_ZQLBMX1
                                   , L_ZQLBMX2
                                   , L_ZTBH
                                   , L_MXBZ
                                   , VC_MXFS
                                   , L_ZDZJ
                                   , VC_CBDYGZ
                                   , VC_BZW
                                   , VC_JSBZ
                                   , C_DYJYRLX
                                   , L_DKFX
                                   , L_CBBZ
                                   , VC_SJCODE
                                   , VC_CBDYLX
                                   , VC_CBDYGL
                                   , VC_YWMS
                                   , VC_CBDYZYJ
                                   , L_QSSD
                                   , L_TZLX
                                   , VC_FZHS
                                   , VC_CBDYJZZB
                                   , VC_CPLXBZW
                                   , VC_JDFX
                                   , VC_CBDYLXSDS
                                   , VC_CBDYGZSDS
                                   , L_CCFL
                                   , VC_SXDM
                                FROM ${hsfa_src_schema}.TACCOUNT_HS"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "VC_CODE", "type": "STRING"}, {"name": "VC_NAME_HS", "type": "STRING"}, {"name": "L_SCLB", "type": "DOUBLE"}, {"name": "L_ZQLB", "type": "DOUBLE"}, {"name": "L_ZQLBMX1", "type": "DOUBLE"}, {"name": "L_ZQLBMX2", "type": "DOUBLE"}, {"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "L_MXBZ", "type": "DOUBLE"}, {"name": "VC_MXFS", "type": "STRING"}, {"name": "L_ZDZJ", "type": "DOUBLE"}, {"name": "VC_CBDYGZ", "type": "STRING"}, {"name": "VC_BZW", "type": "STRING"}, {"name": "VC_JSBZ", "type": "STRING"}, {"name": "C_DYJYRLX", "type": "STRING"}, {"name": "L_DKFX", "type": "DOUBLE"}, {"name": "L_CBBZ", "type": "DOUBLE"}, {"name": "VC_SJCODE", "type": "STRING"}, {"name": "VC_CBDYLX", "type": "STRING"}, {"name": "VC_CBDYGL", "type": "STRING"}, {"name": "VC_YWMS", "type": "STRING"}, {"name": "VC_CBDYZYJ", "type": "STRING"}, {"name": "L_QSSD", "type": "DOUBLE"}, {"name": "L_TZLX", "type": "DOUBLE"}, {"name": "VC_FZHS", "type": "STRING"}, {"name": "VC_CBDYJZZB", "type": "STRING"}, {"name": "VC_CPLXBZW", "type": "STRING"}, {"name": "VC_JDFX", "type": "STRING"}, {"name": "VC_CBDYLXSDS", "type": "STRING"}, {"name": "VC_CBDYGZSDS", "type": "STRING"}, {"name": "L_CCFL", "type": "DOUBLE"}, {"name": "VC_SXDM", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_taccount_hs_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_taccount_hs_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_taccount_hs_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_taccount_hs_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TACCOUNT_HS_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TACCOUNT_HS_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_taccount_hs_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TACCOUNT_HS_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       VC_CODE
     , VC_NAME_HS
     , L_SCLB
     , L_ZQLB
     , L_ZQLBMX1
     , L_ZQLBMX2
     , L_ZTBH
     , L_MXBZ
     , VC_MXFS
     , L_ZDZJ
     , VC_CBDYGZ
     , VC_BZW
     , VC_JSBZ
     , C_DYJYRLX
     , L_DKFX
     , L_CBBZ
     , VC_SJCODE
     , VC_CBDYLX
     , VC_CBDYGL
     , VC_YWMS
     , VC_CBDYZYJ
     , L_QSSD
     , L_TZLX
     , VC_FZHS
     , VC_CBDYJZZB
     , VC_CPLXBZW
     , VC_JDFX
     , VC_CBDYLXSDS
     , VC_CBDYGZSDS
     , L_CCFL
     , VC_SXDM
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TACCOUNT_HS_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TACCOUNT_HS_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TACCOUNT_HS_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TACCOUNT_HS_PFD成功"
      exit 0
   fi
fi
