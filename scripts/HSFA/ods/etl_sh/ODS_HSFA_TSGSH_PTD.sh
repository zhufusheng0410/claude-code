#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TSGSH_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TSGSH_PTD_TMP(
  L_ID  DECIMAL(10,0)  COMMENT  '序号',
  D_RQ  STRING  COMMENT  '日期',
  L_JGID  DECIMAL(4,0)  COMMENT  '机构ID',
  L_SGSL  DECIMAL(21,6)  COMMENT  '【申购】申购数量',
  EN_SGJE  DECIMAL(19,4)  COMMENT  '【申购】申购金额',
  L_SHSL  DECIMAL(21,6)  COMMENT  '【赎回】赎回数量',
  EN_SHJE  DECIMAL(19,4)  COMMENT  '【赎回】赎回金额',
  EN_JGSHF  DECIMAL(19,4)  COMMENT  '【赎回】机构赎回费',
  EN_JJSHF  DECIMAL(19,4)  COMMENT  '【赎回】基金赎回费',
  L_SGPZID  DECIMAL(8,0)  COMMENT  '申购凭证ID',
  L_SHPZID  DECIMAL(8,0)  COMMENT  '赎回凭证ID',
  L_ZTBH  STRING  COMMENT  '账套编号',
  VC_JGDM  STRING  COMMENT  '机构代码',
  VC_JGMC  STRING  COMMENT  '机构名称',
  L_IMPORT  DECIMAL(2,0)  COMMENT  '数据标记:1:申购',
  D_QRRQ  STRING  COMMENT  '确认日期',
  EN_YJTCJE  DECIMAL(19,4)  COMMENT  '【赎回】已计提成交额',
  EN_WSXSYPZJ  DECIMAL(19,4)  COMMENT  '未实现损益平准金',
  EN_SSWTZC  DECIMAL(19,4)  COMMENT  '实收委托资产金额',
  EN_ZHFSR  DECIMAL(19,4)  COMMENT  '【转出】转换费收入',
  VC_JJDM  STRING  COMMENT  '基金代码/分级基金代码',
  EN_HDSGF  DECIMAL(19,4)  COMMENT  '【赎回】后端申购费',
  L_CLBZ  STRING  COMMENT  '处理标志',
  EN_SHSY  DECIMAL(19,4)  COMMENT  '货币赎回收益',
  EN_BCF  DECIMAL(19,4)  COMMENT  '【转出】补差费',
  EN_WYJ  DECIMAL(19,4)  COMMENT  '【赎回】违约金',
  VC_SYRBH  STRING  COMMENT  '受益人编号',
  EN_TKJE  DECIMAL(19,4)  COMMENT  '退款金额',
  L_ZHLB  DECIMAL(4,0)  COMMENT  '账户类别',
  VC_SYRBH2  STRING  COMMENT  '受益人编号',
  L_SYRLB  DECIMAL(4,0)  COMMENT  '受益人类别:',
  VC_FELB  STRING  COMMENT  '份额类别',
  EN_FEZS  DECIMAL(19,4)  COMMENT  '份额折算',
  VC_DYJJ  STRING  COMMENT  '',
  D_TCRQ  STRING  COMMENT  '',
  L_GLFBH  DECIMAL(10,0)  COMMENT  '',
  L_TGFBH  DECIMAL(10,0)  COMMENT  '',
  C_SJLY  STRING  COMMENT  '数据来源',
  VC_JSBZ  STRING  COMMENT  '',
  EN_EXCH  DECIMAL(14,10)  COMMENT  '',
  EN_HKF  DECIMAL(19,4)  COMMENT  '',
  VC_SGLSBH  STRING  COMMENT  '',
  L_YTHWHGLBH  DECIMAL(12,0)  COMMENT  '',
  EN_LXCZFS  DECIMAL(1,0)  COMMENT  '',
  EN_LXFY  DECIMAL(19,4)  COMMENT  '',
  L_SFRGJDZ  DECIMAL(1,0)  COMMENT  '',
  VC_FHR  STRING  COMMENT  '',
  VC_LLR  STRING  COMMENT  '',
  L_KHLX  DECIMAL(1,0)  COMMENT  '',
  EN_FDTZGWF  DECIMAL(19,4)  COMMENT  '',
  D_MODIFY  STRING  COMMENT  '',
  VC_ZY  STRING  COMMENT  '',
  D_HFRQ  STRING  COMMENT  '',
  D_SYHFRQ  STRING  COMMENT  ''
)
COMMENT '申购赎回表'
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
                                   , TO_CHAR(D_RQ,'YYYYMMDD') D_RQ
                                   , L_JGID
                                   , L_SGSL
                                   , EN_SGJE
                                   , L_SHSL
                                   , EN_SHJE
                                   , EN_JGSHF
                                   , EN_JJSHF
                                   , L_SGPZID
                                   , L_SHPZID
                                   , L_ZTBH
                                   , VC_JGDM
                                   , VC_JGMC
                                   , L_IMPORT
                                   , D_QRRQ
                                   , EN_YJTCJE
                                   , EN_WSXSYPZJ
                                   , EN_SSWTZC
                                   , EN_ZHFSR
                                   , VC_JJDM
                                   , EN_HDSGF
                                   , L_CLBZ
                                   , EN_SHSY
                                   , EN_BCF
                                   , EN_WYJ
                                   , VC_SYRBH
                                   , EN_TKJE
                                   , L_ZHLB
                                   , VC_SYRBH2
                                   , L_SYRLB
                                   , VC_FELB
                                   , EN_FEZS
                                   , VC_DYJJ
                                   , D_TCRQ
                                   , L_GLFBH
                                   , L_TGFBH
                                   , C_SJLY
                                   , VC_JSBZ
                                   , EN_EXCH
                                   , EN_HKF
                                   , VC_SGLSBH
                                   , L_YTHWHGLBH
                                   , EN_LXCZFS
                                   , EN_LXFY
                                   , L_SFRGJDZ
                                   , VC_FHR
                                   , VC_LLR
                                   , L_KHLX
                                   , EN_FDTZGWF
                                   , D_MODIFY
                                   , VC_ZY
                                   , D_HFRQ
                                   , D_SYHFRQ
                                FROM ${hsfa_src_schema}.TSGSH
                                WHERE D_RQ between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ID", "type": "DOUBLE"}, {"name": "D_RQ", "type": "STRING"}, {"name": "L_JGID", "type": "DOUBLE"}, {"name": "L_SGSL", "type": "DOUBLE"}, {"name": "EN_SGJE", "type": "DOUBLE"}, {"name": "L_SHSL", "type": "DOUBLE"}, {"name": "EN_SHJE", "type": "DOUBLE"}, {"name": "EN_JGSHF", "type": "DOUBLE"}, {"name": "EN_JJSHF", "type": "DOUBLE"}, {"name": "L_SGPZID", "type": "DOUBLE"}, {"name": "L_SHPZID", "type": "DOUBLE"}, {"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "VC_JGDM", "type": "STRING"}, {"name": "VC_JGMC", "type": "STRING"}, {"name": "L_IMPORT", "type": "DOUBLE"}, {"name": "D_QRRQ", "type": "STRING"}, {"name": "EN_YJTCJE", "type": "DOUBLE"}, {"name": "EN_WSXSYPZJ", "type": "DOUBLE"}, {"name": "EN_SSWTZC", "type": "DOUBLE"}, {"name": "EN_ZHFSR", "type": "DOUBLE"}, {"name": "VC_JJDM", "type": "STRING"}, {"name": "EN_HDSGF", "type": "DOUBLE"}, {"name": "L_CLBZ", "type": "DOUBLE"}, {"name": "EN_SHSY", "type": "DOUBLE"}, {"name": "EN_BCF", "type": "DOUBLE"}, {"name": "EN_WYJ", "type": "DOUBLE"}, {"name": "VC_SYRBH", "type": "STRING"}, {"name": "EN_TKJE", "type": "DOUBLE"}, {"name": "L_ZHLB", "type": "DOUBLE"}, {"name": "VC_SYRBH2", "type": "STRING"}, {"name": "L_SYRLB", "type": "DOUBLE"}, {"name": "VC_FELB", "type": "STRING"}, {"name": "EN_FEZS", "type": "DOUBLE"}, {"name": "VC_DYJJ", "type": "STRING"}, {"name": "D_TCRQ", "type": "STRING"}, {"name": "L_GLFBH", "type": "DOUBLE"}, {"name": "L_TGFBH", "type": "DOUBLE"}, {"name": "C_SJLY", "type": "STRING"}, {"name": "VC_JSBZ", "type": "STRING"}, {"name": "EN_EXCH", "type": "DOUBLE"}, {"name": "EN_HKF", "type": "DOUBLE"}, {"name": "VC_SGLSBH", "type": "STRING"}, {"name": "L_YTHWHGLBH", "type": "DOUBLE"}, {"name": "EN_LXCZFS", "type": "DOUBLE"}, {"name": "EN_LXFY", "type": "DOUBLE"}, {"name": "L_SFRGJDZ", "type": "DOUBLE"}, {"name": "VC_FHR", "type": "STRING"}, {"name": "VC_LLR", "type": "STRING"}, {"name": "L_KHLX", "type": "DOUBLE"}, {"name": "EN_FDTZGWF", "type": "DOUBLE"}, {"name": "D_MODIFY", "type": "STRING"}, {"name": "VC_ZY", "type": "STRING"}, {"name": "D_HFRQ", "type": "STRING"}, {"name": "D_SYHFRQ", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tsgsh_ptd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tsgsh_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tsgsh_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tsgsh_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TSGSH_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TSGSH_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tsgsh_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TSGSH_PTD PARTITION(P_DT)
SELECT
       L_ID
     , D_RQ
     , L_JGID
     , L_SGSL
     , EN_SGJE
     , L_SHSL
     , EN_SHJE
     , EN_JGSHF
     , EN_JJSHF
     , L_SGPZID
     , L_SHPZID
     , L_ZTBH
     , VC_JGDM
     , VC_JGMC
     , L_IMPORT
     , D_QRRQ
     , EN_YJTCJE
     , EN_WSXSYPZJ
     , EN_SSWTZC
     , EN_ZHFSR
     , VC_JJDM
     , EN_HDSGF
     , L_CLBZ
     , EN_SHSY
     , EN_BCF
     , EN_WYJ
     , VC_SYRBH
     , EN_TKJE
     , L_ZHLB
     , VC_SYRBH2
     , L_SYRLB
     , VC_FELB
     , EN_FEZS
     , VC_DYJJ
     , D_TCRQ
     , L_GLFBH
     , L_TGFBH
     , C_SJLY
     , VC_JSBZ
     , EN_EXCH
     , EN_HKF
     , VC_SGLSBH
     , L_YTHWHGLBH
     , EN_LXCZFS
     , EN_LXFY
     , L_SFRGJDZ
     , VC_FHR
     , VC_LLR
     , L_KHLX
     , EN_FDTZGWF
     , D_MODIFY
     , VC_ZY
     , D_HFRQ
     , D_SYHFRQ
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_RQ,'-','') P_DT
  FROM ODS_XDAY_HSFA.ODS_HSFA_TSGSH_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TSGSH_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TSGSH_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TSGSH_PTD成功"
      exit 0
   fi
fi
