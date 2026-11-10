#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TZHAIQUANLX_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TZHAIQUANLX_PTD_TMP(
  L_ZTBH  STRING  COMMENT  '帐套编号',
  D_DATE  STRING  COMMENT  '日期',
  L_ZQNM  DECIMAL(8,0)  COMMENT  '证券内码',
  VC_ZQDM  STRING  COMMENT  '证券代码',
  L_ZQCC  DECIMAL(19,4)  COMMENT  '证券持仓',
  EN_WBLX  DECIMAL(19,4)  COMMENT  '外币利息',
  EN_BWBLX  DECIMAL(19,4)  COMMENT  '本位币利息',
  EN_EXCH  DECIMAL(18,14)  COMMENT  '汇率',
  VC_JSBZ  STRING  COMMENT  '结算币种',
  L_YWLB  DECIMAL(4,0)  COMMENT  '业务类别',
  D_SCSJ  STRING  COMMENT  '生成时间',
  VC_BH  STRING  COMMENT  '编号',
  EN_LJLX  DECIMAL(19,4)  COMMENT  '累计利息',
  EN_SJLX  DECIMAL(19,4)  COMMENT  '实际利息',
  EN_LJZYJ  DECIMAL(19,4)  COMMENT  '累计折溢价',
  EN_YBLJZYJ  DECIMAL(19,4)  COMMENT  '原币累计折溢价',
  EN_SJLL  DECIMAL(18,12)  COMMENT  '实际利率',
  L_TZLX  STRING  COMMENT  '投资类型',
  L_BH  DECIMAL(10,0)  COMMENT  'seq_public_id',
  EN_LXSDS  DECIMAL(19,4)  COMMENT  '利息所得税',
  EN_YBLXSDS  DECIMAL(19,4)  COMMENT  '原币利息所得税',
  EN_LJLXSDS  DECIMAL(19,4)  COMMENT  '累计利息所得税',
  L_JYSMRYXDTJS  DECIMAL(1,0)  COMMENT  '',
  L_CCFL  DECIMAL(4,0)  COMMENT  '',
  VC_QMBZ  STRING  COMMENT  '',
  EN_RATE  DECIMAL(18,4)  COMMENT  '',
  EN_YBCB  DECIMAL(19,4)  COMMENT  '',
  L_ZYJTXCC  DECIMAL(19,4)  COMMENT  '',
  EN_WBLX_WFY  DECIMAL(19,4)  COMMENT  '',
  EN_LJJZZB  DECIMAL(19,4)  COMMENT  '',
  EN_YBLJJZZB  DECIMAL(19,4)  COMMENT  '',
  L_CLBZ  DECIMAL(1,0)  COMMENT  '',
  VC_LLR  STRING  COMMENT  '',
  VC_FHR  STRING  COMMENT  ''
)
COMMENT '债券计息表'
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
                                   , TO_CHAR(D_DATE,'YYYYMMDD') D_DATE
                                   , L_ZQNM
                                   , VC_ZQDM
                                   , L_ZQCC
                                   , EN_WBLX
                                   , EN_BWBLX
                                   , EN_EXCH
                                   , VC_JSBZ
                                   , L_YWLB
                                   , D_SCSJ
                                   , VC_BH
                                   , EN_LJLX
                                   , EN_SJLX
                                   , EN_LJZYJ
                                   , EN_YBLJZYJ
                                   , EN_SJLL
                                   , L_TZLX
                                   , L_BH
                                   , EN_LXSDS
                                   , EN_YBLXSDS
                                   , EN_LJLXSDS
                                   , L_JYSMRYXDTJS
                                   , L_CCFL
                                   , VC_QMBZ
                                   , EN_RATE
                                   , EN_YBCB
                                   , L_ZYJTXCC
                                   , EN_WBLX_WFY
                                   , EN_LJJZZB
                                   , EN_YBLJJZZB
                                   , L_CLBZ
                                   , VC_LLR
                                   , VC_FHR
                                FROM ${hsfa_src_schema}.TZHAIQUANLX
                                WHERE D_DATE between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "D_DATE", "type": "STRING"}, {"name": "L_ZQNM", "type": "DOUBLE"}, {"name": "VC_ZQDM", "type": "STRING"}, {"name": "L_ZQCC", "type": "DOUBLE"}, {"name": "EN_WBLX", "type": "DOUBLE"}, {"name": "EN_BWBLX", "type": "DOUBLE"}, {"name": "EN_EXCH", "type": "DOUBLE"}, {"name": "VC_JSBZ", "type": "STRING"}, {"name": "L_YWLB", "type": "DOUBLE"}, {"name": "D_SCSJ", "type": "STRING"}, {"name": "VC_BH", "type": "STRING"}, {"name": "EN_LJLX", "type": "DOUBLE"}, {"name": "EN_SJLX", "type": "DOUBLE"}, {"name": "EN_LJZYJ", "type": "DOUBLE"}, {"name": "EN_YBLJZYJ", "type": "DOUBLE"}, {"name": "EN_SJLL", "type": "DOUBLE"}, {"name": "L_TZLX", "type": "DOUBLE"}, {"name": "L_BH", "type": "DOUBLE"}, {"name": "EN_LXSDS", "type": "DOUBLE"}, {"name": "EN_YBLXSDS", "type": "DOUBLE"}, {"name": "EN_LJLXSDS", "type": "DOUBLE"}, {"name": "L_JYSMRYXDTJS", "type": "DOUBLE"}, {"name": "L_CCFL", "type": "DOUBLE"}, {"name": "VC_QMBZ", "type": "STRING"}, {"name": "EN_RATE", "type": "DOUBLE"}, {"name": "EN_YBCB", "type": "DOUBLE"}, {"name": "L_ZYJTXCC", "type": "DOUBLE"}, {"name": "EN_WBLX_WFY", "type": "DOUBLE"}, {"name": "EN_LJJZZB", "type": "DOUBLE"}, {"name": "EN_YBLJJZZB", "type": "DOUBLE"}, {"name": "L_CLBZ", "type": "DOUBLE"}, {"name": "VC_LLR", "type": "STRING"}, {"name": "VC_FHR", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tzhaiquanlx_ptd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tzhaiquanlx_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tzhaiquanlx_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tzhaiquanlx_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TZHAIQUANLX_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TZHAIQUANLX_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tzhaiquanlx_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TZHAIQUANLX_PTD PARTITION(P_DT)
SELECT
       L_ZTBH
     , D_DATE
     , L_ZQNM
     , VC_ZQDM
     , L_ZQCC
     , EN_WBLX
     , EN_BWBLX
     , EN_EXCH
     , VC_JSBZ
     , L_YWLB
     , D_SCSJ
     , VC_BH
     , EN_LJLX
     , EN_SJLX
     , EN_LJZYJ
     , EN_YBLJZYJ
     , EN_SJLL
     , L_TZLX
     , L_BH
     , EN_LXSDS
     , EN_YBLXSDS
     , EN_LJLXSDS
     , L_JYSMRYXDTJS
     , L_CCFL
     , VC_QMBZ
     , EN_RATE
     , EN_YBCB
     , L_ZYJTXCC
     , EN_WBLX_WFY
     , EN_LJJZZB
     , EN_YBLJJZZB
     , L_CLBZ
     , VC_LLR
     , VC_FHR
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_DATE,'-','') P_DT
  FROM ODS_XDAY_HSFA.ODS_HSFA_TZHAIQUANLX_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TZHAIQUANLX_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TZHAIQUANLX_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TZHAIQUANLX_PTD成功"
      exit 0
   fi
fi
