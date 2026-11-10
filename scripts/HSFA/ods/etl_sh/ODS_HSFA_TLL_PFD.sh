#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TLL_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TLL_PFD_TMP(
  L_BH  STRING  COMMENT  '编号',
  VC_YH  STRING  COMMENT  '银行',
  VC_ZH  STRING  COMMENT  '帐号',
  L_ZTBH  STRING  COMMENT  '帐套编号',
  VC_DYKM  STRING  COMMENT  '对应科目',
  EN_NLL  DECIMAL(12,10)  COMMENT  '年利率',
  L_JXTS  DECIMAL(4,0)  COMMENT  '年记息天数',
  VC_JFKM  STRING  COMMENT  '借方科目',
  VC_DFKM  STRING  COMMENT  '贷方科目',
  D_BEGIN  STRING  COMMENT  '开始日期',
  D_END  STRING  COMMENT  '结束日期',
  L_JZRQ  DECIMAL(2,0)  COMMENT  '记账日期',
  VC_JXLB  STRING  COMMENT  '计息类型',
  VC_LXDZKM  STRING  COMMENT  '结息到账科目',
  VC_LXSDSKM  STRING  COMMENT  '利息所得税科目',
  VC_FHR  STRING  COMMENT  '',
  VC_LLR  STRING  COMMENT  '',
  L_LLLB  DECIMAL(3,0)  COMMENT  '',
  VC_JZLL  STRING  COMMENT  ''
)
COMMENT '存款计息表'
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
                                   , VC_YH
                                   , VC_ZH
                                   , L_ZTBH
                                   , VC_DYKM
                                   , EN_NLL
                                   , L_JXTS
                                   , VC_JFKM
                                   , VC_DFKM
                                   , D_BEGIN
                                   , D_END
                                   , L_JZRQ
                                   , VC_JXLB
                                   , VC_LXDZKM
                                   , VC_LXSDSKM
                                   , VC_FHR
                                   , VC_LLR
                                   , L_LLLB
                                   , VC_JZLL
                                FROM ${hsfa_src_schema}.TLL"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_BH", "type": "DOUBLE"}, {"name": "VC_YH", "type": "STRING"}, {"name": "VC_ZH", "type": "STRING"}, {"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "VC_DYKM", "type": "STRING"}, {"name": "EN_NLL", "type": "DOUBLE"}, {"name": "L_JXTS", "type": "DOUBLE"}, {"name": "VC_JFKM", "type": "STRING"}, {"name": "VC_DFKM", "type": "STRING"}, {"name": "D_BEGIN", "type": "STRING"}, {"name": "D_END", "type": "STRING"}, {"name": "L_JZRQ", "type": "DOUBLE"}, {"name": "VC_JXLB", "type": "STRING"}, {"name": "VC_LXDZKM", "type": "STRING"}, {"name": "VC_LXSDSKM", "type": "STRING"}, {"name": "VC_FHR", "type": "STRING"}, {"name": "VC_LLR", "type": "STRING"}, {"name": "L_LLLB", "type": "DOUBLE"}, {"name": "VC_JZLL", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tll_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tll_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tll_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tll_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TLL_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TLL_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tll_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TLL_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_BH
     , VC_YH
     , VC_ZH
     , L_ZTBH
     , VC_DYKM
     , EN_NLL
     , L_JXTS
     , VC_JFKM
     , VC_DFKM
     , D_BEGIN
     , D_END
     , L_JZRQ
     , VC_JXLB
     , VC_LXDZKM
     , VC_LXSDSKM
     , VC_FHR
     , VC_LLR
     , L_LLLB
     , VC_JZLL
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TLL_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TLL_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TLL_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TLL_PFD成功"
      exit 0
   fi
fi
