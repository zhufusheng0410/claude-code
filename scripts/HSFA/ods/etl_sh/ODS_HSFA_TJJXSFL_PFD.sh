#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TJJXSFL_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TJJXSFL_PFD_TMP(
  L_ZTBH  STRING  COMMENT  '账套编号',
  VC_JJDM  STRING  COMMENT  '基金代码',
  VC_FJJJDM  STRING  COMMENT  '分级基金代码',
  VC_FJJJMC  STRING  COMMENT  '分级基金名称',
  EN_XSFL  DECIMAL(11,6)  COMMENT  '销售费率',
  VC_DYKMDM  STRING  COMMENT  '对应科目代码',
  VC_SFWFBZ  STRING  COMMENT  '收服务费标志',
  L_YXBZ  DECIMAL(1,0)  COMMENT  '是否优先',
  EN_YXNSYL  DECIMAL(14,8)  COMMENT  '优先年化收益率',
  EN_YXSYBL  DECIMAL(14,8)  COMMENT  '优先收益分配比例',
  VC_FJJB  STRING  COMMENT  '分级级别',
  EN_YQSY  DECIMAL(19,6)  COMMENT  '',
  D_KSRQ  STRING  COMMENT  '',
  D_JSRQ  STRING  COMMENT  '',
  VC_JSBZ  STRING  COMMENT  '',
  VC_ZSCPDM  STRING  COMMENT  '',
  L_FPSY  DECIMAL(1,0)  COMMENT  '',
  VC_FEJB  STRING  COMMENT  '',
  EN_CSDWJZ  DECIMAL(19,10)  COMMENT  '',
  D_TQJSRQ  STRING  COMMENT  '',
  L_YXJLB  DECIMAL(1,0)  COMMENT  '',
  VC_LLR  STRING  COMMENT  '',
  VC_FHR  STRING  COMMENT  '',
  EN_CLRHL  DECIMAL(18,14)  COMMENT  '',
  VC_TABZ  STRING  COMMENT  '',
  EN_CSMZ  DECIMAL(19,6)  COMMENT  '',
  EN_ZSMZ  DECIMAL(19,6)  COMMENT  '',
  VC_DWBSLB  STRING  COMMENT  '',
  EN_DWJZZZLBJJZ  DECIMAL(19,6)  COMMENT  '',
  D_MODIFY  STRING  COMMENT  '',
  L_ZDSCKM  DECIMAL(1,0)  COMMENT  '',
  L_ZDSCSYJZ  DECIMAL(1,0)  COMMENT  '',
  VC_LRJZPD  STRING  COMMENT  '',
  VC_SYPZJJZPD  STRING  COMMENT  '',
  VC_GLJJDM  STRING  COMMENT  ''
)
COMMENT '基金分级设置表'
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
                                   , VC_JJDM
                                   , VC_FJJJDM
                                   , VC_FJJJMC
                                   , EN_XSFL
                                   , VC_DYKMDM
                                   , VC_SFWFBZ
                                   , L_YXBZ
                                   , EN_YXNSYL
                                   , EN_YXSYBL
                                   , VC_FJJB
                                   , EN_YQSY
                                   , D_KSRQ
                                   , D_JSRQ
                                   , VC_JSBZ
                                   , VC_ZSCPDM
                                   , L_FPSY
                                   , VC_FEJB
                                   , EN_CSDWJZ
                                   , D_TQJSRQ
                                   , L_YXJLB
                                   , VC_LLR
                                   , VC_FHR
                                   , EN_CLRHL
                                   , VC_TABZ
                                   , EN_CSMZ
                                   , EN_ZSMZ
                                   , VC_DWBSLB
                                   , EN_DWJZZZLBJJZ
                                   , D_MODIFY
                                   , L_ZDSCKM
                                   , L_ZDSCSYJZ
                                   , VC_LRJZPD
                                   , VC_SYPZJJZPD
                                   , VC_GLJJDM
                                FROM ${hsfa_src_schema}.TJJXSFL"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "VC_JJDM", "type": "STRING"}, {"name": "VC_FJJJDM", "type": "STRING"}, {"name": "VC_FJJJMC", "type": "STRING"}, {"name": "EN_XSFL", "type": "DOUBLE"}, {"name": "VC_DYKMDM", "type": "STRING"}, {"name": "VC_SFWFBZ", "type": "STRING"}, {"name": "L_YXBZ", "type": "DOUBLE"}, {"name": "EN_YXNSYL", "type": "DOUBLE"}, {"name": "EN_YXSYBL", "type": "DOUBLE"}, {"name": "VC_FJJB", "type": "STRING"}, {"name": "EN_YQSY", "type": "DOUBLE"}, {"name": "D_KSRQ", "type": "STRING"}, {"name": "D_JSRQ", "type": "STRING"}, {"name": "VC_JSBZ", "type": "STRING"}, {"name": "VC_ZSCPDM", "type": "STRING"}, {"name": "L_FPSY", "type": "DOUBLE"}, {"name": "VC_FEJB", "type": "STRING"}, {"name": "EN_CSDWJZ", "type": "DOUBLE"}, {"name": "D_TQJSRQ", "type": "STRING"}, {"name": "L_YXJLB", "type": "DOUBLE"}, {"name": "VC_LLR", "type": "STRING"}, {"name": "VC_FHR", "type": "STRING"}, {"name": "EN_CLRHL", "type": "DOUBLE"}, {"name": "VC_TABZ", "type": "STRING"}, {"name": "EN_CSMZ", "type": "DOUBLE"}, {"name": "EN_ZSMZ", "type": "DOUBLE"}, {"name": "VC_DWBSLB", "type": "STRING"}, {"name": "EN_DWJZZZLBJJZ", "type": "DOUBLE"}, {"name": "D_MODIFY", "type": "STRING"}, {"name": "L_ZDSCKM", "type": "DOUBLE"}, {"name": "L_ZDSCSYJZ", "type": "DOUBLE"}, {"name": "VC_LRJZPD", "type": "STRING"}, {"name": "VC_SYPZJJZPD", "type": "STRING"}, {"name": "VC_GLJJDM", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tjjxsfl_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tjjxsfl_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tjjxsfl_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tjjxsfl_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TJJXSFL_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TJJXSFL_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tjjxsfl_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TJJXSFL_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_ZTBH
     , VC_JJDM
     , VC_FJJJDM
     , VC_FJJJMC
     , EN_XSFL
     , VC_DYKMDM
     , VC_SFWFBZ
     , L_YXBZ
     , EN_YXNSYL
     , EN_YXSYBL
     , VC_FJJB
     , EN_YQSY
     , D_KSRQ
     , D_JSRQ
     , VC_JSBZ
     , VC_ZSCPDM
     , L_FPSY
     , VC_FEJB
     , EN_CSDWJZ
     , D_TQJSRQ
     , L_YXJLB
     , VC_LLR
     , VC_FHR
     , EN_CLRHL
     , VC_TABZ
     , EN_CSMZ
     , EN_ZSMZ
     , VC_DWBSLB
     , EN_DWJZZZLBJJZ
     , D_MODIFY
     , L_ZDSCKM
     , L_ZDSCSYJZ
     , VC_LRJZPD
     , VC_SYPZJJZPD
     , VC_GLJJDM
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TJJXSFL_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TJJXSFL_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TJJXSFL_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TJJXSFL_PFD成功"
      exit 0
   fi
fi
