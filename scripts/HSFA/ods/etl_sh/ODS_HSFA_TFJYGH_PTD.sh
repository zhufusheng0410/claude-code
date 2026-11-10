#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TFJYGH_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TFJYGH_PTD_TMP(
  L_BH  DECIMAL(18,2)  COMMENT  '编号',
  L_ZTBH  STRING  COMMENT  '账套编号',
  D_RQ  STRING  COMMENT  '日期',
  VC_XWDM  STRING  COMMENT  '席位代码',
  VC_GDDM  STRING  COMMENT  '股东代码',
  L_YWLB  DECIMAL(4,0)  COMMENT  '业务类别',
  L_SCLB  DECIMAL(4,0)  COMMENT  '市场类别',
  L_ZQNM  DECIMAL(8,0)  COMMENT  '证券内码',
  VC_ZQDM  STRING  COMMENT  '证券代码',
  VC_PFNF  STRING  COMMENT  '派发年份',
  L_GHSL  DECIMAL(19,4)  COMMENT  '过户数量',
  EN_JG  DECIMAL(19,4)  COMMENT  '价格\金额',
  VC_CJBH  STRING  COMMENT  '成交编号',
  VC_XZDM  STRING  COMMENT  '险种代码',
  L_TZLX  STRING  COMMENT  '投资类型',
  VC_GZZ  STRING  COMMENT  '工作组',
  L_JSRQ  DECIMAL(8,0)  COMMENT  '结算日期',
  L_CLBZ  STRING  COMMENT  '业务处理标志',
  L_PZID  DECIMAL(8,0)  COMMENT  '',
  VC_BZ  STRING  COMMENT  '备注',
  VC_JSBZ  STRING  COMMENT  '结算币种',
  EN_EXCH  DECIMAL(18,14)  COMMENT  '汇率',
  EN_QYBL  DECIMAL(12,6)  COMMENT  '权益比例',
  VC_ZHDM  STRING  COMMENT  '转换代码',
  EN_ZCLX  DECIMAL(19,4)  COMMENT  '转出利息',
  C_XWLX  STRING  COMMENT  '席位类型',
  EN_LXS  DECIMAL(19,4)  COMMENT  '兑息应付税金',
  VC_DJBZ  STRING  COMMENT  '登记币种',
  EN_DJHL  DECIMAL(10,6)  COMMENT  '登记日汇率',
  L_YSGLKMFL  STRING  COMMENT  '应收股利分类',
  D_YERQ  STRING  COMMENT  '余额日期',
  VC_LLR  STRING  COMMENT  '录入人',
  VC_FHR  STRING  COMMENT  '复核人',
  C_SJLY  STRING  COMMENT  '数据来源',
  D_JYRQ  STRING  COMMENT  '交易日期',
  L_CEGRCB  DECIMAL(4,0)  COMMENT  'ETF现金差额是否冲减成本',
  VC_BFZH  STRING  COMMENT  '本方账户',
  EN_ZCCB  DECIMAL(19,4)  COMMENT  '转出成本',
  L_CCFL  DECIMAL(4,0)  COMMENT  '',
  EN_JYFY  DECIMAL(19,4)  COMMENT  '',
  EN_BWBZCLX  DECIMAL(19,4)  COMMENT  '',
  EN_BWBZCCB  DECIMAL(19,4)  COMMENT  '',
  L_GLZQNM  DECIMAL(8,0)  COMMENT  '',
  EN_ZCGYJZBDSY  DECIMAL(19,4)  COMMENT  '',
  EN_HBBJ  DECIMAL(19,4)  COMMENT  '',
  L_HBSL  DECIMAL(19,4)  COMMENT  '',
  EN_ZCZYJ  DECIMAL(19,4)  COMMENT  '',
  EN_JSFWF  DECIMAL(19,4)  COMMENT  '',
  EN_LXSDS  DECIMAL(19,4)  COMMENT  '',
  L_YTHWHGLBH  DECIMAL(10,0)  COMMENT  '',
  D_DZRQ  STRING  COMMENT  '',
  EN_YJ  DECIMAL(19,4)  COMMENT  '',
  VC_QSBH  STRING  COMMENT  '',
  VC_SJLY  STRING  COMMENT  '',
  L_GLBH  DECIMAL(18,2)  COMMENT  '',
  L_SFXGFELB  DECIMAL(1,0)  COMMENT  '',
  EN_BDQDXJE1  DECIMAL(19,4)  COMMENT  '',
  EN_BDQDXJE  DECIMAL(19,4)  COMMENT  '',
  EN_BDQHBJE  DECIMAL(19,4)  COMMENT  '',
  EN_BWBJG  DECIMAL(19,4)  COMMENT  '',
  L_XSQBZ  DECIMAL(1,0)  COMMENT  '',
  D_MODIFY  STRING  COMMENT  '',
  L_JZJD  DECIMAL(1,0)  COMMENT  '',
  EN_ZCJZZB  DECIMAL(19,4)  COMMENT  '',
  EN_BWBZCJZZB  DECIMAL(19,4)  COMMENT  '',
  VC_XYZJZH  STRING  COMMENT  '',
  VC_CJMX  STRING  COMMENT  '',
  L_ADZLXCJHL  DECIMAL(1,0)  COMMENT  '',
  EN_ZCGZZZ  DECIMAL(19,4)  COMMENT  '',
  L_DZZT  DECIMAL(1,0)  COMMENT  '',
  EN_ZCBWBGYJZBDSY  DECIMAL(19,4)  COMMENT  '',
  EN_ZCLX_SJ  DECIMAL(19,4)  COMMENT  '',
  EN_DJJE  DECIMAL(19,4)  COMMENT  ''
)
COMMENT '非交易过户表'
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
                                   , L_ZTBH
                                   , TO_CHAR(D_RQ,'YYYYMMDD') D_RQ
                                   , VC_XWDM
                                   , VC_GDDM
                                   , L_YWLB
                                   , L_SCLB
                                   , L_ZQNM
                                   , VC_ZQDM
                                   , VC_PFNF
                                   , L_GHSL
                                   , EN_JG
                                   , VC_CJBH
                                   , VC_XZDM
                                   , L_TZLX
                                   , VC_GZZ
                                   , L_JSRQ
                                   , L_CLBZ
                                   , L_PZID
                                   , VC_BZ
                                   , VC_JSBZ
                                   , EN_EXCH
                                   , EN_QYBL
                                   , VC_ZHDM
                                   , EN_ZCLX
                                   , C_XWLX
                                   , EN_LXS
                                   , VC_DJBZ
                                   , EN_DJHL
                                   , L_YSGLKMFL
                                   , D_YERQ
                                   , VC_LLR
                                   , VC_FHR
                                   , C_SJLY
                                   , D_JYRQ
                                   , L_CEGRCB
                                   , VC_BFZH
                                   , EN_ZCCB
                                   , L_CCFL
                                   , EN_JYFY
                                   , EN_BWBZCLX
                                   , EN_BWBZCCB
                                   , L_GLZQNM
                                   , EN_ZCGYJZBDSY
                                   , EN_HBBJ
                                   , L_HBSL
                                   , EN_ZCZYJ
                                   , EN_JSFWF
                                   , EN_LXSDS
                                   , L_YTHWHGLBH
                                   , D_DZRQ
                                   , EN_YJ
                                   , VC_QSBH
                                   , VC_SJLY
                                   , L_GLBH
                                   , L_SFXGFELB
                                   , EN_BDQDXJE1
                                   , EN_BDQDXJE
                                   , EN_BDQHBJE
                                   , EN_BWBJG
                                   , L_XSQBZ
                                   , D_MODIFY
                                   , L_JZJD
                                   , EN_ZCJZZB
                                   , EN_BWBZCJZZB
                                   , VC_XYZJZH
                                   , VC_CJMX
                                   , L_ADZLXCJHL
                                   , EN_ZCGZZZ
                                   , L_DZZT
                                   , EN_ZCBWBGYJZBDSY
                                   , EN_ZCLX_SJ
                                   , EN_DJJE
                                FROM ${hsfa_src_schema}.TFJYGH
                                WHERE D_RQ between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_BH", "type": "DOUBLE"}, {"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "D_RQ", "type": "STRING"}, {"name": "VC_XWDM", "type": "STRING"}, {"name": "VC_GDDM", "type": "STRING"}, {"name": "L_YWLB", "type": "DOUBLE"}, {"name": "L_SCLB", "type": "DOUBLE"}, {"name": "L_ZQNM", "type": "DOUBLE"}, {"name": "VC_ZQDM", "type": "STRING"}, {"name": "VC_PFNF", "type": "STRING"}, {"name": "L_GHSL", "type": "DOUBLE"}, {"name": "EN_JG", "type": "DOUBLE"}, {"name": "VC_CJBH", "type": "STRING"}, {"name": "VC_XZDM", "type": "STRING"}, {"name": "L_TZLX", "type": "DOUBLE"}, {"name": "VC_GZZ", "type": "STRING"}, {"name": "L_JSRQ", "type": "DOUBLE"}, {"name": "L_CLBZ", "type": "DOUBLE"}, {"name": "L_PZID", "type": "DOUBLE"}, {"name": "VC_BZ", "type": "STRING"}, {"name": "VC_JSBZ", "type": "STRING"}, {"name": "EN_EXCH", "type": "DOUBLE"}, {"name": "EN_QYBL", "type": "DOUBLE"}, {"name": "VC_ZHDM", "type": "STRING"}, {"name": "EN_ZCLX", "type": "DOUBLE"}, {"name": "C_XWLX", "type": "STRING"}, {"name": "EN_LXS", "type": "DOUBLE"}, {"name": "VC_DJBZ", "type": "STRING"}, {"name": "EN_DJHL", "type": "DOUBLE"}, {"name": "L_YSGLKMFL", "type": "DOUBLE"}, {"name": "D_YERQ", "type": "STRING"}, {"name": "VC_LLR", "type": "STRING"}, {"name": "VC_FHR", "type": "STRING"}, {"name": "C_SJLY", "type": "STRING"}, {"name": "D_JYRQ", "type": "STRING"}, {"name": "L_CEGRCB", "type": "DOUBLE"}, {"name": "VC_BFZH", "type": "STRING"}, {"name": "EN_ZCCB", "type": "DOUBLE"}, {"name": "L_CCFL", "type": "DOUBLE"}, {"name": "EN_JYFY", "type": "DOUBLE"}, {"name": "EN_BWBZCLX", "type": "DOUBLE"}, {"name": "EN_BWBZCCB", "type": "DOUBLE"}, {"name": "L_GLZQNM", "type": "DOUBLE"}, {"name": "EN_ZCGYJZBDSY", "type": "DOUBLE"}, {"name": "EN_HBBJ", "type": "DOUBLE"}, {"name": "L_HBSL", "type": "DOUBLE"}, {"name": "EN_ZCZYJ", "type": "DOUBLE"}, {"name": "EN_JSFWF", "type": "DOUBLE"}, {"name": "EN_LXSDS", "type": "DOUBLE"}, {"name": "L_YTHWHGLBH", "type": "DOUBLE"}, {"name": "D_DZRQ", "type": "STRING"}, {"name": "EN_YJ", "type": "DOUBLE"}, {"name": "VC_QSBH", "type": "STRING"}, {"name": "VC_SJLY", "type": "STRING"}, {"name": "L_GLBH", "type": "DOUBLE"}, {"name": "L_SFXGFELB", "type": "DOUBLE"}, {"name": "EN_BDQDXJE1", "type": "DOUBLE"}, {"name": "EN_BDQDXJE", "type": "DOUBLE"}, {"name": "EN_BDQHBJE", "type": "DOUBLE"}, {"name": "EN_BWBJG", "type": "DOUBLE"}, {"name": "L_XSQBZ", "type": "DOUBLE"}, {"name": "D_MODIFY", "type": "STRING"}, {"name": "L_JZJD", "type": "DOUBLE"}, {"name": "EN_ZCJZZB", "type": "DOUBLE"}, {"name": "EN_BWBZCJZZB", "type": "DOUBLE"}, {"name": "VC_XYZJZH", "type": "STRING"}, {"name": "VC_CJMX", "type": "STRING"}, {"name": "L_ADZLXCJHL", "type": "DOUBLE"}, {"name": "EN_ZCGZZZ", "type": "DOUBLE"}, {"name": "L_DZZT", "type": "DOUBLE"}, {"name": "EN_ZCBWBGYJZBDSY", "type": "DOUBLE"}, {"name": "EN_ZCLX_SJ", "type": "DOUBLE"}, {"name": "EN_DJJE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tfjygh_ptd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tfjygh_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tfjygh_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tfjygh_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TFJYGH_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TFJYGH_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tfjygh_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TFJYGH_PTD PARTITION(P_DT)
SELECT
       L_BH
     , L_ZTBH
     , D_RQ
     , VC_XWDM
     , VC_GDDM
     , L_YWLB
     , L_SCLB
     , L_ZQNM
     , VC_ZQDM
     , VC_PFNF
     , L_GHSL
     , EN_JG
     , VC_CJBH
     , VC_XZDM
     , L_TZLX
     , VC_GZZ
     , L_JSRQ
     , L_CLBZ
     , L_PZID
     , VC_BZ
     , VC_JSBZ
     , EN_EXCH
     , EN_QYBL
     , VC_ZHDM
     , EN_ZCLX
     , C_XWLX
     , EN_LXS
     , VC_DJBZ
     , EN_DJHL
     , L_YSGLKMFL
     , D_YERQ
     , VC_LLR
     , VC_FHR
     , C_SJLY
     , D_JYRQ
     , L_CEGRCB
     , VC_BFZH
     , EN_ZCCB
     , L_CCFL
     , EN_JYFY
     , EN_BWBZCLX
     , EN_BWBZCCB
     , L_GLZQNM
     , EN_ZCGYJZBDSY
     , EN_HBBJ
     , L_HBSL
     , EN_ZCZYJ
     , EN_JSFWF
     , EN_LXSDS
     , L_YTHWHGLBH
     , D_DZRQ
     , EN_YJ
     , VC_QSBH
     , VC_SJLY
     , L_GLBH
     , L_SFXGFELB
     , EN_BDQDXJE1
     , EN_BDQDXJE
     , EN_BDQHBJE
     , EN_BWBJG
     , L_XSQBZ
     , D_MODIFY
     , L_JZJD
     , EN_ZCJZZB
     , EN_BWBZCJZZB
     , VC_XYZJZH
     , VC_CJMX
     , L_ADZLXCJHL
     , EN_ZCGZZZ
     , L_DZZT
     , EN_ZCBWBGYJZBDSY
     , EN_ZCLX_SJ
     , EN_DJJE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_RQ,'-','') P_DT
  FROM ODS_XDAY_HSFA.ODS_HSFA_TFJYGH_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TFJYGH_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TFJYGH_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TFJYGH_PTD成功"
      exit 0
   fi
fi
