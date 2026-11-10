#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TACCOUNTZQJC_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TACCOUNTZQJC_PTD_TMP(
  L_ZTBH  STRING  COMMENT  '帐套编号',
  L_ZQNM  DECIMAL(8,0)  COMMENT  '证券内码',
  VC_ZQDM  STRING  COMMENT  '证券代码',
  D_DATE  STRING  COMMENT  '日期',
  L_ZQCC  DECIMAL(23,4)  COMMENT  '证券持仓',
  EN_ZQCB  DECIMAL(19,4)  COMMENT  '证券成本',
  VC_ZQFL  STRING  COMMENT  '证券分类',
  EN_LJGZ  DECIMAL(19,4)  COMMENT  '累计估值',
  L_SDFLAG  STRING  COMMENT  '锁定标志',
  L_LTBZ  STRING  COMMENT  '流通标志',
  L_ZFBZ  STRING  COMMENT  '增发标志',
  L_PGBZ  STRING  COMMENT  '配股标志',
  EN_YBCB  DECIMAL(19,4)  COMMENT  '原币成本',
  VC_JSBZ  STRING  COMMENT  '结算币种',
  EN_EXCH  DECIMAL(18,14)  COMMENT  '汇率',
  EN_YBLJGZ  DECIMAL(19,4)  COMMENT  '原币累计估值',
  VC_CBDYGZ  STRING  COMMENT  '成本对应估值',
  VC_KMDM  STRING  COMMENT  '科目代码',
  L_XGBZ  STRING  COMMENT  '新股标志',
  L_DKFX  STRING  COMMENT  '多空方向',
  EN_HYCS  DECIMAL(12,4)  COMMENT  '合约乘数',
  L_SCLB  DECIMAL(4,0)  COMMENT  '市场类别',
  EN_LJLX  DECIMAL(19,4)  COMMENT  '累计利息',
  EN_YBLJLX  DECIMAL(19,4)  COMMENT  '原币累计利息',
  VC_CBDYLX  STRING  COMMENT  '成本对应利息',
  EN_YBLJGL  DECIMAL(19,4)  COMMENT  '原币累计股利',
  VC_CBDYGL  STRING  COMMENT  '成本对应股利',
  EN_LJGL  DECIMAL(19,4)  COMMENT  '累计股利',
  EN_LJZYJ  DECIMAL(19,4)  COMMENT  '累计对应折溢价',
  EN_YBLJZYJ  DECIMAL(19,4)  COMMENT  '原币累计折溢价',
  VC_CBDYZYJ  STRING  COMMENT  '成本对应折溢价',
  L_TZLX  STRING  COMMENT  '投资类型',
  L_CCHSID  DECIMAL(4,0)  COMMENT  '持仓核算ID',
  C_XWLX  STRING  COMMENT  '席位类型',
  VC_CBDYJZZB  STRING  COMMENT  '减值准备科目代码',
  EN_LJJZZB  DECIMAL(19,4)  COMMENT  '累计减值准备金额',
  EN_YBLJJZZB  DECIMAL(19,4)  COMMENT  '原币累计减值准备金额',
  L_TQBZ  STRING  COMMENT  '套期保值标志',
  L_ZCBZ  STRING  COMMENT  '转持标志',
  L_ZCJSBZ  STRING  COMMENT  '转持限售标志',
  EN_LJLXSDS  DECIMAL(19,4)  COMMENT  '累计利息所得税',
  EN_YBLJLXSDS  DECIMAL(19,4)  COMMENT  '原币累计利息所得税',
  EN_LJGZSDS  DECIMAL(19,4)  COMMENT  '累计估值所得税',
  EN_YBLJGZSDS  DECIMAL(19,4)  COMMENT  '原币累计估值所得税',
  VC_CBDYLXSDS  STRING  COMMENT  '成本对应利息所得税',
  VC_CBDYGZSDS  STRING  COMMENT  '成本对应估值所得税',
  L_CCFL  DECIMAL(4,0)  COMMENT  ''
)
COMMENT '证券结存表'
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
                                   , L_ZQNM
                                   , VC_ZQDM
                                   , TO_CHAR(D_DATE,'YYYYMMDD') D_DATE
                                   , L_ZQCC
                                   , EN_ZQCB
                                   , VC_ZQFL
                                   , EN_LJGZ
                                   , L_SDFLAG
                                   , L_LTBZ
                                   , L_ZFBZ
                                   , L_PGBZ
                                   , EN_YBCB
                                   , VC_JSBZ
                                   , EN_EXCH
                                   , EN_YBLJGZ
                                   , VC_CBDYGZ
                                   , VC_KMDM
                                   , L_XGBZ
                                   , L_DKFX
                                   , EN_HYCS
                                   , L_SCLB
                                   , EN_LJLX
                                   , EN_YBLJLX
                                   , VC_CBDYLX
                                   , EN_YBLJGL
                                   , VC_CBDYGL
                                   , EN_LJGL
                                   , EN_LJZYJ
                                   , EN_YBLJZYJ
                                   , VC_CBDYZYJ
                                   , L_TZLX
                                   , L_CCHSID
                                   , C_XWLX
                                   , VC_CBDYJZZB
                                   , EN_LJJZZB
                                   , EN_YBLJJZZB
                                   , L_TQBZ
                                   , L_ZCBZ
                                   , L_ZCJSBZ
                                   , EN_LJLXSDS
                                   , EN_YBLJLXSDS
                                   , EN_LJGZSDS
                                   , EN_YBLJGZSDS
                                   , VC_CBDYLXSDS
                                   , VC_CBDYGZSDS
                                   , L_CCFL
                                FROM ${hsfa_src_schema}.TACCOUNTZQJC
                                WHERE D_DATE between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "L_ZQNM", "type": "DOUBLE"}, {"name": "VC_ZQDM", "type": "STRING"}, {"name": "D_DATE", "type": "STRING"}, {"name": "L_ZQCC", "type": "DOUBLE"}, {"name": "EN_ZQCB", "type": "DOUBLE"}, {"name": "VC_ZQFL", "type": "STRING"}, {"name": "EN_LJGZ", "type": "DOUBLE"}, {"name": "L_SDFLAG", "type": "DOUBLE"}, {"name": "L_LTBZ", "type": "DOUBLE"}, {"name": "L_ZFBZ", "type": "DOUBLE"}, {"name": "L_PGBZ", "type": "DOUBLE"}, {"name": "EN_YBCB", "type": "DOUBLE"}, {"name": "VC_JSBZ", "type": "STRING"}, {"name": "EN_EXCH", "type": "DOUBLE"}, {"name": "EN_YBLJGZ", "type": "DOUBLE"}, {"name": "VC_CBDYGZ", "type": "STRING"}, {"name": "VC_KMDM", "type": "STRING"}, {"name": "L_XGBZ", "type": "DOUBLE"}, {"name": "L_DKFX", "type": "DOUBLE"}, {"name": "EN_HYCS", "type": "DOUBLE"}, {"name": "L_SCLB", "type": "DOUBLE"}, {"name": "EN_LJLX", "type": "DOUBLE"}, {"name": "EN_YBLJLX", "type": "DOUBLE"}, {"name": "VC_CBDYLX", "type": "STRING"}, {"name": "EN_YBLJGL", "type": "DOUBLE"}, {"name": "VC_CBDYGL", "type": "STRING"}, {"name": "EN_LJGL", "type": "DOUBLE"}, {"name": "EN_LJZYJ", "type": "DOUBLE"}, {"name": "EN_YBLJZYJ", "type": "DOUBLE"}, {"name": "VC_CBDYZYJ", "type": "STRING"}, {"name": "L_TZLX", "type": "DOUBLE"}, {"name": "L_CCHSID", "type": "DOUBLE"}, {"name": "C_XWLX", "type": "STRING"}, {"name": "VC_CBDYJZZB", "type": "STRING"}, {"name": "EN_LJJZZB", "type": "DOUBLE"}, {"name": "EN_YBLJJZZB", "type": "DOUBLE"}, {"name": "L_TQBZ", "type": "DOUBLE"}, {"name": "L_ZCBZ", "type": "DOUBLE"}, {"name": "L_ZCJSBZ", "type": "DOUBLE"}, {"name": "EN_LJLXSDS", "type": "DOUBLE"}, {"name": "EN_YBLJLXSDS", "type": "DOUBLE"}, {"name": "EN_LJGZSDS", "type": "DOUBLE"}, {"name": "EN_YBLJGZSDS", "type": "DOUBLE"}, {"name": "VC_CBDYLXSDS", "type": "STRING"}, {"name": "VC_CBDYGZSDS", "type": "STRING"}, {"name": "L_CCFL", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_taccountzqjc_ptd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_taccountzqjc_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_taccountzqjc_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_taccountzqjc_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TACCOUNTZQJC_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TACCOUNTZQJC_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_taccountzqjc_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TACCOUNTZQJC_PTD PARTITION(P_DT)
SELECT
       L_ZTBH
     , L_ZQNM
     , VC_ZQDM
     , D_DATE
     , L_ZQCC
     , EN_ZQCB
     , VC_ZQFL
     , EN_LJGZ
     , L_SDFLAG
     , L_LTBZ
     , L_ZFBZ
     , L_PGBZ
     , EN_YBCB
     , VC_JSBZ
     , EN_EXCH
     , EN_YBLJGZ
     , VC_CBDYGZ
     , VC_KMDM
     , L_XGBZ
     , L_DKFX
     , EN_HYCS
     , L_SCLB
     , EN_LJLX
     , EN_YBLJLX
     , VC_CBDYLX
     , EN_YBLJGL
     , VC_CBDYGL
     , EN_LJGL
     , EN_LJZYJ
     , EN_YBLJZYJ
     , VC_CBDYZYJ
     , L_TZLX
     , L_CCHSID
     , C_XWLX
     , VC_CBDYJZZB
     , EN_LJJZZB
     , EN_YBLJJZZB
     , L_TQBZ
     , L_ZCBZ
     , L_ZCJSBZ
     , EN_LJLXSDS
     , EN_YBLJLXSDS
     , EN_LJGZSDS
     , EN_YBLJGZSDS
     , VC_CBDYLXSDS
     , VC_CBDYGZSDS
     , L_CCFL
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_DATE,'-','') P_DT
  FROM ODS_XDAY_HSFA.ODS_HSFA_TACCOUNTZQJC_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TACCOUNTZQJC_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TACCOUNTZQJC_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TACCOUNTZQJC_PTD成功"
      exit 0
   fi
fi
