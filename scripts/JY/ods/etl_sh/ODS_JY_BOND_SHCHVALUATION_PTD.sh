#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_SHCHVALUATION_PTD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_SHCHVALUATION_PTD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  ENDDATE  STRING  COMMENT  '日期',
  VALUEFULLPRICE  DECIMAL(18,10)  COMMENT  '估价全价',
  ACCRUINTEREST  DECIMAL(18,12)  COMMENT  '应计利息',
  VALUECLEANPRICE  DECIMAL(18,10)  COMMENT  '估价净价',
  VPYIELD  DECIMAL(18,12)  COMMENT  '估价收益率(%)',
  VPADURATION  DECIMAL(18,10)  COMMENT  '估价修正久期',
  VPCONVEXITY  DECIMAL(18,10)  COMMENT  '估价凸性',
  VPPOINTVALUE  DECIMAL(18,10)  COMMENT  '估价基点价值',
  VPINTERESTDURATION  DECIMAL(18,10)  COMMENT  '估价利率久期',
  VPINTERESTCONVEXITY  DECIMAL(18,10)  COMMENT  '估价利率凸性',
  VPSPREADDURATION  DECIMAL(18,10)  COMMENT  '估价利差久期',
  VPSPREADCONVEXITY  DECIMAL(18,10)  COMMENT  '估价利差凸性',
  TRUEFULLPRICE  DECIMAL(18,10)  COMMENT  '加权平均结算全价(真实全价)(元)',
  TRUECLEANPRICE  DECIMAL(18,10)  COMMENT  '加权平均结算净价(真实净价)(元)',
  TRUEYIELD  DECIMAL(18,12)  COMMENT  '加权平均结算价收益率(真实收益率)',
  TRUEREMAINMATURITY  DECIMAL(18,10)  COMMENT  '实际待偿期(年)',
  TRUEADURATION  DECIMAL(18,10)  COMMENT  '加权平均结算价修正久期(真实修正久期)',
  TRUECONVEXITY  DECIMAL(18,10)  COMMENT  '凸性',
  TRUEPOINTVALUE  DECIMAL(18,10)  COMMENT  '加权平均结算价基点价值(真实基点价值)',
  TRUEINTERESTDURATION  DECIMAL(18,10)  COMMENT  '加权平均结算价利率久期(真实利率久期)',
  TRUEINTERESTCONVEXITY  DECIMAL(18,10)  COMMENT  '加权平均结算价利率凸性(真实利率凸性)',
  TRUESPREADDURATION  DECIMAL(18,10)  COMMENT  '加权平均结算价利差久期(真实利差久期)',
  TRUESPREADCONVEXITY  DECIMAL(18,10)  COMMENT  '加权平均结算价利差凸性(真实利差凸性)',
  SETTFULLPRICE  DECIMAL(18,10)  COMMENT  '日终估价全价',
  SETTACCRUINTEREST  DECIMAL(18,12)  COMMENT  '日终应计利息',
  RESIDUALCAPITAL  DECIMAL(18,10)  COMMENT  '剩余本金(元)',
  CREDIBILITYCODE  STRING  COMMENT  '可信度代码',
  CREDIBILITYDESC  STRING  COMMENT  '可信度描述',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID'
)
COMMENT '上清所债券估值'
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
            "username": "${jy_username}",
            "password": "${jy_password}",
            "connection": [{
              "querySql": ["SELECT  ID
                                   , INNERCODE
                                   , TO_CHAR(ENDDATE,'YYYYMMDD') ENDDATE
                                   , VALUEFULLPRICE
                                   , ACCRUINTEREST
                                   , VALUECLEANPRICE
                                   , VPYIELD
                                   , VPADURATION
                                   , VPCONVEXITY
                                   , VPPOINTVALUE
                                   , VPINTERESTDURATION
                                   , VPINTERESTCONVEXITY
                                   , VPSPREADDURATION
                                   , VPSPREADCONVEXITY
                                   , TRUEFULLPRICE
                                   , TRUECLEANPRICE
                                   , TRUEYIELD
                                   , TRUEREMAINMATURITY
                                   , TRUEADURATION
                                   , TRUECONVEXITY
                                   , TRUEPOINTVALUE
                                   , TRUEINTERESTDURATION
                                   , TRUEINTERESTCONVEXITY
                                   , TRUESPREADDURATION
                                   , TRUESPREADCONVEXITY
                                   , SETTFULLPRICE
                                   , SETTACCRUINTEREST
                                   , RESIDUALCAPITAL
                                   , CREDIBILITYCODE
                                   , CREDIBILITYDESC
                                   , UPDATETIME
                                   , JSID
                                FROM ${jy_src_schema}.BOND_SHCHVALUATION
                                WHERE ENDDATE between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "ENDDATE", "type": "STRING"}, {"name": "VALUEFULLPRICE", "type": "DOUBLE"}, {"name": "ACCRUINTEREST", "type": "DOUBLE"}, {"name": "VALUECLEANPRICE", "type": "DOUBLE"}, {"name": "VPYIELD", "type": "DOUBLE"}, {"name": "VPADURATION", "type": "DOUBLE"}, {"name": "VPCONVEXITY", "type": "DOUBLE"}, {"name": "VPPOINTVALUE", "type": "DOUBLE"}, {"name": "VPINTERESTDURATION", "type": "DOUBLE"}, {"name": "VPINTERESTCONVEXITY", "type": "DOUBLE"}, {"name": "VPSPREADDURATION", "type": "DOUBLE"}, {"name": "VPSPREADCONVEXITY", "type": "DOUBLE"}, {"name": "TRUEFULLPRICE", "type": "DOUBLE"}, {"name": "TRUECLEANPRICE", "type": "DOUBLE"}, {"name": "TRUEYIELD", "type": "DOUBLE"}, {"name": "TRUEREMAINMATURITY", "type": "DOUBLE"}, {"name": "TRUEADURATION", "type": "DOUBLE"}, {"name": "TRUECONVEXITY", "type": "DOUBLE"}, {"name": "TRUEPOINTVALUE", "type": "DOUBLE"}, {"name": "TRUEINTERESTDURATION", "type": "DOUBLE"}, {"name": "TRUEINTERESTCONVEXITY", "type": "DOUBLE"}, {"name": "TRUESPREADDURATION", "type": "DOUBLE"}, {"name": "TRUESPREADCONVEXITY", "type": "DOUBLE"}, {"name": "SETTFULLPRICE", "type": "DOUBLE"}, {"name": "SETTACCRUINTEREST", "type": "DOUBLE"}, {"name": "RESIDUALCAPITAL", "type": "DOUBLE"}, {"name": "CREDIBILITYCODE", "type": "DOUBLE"}, {"name": "CREDIBILITYDESC", "type": "STRING"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_shchvaluation_ptd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_shchvaluation_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_shchvaluation_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_shchvaluation_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_SHCHVALUATION_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_SHCHVALUATION_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_shchvaluation_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_SHCHVALUATION_PTD PARTITION(P_DT)
SELECT
       ID
     , INNERCODE
     , ENDDATE
     , VALUEFULLPRICE
     , ACCRUINTEREST
     , VALUECLEANPRICE
     , VPYIELD
     , VPADURATION
     , VPCONVEXITY
     , VPPOINTVALUE
     , VPINTERESTDURATION
     , VPINTERESTCONVEXITY
     , VPSPREADDURATION
     , VPSPREADCONVEXITY
     , TRUEFULLPRICE
     , TRUECLEANPRICE
     , TRUEYIELD
     , TRUEREMAINMATURITY
     , TRUEADURATION
     , TRUECONVEXITY
     , TRUEPOINTVALUE
     , TRUEINTERESTDURATION
     , TRUEINTERESTCONVEXITY
     , TRUESPREADDURATION
     , TRUESPREADCONVEXITY
     , SETTFULLPRICE
     , SETTACCRUINTEREST
     , RESIDUALCAPITAL
     , CREDIBILITYCODE
     , CREDIBILITYDESC
     , UPDATETIME
     , JSID
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(ENDDATE,'-','') P_DT
  FROM ODS_XDAY_JY.ODS_JY_BOND_SHCHVALUATION_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_SHCHVALUATION_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_SHCHVALUATION_PTD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_SHCHVALUATION_PTD成功"
      exit 0
   fi
fi
