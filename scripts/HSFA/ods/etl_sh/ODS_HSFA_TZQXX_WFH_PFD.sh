#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TZQXX_WFH_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TZQXX_WFH_PFD_TMP(
  L_ZQNM  DECIMAL(8,0)  COMMENT  '',
  VC_ZQDM  STRING  COMMENT  '',
  L_ZQLB  DECIMAL(4,0)  COMMENT  '',
  L_ZQLBMX1  DECIMAL(4,0)  COMMENT  '',
  L_ZQLBMX2  DECIMAL(4,0)  COMMENT  '',
  L_SCLB  DECIMAL(4,0)  COMMENT  '',
  VC_ZQJC  STRING  COMMENT  '',
  VC_YWJC  STRING  COMMENT  '',
  VC_SSHY  STRING  COMMENT  '',
  VC_JSBZ  STRING  COMMENT  '',
  L_ZGB  DECIMAL(19,2)  COMMENT  '',
  L_LTGS  DECIMAL(19,2)  COMMENT  '',
  EN_MGMZ  DECIMAL(23,8)  COMMENT  '',
  D_FXRQ  STRING  COMMENT  '',
  D_DQRQ  STRING  COMMENT  '',
  C_ZQZT  STRING  COMMENT  '',
  L_HGTS  DECIMAL(4,0)  COMMENT  '',
  L_NJXTS  DECIMAL(4,0)  COMMENT  '',
  EN_NLL  DECIMAL(14,8)  COMMENT  '',
  D_QXR  STRING  COMMENT  '',
  L_FXFS  DECIMAL(4,0)  COMMENT  '',
  D_MODIFY  STRING  COMMENT  '',
  D_CHECK  STRING  COMMENT  '',
  VC_CHECKER  STRING  COMMENT  '',
  VC_MAKER  STRING  COMMENT  '',
  L_JXFS  STRING  COMMENT  '',
  EN_FXJG  DECIMAL(14,8)  COMMENT  '',
  VC_ZQQC  STRING  COMMENT  '',
  VC_SEDOL  STRING  COMMENT  '',
  VC_ISIN  STRING  COMMENT  '',
  VC_TICKER  STRING  COMMENT  '',
  VC_JYRLX  STRING  COMMENT  '',
  EN_HYCS  DECIMAL(12,4)  COMMENT  '',
  EN_BZJL  DECIMAL(14,8)  COMMENT  '',
  L_CTPZ  DECIMAL(4,0)  COMMENT  '',
  L_HYYF  DECIMAL(4,0)  COMMENT  '',
  D_JGRQ  STRING  COMMENT  '',
  L_JGFS  DECIMAL(4,0)  COMMENT  '',
  L_HYZT  DECIMAL(4,0)  COMMENT  '',
  VC_MBBZ  STRING  COMMENT  '',
  VC_BZ  STRING  COMMENT  '',
  C_QJJJ  STRING  COMMENT  '',
  L_LXJSFF  DECIMAL(2,0)  COMMENT  '',
  L_DLFL  DECIMAL(1,0)  COMMENT  '',
  EN_LXSL  DECIMAL(11,6)  COMMENT  '',
  VC_BKDM  STRING  COMMENT  '',
  D_XGZF  STRING  COMMENT  '',
  VC_TRADEZQDM  STRING  COMMENT  '',
  L_DBBZ  DECIMAL(1,0)  COMMENT  '',
  C_SYNCHRO_FLAG  STRING  COMMENT  '',
  D_SYNCHRO_TIME  STRING  COMMENT  '',
  D_ZGQKS  STRING  COMMENT  '',
  D_ZGQJS  STRING  COMMENT  '',
  VC_HQBZ  STRING  COMMENT  '',
  L_DQFXFS  DECIMAL(4,0)  COMMENT  '',
  L_XGBZ  DECIMAL(4,0)  COMMENT  '',
  L_YMFXBZ  DECIMAL(1,0)  COMMENT  '',
  D_QYSXR  STRING  COMMENT  '',
  L_ZQLBMX3  DECIMAL(4,0)  COMMENT  '',
  L_JSJG  DECIMAL(1,0)  COMMENT  '',
  D_SCFXR  STRING  COMMENT  '',
  VC_HBD  STRING  COMMENT  '',
  L_ZBFS  DECIMAL(4,0)  COMMENT  '',
  L_HBFS  DECIMAL(1,0)  COMMENT  '',
  L_GLZQNM  DECIMAL(8,0)  COMMENT  '',
  VC_GJISIN  STRING  COMMENT  '',
  L_SYLB  DECIMAL(4,0)  COMMENT  '',
  VC_FXJG  STRING  COMMENT  '',
  L_FJTK  DECIMAL(1,0)  COMMENT  '',
  L_SYLX  DECIMAL(4,0)  COMMENT  '',
  VC_TGR  STRING  COMMENT  '',
  VC_GLR  STRING  COMMENT  '',
  L_SFBA  DECIMAL(1,0)  COMMENT  '',
  VC_SSHY_GICS  STRING  COMMENT  '',
  VC_SSHY_BICS  STRING  COMMENT  '',
  VC_ZWMC  STRING  COMMENT  '',
  L_0229SFJX  DECIMAL(1,0)  COMMENT  '',
  VC_YWQC  STRING  COMMENT  '',
  L_SFJRJG  DECIMAL(1,0)  COMMENT  '',
  D_TQDFR  STRING  COMMENT  '',
  D_SSRQ  STRING  COMMENT  '',
  L_FDCXTPZ  DECIMAL(1,0)  COMMENT  '',
  VC_SFWYL  STRING  COMMENT  '',
  VC_SFCZTPQCY  STRING  COMMENT  '',
  VC_SFZCZ  STRING  COMMENT  '',
  VC_SFJYXYKZJG  STRING  COMMENT  '',
  L_SFSSDK  DECIMAL(1,0)  COMMENT  '',
  L_SFYXZ  DECIMAL(1,0)  COMMENT  '',
  L_JRGJFL  DECIMAL(1,0)  COMMENT  '',
  L_LCCPMXFL  DECIMAL(1,0)  COMMENT  '',
  L_SFSSLT  DECIMAL(1,0)  COMMENT  '',
  VC_GLR_YW  STRING  COMMENT  '',
  VC_TGR_YW  STRING  COMMENT  '',
  L_ZXMMDW  DECIMAL(9,0)  COMMENT  '',
  C_O_QJJJ  STRING  COMMENT  '',
  VC_YWMC  STRING  COMMENT  '',
  L_YZFS  DECIMAL(1,0)  COMMENT  ''
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
              "querySql": ["SELECT  L_ZQNM
                                   , VC_ZQDM
                                   , L_ZQLB
                                   , L_ZQLBMX1
                                   , L_ZQLBMX2
                                   , L_SCLB
                                   , VC_ZQJC
                                   , VC_YWJC
                                   , VC_SSHY
                                   , VC_JSBZ
                                   , L_ZGB
                                   , L_LTGS
                                   , EN_MGMZ
                                   , D_FXRQ
                                   , D_DQRQ
                                   , C_ZQZT
                                   , L_HGTS
                                   , L_NJXTS
                                   , EN_NLL
                                   , D_QXR
                                   , L_FXFS
                                   , D_MODIFY
                                   , D_CHECK
                                   , VC_CHECKER
                                   , VC_MAKER
                                   , L_JXFS
                                   , EN_FXJG
                                   , VC_ZQQC
                                   , VC_SEDOL
                                   , VC_ISIN
                                   , VC_TICKER
                                   , VC_JYRLX
                                   , EN_HYCS
                                   , EN_BZJL
                                   , L_CTPZ
                                   , L_HYYF
                                   , D_JGRQ
                                   , L_JGFS
                                   , L_HYZT
                                   , VC_MBBZ
                                   , VC_BZ
                                   , C_QJJJ
                                   , L_LXJSFF
                                   , L_DLFL
                                   , EN_LXSL
                                   , VC_BKDM
                                   , D_XGZF
                                   , VC_TRADEZQDM
                                   , L_DBBZ
                                   , C_SYNCHRO_FLAG
                                   , D_SYNCHRO_TIME
                                   , D_ZGQKS
                                   , D_ZGQJS
                                   , VC_HQBZ
                                   , L_DQFXFS
                                   , L_XGBZ
                                   , L_YMFXBZ
                                   , D_QYSXR
                                   , L_ZQLBMX3
                                   , L_JSJG
                                   , D_SCFXR
                                   , VC_HBD
                                   , L_ZBFS
                                   , L_HBFS
                                   , L_GLZQNM
                                   , VC_GJISIN
                                   , L_SYLB
                                   , VC_FXJG
                                   , L_FJTK
                                   , L_SYLX
                                   , VC_TGR
                                   , VC_GLR
                                   , L_SFBA
                                   , VC_SSHY_GICS
                                   , VC_SSHY_BICS
                                   , VC_ZWMC
                                   , L_0229SFJX
                                   , VC_YWQC
                                   , L_SFJRJG
                                   , D_TQDFR
                                   , D_SSRQ
                                   , L_FDCXTPZ
                                   , VC_SFWYL
                                   , VC_SFCZTPQCY
                                   , VC_SFZCZ
                                   , VC_SFJYXYKZJG
                                   , L_SFSSDK
                                   , L_SFYXZ
                                   , L_JRGJFL
                                   , L_LCCPMXFL
                                   , L_SFSSLT
                                   , VC_GLR_YW
                                   , VC_TGR_YW
                                   , L_ZXMMDW
                                   , C_O_QJJJ
                                   , VC_YWMC
                                   , L_YZFS
                                FROM ${hsfa_src_schema}.TZQXX_WFH"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ZQNM", "type": "DOUBLE"}, {"name": "VC_ZQDM", "type": "STRING"}, {"name": "L_ZQLB", "type": "DOUBLE"}, {"name": "L_ZQLBMX1", "type": "DOUBLE"}, {"name": "L_ZQLBMX2", "type": "DOUBLE"}, {"name": "L_SCLB", "type": "DOUBLE"}, {"name": "VC_ZQJC", "type": "STRING"}, {"name": "VC_YWJC", "type": "STRING"}, {"name": "VC_SSHY", "type": "STRING"}, {"name": "VC_JSBZ", "type": "STRING"}, {"name": "L_ZGB", "type": "DOUBLE"}, {"name": "L_LTGS", "type": "DOUBLE"}, {"name": "EN_MGMZ", "type": "DOUBLE"}, {"name": "D_FXRQ", "type": "STRING"}, {"name": "D_DQRQ", "type": "STRING"}, {"name": "C_ZQZT", "type": "STRING"}, {"name": "L_HGTS", "type": "DOUBLE"}, {"name": "L_NJXTS", "type": "DOUBLE"}, {"name": "EN_NLL", "type": "DOUBLE"}, {"name": "D_QXR", "type": "STRING"}, {"name": "L_FXFS", "type": "DOUBLE"}, {"name": "D_MODIFY", "type": "STRING"}, {"name": "D_CHECK", "type": "STRING"}, {"name": "VC_CHECKER", "type": "STRING"}, {"name": "VC_MAKER", "type": "STRING"}, {"name": "L_JXFS", "type": "STRING"}, {"name": "EN_FXJG", "type": "DOUBLE"}, {"name": "VC_ZQQC", "type": "STRING"}, {"name": "VC_SEDOL", "type": "STRING"}, {"name": "VC_ISIN", "type": "STRING"}, {"name": "VC_TICKER", "type": "STRING"}, {"name": "VC_JYRLX", "type": "STRING"}, {"name": "EN_HYCS", "type": "DOUBLE"}, {"name": "EN_BZJL", "type": "DOUBLE"}, {"name": "L_CTPZ", "type": "DOUBLE"}, {"name": "L_HYYF", "type": "DOUBLE"}, {"name": "D_JGRQ", "type": "STRING"}, {"name": "L_JGFS", "type": "DOUBLE"}, {"name": "L_HYZT", "type": "DOUBLE"}, {"name": "VC_MBBZ", "type": "STRING"}, {"name": "VC_BZ", "type": "STRING"}, {"name": "C_QJJJ", "type": "STRING"}, {"name": "L_LXJSFF", "type": "DOUBLE"}, {"name": "L_DLFL", "type": "DOUBLE"}, {"name": "EN_LXSL", "type": "DOUBLE"}, {"name": "VC_BKDM", "type": "STRING"}, {"name": "D_XGZF", "type": "STRING"}, {"name": "VC_TRADEZQDM", "type": "STRING"}, {"name": "L_DBBZ", "type": "DOUBLE"}, {"name": "C_SYNCHRO_FLAG", "type": "STRING"}, {"name": "D_SYNCHRO_TIME", "type": "STRING"}, {"name": "D_ZGQKS", "type": "STRING"}, {"name": "D_ZGQJS", "type": "STRING"}, {"name": "VC_HQBZ", "type": "STRING"}, {"name": "L_DQFXFS", "type": "DOUBLE"}, {"name": "L_XGBZ", "type": "DOUBLE"}, {"name": "L_YMFXBZ", "type": "DOUBLE"}, {"name": "D_QYSXR", "type": "STRING"}, {"name": "L_ZQLBMX3", "type": "DOUBLE"}, {"name": "L_JSJG", "type": "DOUBLE"}, {"name": "D_SCFXR", "type": "STRING"}, {"name": "VC_HBD", "type": "STRING"}, {"name": "L_ZBFS", "type": "DOUBLE"}, {"name": "L_HBFS", "type": "DOUBLE"}, {"name": "L_GLZQNM", "type": "DOUBLE"}, {"name": "VC_GJISIN", "type": "STRING"}, {"name": "L_SYLB", "type": "DOUBLE"}, {"name": "VC_FXJG", "type": "STRING"}, {"name": "L_FJTK", "type": "DOUBLE"}, {"name": "L_SYLX", "type": "DOUBLE"}, {"name": "VC_TGR", "type": "STRING"}, {"name": "VC_GLR", "type": "STRING"}, {"name": "L_SFBA", "type": "DOUBLE"}, {"name": "VC_SSHY_GICS", "type": "STRING"}, {"name": "VC_SSHY_BICS", "type": "STRING"}, {"name": "VC_ZWMC", "type": "STRING"}, {"name": "L_0229SFJX", "type": "DOUBLE"}, {"name": "VC_YWQC", "type": "STRING"}, {"name": "L_SFJRJG", "type": "DOUBLE"}, {"name": "D_TQDFR", "type": "STRING"}, {"name": "D_SSRQ", "type": "STRING"}, {"name": "L_FDCXTPZ", "type": "DOUBLE"}, {"name": "VC_SFWYL", "type": "STRING"}, {"name": "VC_SFCZTPQCY", "type": "STRING"}, {"name": "VC_SFZCZ", "type": "STRING"}, {"name": "VC_SFJYXYKZJG", "type": "STRING"}, {"name": "L_SFSSDK", "type": "DOUBLE"}, {"name": "L_SFYXZ", "type": "DOUBLE"}, {"name": "L_JRGJFL", "type": "DOUBLE"}, {"name": "L_LCCPMXFL", "type": "DOUBLE"}, {"name": "L_SFSSLT", "type": "DOUBLE"}, {"name": "VC_GLR_YW", "type": "STRING"}, {"name": "VC_TGR_YW", "type": "STRING"}, {"name": "L_ZXMMDW", "type": "DOUBLE"}, {"name": "C_O_QJJJ", "type": "STRING"}, {"name": "VC_YWMC", "type": "STRING"}, {"name": "L_YZFS", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tzqxx_wfh_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tzqxx_wfh_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tzqxx_wfh_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tzqxx_wfh_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TZQXX_WFH_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TZQXX_WFH_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tzqxx_wfh_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TZQXX_WFH_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_ZQNM
     , VC_ZQDM
     , L_ZQLB
     , L_ZQLBMX1
     , L_ZQLBMX2
     , L_SCLB
     , VC_ZQJC
     , VC_YWJC
     , VC_SSHY
     , VC_JSBZ
     , L_ZGB
     , L_LTGS
     , EN_MGMZ
     , D_FXRQ
     , D_DQRQ
     , C_ZQZT
     , L_HGTS
     , L_NJXTS
     , EN_NLL
     , D_QXR
     , L_FXFS
     , D_MODIFY
     , D_CHECK
     , VC_CHECKER
     , VC_MAKER
     , L_JXFS
     , EN_FXJG
     , VC_ZQQC
     , VC_SEDOL
     , VC_ISIN
     , VC_TICKER
     , VC_JYRLX
     , EN_HYCS
     , EN_BZJL
     , L_CTPZ
     , L_HYYF
     , D_JGRQ
     , L_JGFS
     , L_HYZT
     , VC_MBBZ
     , VC_BZ
     , C_QJJJ
     , L_LXJSFF
     , L_DLFL
     , EN_LXSL
     , VC_BKDM
     , D_XGZF
     , VC_TRADEZQDM
     , L_DBBZ
     , C_SYNCHRO_FLAG
     , D_SYNCHRO_TIME
     , D_ZGQKS
     , D_ZGQJS
     , VC_HQBZ
     , L_DQFXFS
     , L_XGBZ
     , L_YMFXBZ
     , D_QYSXR
     , L_ZQLBMX3
     , L_JSJG
     , D_SCFXR
     , VC_HBD
     , L_ZBFS
     , L_HBFS
     , L_GLZQNM
     , VC_GJISIN
     , L_SYLB
     , VC_FXJG
     , L_FJTK
     , L_SYLX
     , VC_TGR
     , VC_GLR
     , L_SFBA
     , VC_SSHY_GICS
     , VC_SSHY_BICS
     , VC_ZWMC
     , L_0229SFJX
     , VC_YWQC
     , L_SFJRJG
     , D_TQDFR
     , D_SSRQ
     , L_FDCXTPZ
     , VC_SFWYL
     , VC_SFCZTPQCY
     , VC_SFZCZ
     , VC_SFJYXYKZJG
     , L_SFSSDK
     , L_SFYXZ
     , L_JRGJFL
     , L_LCCPMXFL
     , L_SFSSLT
     , VC_GLR_YW
     , VC_TGR_YW
     , L_ZXMMDW
     , C_O_QJJJ
     , VC_YWMC
     , L_YZFS
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TZQXX_WFH_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TZQXX_WFH_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TZQXX_WFH_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TZQXX_WFH_PFD成功"
      exit 0
   fi
fi
