#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TCJHB_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TCJHB_PTD_TMP(
  L_BH  DECIMAL(18,2)  COMMENT  '编号',
  L_ZTBH  STRING  COMMENT  '账套编号',
  D_RQ  STRING  COMMENT  '日期',
  VC_GDDM  STRING  COMMENT  '股东代码',
  VC_XWDM  STRING  COMMENT  '席位代码',
  L_YWLB  DECIMAL(4,0)  COMMENT  '业务类别',
  L_LBMXBH  STRING  COMMENT  '类别明细编号',
  L_SCLB  DECIMAL(4,0)  COMMENT  '市场类别',
  L_ZQNM  DECIMAL(18,2)  COMMENT  '证券内码',
  VC_ZQDM  STRING  COMMENT  '证券代码',
  L_CJSL  DECIMAL(19,4)  COMMENT  '成交数量',
  EN_CJJG  DECIMAL(10,4)  COMMENT  '成交价格',
  EN_CJJE  DECIMAL(19,4)  COMMENT  '成交金额',
  D_CJSJ  STRING  COMMENT  '成交时间',
  VC_CJBM  STRING  COMMENT  '成交编号',
  VC_SQBH  STRING  COMMENT  '申请编号',
  C_MM  STRING  COMMENT  '买卖',
  L_TZLX  STRING  COMMENT  '投资类型',
  VC_BZ  STRING  COMMENT  '备注',
  VC_YSZQDM  STRING  COMMENT  '原始证券代码',
  L_ZQLB  DECIMAL(4,0)  COMMENT  '证券类别',
  VC_JSBZ  STRING  COMMENT  '结算币种',
  VC_WTFS  STRING  COMMENT  '委托方式',
  VC_QSBH  STRING  COMMENT  '券商编号',
  C_SJLY  STRING  COMMENT  '数据来源',
  L_DKFX  STRING  COMMENT  '多空方向',
  EN_HYCS  DECIMAL(12,4)  COMMENT  '合约乘数',
  L_DYQSL  DECIMAL(10,0)  COMMENT  '抵押券数量',
  L_QSSD  DECIMAL(2,0)  COMMENT  '清算速度',
  L_GLBH  STRING  COMMENT  '关联编号',
  VC_ZHDM  STRING  COMMENT  '转换代码',
  EN_SQLX  DECIMAL(23,8)  COMMENT  '税前利息',
  EN_LX  DECIMAL(19,4)  COMMENT  '利息',
  VC_BFZH  STRING  COMMENT  '本方账号',
  L_DZJYBZ  STRING  COMMENT  '大宗交易标志',
  L_YJMXBH  STRING  COMMENT  '佣金类别明细编号',
  L_TQBZ  STRING  COMMENT  '套期保值标志',
  D_JSRQ  STRING  COMMENT  '理论交收日期',
  L_CLBZ  DECIMAL(18,2)  COMMENT  '处理标志',
  L_JSJG  DECIMAL(1,0)  COMMENT  '',
  EN_QMZE  DECIMAL(23,8)  COMMENT  '',
  VC_QSBSLX  STRING  COMMENT  '',
  VC_QSBSDM  STRING  COMMENT  '',
  VC_QSDLJGBSLX  STRING  COMMENT  '',
  VC_QSDLJGBSDM  STRING  COMMENT  '',
  VC_QSDLJGZH  STRING  COMMENT  '',
  VC_QSJGBIC  STRING  COMMENT  '',
  L_CCFL  DECIMAL(4,0)  COMMENT  '',
  VC_CJSJ  STRING  COMMENT  '',
  VC_QSBZ  STRING  COMMENT  '',
  L_JSFS  DECIMAL(2,0)  COMMENT  '',
  L_XSQBZ  DECIMAL(1,0)  COMMENT  '',
  VC_JYDS  STRING  COMMENT  '',
  L_XQSBFS  DECIMAL(1,0)  COMMENT  '',
  EN_YBQMZE  DECIMAL(23,8)  COMMENT  '',
  L_XZBZ  DECIMAL(2,0)  COMMENT  ''
)
COMMENT '成交回报表'
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
                                   , VC_GDDM
                                   , VC_XWDM
                                   , L_YWLB
                                   , L_LBMXBH
                                   , L_SCLB
                                   , L_ZQNM
                                   , VC_ZQDM
                                   , L_CJSL
                                   , EN_CJJG
                                   , EN_CJJE
                                   , D_CJSJ
                                   , VC_CJBM
                                   , VC_SQBH
                                   , C_MM
                                   , L_TZLX
                                   , VC_BZ
                                   , VC_YSZQDM
                                   , L_ZQLB
                                   , VC_JSBZ
                                   , VC_WTFS
                                   , VC_QSBH
                                   , C_SJLY
                                   , L_DKFX
                                   , EN_HYCS
                                   , L_DYQSL
                                   , L_QSSD
                                   , L_GLBH
                                   , VC_ZHDM
                                   , EN_SQLX
                                   , EN_LX
                                   , VC_BFZH
                                   , L_DZJYBZ
                                   , L_YJMXBH
                                   , L_TQBZ
                                   , D_JSRQ
                                   , L_CLBZ
                                   , L_JSJG
                                   , EN_QMZE
                                   , VC_QSBSLX
                                   , VC_QSBSDM
                                   , VC_QSDLJGBSLX
                                   , VC_QSDLJGBSDM
                                   , VC_QSDLJGZH
                                   , VC_QSJGBIC
                                   , L_CCFL
                                   , VC_CJSJ
                                   , VC_QSBZ
                                   , L_JSFS
                                   , L_XSQBZ
                                   , VC_JYDS
                                   , L_XQSBFS
                                   , EN_YBQMZE
                                   , L_XZBZ
                                FROM ${hsfa_src_schema}.T_H_CJHB
                                WHERE D_RQ between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_BH", "type": "DOUBLE"}, {"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "D_RQ", "type": "STRING"}, {"name": "VC_GDDM", "type": "STRING"}, {"name": "VC_XWDM", "type": "STRING"}, {"name": "L_YWLB", "type": "DOUBLE"}, {"name": "L_LBMXBH", "type": "DOUBLE"}, {"name": "L_SCLB", "type": "DOUBLE"}, {"name": "L_ZQNM", "type": "DOUBLE"}, {"name": "VC_ZQDM", "type": "STRING"}, {"name": "L_CJSL", "type": "DOUBLE"}, {"name": "EN_CJJG", "type": "DOUBLE"}, {"name": "EN_CJJE", "type": "DOUBLE"}, {"name": "D_CJSJ", "type": "STRING"}, {"name": "VC_CJBM", "type": "STRING"}, {"name": "VC_SQBH", "type": "STRING"}, {"name": "C_MM", "type": "STRING"}, {"name": "L_TZLX", "type": "DOUBLE"}, {"name": "VC_BZ", "type": "STRING"}, {"name": "VC_YSZQDM", "type": "STRING"}, {"name": "L_ZQLB", "type": "DOUBLE"}, {"name": "VC_JSBZ", "type": "STRING"}, {"name": "VC_WTFS", "type": "STRING"}, {"name": "VC_QSBH", "type": "STRING"}, {"name": "C_SJLY", "type": "STRING"}, {"name": "L_DKFX", "type": "DOUBLE"}, {"name": "EN_HYCS", "type": "DOUBLE"}, {"name": "L_DYQSL", "type": "DOUBLE"}, {"name": "L_QSSD", "type": "DOUBLE"}, {"name": "L_GLBH", "type": "STRING"}, {"name": "VC_ZHDM", "type": "STRING"}, {"name": "EN_SQLX", "type": "DOUBLE"}, {"name": "EN_LX", "type": "DOUBLE"}, {"name": "VC_BFZH", "type": "STRING"}, {"name": "L_DZJYBZ", "type": "DOUBLE"}, {"name": "L_YJMXBH", "type": "DOUBLE"}, {"name": "L_TQBZ", "type": "DOUBLE"}, {"name": "D_JSRQ", "type": "STRING"}, {"name": "L_CLBZ", "type": "DOUBLE"}, {"name": "L_JSJG", "type": "DOUBLE"}, {"name": "EN_QMZE", "type": "DOUBLE"}, {"name": "VC_QSBSLX", "type": "STRING"}, {"name": "VC_QSBSDM", "type": "STRING"}, {"name": "VC_QSDLJGBSLX", "type": "STRING"}, {"name": "VC_QSDLJGBSDM", "type": "STRING"}, {"name": "VC_QSDLJGZH", "type": "STRING"}, {"name": "VC_QSJGBIC", "type": "STRING"}, {"name": "L_CCFL", "type": "DOUBLE"}, {"name": "VC_CJSJ", "type": "STRING"}, {"name": "VC_QSBZ", "type": "STRING"}, {"name": "L_JSFS", "type": "DOUBLE"}, {"name": "L_XSQBZ", "type": "DOUBLE"}, {"name": "VC_JYDS", "type": "STRING"}, {"name": "L_XQSBFS", "type": "DOUBLE"}, {"name": "EN_YBQMZE", "type": "DOUBLE"}, {"name": "L_XZBZ", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tcjhb_ptd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tcjhb_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tcjhb_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tcjhb_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TCJHB_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TCJHB_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tcjhb_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TCJHB_PTD PARTITION(P_DT)
SELECT
       L_BH
     , L_ZTBH
     , D_RQ
     , VC_GDDM
     , VC_XWDM
     , L_YWLB
     , L_LBMXBH
     , L_SCLB
     , L_ZQNM
     , VC_ZQDM
     , L_CJSL
     , EN_CJJG
     , EN_CJJE
     , D_CJSJ
     , VC_CJBM
     , VC_SQBH
     , C_MM
     , L_TZLX
     , VC_BZ
     , VC_YSZQDM
     , L_ZQLB
     , VC_JSBZ
     , VC_WTFS
     , VC_QSBH
     , C_SJLY
     , L_DKFX
     , EN_HYCS
     , L_DYQSL
     , L_QSSD
     , L_GLBH
     , VC_ZHDM
     , EN_SQLX
     , EN_LX
     , VC_BFZH
     , L_DZJYBZ
     , L_YJMXBH
     , L_TQBZ
     , D_JSRQ
     , L_CLBZ
     , L_JSJG
     , EN_QMZE
     , VC_QSBSLX
     , VC_QSBSDM
     , VC_QSDLJGBSLX
     , VC_QSDLJGBSDM
     , VC_QSDLJGZH
     , VC_QSJGBIC
     , L_CCFL
     , VC_CJSJ
     , VC_QSBZ
     , L_JSFS
     , L_XSQBZ
     , VC_JYDS
     , L_XQSBFS
     , EN_YBQMZE
     , L_XZBZ
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_RQ,'-','') P_DT
  FROM ODS_XDAY_HSFA.ODS_HSFA_TCJHB_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TCJHB_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TCJHB_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TCJHB_PTD成功"
      exit 0
   fi
fi
