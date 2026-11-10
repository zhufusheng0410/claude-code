#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_THGJY_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_THGJY_PTD_TMP(
  L_BH  DECIMAL(8,0)  COMMENT  '序号',
  L_ZTBH  STRING  COMMENT  '账套编号',
  L_ZQNM  DECIMAL(8,0)  COMMENT  '证券内码',
  VC_GDDM  STRING  COMMENT  '股东代码',
  VC_XWDM  STRING  COMMENT  '席位代码',
  VC_ZQDM  STRING  COMMENT  '证券代码',
  D_CJRQ  STRING  COMMENT  '交易日期',
  D_JGRI  STRING  COMMENT  '交割日期',
  L_HGSL  DECIMAL(19,4)  COMMENT  '回购数量',
  EN_HGJG  DECIMAL(20,10)  COMMENT  '回购价格',
  EN_HGJE  DECIMAL(20,4)  COMMENT  '回购金额',
  EN_HGFY  DECIMAL(19,4)  COMMENT  '回购费用',
  EN_HGLX  DECIMAL(19,4)  COMMENT  '回购利息',
  L_YJXTS  DECIMAL(4,0)  COMMENT  '应计息天数',
  L_YWLB  STRING  COMMENT  '业务类型',
  L_SCLB  DECIMAL(4,0)  COMMENT  '市场类别',
  L_PZID  STRING  COMMENT  '凭证编号',
  VC_BZ  STRING  COMMENT  '备注',
  EN_FKJE  DECIMAL(20,4)  COMMENT  '返款金额',
  EN_JSSXF  DECIMAL(19,4)  COMMENT  '结算手续费',
  VC_JSBZ  STRING  COMMENT  '结算币种',
  EN_EXCH  DECIMAL(18,14)  COMMENT  '汇率',
  L_OPERATORID  DECIMAL(4,0)  COMMENT  '操作员',
  L_CLBZ  STRING  COMMENT  '处理标志',
  VC_FLBH  STRING  COMMENT  '分类编号',
  L_QSSD  DECIMAL(2,0)  COMMENT  '清算速度',
  L_ZQLX  STRING  COMMENT  '回债债券类型',
  VC_JYDS  STRING  COMMENT  '交易对手',
  VC_FHR  STRING  COMMENT  '复核人',
  VC_LLR  STRING  COMMENT  '录入人',
  L_FHR  DECIMAL(4,0)  COMMENT  '',
  VC_BFZH  STRING  COMMENT  '本方账号',
  VC_DQBFZH  STRING  COMMENT  '到期本方账号',
  L_JYFS  DECIMAL(1,0)  COMMENT  '交易方式',
  EN_NLL  DECIMAL(14,8)  COMMENT  '年利率',
  L_NBJYID  DECIMAL(10,0)  COMMENT  '内部交易流水号',
  EN_YJ  DECIMAL(19,4)  COMMENT  '佣金',
  L_DYQSL  DECIMAL(4,0)  COMMENT  '银行间回购抵押券数量',
  EN_FXJ  DECIMAL(15,4)  COMMENT  '风险金',
  L_CJHBBH  DECIMAL(18,2)  COMMENT  '成交回报编号',
  L_JSJG  DECIMAL(1,0)  COMMENT  '',
  VC_CJBH  STRING  COMMENT  '',
  L_SCJSFS  DECIMAL(4,0)  COMMENT  '',
  L_DQJSFS  DECIMAL(4,0)  COMMENT  '',
  EN_QMZE  DECIMAL(19,4)  COMMENT  '',
  L_CCFL  DECIMAL(4,0)  COMMENT  '',
  L_HYLX  DECIMAL(4,0)  COMMENT  '',
  EN_DQFXJ  DECIMAL(19,4)  COMMENT  '',
  EN_BZJ  DECIMAL(19,4)  COMMENT  '',
  L_TQBZ  DECIMAL(4,0)  COMMENT  '',
  D_CLRDT  STRING  COMMENT  '',
  L_ZQNM2  DECIMAL(8,0)  COMMENT  '',
  VC_ZQDM2  STRING  COMMENT  '',
  L_STATE  DECIMAL(1,0)  COMMENT  '',
  EN_ZYDQLX  DECIMAL(19,4)  COMMENT  '',
  D_SQQSR  STRING  COMMENT  '',
  D_SJDQR  STRING  COMMENT  '',
  EN_SJHGLX  DECIMAL(19,4)  COMMENT  '',
  EN_SJFKJE  DECIMAL(20,4)  COMMENT  '',
  L_DZJYBZ  DECIMAL(1,0)  COMMENT  '',
  L_XSQBZ  DECIMAL(1,0)  COMMENT  '',
  L_CJLX  DECIMAL(1,0)  COMMENT  '',
  D_MODIFY  STRING  COMMENT  '',
  L_FLLX  DECIMAL(1,0)  COMMENT  '',
  EN_HGFY_ZZD  DECIMAL(19,4)  COMMENT  '',
  EN_HGFY_SQS  DECIMAL(19,4)  COMMENT  '',
  EN_JSSXF_ZZD  DECIMAL(19,4)  COMMENT  '',
  EN_JSSXF_SQS  DECIMAL(19,4)  COMMENT  '',
  EN_HGJE_ZZD  DECIMAL(19,4)  COMMENT  '',
  EN_HGJE_SQS  DECIMAL(19,4)  COMMENT  '',
  EN_FKJE_ZZD  DECIMAL(19,4)  COMMENT  '',
  EN_FKJE_SQS  DECIMAL(19,4)  COMMENT  '',
  EN_HGLX_ZZD  DECIMAL(19,4)  COMMENT  '',
  EN_HGLX_SQS  DECIMAL(19,4)  COMMENT  '',
  EN_QMZE_ZZD  DECIMAL(19,4)  COMMENT  '',
  EN_QMZE_SQS  DECIMAL(19,4)  COMMENT  '',
  VC_SJLY  STRING  COMMENT  '',
  EN_ZCJZZB  DECIMAL(19,4)  COMMENT  '',
  L_JZJD  DECIMAL(1,0)  COMMENT  ''
)
COMMENT '回购交易表'
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
                                   , L_ZQNM
                                   , VC_GDDM
                                   , VC_XWDM
                                   , VC_ZQDM
                                   , TO_CHAR(D_CJRQ,'YYYYMMDD') D_CJRQ
                                   , D_JGRI
                                   , L_HGSL
                                   , EN_HGJG
                                   , EN_HGJE
                                   , EN_HGFY
                                   , EN_HGLX
                                   , L_YJXTS
                                   , L_YWLB
                                   , L_SCLB
                                   , L_PZID
                                   , VC_BZ
                                   , EN_FKJE
                                   , EN_JSSXF
                                   , VC_JSBZ
                                   , EN_EXCH
                                   , L_OPERATORID
                                   , L_CLBZ
                                   , VC_FLBH
                                   , L_QSSD
                                   , L_ZQLX
                                   , VC_JYDS
                                   , VC_FHR
                                   , VC_LLR
                                   , L_FHR
                                   , VC_BFZH
                                   , VC_DQBFZH
                                   , L_JYFS
                                   , EN_NLL
                                   , L_NBJYID
                                   , EN_YJ
                                   , L_DYQSL
                                   , EN_FXJ
                                   , L_CJHBBH
                                   , L_JSJG
                                   , VC_CJBH
                                   , L_SCJSFS
                                   , L_DQJSFS
                                   , EN_QMZE
                                   , L_CCFL
                                   , L_HYLX
                                   , EN_DQFXJ
                                   , EN_BZJ
                                   , L_TQBZ
                                   , D_CLRDT
                                   , L_ZQNM2
                                   , VC_ZQDM2
                                   , L_STATE
                                   , EN_ZYDQLX
                                   , D_SQQSR
                                   , D_SJDQR
                                   , EN_SJHGLX
                                   , EN_SJFKJE
                                   , L_DZJYBZ
                                   , L_XSQBZ
                                   , L_CJLX
                                   , D_MODIFY
                                   , L_FLLX
                                   , EN_HGFY_ZZD
                                   , EN_HGFY_SQS
                                   , EN_JSSXF_ZZD
                                   , EN_JSSXF_SQS
                                   , EN_HGJE_ZZD
                                   , EN_HGJE_SQS
                                   , EN_FKJE_ZZD
                                   , EN_FKJE_SQS
                                   , EN_HGLX_ZZD
                                   , EN_HGLX_SQS
                                   , EN_QMZE_ZZD
                                   , EN_QMZE_SQS
                                   , VC_SJLY
                                   , EN_ZCJZZB
                                   , L_JZJD
                                FROM ${hsfa_src_schema}.THGJY
                                WHERE D_CJRQ between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_BH", "type": "DOUBLE"}, {"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "L_ZQNM", "type": "DOUBLE"}, {"name": "VC_GDDM", "type": "STRING"}, {"name": "VC_XWDM", "type": "STRING"}, {"name": "VC_ZQDM", "type": "STRING"}, {"name": "D_CJRQ", "type": "STRING"}, {"name": "D_JGRI", "type": "STRING"}, {"name": "L_HGSL", "type": "DOUBLE"}, {"name": "EN_HGJG", "type": "DOUBLE"}, {"name": "EN_HGJE", "type": "DOUBLE"}, {"name": "EN_HGFY", "type": "DOUBLE"}, {"name": "EN_HGLX", "type": "DOUBLE"}, {"name": "L_YJXTS", "type": "DOUBLE"}, {"name": "L_YWLB", "type": "DOUBLE"}, {"name": "L_SCLB", "type": "DOUBLE"}, {"name": "L_PZID", "type": "DOUBLE"}, {"name": "VC_BZ", "type": "STRING"}, {"name": "EN_FKJE", "type": "DOUBLE"}, {"name": "EN_JSSXF", "type": "DOUBLE"}, {"name": "VC_JSBZ", "type": "STRING"}, {"name": "EN_EXCH", "type": "DOUBLE"}, {"name": "L_OPERATORID", "type": "DOUBLE"}, {"name": "L_CLBZ", "type": "DOUBLE"}, {"name": "VC_FLBH", "type": "STRING"}, {"name": "L_QSSD", "type": "DOUBLE"}, {"name": "L_ZQLX", "type": "DOUBLE"}, {"name": "VC_JYDS", "type": "STRING"}, {"name": "VC_FHR", "type": "STRING"}, {"name": "VC_LLR", "type": "STRING"}, {"name": "L_FHR", "type": "DOUBLE"}, {"name": "VC_BFZH", "type": "STRING"}, {"name": "VC_DQBFZH", "type": "STRING"}, {"name": "L_JYFS", "type": "DOUBLE"}, {"name": "EN_NLL", "type": "DOUBLE"}, {"name": "L_NBJYID", "type": "DOUBLE"}, {"name": "EN_YJ", "type": "DOUBLE"}, {"name": "L_DYQSL", "type": "DOUBLE"}, {"name": "EN_FXJ", "type": "DOUBLE"}, {"name": "L_CJHBBH", "type": "DOUBLE"}, {"name": "L_JSJG", "type": "DOUBLE"}, {"name": "VC_CJBH", "type": "STRING"}, {"name": "L_SCJSFS", "type": "DOUBLE"}, {"name": "L_DQJSFS", "type": "DOUBLE"}, {"name": "EN_QMZE", "type": "DOUBLE"}, {"name": "L_CCFL", "type": "DOUBLE"}, {"name": "L_HYLX", "type": "DOUBLE"}, {"name": "EN_DQFXJ", "type": "DOUBLE"}, {"name": "EN_BZJ", "type": "DOUBLE"}, {"name": "L_TQBZ", "type": "DOUBLE"}, {"name": "D_CLRDT", "type": "STRING"}, {"name": "L_ZQNM2", "type": "DOUBLE"}, {"name": "VC_ZQDM2", "type": "STRING"}, {"name": "L_STATE", "type": "DOUBLE"}, {"name": "EN_ZYDQLX", "type": "DOUBLE"}, {"name": "D_SQQSR", "type": "STRING"}, {"name": "D_SJDQR", "type": "STRING"}, {"name": "EN_SJHGLX", "type": "DOUBLE"}, {"name": "EN_SJFKJE", "type": "DOUBLE"}, {"name": "L_DZJYBZ", "type": "DOUBLE"}, {"name": "L_XSQBZ", "type": "DOUBLE"}, {"name": "L_CJLX", "type": "DOUBLE"}, {"name": "D_MODIFY", "type": "STRING"}, {"name": "L_FLLX", "type": "DOUBLE"}, {"name": "EN_HGFY_ZZD", "type": "DOUBLE"}, {"name": "EN_HGFY_SQS", "type": "DOUBLE"}, {"name": "EN_JSSXF_ZZD", "type": "DOUBLE"}, {"name": "EN_JSSXF_SQS", "type": "DOUBLE"}, {"name": "EN_HGJE_ZZD", "type": "DOUBLE"}, {"name": "EN_HGJE_SQS", "type": "DOUBLE"}, {"name": "EN_FKJE_ZZD", "type": "DOUBLE"}, {"name": "EN_FKJE_SQS", "type": "DOUBLE"}, {"name": "EN_HGLX_ZZD", "type": "DOUBLE"}, {"name": "EN_HGLX_SQS", "type": "DOUBLE"}, {"name": "EN_QMZE_ZZD", "type": "DOUBLE"}, {"name": "EN_QMZE_SQS", "type": "DOUBLE"}, {"name": "VC_SJLY", "type": "STRING"}, {"name": "EN_ZCJZZB", "type": "DOUBLE"}, {"name": "L_JZJD", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_thgjy_ptd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_thgjy_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_thgjy_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_thgjy_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_THGJY_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_THGJY_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_thgjy_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_THGJY_PTD PARTITION(P_DT)
SELECT
       L_BH
     , L_ZTBH
     , L_ZQNM
     , VC_GDDM
     , VC_XWDM
     , VC_ZQDM
     , D_CJRQ
     , D_JGRI
     , L_HGSL
     , EN_HGJG
     , EN_HGJE
     , EN_HGFY
     , EN_HGLX
     , L_YJXTS
     , L_YWLB
     , L_SCLB
     , L_PZID
     , VC_BZ
     , EN_FKJE
     , EN_JSSXF
     , VC_JSBZ
     , EN_EXCH
     , L_OPERATORID
     , L_CLBZ
     , VC_FLBH
     , L_QSSD
     , L_ZQLX
     , VC_JYDS
     , VC_FHR
     , VC_LLR
     , L_FHR
     , VC_BFZH
     , VC_DQBFZH
     , L_JYFS
     , EN_NLL
     , L_NBJYID
     , EN_YJ
     , L_DYQSL
     , EN_FXJ
     , L_CJHBBH
     , L_JSJG
     , VC_CJBH
     , L_SCJSFS
     , L_DQJSFS
     , EN_QMZE
     , L_CCFL
     , L_HYLX
     , EN_DQFXJ
     , EN_BZJ
     , L_TQBZ
     , D_CLRDT
     , L_ZQNM2
     , VC_ZQDM2
     , L_STATE
     , EN_ZYDQLX
     , D_SQQSR
     , D_SJDQR
     , EN_SJHGLX
     , EN_SJFKJE
     , L_DZJYBZ
     , L_XSQBZ
     , L_CJLX
     , D_MODIFY
     , L_FLLX
     , EN_HGFY_ZZD
     , EN_HGFY_SQS
     , EN_JSSXF_ZZD
     , EN_JSSXF_SQS
     , EN_HGJE_ZZD
     , EN_HGJE_SQS
     , EN_FKJE_ZZD
     , EN_FKJE_SQS
     , EN_HGLX_ZZD
     , EN_HGLX_SQS
     , EN_QMZE_ZZD
     , EN_QMZE_SQS
     , VC_SJLY
     , EN_ZCJZZB
     , L_JZJD
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_CJRQ,'-','') P_DT
  FROM ODS_XDAY_HSFA.ODS_HSFA_THGJY_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_THGJY_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_THGJY_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_THGJY_PTD成功"
      exit 0
   fi
fi
