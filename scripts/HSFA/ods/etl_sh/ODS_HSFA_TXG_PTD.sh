#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TXG_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TXG_PTD_TMP(
  L_ID  DECIMAL(8,0)  COMMENT  '流水序号',
  L_ZTBH  STRING  COMMENT  '帐套编号',
  VC_GDDM  STRING  COMMENT  '股东代码',
  VC_XWDM  STRING  COMMENT  '席位代码',
  L_ZQNM  DECIMAL(10,0)  COMMENT  '证券内码',
  VC_ZQDM  STRING  COMMENT  '证券代码',
  L_SCLB  DECIMAL(4,0)  COMMENT  '市场类别',
  L_PZID  STRING  COMMENT  '凭证编号',
  L_CLBZ  STRING  COMMENT  '业务出来标志',
  L_SGID  STRING  COMMENT  '申购编号',
  L_YWLB  DECIMAL(6,0)  COMMENT  '业务类别',
  L_TZLX  STRING  COMMENT  '投资类型',
  VC_YSZQDM  STRING  COMMENT  '原始证券代码',
  D_CJRQ  STRING  COMMENT  '凭证日期',
  EN_CJJG  DECIMAL(19,4)  COMMENT  '成交价格',
  EN_CJJE  DECIMAL(19,4)  COMMENT  '成交金额',
  VC_CJBH  STRING  COMMENT  '成交编号',
  VC_SQBH  STRING  COMMENT  '申请编号',
  EN_CJSL  DECIMAL(19,4)  COMMENT  '成交数量',
  VC_BZ  STRING  COMMENT  '备注',
  VC_JSBZ  STRING  COMMENT  '结算币种',
  EN_EXCH  DECIMAL(18,14)  COMMENT  '汇率',
  C_YWMS  STRING  COMMENT  '业务模式',
  D_RQ  STRING  COMMENT  '日期',
  VC_GLZQDM  STRING  COMMENT  '关联证券代码',
  L_GLZQNM  DECIMAL(18,2)  COMMENT  '关联证券内码',
  EN_LTLX  DECIMAL(19,4)  COMMENT  '流通利息',
  EN_LTGZ  DECIMAL(19,4)  COMMENT  '流通估值',
  EN_QSJE  DECIMAL(19,4)  COMMENT  '清算金额',
  EN_CJFY  DECIMAL(19,4)  COMMENT  '成交费用',
  VC_ZHDM  STRING  COMMENT  '账户代码',
  C_XWLX  STRING  COMMENT  '席位类型',
  VC_LLR  STRING  COMMENT  '录入人',
  VC_FHR  STRING  COMMENT  '复核人',
  VC_BFZH  STRING  COMMENT  '本方账户',
  EN_LXSDS  DECIMAL(19,4)  COMMENT  '利息所得税',
  EN_GZSDS  DECIMAL(19,4)  COMMENT  '估值所得税',
  EN_LXS  DECIMAL(19,4)  COMMENT  '',
  L_CCFL  DECIMAL(4,0)  COMMENT  '',
  EN_BWBCJJE  DECIMAL(19,4)  COMMENT  '',
  EN_BWBLTLX  DECIMAL(19,4)  COMMENT  '',
  EN_BWBLTGZ  DECIMAL(19,4)  COMMENT  '',
  EN_BWBLXSDS  DECIMAL(19,4)  COMMENT  '',
  EN_BWBGZSDS  DECIMAL(19,4)  COMMENT  '',
  VC_SJLY  STRING  COMMENT  '',
  VC_JYDS  STRING  COMMENT  '',
  L_YTHWHGLBH  DECIMAL(10,0)  COMMENT  '',
  EN_BWBCJJG  DECIMAL(19,4)  COMMENT  '',
  EN_BWBCJFY  DECIMAL(19,4)  COMMENT  '',
  EN_BWBLXS  DECIMAL(19,4)  COMMENT  '',
  VC_QSBH  STRING  COMMENT  '',
  EN_ZQJKJE  DECIMAL(19,4)  COMMENT  '',
  C_LTSXGPYWMS  STRING  COMMENT  '',
  EN_ZCZYJ  DECIMAL(19,4)  COMMENT  '',
  EN_BDQHBJE  DECIMAL(19,4)  COMMENT  '',
  EN_LXBCJE  DECIMAL(19,4)  COMMENT  '',
  EN_HBJE  DECIMAL(19,4)  COMMENT  '',
  EN_YJLL  DECIMAL(6,4)  COMMENT  '',
  D_MODIFY  STRING  COMMENT  '',
  EN_ZCJZZB  DECIMAL(19,4)  COMMENT  '',
  L_GLBH  DECIMAL(18,2)  COMMENT  '',
  EN_LTZYJ  DECIMAL(19,4)  COMMENT  '',
  D_JKRQ  STRING  COMMENT  '',
  EN_ZRZYJ  DECIMAL(19,4)  COMMENT  '',
  EN_CJZCJE  DECIMAL(19,4)  COMMENT  ''
)
COMMENT '新股表'
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
              "querySql": ["SELECT  L_ID
                                   , L_ZTBH
                                   , VC_GDDM
                                   , VC_XWDM
                                   , L_ZQNM
                                   , VC_ZQDM
                                   , L_SCLB
                                   , L_PZID
                                   , L_CLBZ
                                   , L_SGID
                                   , L_YWLB
                                   , L_TZLX
                                   , VC_YSZQDM
                                   , TO_CHAR(D_CJRQ,'YYYYMMDD') D_CJRQ
                                   , EN_CJJG
                                   , EN_CJJE
                                   , VC_CJBH
                                   , VC_SQBH
                                   , EN_CJSL
                                   , VC_BZ
                                   , VC_JSBZ
                                   , EN_EXCH
                                   , C_YWMS
                                   , D_RQ
                                   , VC_GLZQDM
                                   , L_GLZQNM
                                   , EN_LTLX
                                   , EN_LTGZ
                                   , EN_QSJE
                                   , EN_CJFY
                                   , VC_ZHDM
                                   , C_XWLX
                                   , VC_LLR
                                   , VC_FHR
                                   , VC_BFZH
                                   , EN_LXSDS
                                   , EN_GZSDS
                                   , EN_LXS
                                   , L_CCFL
                                   , EN_BWBCJJE
                                   , EN_BWBLTLX
                                   , EN_BWBLTGZ
                                   , EN_BWBLXSDS
                                   , EN_BWBGZSDS
                                   , VC_SJLY
                                   , VC_JYDS
                                   , L_YTHWHGLBH
                                   , EN_BWBCJJG
                                   , EN_BWBCJFY
                                   , EN_BWBLXS
                                   , VC_QSBH
                                   , EN_ZQJKJE
                                   , C_LTSXGPYWMS
                                   , EN_ZCZYJ
                                   , EN_BDQHBJE
                                   , EN_LXBCJE
                                   , EN_HBJE
                                   , EN_YJLL
                                   , D_MODIFY
                                   , EN_ZCJZZB
                                   , L_GLBH
                                   , EN_LTZYJ
                                   , D_JKRQ
                                   , EN_ZRZYJ
                                   , EN_CJZCJE
                                FROM ${hsfa_src_schema}.TXG
                                WHERE D_CJRQ between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ID", "type": "DOUBLE"}, {"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "VC_GDDM", "type": "STRING"}, {"name": "VC_XWDM", "type": "STRING"}, {"name": "L_ZQNM", "type": "DOUBLE"}, {"name": "VC_ZQDM", "type": "STRING"}, {"name": "L_SCLB", "type": "DOUBLE"}, {"name": "L_PZID", "type": "STRING"}, {"name": "L_CLBZ", "type": "DOUBLE"}, {"name": "L_SGID", "type": "DOUBLE"}, {"name": "L_YWLB", "type": "DOUBLE"}, {"name": "L_TZLX", "type": "DOUBLE"}, {"name": "VC_YSZQDM", "type": "STRING"}, {"name": "D_CJRQ", "type": "STRING"}, {"name": "EN_CJJG", "type": "DOUBLE"}, {"name": "EN_CJJE", "type": "DOUBLE"}, {"name": "VC_CJBH", "type": "STRING"}, {"name": "VC_SQBH", "type": "STRING"}, {"name": "EN_CJSL", "type": "DOUBLE"}, {"name": "VC_BZ", "type": "STRING"}, {"name": "VC_JSBZ", "type": "STRING"}, {"name": "EN_EXCH", "type": "DOUBLE"}, {"name": "C_YWMS", "type": "STRING"}, {"name": "D_RQ", "type": "STRING"}, {"name": "VC_GLZQDM", "type": "STRING"}, {"name": "L_GLZQNM", "type": "DOUBLE"}, {"name": "EN_LTLX", "type": "DOUBLE"}, {"name": "EN_LTGZ", "type": "DOUBLE"}, {"name": "EN_QSJE", "type": "DOUBLE"}, {"name": "EN_CJFY", "type": "DOUBLE"}, {"name": "VC_ZHDM", "type": "STRING"}, {"name": "C_XWLX", "type": "STRING"}, {"name": "VC_LLR", "type": "STRING"}, {"name": "VC_FHR", "type": "STRING"}, {"name": "VC_BFZH", "type": "STRING"}, {"name": "EN_LXSDS", "type": "DOUBLE"}, {"name": "EN_GZSDS", "type": "DOUBLE"}, {"name": "EN_LXS", "type": "DOUBLE"}, {"name": "L_CCFL", "type": "DOUBLE"}, {"name": "EN_BWBCJJE", "type": "DOUBLE"}, {"name": "EN_BWBLTLX", "type": "DOUBLE"}, {"name": "EN_BWBLTGZ", "type": "DOUBLE"}, {"name": "EN_BWBLXSDS", "type": "DOUBLE"}, {"name": "EN_BWBGZSDS", "type": "DOUBLE"}, {"name": "VC_SJLY", "type": "STRING"}, {"name": "VC_JYDS", "type": "STRING"}, {"name": "L_YTHWHGLBH", "type": "DOUBLE"}, {"name": "EN_BWBCJJG", "type": "DOUBLE"}, {"name": "EN_BWBCJFY", "type": "DOUBLE"}, {"name": "EN_BWBLXS", "type": "DOUBLE"}, {"name": "VC_QSBH", "type": "STRING"}, {"name": "EN_ZQJKJE", "type": "DOUBLE"}, {"name": "C_LTSXGPYWMS", "type": "STRING"}, {"name": "EN_ZCZYJ", "type": "DOUBLE"}, {"name": "EN_BDQHBJE", "type": "DOUBLE"}, {"name": "EN_LXBCJE", "type": "DOUBLE"}, {"name": "EN_HBJE", "type": "DOUBLE"}, {"name": "EN_YJLL", "type": "DOUBLE"}, {"name": "D_MODIFY", "type": "STRING"}, {"name": "EN_ZCJZZB", "type": "DOUBLE"}, {"name": "L_GLBH", "type": "DOUBLE"}, {"name": "EN_LTZYJ", "type": "DOUBLE"}, {"name": "D_JKRQ", "type": "STRING"}, {"name": "EN_ZRZYJ", "type": "DOUBLE"}, {"name": "EN_CJZCJE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_txg_ptd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_txg_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_txg_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_txg_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TXG_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TXG_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_txg_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TXG_PTD PARTITION(P_DT)
SELECT
       L_ID
     , L_ZTBH
     , VC_GDDM
     , VC_XWDM
     , L_ZQNM
     , VC_ZQDM
     , L_SCLB
     , L_PZID
     , L_CLBZ
     , L_SGID
     , L_YWLB
     , L_TZLX
     , VC_YSZQDM
     , D_CJRQ
     , EN_CJJG
     , EN_CJJE
     , VC_CJBH
     , VC_SQBH
     , EN_CJSL
     , VC_BZ
     , VC_JSBZ
     , EN_EXCH
     , C_YWMS
     , D_RQ
     , VC_GLZQDM
     , L_GLZQNM
     , EN_LTLX
     , EN_LTGZ
     , EN_QSJE
     , EN_CJFY
     , VC_ZHDM
     , C_XWLX
     , VC_LLR
     , VC_FHR
     , VC_BFZH
     , EN_LXSDS
     , EN_GZSDS
     , EN_LXS
     , L_CCFL
     , EN_BWBCJJE
     , EN_BWBLTLX
     , EN_BWBLTGZ
     , EN_BWBLXSDS
     , EN_BWBGZSDS
     , VC_SJLY
     , VC_JYDS
     , L_YTHWHGLBH
     , EN_BWBCJJG
     , EN_BWBCJFY
     , EN_BWBLXS
     , VC_QSBH
     , EN_ZQJKJE
     , C_LTSXGPYWMS
     , EN_ZCZYJ
     , EN_BDQHBJE
     , EN_LXBCJE
     , EN_HBJE
     , EN_YJLL
     , D_MODIFY
     , EN_ZCJZZB
     , L_GLBH
     , EN_LTZYJ
     , D_JKRQ
     , EN_ZRZYJ
     , EN_CJZCJE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_CJRQ,'-','') P_DT
  FROM ODS_XDAY_HSFA.ODS_HSFA_TXG_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TXG_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TXG_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TXG_PTD成功"
      exit 0
   fi
fi
