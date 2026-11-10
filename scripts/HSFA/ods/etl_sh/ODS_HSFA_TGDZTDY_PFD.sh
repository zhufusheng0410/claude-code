#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TGDZTDY_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TGDZTDY_PFD_TMP(
  VC_GDDM  STRING  COMMENT  '股东代码',
  L_SCLB  DECIMAL(4,0)  COMMENT  '市场类别',
  L_ZTBH  STRING  COMMENT  '账套编号',
  VC_GDMC  STRING  COMMENT  '股东名称',
  C_STOCKHOLDER_STATUS  STRING  COMMENT  '',
  VC_BIND_SEAT  STRING  COMMENT  '对场外和QDII',
  L_TZLX  STRING  COMMENT  '投资类型',
  VC_QSBH  STRING  COMMENT  '券商编号',
  VC_FUNDCODE  STRING  COMMENT  '基金代码',
  C_SYNCHRO_FLAG  STRING  COMMENT  '同步标志',
  D_SYNCHRO_TIME  STRING  COMMENT  '同步时间',
  C_XWLX  STRING  COMMENT  '席位类型',
  L_JGHF  DECIMAL(1,0)  COMMENT  '减过户费',
  VC_ZJZH  STRING  COMMENT  '资金账号',
  L_TQBZ  DECIMAL(4,0)  COMMENT  '套期保值',
  L_JSJG  DECIMAL(1,0)  COMMENT  '',
  VC_JYHY  STRING  COMMENT  '',
  L_XYZH  DECIMAL(1,0)  COMMENT  '',
  L_JCHJZF  DECIMAL(1,0)  COMMENT  '',
  L_YJJSXF  DECIMAL(1,0)  COMMENT  '',
  L_YJJJSF  DECIMAL(1,0)  COMMENT  '',
  L_YJJZGF  DECIMAL(1,0)  COMMENT  ''
)
COMMENT '股东设置'
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
              "querySql": ["SELECT  VC_GDDM
                                   , L_SCLB
                                   , L_ZTBH
                                   , VC_GDMC
                                   , C_STOCKHOLDER_STATUS
                                   , VC_BIND_SEAT
                                   , L_TZLX
                                   , VC_QSBH
                                   , VC_FUNDCODE
                                   , C_SYNCHRO_FLAG
                                   , D_SYNCHRO_TIME
                                   , C_XWLX
                                   , L_JGHF
                                   , VC_ZJZH
                                   , L_TQBZ
                                   , L_JSJG
                                   , VC_JYHY
                                   , L_XYZH
                                   , L_JCHJZF
                                   , L_YJJSXF
                                   , L_YJJJSF
                                   , L_YJJZGF
                                FROM ${hsfa_src_schema}.TGDZTDY"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "VC_GDDM", "type": "STRING"}, {"name": "L_SCLB", "type": "DOUBLE"}, {"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "VC_GDMC", "type": "STRING"}, {"name": "C_STOCKHOLDER_STATUS", "type": "STRING"}, {"name": "VC_BIND_SEAT", "type": "STRING"}, {"name": "L_TZLX", "type": "DOUBLE"}, {"name": "VC_QSBH", "type": "STRING"}, {"name": "VC_FUNDCODE", "type": "STRING"}, {"name": "C_SYNCHRO_FLAG", "type": "STRING"}, {"name": "D_SYNCHRO_TIME", "type": "STRING"}, {"name": "C_XWLX", "type": "STRING"}, {"name": "L_JGHF", "type": "DOUBLE"}, {"name": "VC_ZJZH", "type": "STRING"}, {"name": "L_TQBZ", "type": "DOUBLE"}, {"name": "L_JSJG", "type": "DOUBLE"}, {"name": "VC_JYHY", "type": "STRING"}, {"name": "L_XYZH", "type": "DOUBLE"}, {"name": "L_JCHJZF", "type": "DOUBLE"}, {"name": "L_YJJSXF", "type": "DOUBLE"}, {"name": "L_YJJJSF", "type": "DOUBLE"}, {"name": "L_YJJZGF", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tgdztdy_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tgdztdy_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tgdztdy_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tgdztdy_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TGDZTDY_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TGDZTDY_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tgdztdy_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TGDZTDY_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       VC_GDDM
     , L_SCLB
     , L_ZTBH
     , VC_GDMC
     , C_STOCKHOLDER_STATUS
     , VC_BIND_SEAT
     , L_TZLX
     , VC_QSBH
     , VC_FUNDCODE
     , C_SYNCHRO_FLAG
     , D_SYNCHRO_TIME
     , C_XWLX
     , L_JGHF
     , VC_ZJZH
     , L_TQBZ
     , L_JSJG
     , VC_JYHY
     , L_XYZH
     , L_JCHJZF
     , L_YJJSXF
     , L_YJJJSF
     , L_YJJZGF
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TGDZTDY_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TGDZTDY_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TGDZTDY_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TGDZTDY_PFD成功"
      exit 0
   fi
fi
