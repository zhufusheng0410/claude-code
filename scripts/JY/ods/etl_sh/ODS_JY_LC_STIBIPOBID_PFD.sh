#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_STIBIPOBID_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_STIBIPOBID_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '内部编码',
  COMPANYCODE  STRING  COMMENT  '公司代码',
  SERIALNUMBER  DECIMAL(10,0)  COMMENT  '序号',
  INVESTORCODE  STRING  COMMENT  '投资者编码',
  INVESTORNAME  STRING  COMMENT  '投资者名称',
  BIDDERCODE  STRING  COMMENT  '配售对象代码',
  BIDDERNAME  STRING  COMMENT  '配售对象名称',
  BIDDERCATEGORY  DECIMAL(10,0)  COMMENT  '配售对象类别',
  PRICEUNIT  DECIMAL(19,4)  COMMENT  '申报价格',
  PLANNEDBIDVOL  DECIMAL(19,2)  COMMENT  '拟申购股数(股)',
  PREMIUMRATE  DECIMAL(19,4)  COMMENT  '申报价折溢价比率',
  BIDVOLEX  DECIMAL(19,2)  COMMENT  '被剔除申购股数(股)',
  ACTUALBIDVOL  DECIMAL(19,2)  COMMENT  '总实际申购股数(股)',
  ACTUALALLOTMENT  DECIMAL(19,2)  COMMENT  '总获配售股数(股)',
  INSERTTIME  STRING  COMMENT  '发布时间',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID'
)
COMMENT '科创板IPO询价明细'
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
                                   , COMPANYCODE
                                   , SERIALNUMBER
                                   , INVESTORCODE
                                   , INVESTORNAME
                                   , BIDDERCODE
                                   , BIDDERNAME
                                   , BIDDERCATEGORY
                                   , PRICEUNIT
                                   , PLANNEDBIDVOL
                                   , PREMIUMRATE
                                   , BIDVOLEX
                                   , ACTUALBIDVOL
                                   , ACTUALALLOTMENT
                                   , INSERTTIME
                                   , UPDATETIME
                                   , JSID
                                FROM ${jy_src_schema}.LC_STIBIPOBID"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "COMPANYCODE", "type": "DOUBLE"}, {"name": "SERIALNUMBER", "type": "DOUBLE"}, {"name": "INVESTORCODE", "type": "DOUBLE"}, {"name": "INVESTORNAME", "type": "STRING"}, {"name": "BIDDERCODE", "type": "DOUBLE"}, {"name": "BIDDERNAME", "type": "STRING"}, {"name": "BIDDERCATEGORY", "type": "DOUBLE"}, {"name": "PRICEUNIT", "type": "DOUBLE"}, {"name": "PLANNEDBIDVOL", "type": "DOUBLE"}, {"name": "PREMIUMRATE", "type": "DOUBLE"}, {"name": "BIDVOLEX", "type": "DOUBLE"}, {"name": "ACTUALBIDVOL", "type": "DOUBLE"}, {"name": "ACTUALALLOTMENT", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_stibipobid_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_stibipobid_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_stibipobid_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_stibipobid_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_STIBIPOBID_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_STIBIPOBID_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_stibipobid_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_STIBIPOBID_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , COMPANYCODE
     , SERIALNUMBER
     , INVESTORCODE
     , INVESTORNAME
     , BIDDERCODE
     , BIDDERNAME
     , BIDDERCATEGORY
     , PRICEUNIT
     , PLANNEDBIDVOL
     , PREMIUMRATE
     , BIDVOLEX
     , ACTUALBIDVOL
     , ACTUALALLOTMENT
     , INSERTTIME
     , UPDATETIME
     , JSID
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_LC_STIBIPOBID_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_STIBIPOBID_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_STIBIPOBID_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_STIBIPOBID_PFD成功"
      exit 0
   fi
fi
