#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TFYMX_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TFYMX_PTD_TMP(
  L_BH  DECIMAL(18,2)  COMMENT  '编号',
  EN_YHS  DECIMAL(30,15)  COMMENT  '印花税',
  EN_JSF  DECIMAL(30,15)  COMMENT  '经手费',
  EN_GHF  DECIMAL(30,15)  COMMENT  '过户费',
  EN_ZGF  DECIMAL(30,15)  COMMENT  '证管费',
  EN_SXF  DECIMAL(30,15)  COMMENT  '手续费',
  EN_YJ  DECIMAL(30,15)  COMMENT  '佣金',
  EN_QTFY  DECIMAL(30,15)  COMMENT  '其他费用',
  VC_SQBH  STRING  COMMENT  '申请编号',
  L_ZTBH  STRING  COMMENT  '帐套编号',
  L_SCLB  DECIMAL(4,0)  COMMENT  '市场类别',
  D_YWRQ  STRING  COMMENT  '业务日期',
  VC_CJBM  STRING  COMMENT  '成交编码',
  L_YWLBMX  DECIMAL(10,0)  COMMENT  '业务类别明细',
  L_YWLB  DECIMAL(6,0)  COMMENT  '业务类别',
  L_HZFS  DECIMAL(1,0)  COMMENT  '汇总方式',
  L_ZQNM  DECIMAL(8,0)  COMMENT  '证券内码',
  EN_JYFY  DECIMAL(30,15)  COMMENT  '交易费用',
  L_JGHF  STRING  COMMENT  '减过户费标志',
  VC_BZ  STRING  COMMENT  '备注',
  EN_ZDGHF  DECIMAL(30,15)  COMMENT  '中登过户费',
  EN_WBHL  DECIMAL(18,14)  COMMENT  '',
  EN_XTSYF  DECIMAL(30,15)  COMMENT  '',
  EN_CHJZF  DECIMAL(30,15)  COMMENT  '',
  L_JCHJZF  DECIMAL(1,0)  COMMENT  '',
  L_YJJSXF  DECIMAL(1,0)  COMMENT  '',
  L_YJJJSF  DECIMAL(1,0)  COMMENT  '',
  L_YJJZGF  DECIMAL(1,0)  COMMENT  ''
)
COMMENT '交易所费用明细表'
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
                                   , EN_YHS
                                   , EN_JSF
                                   , EN_GHF
                                   , EN_ZGF
                                   , EN_SXF
                                   , EN_YJ
                                   , EN_QTFY
                                   , VC_SQBH
                                   , L_ZTBH
                                   , L_SCLB
                                   , TO_CHAR(D_YWRQ,'YYYYMMDD') D_YWRQ
                                   , VC_CJBM
                                   , L_YWLBMX
                                   , L_YWLB
                                   , L_HZFS
                                   , L_ZQNM
                                   , EN_JYFY
                                   , L_JGHF
                                   , VC_BZ
                                   , EN_ZDGHF
                                   , EN_WBHL
                                   , EN_XTSYF
                                   , EN_CHJZF
                                   , L_JCHJZF
                                   , L_YJJSXF
                                   , L_YJJJSF
                                   , L_YJJZGF
                                FROM ${hsfa_src_schema}.T_H_FYMX
                                WHERE D_YWRQ between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_BH", "type": "DOUBLE"}, {"name": "EN_YHS", "type": "DOUBLE"}, {"name": "EN_JSF", "type": "DOUBLE"}, {"name": "EN_GHF", "type": "DOUBLE"}, {"name": "EN_ZGF", "type": "DOUBLE"}, {"name": "EN_SXF", "type": "DOUBLE"}, {"name": "EN_YJ", "type": "DOUBLE"}, {"name": "EN_QTFY", "type": "DOUBLE"}, {"name": "VC_SQBH", "type": "STRING"}, {"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "L_SCLB", "type": "DOUBLE"}, {"name": "D_YWRQ", "type": "STRING"}, {"name": "VC_CJBM", "type": "STRING"}, {"name": "L_YWLBMX", "type": "DOUBLE"}, {"name": "L_YWLB", "type": "DOUBLE"}, {"name": "L_HZFS", "type": "DOUBLE"}, {"name": "L_ZQNM", "type": "DOUBLE"}, {"name": "EN_JYFY", "type": "DOUBLE"}, {"name": "L_JGHF", "type": "DOUBLE"}, {"name": "VC_BZ", "type": "STRING"}, {"name": "EN_ZDGHF", "type": "DOUBLE"}, {"name": "EN_WBHL", "type": "DOUBLE"}, {"name": "EN_XTSYF", "type": "DOUBLE"}, {"name": "EN_CHJZF", "type": "DOUBLE"}, {"name": "L_JCHJZF", "type": "DOUBLE"}, {"name": "L_YJJSXF", "type": "DOUBLE"}, {"name": "L_YJJJSF", "type": "DOUBLE"}, {"name": "L_YJJZGF", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tfymx_ptd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tfymx_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tfymx_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tfymx_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TFYMX_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TFYMX_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tfymx_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TFYMX_PTD PARTITION(P_DT)
SELECT
       L_BH
     , EN_YHS
     , EN_JSF
     , EN_GHF
     , EN_ZGF
     , EN_SXF
     , EN_YJ
     , EN_QTFY
     , VC_SQBH
     , L_ZTBH
     , L_SCLB
     , D_YWRQ
     , VC_CJBM
     , L_YWLBMX
     , L_YWLB
     , L_HZFS
     , L_ZQNM
     , EN_JYFY
     , L_JGHF
     , VC_BZ
     , EN_ZDGHF
     , EN_WBHL
     , EN_XTSYF
     , EN_CHJZF
     , L_JCHJZF
     , L_YJJSXF
     , L_YJJJSF
     , L_YJJZGF
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_YWRQ,'-','') P_DT
  FROM ODS_XDAY_HSFA.ODS_HSFA_TFYMX_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TFYMX_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TFYMX_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TFYMX_PTD成功"
      exit 0
   fi
fi
