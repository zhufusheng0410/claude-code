#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TQSKJZLS_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TQSKJZLS_PTD_TMP(
  L_ZTBH  STRING  COMMENT  '帐套编号',
  D_DATE  STRING  COMMENT  '',
  VC_DYKM  STRING  COMMENT  '对应科目',
  EN_WBYE  DECIMAL(19,4)  COMMENT  '外币余额',
  EN_KMYE  DECIMAL(19,4)  COMMENT  '科目余额',
  EN_EXCH  DECIMAL(14,10)  COMMENT  '汇率',
  VC_JSBZ  STRING  COMMENT  '结算币种',
  EN_WBJZJE  DECIMAL(19,4)  COMMENT  '外币结转金额',
  EN_BWBJZJE  DECIMAL(19,4)  COMMENT  '本位币结转金额',
  D_SCSJ  STRING  COMMENT  '生成时间',
  VC_JFKM  STRING  COMMENT  '借方科目',
  VC_DFKM  STRING  COMMENT  '贷方科目',
  VC_ZY  STRING  COMMENT  '摘要',
  L_TS  DECIMAL(4,0)  COMMENT  '天数',
  L_YEZFBZ  STRING  COMMENT  '余额正负标志',
  L_BH  STRING  COMMENT  '编号',
  L_YWLB  DECIMAL(4,0)  COMMENT  '业务类别',
  D_YERQ  STRING  COMMENT  '余额日期',
  L_CLBZ  STRING  COMMENT  '处理标志',
  L_JZBZ  STRING  COMMENT  '记账标志',
  VC_JZZQ  STRING  COMMENT  '结转周期',
  L_KIND  STRING  COMMENT  '科目方向',
  VC_LXSRKM  STRING  COMMENT  '利息收入科目',
  L_ID  DECIMAL(10,0)  COMMENT  'seq_public_id',
  EN_ZFBL  DECIMAL(19,6)  COMMENT  '支付比例',
  L_JSFS  DECIMAL(1,0)  COMMENT  '计算方式',
  EN_WBDVPYE  DECIMAL(19,4)  COMMENT  '',
  EN_BWBDVPYE  DECIMAL(19,4)  COMMENT  '',
  VC_SJLY  STRING  COMMENT  '',
  VC_LXSDSKM  STRING  COMMENT  '',
  EN_LXSDS  DECIMAL(19,4)  COMMENT  '',
  EN_KMYE2  DECIMAL(19,4)  COMMENT  '',
  EN_KMYE3  DECIMAL(19,4)  COMMENT  '',
  L_LBMX  STRING  COMMENT  '费用类别',
  L_YTHWHGLBH  DECIMAL(12,0)  COMMENT  '',
  VC_LLR  STRING  COMMENT  '',
  VC_FHR  STRING  COMMENT  '',
  VC_JYRLX  STRING  COMMENT  '',
  D_MODIFY  STRING  COMMENT  '',
  L_SFCF  DECIMAL(1,0)  COMMENT  '',
  L_JTKMCLFS  DECIMAL(1,0)  COMMENT  ''
)
COMMENT '科目结转流水表tqskjzls'
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
                                   , TO_CHAR(D_DATE,'YYYYMMDD') D_DATE
                                   , VC_DYKM
                                   , EN_WBYE
                                   , EN_KMYE
                                   , EN_EXCH
                                   , VC_JSBZ
                                   , EN_WBJZJE
                                   , EN_BWBJZJE
                                   , D_SCSJ
                                   , VC_JFKM
                                   , VC_DFKM
                                   , VC_ZY
                                   , L_TS
                                   , L_YEZFBZ
                                   , L_BH
                                   , L_YWLB
                                   , D_YERQ
                                   , L_CLBZ
                                   , L_JZBZ
                                   , VC_JZZQ
                                   , L_KIND
                                   , VC_LXSRKM
                                   , L_ID
                                   , EN_ZFBL
                                   , L_JSFS
                                   , EN_WBDVPYE
                                   , EN_BWBDVPYE
                                   , VC_SJLY
                                   , VC_LXSDSKM
                                   , EN_LXSDS
                                   , EN_KMYE2
                                   , EN_KMYE3
                                   , L_LBMX
                                   , L_YTHWHGLBH
                                   , VC_LLR
                                   , VC_FHR
                                   , VC_JYRLX
                                   , D_MODIFY
                                   , L_SFCF
                                   , L_JTKMCLFS
                                FROM ${hsfa_src_schema}.TQSKJZLS
                                WHERE D_DATE between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "D_DATE", "type": "STRING"}, {"name": "VC_DYKM", "type": "STRING"}, {"name": "EN_WBYE", "type": "DOUBLE"}, {"name": "EN_KMYE", "type": "DOUBLE"}, {"name": "EN_EXCH", "type": "DOUBLE"}, {"name": "VC_JSBZ", "type": "STRING"}, {"name": "EN_WBJZJE", "type": "DOUBLE"}, {"name": "EN_BWBJZJE", "type": "DOUBLE"}, {"name": "D_SCSJ", "type": "STRING"}, {"name": "VC_JFKM", "type": "STRING"}, {"name": "VC_DFKM", "type": "STRING"}, {"name": "VC_ZY", "type": "STRING"}, {"name": "L_TS", "type": "DOUBLE"}, {"name": "L_YEZFBZ", "type": "DOUBLE"}, {"name": "L_BH", "type": "DOUBLE"}, {"name": "L_YWLB", "type": "DOUBLE"}, {"name": "D_YERQ", "type": "STRING"}, {"name": "L_CLBZ", "type": "DOUBLE"}, {"name": "L_JZBZ", "type": "DOUBLE"}, {"name": "VC_JZZQ", "type": "STRING"}, {"name": "L_KIND", "type": "DOUBLE"}, {"name": "VC_LXSRKM", "type": "STRING"}, {"name": "L_ID", "type": "DOUBLE"}, {"name": "EN_ZFBL", "type": "DOUBLE"}, {"name": "L_JSFS", "type": "DOUBLE"}, {"name": "EN_WBDVPYE", "type": "DOUBLE"}, {"name": "EN_BWBDVPYE", "type": "DOUBLE"}, {"name": "VC_SJLY", "type": "STRING"}, {"name": "VC_LXSDSKM", "type": "STRING"}, {"name": "EN_LXSDS", "type": "DOUBLE"}, {"name": "EN_KMYE2", "type": "DOUBLE"}, {"name": "EN_KMYE3", "type": "DOUBLE"}, {"name": "L_LBMX", "type": "STRING"}, {"name": "L_YTHWHGLBH", "type": "DOUBLE"}, {"name": "VC_LLR", "type": "STRING"}, {"name": "VC_FHR", "type": "STRING"}, {"name": "VC_JYRLX", "type": "STRING"}, {"name": "D_MODIFY", "type": "STRING"}, {"name": "L_SFCF", "type": "DOUBLE"}, {"name": "L_JTKMCLFS", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tqskjzls_ptd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tqskjzls_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tqskjzls_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tqskjzls_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TQSKJZLS_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TQSKJZLS_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tqskjzls_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TQSKJZLS_PTD PARTITION(P_DT)
SELECT
       L_ZTBH
     , D_DATE
     , VC_DYKM
     , EN_WBYE
     , EN_KMYE
     , EN_EXCH
     , VC_JSBZ
     , EN_WBJZJE
     , EN_BWBJZJE
     , D_SCSJ
     , VC_JFKM
     , VC_DFKM
     , VC_ZY
     , L_TS
     , L_YEZFBZ
     , L_BH
     , L_YWLB
     , D_YERQ
     , L_CLBZ
     , L_JZBZ
     , VC_JZZQ
     , L_KIND
     , VC_LXSRKM
     , L_ID
     , EN_ZFBL
     , L_JSFS
     , EN_WBDVPYE
     , EN_BWBDVPYE
     , VC_SJLY
     , VC_LXSDSKM
     , EN_LXSDS
     , EN_KMYE2
     , EN_KMYE3
     , L_LBMX
     , L_YTHWHGLBH
     , VC_LLR
     , VC_FHR
     , VC_JYRLX
     , D_MODIFY
     , L_SFCF
     , L_JTKMCLFS
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_DATE,'-','') P_DT
  FROM ODS_XDAY_HSFA.ODS_HSFA_TQSKJZLS_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TQSKJZLS_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TQSKJZLS_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TQSKJZLS_PTD成功"
      exit 0
   fi
fi
