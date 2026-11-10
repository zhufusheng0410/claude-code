#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TFUNDINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TFUNDINFO_PFD_TMP(
  L_FUNDID  STRING  COMMENT  '帐套编号',
  VC_CODE  STRING  COMMENT  '基金代码',
  VC_NAME  STRING  COMMENT  '基金名称',
  VC_FULLNAME  STRING  COMMENT  '基金全称',
  L_CLASS  STRING  COMMENT  '基金类型',
  D_CREATE  STRING  COMMENT  '成立时间',
  VC_TGR  STRING  COMMENT  '基金托管人',
  VC_GLR  STRING  COMMENT  '基金管理人',
  VC_FQR  STRING  COMMENT  '发起人',
  EN_ZFE  DECIMAL(21,6)  COMMENT  '基金总份额',
  L_JJTZLX  STRING  COMMENT  '基金投资类型',
  L_KHLX  STRING  COMMENT  '投资者类型',
  VC_JSBH  STRING  COMMENT  '结算编号',
  EN_MJJE  DECIMAL(19,4)  COMMENT  '募集金额',
  C_SYNCHRO_FLAG  STRING  COMMENT  '同步标志',
  D_SYNCHRO_TIME  STRING  COMMENT  '同步时间',
  VC_TGZH  STRING  COMMENT  '托管账号',
  L_TZRS  DECIMAL(8,0)  COMMENT  '投资人数',
  D_DQRQ  STRING  COMMENT  '到期日期',
  L_BXCPLX  STRING  COMMENT  '保险产品类型',
  L_JHJHLX  STRING  COMMENT  '集合计划类型',
  EN_MBGM  DECIMAL(19,4)  COMMENT  '目标规模',
  VC_BFJZH  STRING  COMMENT  '备付金账号',
  L_SCLB  DECIMAL(4,0)  COMMENT  '市场类别',
  L_ZXSHDW  DECIMAL(10,0)  COMMENT  '最小申赎单位',
  VC_TGHID  STRING  COMMENT  '托管行ID',
  EN_CSMZ  DECIMAL(19,4)  COMMENT  '初始面值',
  L_JHCPLX  DECIMAL(1,0)  COMMENT  '',
  L_KHBH  DECIMAL(8,0)  COMMENT  '',
  D_TGBARQ  STRING  COMMENT  '',
  L_GLFS  DECIMAL(4,0)  COMMENT  '',
  L_ZTFL  DECIMAL(4,0)  COMMENT  '',
  L_ZZZTBH  DECIMAL(9,0)  COMMENT  '',
  L_FBCP  DECIMAL(4,0)  COMMENT  '',
  VC_PSDXDM  STRING  COMMENT  '',
  L_FQCPZZ  DECIMAL(12,0)  COMMENT  '',
  VC_BFJZH_BJ  STRING  COMMENT  '',
  L_TZXZ  DECIMAL(4,0)  COMMENT  '',
  L_CPLXYJFL  DECIMAL(4,0)  COMMENT  '',
  L_CPLXEJFL  DECIMAL(4,0)  COMMENT  '',
  EN_DWJZZZLBJJZ  DECIMAL(30,15)  COMMENT  '',
  D_ZXR  STRING  COMMENT  ''
)
COMMENT '基金信息表'
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
              "querySql": ["SELECT  L_FUNDID
                                   , VC_CODE
                                   , VC_NAME
                                   , VC_FULLNAME
                                   , L_CLASS
                                   , D_CREATE
                                   , VC_TGR
                                   , VC_GLR
                                   , VC_FQR
                                   , EN_ZFE
                                   , L_JJTZLX
                                   , L_KHLX
                                   , VC_JSBH
                                   , EN_MJJE
                                   , C_SYNCHRO_FLAG
                                   , D_SYNCHRO_TIME
                                   , VC_TGZH
                                   , L_TZRS
                                   , D_DQRQ
                                   , L_BXCPLX
                                   , L_JHJHLX
                                   , EN_MBGM
                                   , VC_BFJZH
                                   , L_SCLB
                                   , L_ZXSHDW
                                   , VC_TGHID
                                   , EN_CSMZ
                                   , L_JHCPLX
                                   , L_KHBH
                                   , D_TGBARQ
                                   , L_GLFS
                                   , L_ZTFL
                                   , L_ZZZTBH
                                   , L_FBCP
                                   , VC_PSDXDM
                                   , L_FQCPZZ
                                   , VC_BFJZH_BJ
                                   , L_TZXZ
                                   , L_CPLXYJFL
                                   , L_CPLXEJFL
                                   , EN_DWJZZZLBJJZ
                                   , D_ZXR
                                FROM ${hsfa_src_schema}.TFUNDINFO"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_FUNDID", "type": "DOUBLE"}, {"name": "VC_CODE", "type": "STRING"}, {"name": "VC_NAME", "type": "STRING"}, {"name": "VC_FULLNAME", "type": "STRING"}, {"name": "L_CLASS", "type": "DOUBLE"}, {"name": "D_CREATE", "type": "STRING"}, {"name": "VC_TGR", "type": "STRING"}, {"name": "VC_GLR", "type": "STRING"}, {"name": "VC_FQR", "type": "STRING"}, {"name": "EN_ZFE", "type": "DOUBLE"}, {"name": "L_JJTZLX", "type": "DOUBLE"}, {"name": "L_KHLX", "type": "DOUBLE"}, {"name": "VC_JSBH", "type": "STRING"}, {"name": "EN_MJJE", "type": "DOUBLE"}, {"name": "C_SYNCHRO_FLAG", "type": "STRING"}, {"name": "D_SYNCHRO_TIME", "type": "STRING"}, {"name": "VC_TGZH", "type": "STRING"}, {"name": "L_TZRS", "type": "DOUBLE"}, {"name": "D_DQRQ", "type": "STRING"}, {"name": "L_BXCPLX", "type": "DOUBLE"}, {"name": "L_JHJHLX", "type": "DOUBLE"}, {"name": "EN_MBGM", "type": "DOUBLE"}, {"name": "VC_BFJZH", "type": "STRING"}, {"name": "L_SCLB", "type": "DOUBLE"}, {"name": "L_ZXSHDW", "type": "DOUBLE"}, {"name": "VC_TGHID", "type": "STRING"}, {"name": "EN_CSMZ", "type": "DOUBLE"}, {"name": "L_JHCPLX", "type": "DOUBLE"}, {"name": "L_KHBH", "type": "DOUBLE"}, {"name": "D_TGBARQ", "type": "STRING"}, {"name": "L_GLFS", "type": "DOUBLE"}, {"name": "L_ZTFL", "type": "DOUBLE"}, {"name": "L_ZZZTBH", "type": "DOUBLE"}, {"name": "L_FBCP", "type": "DOUBLE"}, {"name": "VC_PSDXDM", "type": "STRING"}, {"name": "L_FQCPZZ", "type": "DOUBLE"}, {"name": "VC_BFJZH_BJ", "type": "STRING"}, {"name": "L_TZXZ", "type": "DOUBLE"}, {"name": "L_CPLXYJFL", "type": "DOUBLE"}, {"name": "L_CPLXEJFL", "type": "DOUBLE"}, {"name": "EN_DWJZZZLBJJZ", "type": "DOUBLE"}, {"name": "D_ZXR", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tfundinfo_pfd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tfundinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tfundinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tfundinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TFUNDINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TFUNDINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tfundinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TFUNDINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_FUNDID
     , VC_CODE
     , VC_NAME
     , VC_FULLNAME
     , L_CLASS
     , D_CREATE
     , VC_TGR
     , VC_GLR
     , VC_FQR
     , EN_ZFE
     , L_JJTZLX
     , L_KHLX
     , VC_JSBH
     , EN_MJJE
     , C_SYNCHRO_FLAG
     , D_SYNCHRO_TIME
     , VC_TGZH
     , L_TZRS
     , D_DQRQ
     , L_BXCPLX
     , L_JHJHLX
     , EN_MBGM
     , VC_BFJZH
     , L_SCLB
     , L_ZXSHDW
     , VC_TGHID
     , EN_CSMZ
     , L_JHCPLX
     , L_KHBH
     , D_TGBARQ
     , L_GLFS
     , L_ZTFL
     , L_ZZZTBH
     , L_FBCP
     , VC_PSDXDM
     , L_FQCPZZ
     , VC_BFJZH_BJ
     , L_TZXZ
     , L_CPLXYJFL
     , L_CPLXEJFL
     , EN_DWJZZZLBJJZ
     , D_ZXR
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFA.ODS_HSFA_TFUNDINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TFUNDINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TFUNDINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TFUNDINFO_PFD成功"
      exit 0
   fi
fi
