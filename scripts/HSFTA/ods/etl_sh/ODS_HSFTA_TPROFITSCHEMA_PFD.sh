#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TPROFITSCHEMA_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TPROFITSCHEMA_PFD_TMP(
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  D_REGISTERDATE  STRING  COMMENT  '登记日期',
  F_UNITPROFIT  DECIMAL(7,4)  COMMENT  '每单位分红',
  D_DISTRIBUTEDATE  STRING  COMMENT  '红利发放日期',
  D_REINVESTDATE  STRING  COMMENT  '再投资日期',
  C_DESCRIBE  STRING  COMMENT  '方案描述',
  C_DEALFLAG  STRING  COMMENT  '分红处理标志',
  F_INCOMETAX  DECIMAL(5,4)  COMMENT  '所得税率',
  C_FBALANCEFLAG  STRING  COMMENT  '是否冻结现金',
  C_FSHARESFLAG  STRING  COMMENT  '是否冻结份额',
  C_FORCEREDEEM  STRING  COMMENT  '冻结是否强制再投资',
  C_MEMO  STRING  COMMENT  '备注',
  C_BONUSTYPE  STRING  COMMENT  '分红方式',
  F_TOTALPROFIT  DECIMAL(16,2)  COMMENT  '红利总额',
  C_FLAG  STRING  COMMENT  '是否已经发起',
  L_LISTEDNUM  DECIMAL(10,0)  COMMENT  '新股上市只数',
  C_FROMFLAG  STRING  COMMENT  '发起标志',
  F_TOTALSHARES  DECIMAL(16,2)  COMMENT  '累计赎回实现份额',
  C_PROFITSCHEMATYPE  STRING  COMMENT  '',
  C_FUNDEND  STRING  COMMENT  '',
  C_LASTFUNDEND  STRING  COMMENT  '',
  F_FACTUNITPROFIT  DECIMAL(17,14)  COMMENT  '',
  C_YEARDAYSTYPE  STRING  COMMENT  '',
  C_LOFPRECISION  STRING  COMMENT  '',
  C_LOFBONUSTYPE  STRING  COMMENT  '',
  C_DIVIDENDDETAILMODE  STRING  COMMENT  '',
  C_FLOORTYPE  STRING  COMMENT  '',
  C_REINVESTMODE  STRING  COMMENT  '',
  C_UPDATELASTDEDUCTDATE  STRING  COMMENT  '',
  D_XRDATE  STRING  COMMENT  ''
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
            "username": "${hsfta_username}",
            "password": "${hsfta_password}",
            "connection": [{
              "querySql": ["SELECT  C_FUNDCODE
                                   , TO_CHAR(D_REGISTERDATE,'YYYYMMDD') D_REGISTERDATE
                                   , F_UNITPROFIT
                                   , D_DISTRIBUTEDATE
                                   , D_REINVESTDATE
                                   , C_DESCRIBE
                                   , C_DEALFLAG
                                   , F_INCOMETAX
                                   , C_FBALANCEFLAG
                                   , C_FSHARESFLAG
                                   , C_FORCEREDEEM
                                   , C_MEMO
                                   , C_BONUSTYPE
                                   , F_TOTALPROFIT
                                   , C_FLAG
                                   , L_LISTEDNUM
                                   , C_FROMFLAG
                                   , F_TOTALSHARES
                                   , C_PROFITSCHEMATYPE
                                   , C_FUNDEND
                                   , C_LASTFUNDEND
                                   , F_FACTUNITPROFIT
                                   , C_YEARDAYSTYPE
                                   , C_LOFPRECISION
                                   , C_LOFBONUSTYPE
                                   , C_DIVIDENDDETAILMODE
                                   , C_FLOORTYPE
                                   , C_REINVESTMODE
                                   , C_UPDATELASTDEDUCTDATE
                                   , D_XRDATE
                                FROM ${hsfta_src_schema}.TPROFITSCHEMA"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDCODE", "type": "STRING"}, {"name": "D_REGISTERDATE", "type": "STRING"}, {"name": "F_UNITPROFIT", "type": "DOUBLE"}, {"name": "D_DISTRIBUTEDATE", "type": "STRING"}, {"name": "D_REINVESTDATE", "type": "STRING"}, {"name": "C_DESCRIBE", "type": "STRING"}, {"name": "C_DEALFLAG", "type": "STRING"}, {"name": "F_INCOMETAX", "type": "DOUBLE"}, {"name": "C_FBALANCEFLAG", "type": "STRING"}, {"name": "C_FSHARESFLAG", "type": "STRING"}, {"name": "C_FORCEREDEEM", "type": "STRING"}, {"name": "C_MEMO", "type": "STRING"}, {"name": "C_BONUSTYPE", "type": "STRING"}, {"name": "F_TOTALPROFIT", "type": "DOUBLE"}, {"name": "C_FLAG", "type": "STRING"}, {"name": "L_LISTEDNUM", "type": "DOUBLE"}, {"name": "C_FROMFLAG", "type": "STRING"}, {"name": "F_TOTALSHARES", "type": "DOUBLE"}, {"name": "C_PROFITSCHEMATYPE", "type": "STRING"}, {"name": "C_FUNDEND", "type": "STRING"}, {"name": "C_LASTFUNDEND", "type": "STRING"}, {"name": "F_FACTUNITPROFIT", "type": "DOUBLE"}, {"name": "C_YEARDAYSTYPE", "type": "STRING"}, {"name": "C_LOFPRECISION", "type": "STRING"}, {"name": "C_LOFBONUSTYPE", "type": "STRING"}, {"name": "C_DIVIDENDDETAILMODE", "type": "STRING"}, {"name": "C_FLOORTYPE", "type": "STRING"}, {"name": "C_REINVESTMODE", "type": "STRING"}, {"name": "C_UPDATELASTDEDUCTDATE", "type": "STRING"}, {"name": "D_XRDATE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_tprofitschema_pfd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_tprofitschema_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_tprofitschema_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_tprofitschema_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TPROFITSCHEMA_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TPROFITSCHEMA_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_tprofitschema_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TPROFITSCHEMA_PFD PARTITION(P_DT='${p_end_dt}')
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
     , C_MEMO
     , C_BONUSTYPE
     , F_TOTALPROFIT
     , C_FLAG
     , L_LISTEDNUM
     , C_FROMFLAG
     , F_TOTALSHARES
     , C_PROFITSCHEMATYPE
     , C_FUNDEND
     , C_LASTFUNDEND
     , F_FACTUNITPROFIT
     , C_YEARDAYSTYPE
     , C_LOFPRECISION
     , C_LOFBONUSTYPE
     , C_DIVIDENDDETAILMODE
     , C_FLOORTYPE
     , C_REINVESTMODE
     , C_UPDATELASTDEDUCTDATE
     , D_XRDATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TPROFITSCHEMA_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TPROFITSCHEMA_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TPROFITSCHEMA_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TPROFITSCHEMA_PFD成功"
      exit 0
   fi
fi
