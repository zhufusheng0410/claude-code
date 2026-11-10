#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TTMP_H_GZB_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TTMP_H_GZB_PTD_TMP(
  L_BH  STRING  COMMENT  '编号',
  VC_KMDM  STRING  COMMENT  '科目代码',
  VC_KMMC  STRING  COMMENT  '科目名称',
  L_SL  DECIMAL(19,4)  COMMENT  '数量',
  EN_DWCB  DECIMAL(30,6)  COMMENT  '单位成本',
  EN_CB  DECIMAL(18,2)  COMMENT  '成本',
  EN_CBZJZ  DECIMAL(19,4)  COMMENT  '成本占净值比',
  EN_HQJZ  DECIMAL(25,12)  COMMENT  '行情价格',
  EN_SZ  DECIMAL(18,2)  COMMENT  '市值',
  EN_SZZJZ  DECIMAL(19,4)  COMMENT  '市值占净值比',
  EN_GZZZ  DECIMAL(19,4)  COMMENT  '估值增值',
  VC_TPXX  STRING  COMMENT  '停牌信息',
  VC_QYXX  STRING  COMMENT  '权益信息',
  L_TMPID  DECIMAL(8,0)  COMMENT  '',
  VC_JYS  STRING  COMMENT  '',
  VC_TZPZ  STRING  COMMENT  '',
  VC_XJL  STRING  COMMENT  '',
  VC_TS  STRING  COMMENT  '',
  EN_FDYKBL  DECIMAL(19,4)  COMMENT  '',
  L_LEAF  STRING  COMMENT  '明细科目标志',
  VC_KMPARENT  STRING  COMMENT  '上级科目代码',
  L_LEVEL  DECIMAL(2,0)  COMMENT  '科目级别',
  L_ZTBH  STRING  COMMENT  '账套编号',
  D_YWRQ  STRING  COMMENT  '业务日期',
  D_SCSJ  STRING  COMMENT  '生成时间',
  L_QUANTITY  STRING  COMMENT  '核算数量标志',
  VC_CODE_HS  STRING  COMMENT  '恒生标准科目',
  L_KIND  DECIMAL(2,1)  COMMENT  '科目借贷方向',
  L_GZKMBZ  STRING  COMMENT  '估增科目标志',
  VC_JSBZ  STRING  COMMENT  '结算币种',
  EN_EXCH  DECIMAL(28,14)  COMMENT  '汇率',
  EN_WBCB  DECIMAL(19,4)  COMMENT  '外币成本',
  EN_WBHQ  DECIMAL(27,12)  COMMENT  '外币行情',
  EN_WBSZ  DECIMAL(19,4)  COMMENT  '外币市值',
  L_ZQNM  DECIMAL(8,0)  COMMENT  '证券内码',
  L_SFQR  DECIMAL(1,0)  COMMENT  '是否确认',
  L_TZLX  STRING  COMMENT  '投资类型',
  EN_ZYJ  DECIMAL(19,4)  COMMENT  '折溢价',
  EN_WBZYJ  DECIMAL(19,4)  COMMENT  '外币折溢价',
  VC_CHECKER  STRING  COMMENT  '审核人',
  VC_BZW  STRING  COMMENT  '标志位',
  VC_LTLX  STRING  COMMENT  '流通类型',
  EN_YBGZZZ  DECIMAL(19,4)  COMMENT  '原币估值增值',
  VC_ZQDM  STRING  COMMENT  '证券代码',
  L_SCLB  DECIMAL(4,0)  COMMENT  '市场类别',
  L_ZQLB  DECIMAL(4,0)  COMMENT  '证券类别',
  EN_QYXX  DECIMAL(19,14)  COMMENT  '权益比例',
  L_SFJCZS  DECIMAL(1,0)  COMMENT  ''
)
COMMENT '估值表'
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
                                   , VC_KMDM
                                   , VC_KMMC
                                   , L_SL
                                   , EN_DWCB
                                   , EN_CB
                                   , EN_CBZJZ
                                   , EN_HQJZ
                                   , EN_SZ
                                   , EN_SZZJZ
                                   , EN_GZZZ
                                   , VC_TPXX
                                   , VC_QYXX
                                   , L_TMPID
                                   , VC_JYS
                                   , VC_TZPZ
                                   , VC_XJL
                                   , VC_TS
                                   , EN_FDYKBL
                                   , L_LEAF
                                   , VC_KMPARENT
                                   , L_LEVEL
                                   , L_ZTBH
                                   , TO_CHAR(D_YWRQ,'YYYYMMDD') D_YWRQ
                                   , D_SCSJ
                                   , L_QUANTITY
                                   , VC_CODE_HS
                                   , L_KIND
                                   , L_GZKMBZ
                                   , VC_JSBZ
                                   , EN_EXCH
                                   , EN_WBCB
                                   , EN_WBHQ
                                   , EN_WBSZ
                                   , L_ZQNM
                                   , L_SFQR
                                   , L_TZLX
                                   , EN_ZYJ
                                   , EN_WBZYJ
                                   , VC_CHECKER
                                   , VC_BZW
                                   , VC_LTLX
                                   , EN_YBGZZZ
                                   , VC_ZQDM
                                   , L_SCLB
                                   , L_ZQLB
                                   , EN_QYXX
                                   , L_SFJCZS
                                FROM ${hsfa_src_schema}.TTMP_H_GZB
                                WHERE D_YWRQ between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_BH", "type": "DOUBLE"}, {"name": "VC_KMDM", "type": "STRING"}, {"name": "VC_KMMC", "type": "STRING"}, {"name": "L_SL", "type": "DOUBLE"}, {"name": "EN_DWCB", "type": "DOUBLE"}, {"name": "EN_CB", "type": "DOUBLE"}, {"name": "EN_CBZJZ", "type": "DOUBLE"}, {"name": "EN_HQJZ", "type": "DOUBLE"}, {"name": "EN_SZ", "type": "DOUBLE"}, {"name": "EN_SZZJZ", "type": "DOUBLE"}, {"name": "EN_GZZZ", "type": "DOUBLE"}, {"name": "VC_TPXX", "type": "STRING"}, {"name": "VC_QYXX", "type": "STRING"}, {"name": "L_TMPID", "type": "DOUBLE"}, {"name": "VC_JYS", "type": "STRING"}, {"name": "VC_TZPZ", "type": "STRING"}, {"name": "VC_XJL", "type": "STRING"}, {"name": "VC_TS", "type": "STRING"}, {"name": "EN_FDYKBL", "type": "DOUBLE"}, {"name": "L_LEAF", "type": "DOUBLE"}, {"name": "VC_KMPARENT", "type": "STRING"}, {"name": "L_LEVEL", "type": "DOUBLE"}, {"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "D_YWRQ", "type": "STRING"}, {"name": "D_SCSJ", "type": "STRING"}, {"name": "L_QUANTITY", "type": "DOUBLE"}, {"name": "VC_CODE_HS", "type": "STRING"}, {"name": "L_KIND", "type": "DOUBLE"}, {"name": "L_GZKMBZ", "type": "DOUBLE"}, {"name": "VC_JSBZ", "type": "STRING"}, {"name": "EN_EXCH", "type": "DOUBLE"}, {"name": "EN_WBCB", "type": "DOUBLE"}, {"name": "EN_WBHQ", "type": "DOUBLE"}, {"name": "EN_WBSZ", "type": "DOUBLE"}, {"name": "L_ZQNM", "type": "DOUBLE"}, {"name": "L_SFQR", "type": "DOUBLE"}, {"name": "L_TZLX", "type": "DOUBLE"}, {"name": "EN_ZYJ", "type": "DOUBLE"}, {"name": "EN_WBZYJ", "type": "DOUBLE"}, {"name": "VC_CHECKER", "type": "STRING"}, {"name": "VC_BZW", "type": "STRING"}, {"name": "VC_LTLX", "type": "STRING"}, {"name": "EN_YBGZZZ", "type": "DOUBLE"}, {"name": "VC_ZQDM", "type": "STRING"}, {"name": "L_SCLB", "type": "DOUBLE"}, {"name": "L_ZQLB", "type": "DOUBLE"}, {"name": "EN_QYXX", "type": "DOUBLE"}, {"name": "L_SFJCZS", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_ttmp_h_gzb_ptd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_ttmp_h_gzb_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_ttmp_h_gzb_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_ttmp_h_gzb_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TTMP_H_GZB_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TTMP_H_GZB_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_ttmp_h_gzb_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TTMP_H_GZB_PTD PARTITION(P_DT)
SELECT
       L_BH
     , VC_KMDM
     , VC_KMMC
     , L_SL
     , EN_DWCB
     , EN_CB
     , EN_CBZJZ
     , EN_HQJZ
     , EN_SZ
     , EN_SZZJZ
     , EN_GZZZ
     , VC_TPXX
     , VC_QYXX
     , L_TMPID
     , VC_JYS
     , VC_TZPZ
     , VC_XJL
     , VC_TS
     , EN_FDYKBL
     , L_LEAF
     , VC_KMPARENT
     , L_LEVEL
     , L_ZTBH
     , D_YWRQ
     , D_SCSJ
     , L_QUANTITY
     , VC_CODE_HS
     , L_KIND
     , L_GZKMBZ
     , VC_JSBZ
     , EN_EXCH
     , EN_WBCB
     , EN_WBHQ
     , EN_WBSZ
     , L_ZQNM
     , L_SFQR
     , L_TZLX
     , EN_ZYJ
     , EN_WBZYJ
     , VC_CHECKER
     , VC_BZW
     , VC_LTLX
     , EN_YBGZZZ
     , VC_ZQDM
     , L_SCLB
     , L_ZQLB
     , EN_QYXX
     , L_SFJCZS
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_YWRQ,'-','') P_DT
  FROM ODS_XDAY_HSFA.ODS_HSFA_TTMP_H_GZB_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TTMP_H_GZB_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TTMP_H_GZB_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TTMP_H_GZB_PTD成功"
      exit 0
   fi
fi
