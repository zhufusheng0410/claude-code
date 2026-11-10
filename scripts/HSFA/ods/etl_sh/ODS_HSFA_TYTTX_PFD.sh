#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TYTTX_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TYTTX_PFD_TMP(
  L_BH  DECIMAL(10,0)  COMMENT  '',
  L_ZTBH  DECIMAL(9,0)  COMMENT  '',
  VC_ZY  STRING  COMMENT  '',
  D_BEGIN  STRING  COMMENT  '',
  D_END  STRING  COMMENT  '',
  EN_JE  DECIMAL(19,4)  COMMENT  '',
  VC_JFKM  STRING  COMMENT  '',
  VC_DFKM  STRING  COMMENT  '',
  L_TS  DECIMAL(4,0)  COMMENT  '',
  L_JTFS  DECIMAL(2,0)  COMMENT  '',
  EN_JTFL  DECIMAL(19,15)  COMMENT  '',
  L_DAY  DECIMAL(4,0)  COMMENT  '',
  VC_JTZQ  STRING  COMMENT  '',
  EN_YJBJJZ  DECIMAL(19,4)  COMMENT  '',
  L_YWLB  DECIMAL(4,0)  COMMENT  '',
  L_MAXFS  DECIMAL(4,0)  COMMENT  '',
  EN_MAX  DECIMAL(19,4)  COMMENT  '',
  L_JZFE_FLAG  DECIMAL(1,0)  COMMENT  '',
  L_YJBCLX  DECIMAL(2,0)  COMMENT  '',
  L_BLMS  DECIMAL(2,0)  COMMENT  '',
  L_GSWJSQD  DECIMAL(2,0)  COMMENT  '',
  L_ZQNM  DECIMAL(8,0)  COMMENT  '',
  L_CLBZ  DECIMAL(1,0)  COMMENT  '',
  D_YWRQ  STRING  COMMENT  '',
  VC_YTKM  STRING  COMMENT  '',
  L_MINFS  DECIMAL(1,0)  COMMENT  '',
  EN_MIN  DECIMAL(19,4)  COMMENT  '',
  L_GZRBH  DECIMAL(10,0)  COMMENT  '',
  L_JSGS  DECIMAL(1,0)  COMMENT  '',
  EN_ZFEBL  DECIMAL(19,4)  COMMENT  '',
  L_GLFJTTJ  DECIMAL(1,0)  COMMENT  '',
  L_TZLX  DECIMAL(1,0)  COMMENT  '',
  L_QSSD  DECIMAL(2,0)  COMMENT  '',
  L_GSWZMS  DECIMAL(4,0)  COMMENT  '',
  L_FLFS  DECIMAL(4,0)  COMMENT  '',
  L_BLTJ  DECIMAL(4,0)  COMMENT  '',
  VC_JJDM  STRING  COMMENT  '',
  VC_EXPRESSION  STRING  COMMENT  '',
  VC_FHR  STRING  COMMENT  '',
  VC_LLR  STRING  COMMENT  '',
  VC_FZPL  STRING  COMMENT  '',
  L_FDGZRBH  DECIMAL(10,0)  COMMENT  '',
  L_YTHWHGLBH  DECIMAL(10,0)  COMMENT  '',
  L_JSFS  DECIMAL(2,0)  COMMENT  '',
  L_DWJZGSID  DECIMAL(6,0)  COMMENT  '',
  D_TQDQR  STRING  COMMENT  '',
  VC_FDPL  STRING  COMMENT  '',
  VC_MZTDFKM  STRING  COMMENT  '',
  VC_MZTJFKM  STRING  COMMENT  '',
  L_JTMS  DECIMAL(1,0)  COMMENT  '',
  L_DQRDJSF  DECIMAL(1,0)  COMMENT  '',
  EN_FDTZGWF  DECIMAL(19,4)  COMMENT  '',
  L_BXJTFS  DECIMAL(1,0)  COMMENT  '',
  D_MODIFY  STRING  COMMENT  '',
  L_SFZGJT  DECIMAL(18,2)  COMMENT  '',
  L_SFJTXNYJBC  DECIMAL(1,0)  COMMENT  '',
  L_RZMS  DECIMAL(1,0)  COMMENT  ''
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
                                   , VC_ZY
                                   , D_BEGIN
                                   , D_END
                                   , EN_JE
                                   , VC_JFKM
                                   , VC_DFKM
                                   , L_TS
                                   , L_JTFS
                                   , EN_JTFL
                                   , L_DAY
                                   , VC_JTZQ
                                   , EN_YJBJJZ
                                   , L_YWLB
                                   , L_MAXFS
                                   , EN_MAX
                                   , L_JZFE_FLAG
                                   , L_YJBCLX
                                   , L_BLMS
                                   , L_GSWJSQD
                                   , L_ZQNM
                                   , L_CLBZ
                                   , D_YWRQ
                                   , VC_YTKM
                                   , L_MINFS
                                   , EN_MIN
                                   , L_GZRBH
                                   , L_JSGS
                                   , EN_ZFEBL
                                   , L_GLFJTTJ
                                   , L_TZLX
                                   , L_QSSD
                                   , L_GSWZMS
                                   , L_FLFS
                                   , L_BLTJ
                                   , VC_JJDM
                                   , VC_EXPRESSION
                                   , VC_FHR
                                   , VC_LLR
                                   , VC_FZPL
                                   , L_FDGZRBH
                                   , L_YTHWHGLBH
                                   , L_JSFS
                                   , L_DWJZGSID
                                   , D_TQDQR
                                   , VC_FDPL
                                   , VC_MZTDFKM
                                   , VC_MZTJFKM
                                   , L_JTMS
                                   , L_DQRDJSF
                                   , EN_FDTZGWF
                                   , L_BXJTFS
                                   , D_MODIFY
                                   , L_SFZGJT
                                   , L_SFJTXNYJBC
                                   , L_RZMS
                                FROM ${hsfa_src_schema}.TYTTX"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_BH", "type": "DOUBLE"}, {"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "VC_ZY", "type": "STRING"}, {"name": "D_BEGIN", "type": "STRING"}, {"name": "D_END", "type": "STRING"}, {"name": "EN_JE", "type": "DOUBLE"}, {"name": "VC_JFKM", "type": "STRING"}, {"name": "VC_DFKM", "type": "STRING"}, {"name": "L_TS", "type": "DOUBLE"}, {"name": "L_JTFS", "type": "DOUBLE"}, {"name": "EN_JTFL", "type": "DOUBLE"}, {"name": "L_DAY", "type": "DOUBLE"}, {"name": "VC_JTZQ", "type": "STRING"}, {"name": "EN_YJBJJZ", "type": "DOUBLE"}, {"name": "L_YWLB", "type": "DOUBLE"}, {"name": "L_MAXFS", "type": "DOUBLE"}, {"name": "EN_MAX", "type": "DOUBLE"}, {"name": "L_JZFE_FLAG", "type": "DOUBLE"}, {"name": "L_YJBCLX", "type": "DOUBLE"}, {"name": "L_BLMS", "type": "DOUBLE"}, {"name": "L_GSWJSQD", "type": "DOUBLE"}, {"name": "L_ZQNM", "type": "DOUBLE"}, {"name": "L_CLBZ", "type": "DOUBLE"}, {"name": "D_YWRQ", "type": "STRING"}, {"name": "VC_YTKM", "type": "STRING"}, {"name": "L_MINFS", "type": "DOUBLE"}, {"name": "EN_MIN", "type": "DOUBLE"}, {"name": "L_GZRBH", "type": "DOUBLE"}, {"name": "L_JSGS", "type": "DOUBLE"}, {"name": "EN_ZFEBL", "type": "DOUBLE"}, {"name": "L_GLFJTTJ", "type": "DOUBLE"}, {"name": "L_TZLX", "type": "DOUBLE"}, {"name": "L_QSSD", "type": "DOUBLE"}, {"name": "L_GSWZMS", "type": "DOUBLE"}, {"name": "L_FLFS", "type": "DOUBLE"}, {"name": "L_BLTJ", "type": "DOUBLE"}, {"name": "VC_JJDM", "type": "STRING"}, {"name": "VC_EXPRESSION", "type": "STRING"}, {"name": "VC_FHR", "type": "STRING"}, {"name": "VC_LLR", "type": "STRING"}, {"name": "VC_FZPL", "type": "STRING"}, {"name": "L_FDGZRBH", "type": "DOUBLE"}, {"name": "L_YTHWHGLBH", "type": "DOUBLE"}, {"name": "L_JSFS", "type": "DOUBLE"}, {"name": "L_DWJZGSID", "type": "DOUBLE"}, {"name": "D_TQDQR", "type": "STRING"}, {"name": "VC_FDPL", "type": "STRING"}, {"name": "VC_MZTDFKM", "type": "STRING"}, {"name": "VC_MZTJFKM", "type": "STRING"}, {"name": "L_JTMS", "type": "DOUBLE"}, {"name": "L_DQRDJSF", "type": "DOUBLE"}, {"name": "EN_FDTZGWF", "type": "DOUBLE"}, {"name": "L_BXJTFS", "type": "DOUBLE"}, {"name": "D_MODIFY", "type": "STRING"}, {"name": "L_SFZGJT", "type": "DOUBLE"}, {"name": "L_SFJTXNYJBC", "type": "DOUBLE"}, {"name": "L_RZMS", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tyttx_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tyttx_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tyttx_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tyttx_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TYTTX_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TYTTX_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tyttx_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TYTTX_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_BH
     , L_ZTBH
     , VC_ZY
     , D_BEGIN
     , D_END
     , EN_JE
     , VC_JFKM
     , VC_DFKM
     , L_TS
     , L_JTFS
     , EN_JTFL
     , L_DAY
     , VC_JTZQ
     , EN_YJBJJZ
     , L_YWLB
     , L_MAXFS
     , EN_MAX
     , L_JZFE_FLAG
     , L_YJBCLX
     , L_BLMS
     , L_GSWJSQD
     , L_ZQNM
     , L_CLBZ
     , D_YWRQ
     , VC_YTKM
     , L_MINFS
     , EN_MIN
     , L_GZRBH
     , L_JSGS
     , EN_ZFEBL
     , L_GLFJTTJ
     , L_TZLX
     , L_QSSD
     , L_GSWZMS
     , L_FLFS
     , L_BLTJ
     , VC_JJDM
     , VC_EXPRESSION
     , VC_FHR
     , VC_LLR
     , VC_FZPL
     , L_FDGZRBH
     , L_YTHWHGLBH
     , L_JSFS
     , L_DWJZGSID
     , D_TQDQR
     , VC_FDPL
     , VC_MZTDFKM
     , VC_MZTJFKM
     , L_JTMS
     , L_DQRDJSF
     , EN_FDTZGWF
     , L_BXJTFS
     , D_MODIFY
     , L_SFZGJT
     , L_SFJTXNYJBC
     , L_RZMS
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TYTTX_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TYTTX_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TYTTX_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TYTTX_PFD成功"
      exit 0
   fi
fi
