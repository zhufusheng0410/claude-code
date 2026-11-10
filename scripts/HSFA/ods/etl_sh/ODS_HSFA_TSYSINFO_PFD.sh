#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TSYSINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TSYSINFO_PFD_TMP(
  L_ID  DECIMAL(9,0)  COMMENT  '帐套id',
  VC_NAME  STRING  COMMENT  '账套名称',
  VC_FULLNAME  STRING  COMMENT  '账套全称',
  D_CREATE  STRING  COMMENT  '创建日期',
  D_DESTORY  STRING  COMMENT  '终止日期',
  L_TYPE  STRING  COMMENT  '账套类型',
  L_INIT  STRING  COMMENT  '初始化标志',
  L_VOID  DECIMAL(1,0)  COMMENT  '废除标记',
  L_GZBZ  DECIMAL(2,0)  COMMENT  '估值标准',
  VC_ZTLX  STRING  COMMENT  '账套类型',
  L_SJZT  DECIMAL(9,0)  COMMENT  '上级账套',
  L_GLZT  DECIMAL(9,0)  COMMENT  '管理账套',
  EN_MRCFBL  DECIMAL(4,2)  COMMENT  '默认拆分比例',
  L_SQLTYPE  DECIMAL(4,0)  COMMENT  '所用转账公式的SQL账套模板',
  L_CLBZ  STRING  COMMENT  '处理标志',
  VC_CLCZYXM  STRING  COMMENT  '处理操作员姓名',
  L_JCZT  DECIMAL(9,0)  COMMENT  '继承账套',
  L_XTLB  DECIMAL(4,0)  COMMENT  '',
  VC_LLR  STRING  COMMENT  '',
  VC_FHR  STRING  COMMENT  '',
  L_FZLX  DECIMAL(1,0)  COMMENT  '',
  L_XKJZZ  DECIMAL(1,0)  COMMENT  '',
  D_QHRQ  STRING  COMMENT  '',
  VC_KMQHPZ  STRING  COMMENT  '',
  D_CHANGEACC  STRING  COMMENT  '',
  EN_JTLMRCFBL  DECIMAL(4,2)  COMMENT  ''
)
COMMENT '帐套信息表'
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
                                   , VC_NAME
                                   , VC_FULLNAME
                                   , D_CREATE
                                   , D_DESTORY
                                   , L_TYPE
                                   , L_INIT
                                   , L_VOID
                                   , L_GZBZ
                                   , VC_ZTLX
                                   , L_SJZT
                                   , L_GLZT
                                   , EN_MRCFBL
                                   , L_SQLTYPE
                                   , L_CLBZ
                                   , VC_CLCZYXM
                                   , L_JCZT
                                   , L_XTLB
                                   , VC_LLR
                                   , VC_FHR
                                   , L_FZLX
                                   , L_XKJZZ
                                   , D_QHRQ
                                   , VC_KMQHPZ
                                   , D_CHANGEACC
                                   , EN_JTLMRCFBL
                                FROM ${hsfa_src_schema}.TSYSINFO"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ID", "type": "DOUBLE"}, {"name": "VC_NAME", "type": "STRING"}, {"name": "VC_FULLNAME", "type": "STRING"}, {"name": "D_CREATE", "type": "STRING"}, {"name": "D_DESTORY", "type": "STRING"}, {"name": "L_TYPE", "type": "DOUBLE"}, {"name": "L_INIT", "type": "DOUBLE"}, {"name": "L_VOID", "type": "DOUBLE"}, {"name": "L_GZBZ", "type": "DOUBLE"}, {"name": "VC_ZTLX", "type": "STRING"}, {"name": "L_SJZT", "type": "DOUBLE"}, {"name": "L_GLZT", "type": "DOUBLE"}, {"name": "EN_MRCFBL", "type": "DOUBLE"}, {"name": "L_SQLTYPE", "type": "DOUBLE"}, {"name": "L_CLBZ", "type": "DOUBLE"}, {"name": "VC_CLCZYXM", "type": "STRING"}, {"name": "L_JCZT", "type": "DOUBLE"}, {"name": "L_XTLB", "type": "DOUBLE"}, {"name": "VC_LLR", "type": "STRING"}, {"name": "VC_FHR", "type": "STRING"}, {"name": "L_FZLX", "type": "DOUBLE"}, {"name": "L_XKJZZ", "type": "DOUBLE"}, {"name": "D_QHRQ", "type": "STRING"}, {"name": "VC_KMQHPZ", "type": "STRING"}, {"name": "D_CHANGEACC", "type": "STRING"}, {"name": "EN_JTLMRCFBL", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tsysinfo_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tsysinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tsysinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tsysinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TSYSINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TSYSINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tsysinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TSYSINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_ID
     , VC_NAME
     , VC_FULLNAME
     , D_CREATE
     , D_DESTORY
     , L_TYPE
     , L_INIT
     , L_VOID
     , L_GZBZ
     , VC_ZTLX
     , L_SJZT
     , L_GLZT
     , EN_MRCFBL
     , L_SQLTYPE
     , L_CLBZ
     , VC_CLCZYXM
     , L_JCZT
     , L_XTLB
     , VC_LLR
     , VC_FHR
     , L_FZLX
     , L_XKJZZ
     , D_QHRQ
     , VC_KMQHPZ
     , D_CHANGEACC
     , EN_JTLMRCFBL
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TSYSINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TSYSINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TSYSINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TSYSINFO_PFD成功"
      exit 0
   fi
fi
