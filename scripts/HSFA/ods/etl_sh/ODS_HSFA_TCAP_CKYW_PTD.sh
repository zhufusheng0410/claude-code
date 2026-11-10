#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYW_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYW_PTD_TMP(
  L_ZTBH  STRING  COMMENT  '账套编号',
  L_CKID  DECIMAL(20,0)  COMMENT  '存款序号',
  L_YWLB  DECIMAL(4,0)  COMMENT  '业务类别',
  D_SDATE  STRING  COMMENT  '开始日期',
  D_EDATE  STRING  COMMENT  '结束日期',
  VC_JYDS  STRING  COMMENT  '交易对手',
  VC_ZQDM  STRING  COMMENT  '账号',
  VC_ZQMC  STRING  COMMENT  '账户名称',
  VC_JSBZ  STRING  COMMENT  '结算币种',
  VC_BJKM  STRING  COMMENT  '本金科目',
  VC_LXKM  STRING  COMMENT  '利息科目',
  VC_LXSRKM  STRING  COMMENT  '利息收入科目',
  L_CLBZ  STRING  COMMENT  '处理标志',
  VC_BZ  STRING  COMMENT  '备注',
  L_NJXTS  DECIMAL(4,0)  COMMENT  '年计息天数',
  L_JXFS  DECIMAL(4,0)  COMMENT  '计息方式',
  C_FXFS  STRING  COMMENT  '结息方式',
  D_XFXR  STRING  COMMENT  '首次结息日',
  VC_BJDYKM  STRING  COMMENT  '本金对应科目',
  VC_ZHBH  STRING  COMMENT  '',
  VC_CKBH  STRING  COMMENT  '',
  EN_ZLX  DECIMAL(19,4)  COMMENT  '',
  L_LLLB  DECIMAL(3,0)  COMMENT  '',
  EN_JBLC  DECIMAL(10,8)  COMMENT  '',
  EN_FDBL  DECIMAL(10,8)  COMMENT  '',
  VC_JZLL  STRING  COMMENT  '',
  L_CYQX  DECIMAL(4,0)  COMMENT  '',
  L_O32_QRBH  DECIMAL(10,0)  COMMENT  '',
  L_O32_CDQRXH  DECIMAL(4,0)  COMMENT  '',
  L_SFKTQZQ  DECIMAL(1,0)  COMMENT  '',
  L_TQZQSSLX  DECIMAL(1,0)  COMMENT  '',
  L_YJXTS  DECIMAL(1,0)  COMMENT  '',
  VC_CDH  STRING  COMMENT  '',
  VC_JZQRKM1  STRING  COMMENT  '',
  VC_JZQRKM2  STRING  COMMENT  '',
  VC_JZQRKM3  STRING  COMMENT  '',
  VC_JZSSKM1  STRING  COMMENT  '',
  VC_JZSSKM2  STRING  COMMENT  '',
  VC_JZSSKM3  STRING  COMMENT  '',
  L_HCXTCKID  DECIMAL(12,0)  COMMENT  '',
  D_TQZQKSRQ  STRING  COMMENT  '',
  VC_JGDM  STRING  COMMENT  '',
  VC_SJLY  STRING  COMMENT  ''
)
COMMENT '存款业务主表'
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
              "querySql": ["SELECT  L_ZTBH
                                   , L_CKID
                                   , L_YWLB
                                   , TO_CHAR(D_SDATE,'YYYYMMDD') D_SDATE
                                   , D_EDATE
                                   , VC_JYDS
                                   , VC_ZQDM
                                   , VC_ZQMC
                                   , VC_JSBZ
                                   , VC_BJKM
                                   , VC_LXKM
                                   , VC_LXSRKM
                                   , L_CLBZ
                                   , VC_BZ
                                   , L_NJXTS
                                   , L_JXFS
                                   , C_FXFS
                                   , D_XFXR
                                   , VC_BJDYKM
                                   , VC_ZHBH
                                   , VC_CKBH
                                   , EN_ZLX
                                   , L_LLLB
                                   , EN_JBLC
                                   , EN_FDBL
                                   , VC_JZLL
                                   , L_CYQX
                                   , L_O32_QRBH
                                   , L_O32_CDQRXH
                                   , L_SFKTQZQ
                                   , L_TQZQSSLX
                                   , L_YJXTS
                                   , VC_CDH
                                   , VC_JZQRKM1
                                   , VC_JZQRKM2
                                   , VC_JZQRKM3
                                   , VC_JZSSKM1
                                   , VC_JZSSKM2
                                   , VC_JZSSKM3
                                   , L_HCXTCKID
                                   , D_TQZQKSRQ
                                   , VC_JGDM
                                   , VC_SJLY
                                FROM ${hsfa_src_schema}.TCAP_CKYW
                                WHERE D_SDATE between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "L_CKID", "type": "DOUBLE"}, {"name": "L_YWLB", "type": "DOUBLE"}, {"name": "D_SDATE", "type": "STRING"}, {"name": "D_EDATE", "type": "STRING"}, {"name": "VC_JYDS", "type": "STRING"}, {"name": "VC_ZQDM", "type": "STRING"}, {"name": "VC_ZQMC", "type": "STRING"}, {"name": "VC_JSBZ", "type": "STRING"}, {"name": "VC_BJKM", "type": "STRING"}, {"name": "VC_LXKM", "type": "STRING"}, {"name": "VC_LXSRKM", "type": "STRING"}, {"name": "L_CLBZ", "type": "DOUBLE"}, {"name": "VC_BZ", "type": "STRING"}, {"name": "L_NJXTS", "type": "DOUBLE"}, {"name": "L_JXFS", "type": "DOUBLE"}, {"name": "C_FXFS", "type": "STRING"}, {"name": "D_XFXR", "type": "STRING"}, {"name": "VC_BJDYKM", "type": "STRING"}, {"name": "VC_ZHBH", "type": "STRING"}, {"name": "VC_CKBH", "type": "STRING"}, {"name": "EN_ZLX", "type": "DOUBLE"}, {"name": "L_LLLB", "type": "DOUBLE"}, {"name": "EN_JBLC", "type": "DOUBLE"}, {"name": "EN_FDBL", "type": "DOUBLE"}, {"name": "VC_JZLL", "type": "STRING"}, {"name": "L_CYQX", "type": "DOUBLE"}, {"name": "L_O32_QRBH", "type": "DOUBLE"}, {"name": "L_O32_CDQRXH", "type": "DOUBLE"}, {"name": "L_SFKTQZQ", "type": "DOUBLE"}, {"name": "L_TQZQSSLX", "type": "DOUBLE"}, {"name": "L_YJXTS", "type": "DOUBLE"}, {"name": "VC_CDH", "type": "STRING"}, {"name": "VC_JZQRKM1", "type": "STRING"}, {"name": "VC_JZQRKM2", "type": "STRING"}, {"name": "VC_JZQRKM3", "type": "STRING"}, {"name": "VC_JZSSKM1", "type": "STRING"}, {"name": "VC_JZSSKM2", "type": "STRING"}, {"name": "VC_JZSSKM3", "type": "STRING"}, {"name": "L_HCXTCKID", "type": "DOUBLE"}, {"name": "D_TQZQKSRQ", "type": "STRING"}, {"name": "VC_JGDM", "type": "STRING"}, {"name": "VC_SJLY", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tcap_ckyw_ptd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tcap_ckyw_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tcap_ckyw_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tcap_ckyw_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TCAP_CKYW_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TCAP_CKYW_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tcap_ckyw_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYW_PTD PARTITION(P_DT)
SELECT
       L_ZTBH
     , L_CKID
     , L_YWLB
     , D_SDATE
     , D_EDATE
     , VC_JYDS
     , VC_ZQDM
     , VC_ZQMC
     , VC_JSBZ
     , VC_BJKM
     , VC_LXKM
     , VC_LXSRKM
     , L_CLBZ
     , VC_BZ
     , L_NJXTS
     , L_JXFS
     , C_FXFS
     , D_XFXR
     , VC_BJDYKM
     , VC_ZHBH
     , VC_CKBH
     , EN_ZLX
     , L_LLLB
     , EN_JBLC
     , EN_FDBL
     , VC_JZLL
     , L_CYQX
     , L_O32_QRBH
     , L_O32_CDQRXH
     , L_SFKTQZQ
     , L_TQZQSSLX
     , L_YJXTS
     , VC_CDH
     , VC_JZQRKM1
     , VC_JZQRKM2
     , VC_JZQRKM3
     , VC_JZSSKM1
     , VC_JZSSKM2
     , VC_JZSSKM3
     , L_HCXTCKID
     , D_TQZQKSRQ
     , VC_JGDM
     , VC_SJLY
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_SDATE,'-','') P_DT
  FROM ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYW_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYW_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TCAP_CKYW_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TCAP_CKYW_PTD成功"
      exit 0
   fi
fi
