#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_MAINOPERINCOME_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_MAINOPERINCOME_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  COMPANYCODE  STRING  COMMENT  '公司代码',
  ENDDATE  STRING  COMMENT  '日期',
  DATETYPE  STRING  COMMENT  '日期类型',
  INFOSOURCE  STRING  COMMENT  '信息来源',
  IFMERGED  STRING  COMMENT  '合并标志',
  IFADJUSTED  DECIMAL(10,0)  COMMENT  '是否调整',
  CLASSIFICATION  DECIMAL(10,0)  COMMENT  '行业级别',
  SN  DECIMAL(10,0)  COMMENT  '显示序号',
  PROJECT  STRING  COMMENT  '经营项目名称',
  INDUSTRY  DECIMAL(10,0)  COMMENT  '所属行业',
  REGIONANDBUSINESS  DECIMAL(10,0)  COMMENT  '地区与业务性质',
  MAINOPERINCOME  DECIMAL(19,4)  COMMENT  '主营业务收入(元)',
  MAINOPERCOST  DECIMAL(19,4)  COMMENT  '主营业务成本(元)',
  MAINOPERPROFIT  DECIMAL(19,4)  COMMENT  '主营业务利润(元)',
  MAINOPERINCOMEFORMERYEAR  DECIMAL(19,4)  COMMENT  '上年同期主营业务收入(元)',
  MAINOPERCOSTFORMERYEAR  DECIMAL(19,4)  COMMENT  '上年同期主营业务成本(元)',
  MAINOPERPROFITFORMERYEAR  DECIMAL(19,4)  COMMENT  '上年同期主营业务利润(元)',
  MAININCOMEGROWRATEYOY  DECIMAL(18,4)  COMMENT  '主营业务收入同比',
  MAINICOSTGROWRATEYOY  DECIMAL(18,4)  COMMENT  '主营业务成本同比',
  MAINPROFITGROWRATEYOY  DECIMAL(18,4)  COMMENT  '主营业务利润同比',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  GROSSPROFIT  DECIMAL(14,8)  COMMENT  '主营业务利润(元)',
  GROSSPROFITYOY  DECIMAL(18,4)  COMMENT  '毛利率同比',
  INSERTTIME  STRING  COMMENT  '发布时间',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  INFOSOURCECODE  STRING  COMMENT  '信息来源编码',
  CURRENCYUNIT  DECIMAL(10,0)  COMMENT  '货币单位',
  LEVEL  DECIMAL(10,0)  COMMENT  '所属层级',
  PARENTNAME  STRING  COMMENT  '上级科目名称',
  GROSSPROFITFORMERYEAR  DECIMAL(14,8)  COMMENT  '上年同期毛利率',
  GROSSPROFITINCREASE  DECIMAL(14,8)  COMMENT  '毛利率比上年同期增减'
)
COMMENT '公司主营业务构成'
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
                                   , COMPANYCODE
                                   , ENDDATE
                                   , DATETYPE
                                   , INFOSOURCE
                                   , IFMERGED
                                   , IFADJUSTED
                                   , CLASSIFICATION
                                   , SN
                                   , PROJECT
                                   , INDUSTRY
                                   , REGIONANDBUSINESS
                                   , MAINOPERINCOME
                                   , MAINOPERCOST
                                   , MAINOPERPROFIT
                                   , MAINOPERINCOMEFORMERYEAR
                                   , MAINOPERCOSTFORMERYEAR
                                   , MAINOPERPROFITFORMERYEAR
                                   , MAININCOMEGROWRATEYOY
                                   , MAINICOSTGROWRATEYOY
                                   , MAINPROFITGROWRATEYOY
                                   , XGRQ
                                   , JSID
                                   , GROSSPROFIT
                                   , GROSSPROFITYOY
                                   , INSERTTIME
                                   , INFOPUBLDATE
                                   , INFOSOURCECODE
                                   , CURRENCYUNIT
                                   , \"LEVEL\"
                                   , PARENTNAME
                                   , GROSSPROFITFORMERYEAR
                                   , GROSSPROFITINCREASE
                                FROM ${jy_src_schema}.LC_MAINOPERINCOME"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "COMPANYCODE", "type": "DOUBLE"}, {"name": "ENDDATE", "type": "STRING"}, {"name": "DATETYPE", "type": "DOUBLE"}, {"name": "INFOSOURCE", "type": "STRING"}, {"name": "IFMERGED", "type": "DOUBLE"}, {"name": "IFADJUSTED", "type": "DOUBLE"}, {"name": "CLASSIFICATION", "type": "DOUBLE"}, {"name": "SN", "type": "DOUBLE"}, {"name": "PROJECT", "type": "STRING"}, {"name": "INDUSTRY", "type": "DOUBLE"}, {"name": "REGIONANDBUSINESS", "type": "DOUBLE"}, {"name": "MAINOPERINCOME", "type": "DOUBLE"}, {"name": "MAINOPERCOST", "type": "DOUBLE"}, {"name": "MAINOPERPROFIT", "type": "DOUBLE"}, {"name": "MAINOPERINCOMEFORMERYEAR", "type": "DOUBLE"}, {"name": "MAINOPERCOSTFORMERYEAR", "type": "DOUBLE"}, {"name": "MAINOPERPROFITFORMERYEAR", "type": "DOUBLE"}, {"name": "MAININCOMEGROWRATEYOY", "type": "DOUBLE"}, {"name": "MAINICOSTGROWRATEYOY", "type": "DOUBLE"}, {"name": "MAINPROFITGROWRATEYOY", "type": "DOUBLE"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "GROSSPROFIT", "type": "DOUBLE"}, {"name": "GROSSPROFITYOY", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "INFOSOURCECODE", "type": "DOUBLE"}, {"name": "CURRENCYUNIT", "type": "DOUBLE"}, {"name": "LEVEL", "type": "DOUBLE"}, {"name": "PARENTNAME", "type": "STRING"}, {"name": "GROSSPROFITFORMERYEAR", "type": "DOUBLE"}, {"name": "GROSSPROFITINCREASE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_mainoperincome_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_mainoperincome_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_mainoperincome_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_mainoperincome_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_MAINOPERINCOME_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_MAINOPERINCOME_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_mainoperincome_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_MAINOPERINCOME_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , COMPANYCODE
     , ENDDATE
     , DATETYPE
     , INFOSOURCE
     , IFMERGED
     , IFADJUSTED
     , CLASSIFICATION
     , SN
     , PROJECT
     , INDUSTRY
     , REGIONANDBUSINESS
     , MAINOPERINCOME
     , MAINOPERCOST
     , MAINOPERPROFIT
     , MAINOPERINCOMEFORMERYEAR
     , MAINOPERCOSTFORMERYEAR
     , MAINOPERPROFITFORMERYEAR
     , MAININCOMEGROWRATEYOY
     , MAINICOSTGROWRATEYOY
     , MAINPROFITGROWRATEYOY
     , XGRQ
     , JSID
     , GROSSPROFIT
     , GROSSPROFITYOY
     , INSERTTIME
     , INFOPUBLDATE
     , INFOSOURCECODE
     , CURRENCYUNIT
     , LEVEL
     , PARENTNAME
     , GROSSPROFITFORMERYEAR
     , GROSSPROFITINCREASE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_LC_MAINOPERINCOME_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_MAINOPERINCOME_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_MAINOPERINCOME_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_MAINOPERINCOME_PFD成功"
      exit 0
   fi
fi
