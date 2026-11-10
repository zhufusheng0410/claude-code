#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TPROFITSCHEMA_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TPROFITSCHEMA_PFD_TMP(
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  D_REGISTERDATE  STRING  COMMENT  '登记日期',
  F_UNITPROFIT  DECIMAL(16,8)  COMMENT  '每单位分红',
  D_DISTRIBUTEDATE  STRING  COMMENT  '红利发放日期',
  D_REINVESTDATE  STRING  COMMENT  '再投资日期',
  C_DESCRIBE  STRING  COMMENT  '方案描述',
  C_DEALFLAG  STRING  COMMENT  '分红处理标志',
  F_INCOMETAX  DECIMAL(5,4)  COMMENT  '所得税率',
  C_FBALANCEFLAG  STRING  COMMENT  '是否冻结现金',
  C_FSHARESFLAG  STRING  COMMENT  '是否冻结份额',
  C_FORCEREDEEM  STRING  COMMENT  '冻结是否强制再投资',
  C_BONUSTYPE  STRING  COMMENT  '分红方式',
  F_TOTALPROFIT  DECIMAL(16,2)  COMMENT  '业绩报酬总金额',
  C_FLAG  STRING  COMMENT  '是否已经发起',
  L_LISTEDNUM  DECIMAL(10,0)  COMMENT  '新股上市只数',
  C_FROMFLAG  STRING  COMMENT  '发起标志',
  C_OUTFUNDCODE  STRING  COMMENT  '对外基金代码',
  C_RATIOTYPE  STRING  COMMENT  '收益率方式',
  F_EXPECTRATIO  DECIMAL(5,4)  COMMENT  '预期收益率',
  C_YEARDAYS  STRING  COMMENT  '年天数标准',
  C_ISBOND  STRING  COMMENT  '',
  C_SCHEMANO  STRING  COMMENT  '分红方案编号',
  C_ONLINEINPUTDATE  STRING  COMMENT  '录入日期',
  C_DEDUCTLASTSHARES  STRING  COMMENT  '',
  C_BONUSDETAIL  STRING  COMMENT  '',
  C_CALINCOMEDAYTYPE  STRING  COMMENT  '',
  D_BEGININCOMEDATE  STRING  COMMENT  '',
  D_ENDINCOMEDATE  STRING  COMMENT  '',
  C_CHECK  STRING  COMMENT  '',
  F_FLOORBONUS  DECIMAL(15,12)  COMMENT  '',
  C_GETRATIOTYPE  STRING  COMMENT  '',
  C_SHAREINVESTTYPE  STRING  COMMENT  '',
  D_XRDATE  STRING  COMMENT  '',
  C_INVESTSHAREFORCERDM  STRING  COMMENT  '',
  C_ISFUNDEND  STRING  COMMENT  '',
  C_INPUTPERSONNEL  STRING  COMMENT  '',
  L_MININTERVALDAYS  DECIMAL(10,0)  COMMENT  '',
  C_INTERVALTYPE  STRING  COMMENT  '',
  C_CHECKPERSONNEL  STRING  COMMENT  '',
  C_BOUNSTAILDECIMAL  STRING  COMMENT  '',
  C_PROFITFLAG  STRING  COMMENT  '',
  C_BONUSFLAG  STRING  COMMENT  '',
  D_INCSHAREDATE  STRING  COMMENT  '',
  C_KEEPLASTDEDUCTDATE  STRING  COMMENT  '',
  D_ORIREGISTERDATE  STRING  COMMENT  '',
  D_ORIREINVESTDATE  STRING  COMMENT  '',
  C_INVESTNETVALUETYPE  STRING  COMMENT  ''
)
COMMENT '基金分红方案'
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
            "username": "${hszta_username}",
            "password": "${hszta_password}",
            "connection": [{
              "querySql": ["SELECT  C_FUNDCODE
                                   , D_REGISTERDATE
                                   , F_UNITPROFIT
                                   , D_DISTRIBUTEDATE
                                   , D_REINVESTDATE
                                   , C_DESCRIBE
                                   , C_DEALFLAG
                                   , F_INCOMETAX
                                   , C_FBALANCEFLAG
                                   , C_FSHARESFLAG
                                   , C_FORCEREDEEM
                                   , C_BONUSTYPE
                                   , F_TOTALPROFIT
                                   , C_FLAG
                                   , L_LISTEDNUM
                                   , C_FROMFLAG
                                   , C_OUTFUNDCODE
                                   , C_RATIOTYPE
                                   , F_EXPECTRATIO
                                   , C_YEARDAYS
                                   , C_ISBOND
                                   , C_SCHEMANO
                                   , C_ONLINEINPUTDATE
                                   , C_DEDUCTLASTSHARES
                                   , C_BONUSDETAIL
                                   , C_CALINCOMEDAYTYPE
                                   , D_BEGININCOMEDATE
                                   , D_ENDINCOMEDATE
                                   , C_CHECK
                                   , F_FLOORBONUS
                                   , C_GETRATIOTYPE
                                   , C_SHAREINVESTTYPE
                                   , D_XRDATE
                                   , C_INVESTSHAREFORCERDM
                                   , C_ISFUNDEND
                                   , C_INPUTPERSONNEL
                                   , L_MININTERVALDAYS
                                   , C_INTERVALTYPE
                                   , C_CHECKPERSONNEL
                                   , C_BOUNSTAILDECIMAL
                                   , C_PROFITFLAG
                                   , C_BONUSFLAG
                                   , D_INCSHAREDATE
                                   , C_KEEPLASTDEDUCTDATE
                                   , D_ORIREGISTERDATE
                                   , D_ORIREINVESTDATE
                                   , C_INVESTNETVALUETYPE
                                FROM ${hszta_src_schema}.TPROFITSCHEMA"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDCODE", "type": "STRING"}, {"name": "D_REGISTERDATE", "type": "STRING"}, {"name": "F_UNITPROFIT", "type": "DOUBLE"}, {"name": "D_DISTRIBUTEDATE", "type": "STRING"}, {"name": "D_REINVESTDATE", "type": "STRING"}, {"name": "C_DESCRIBE", "type": "STRING"}, {"name": "C_DEALFLAG", "type": "STRING"}, {"name": "F_INCOMETAX", "type": "DOUBLE"}, {"name": "C_FBALANCEFLAG", "type": "STRING"}, {"name": "C_FSHARESFLAG", "type": "STRING"}, {"name": "C_FORCEREDEEM", "type": "STRING"}, {"name": "C_BONUSTYPE", "type": "STRING"}, {"name": "F_TOTALPROFIT", "type": "DOUBLE"}, {"name": "C_FLAG", "type": "STRING"}, {"name": "L_LISTEDNUM", "type": "DOUBLE"}, {"name": "C_FROMFLAG", "type": "STRING"}, {"name": "C_OUTFUNDCODE", "type": "STRING"}, {"name": "C_RATIOTYPE", "type": "STRING"}, {"name": "F_EXPECTRATIO", "type": "DOUBLE"}, {"name": "C_YEARDAYS", "type": "STRING"}, {"name": "C_ISBOND", "type": "STRING"}, {"name": "C_SCHEMANO", "type": "STRING"}, {"name": "C_ONLINEINPUTDATE", "type": "STRING"}, {"name": "C_DEDUCTLASTSHARES", "type": "STRING"}, {"name": "C_BONUSDETAIL", "type": "STRING"}, {"name": "C_CALINCOMEDAYTYPE", "type": "STRING"}, {"name": "D_BEGININCOMEDATE", "type": "STRING"}, {"name": "D_ENDINCOMEDATE", "type": "STRING"}, {"name": "C_CHECK", "type": "STRING"}, {"name": "F_FLOORBONUS", "type": "DOUBLE"}, {"name": "C_GETRATIOTYPE", "type": "STRING"}, {"name": "C_SHAREINVESTTYPE", "type": "STRING"}, {"name": "D_XRDATE", "type": "STRING"}, {"name": "C_INVESTSHAREFORCERDM", "type": "STRING"}, {"name": "C_ISFUNDEND", "type": "STRING"}, {"name": "C_INPUTPERSONNEL", "type": "STRING"}, {"name": "L_MININTERVALDAYS", "type": "DOUBLE"}, {"name": "C_INTERVALTYPE", "type": "STRING"}, {"name": "C_CHECKPERSONNEL", "type": "STRING"}, {"name": "C_BOUNSTAILDECIMAL", "type": "STRING"}, {"name": "C_PROFITFLAG", "type": "STRING"}, {"name": "C_BONUSFLAG", "type": "STRING"}, {"name": "D_INCSHAREDATE", "type": "STRING"}, {"name": "C_KEEPLASTDEDUCTDATE", "type": "STRING"}, {"name": "D_ORIREGISTERDATE", "type": "STRING"}, {"name": "D_ORIREINVESTDATE", "type": "STRING"}, {"name": "C_INVESTNETVALUETYPE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tprofitschema_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tprofitschema_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tprofitschema_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tprofitschema_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TPROFITSCHEMA_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TPROFITSCHEMA_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tprofitschema_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TPROFITSCHEMA_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_FUNDCODE
     , D_REGISTERDATE
     , F_UNITPROFIT
     , D_DISTRIBUTEDATE
     , D_REINVESTDATE
     , C_DESCRIBE
     , C_DEALFLAG
     , F_INCOMETAX
     , C_FBALANCEFLAG
     , C_FSHARESFLAG
     , C_FORCEREDEEM
     , C_BONUSTYPE
     , F_TOTALPROFIT
     , C_FLAG
     , L_LISTEDNUM
     , C_FROMFLAG
     , C_OUTFUNDCODE
     , C_RATIOTYPE
     , F_EXPECTRATIO
     , C_YEARDAYS
     , C_ISBOND
     , C_SCHEMANO
     , C_ONLINEINPUTDATE
     , C_DEDUCTLASTSHARES
     , C_BONUSDETAIL
     , C_CALINCOMEDAYTYPE
     , D_BEGININCOMEDATE
     , D_ENDINCOMEDATE
     , C_CHECK
     , F_FLOORBONUS
     , C_GETRATIOTYPE
     , C_SHAREINVESTTYPE
     , D_XRDATE
     , C_INVESTSHAREFORCERDM
     , C_ISFUNDEND
     , C_INPUTPERSONNEL
     , L_MININTERVALDAYS
     , C_INTERVALTYPE
     , C_CHECKPERSONNEL
     , C_BOUNSTAILDECIMAL
     , C_PROFITFLAG
     , C_BONUSFLAG
     , D_INCSHAREDATE
     , C_KEEPLASTDEDUCTDATE
     , D_ORIREGISTERDATE
     , D_ORIREINVESTDATE
     , C_INVESTNETVALUETYPE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TPROFITSCHEMA_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TPROFITSCHEMA_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TPROFITSCHEMA_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TPROFITSCHEMA_PFD成功"
      exit 0
   fi
fi
