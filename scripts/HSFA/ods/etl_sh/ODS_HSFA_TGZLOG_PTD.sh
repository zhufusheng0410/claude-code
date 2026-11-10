#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TGZLOG_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TGZLOG_PTD_TMP(
  L_BH  DECIMAL(18,2)  COMMENT  '编号',
  L_ZTBH  STRING  COMMENT  '帐套编号',
  L_ZQNM  DECIMAL(18,2)  COMMENT  '证券内码',
  VC_ZQDM  STRING  COMMENT  '证券代码',
  D_RQ  STRING  COMMENT  '日期',
  L_SL  DECIMAL(19,4)  COMMENT  '数量',
  EN_CE  DECIMAL(19,4)  COMMENT  '当日差额',
  EN_GZZZ  DECIMAL(19,4)  COMMENT  '估值增值',
  EN_HQJG  DECIMAL(25,12)  COMMENT  '行情价格',
  L_TZLX  STRING  COMMENT  '投资类型',
  L_SCLB  DECIMAL(4,0)  COMMENT  '市场类别',
  VC_GDDM  STRING  COMMENT  '股东代码',
  VC_XWBH  STRING  COMMENT  '席位代码',
  L_SDFLAG  STRING  COMMENT  '锁定标志',
  VC_ZQFL  STRING  COMMENT  '证券分类',
  D_HQRQ  STRING  COMMENT  '行情日期',
  VC_BZ  STRING  COMMENT  '备注',
  EN_ZQCB  DECIMAL(19,4)  COMMENT  '证券成本',
  EN_ZRCE  DECIMAL(19,4)  COMMENT  '昨日差额',
  EN_DRHL  DECIMAL(14,10)  COMMENT  '当日汇率',
  EN_YBHQ  DECIMAL(25,12)  COMMENT  '原币行情',
  VC_JSBZ  STRING  COMMENT  '结算币种',
  EN_YBZQCB  DECIMAL(19,4)  COMMENT  '原币证券成本',
  EN_YBZRCE  DECIMAL(19,4)  COMMENT  '原币昨日差额',
  EN_YBCE  DECIMAL(19,4)  COMMENT  '原币差额',
  EN_YBGZZZ  DECIMAL(19,4)  COMMENT  '原币估值增值',
  VC_KMDM  STRING  COMMENT  '科目代码',
  L_DKFX  STRING  COMMENT  '多空方向',
  EN_HYCS  DECIMAL(12,4)  COMMENT  '合约乘数',
  D_KSTPRQ  STRING  COMMENT  '开始停牌日期',
  EN_YZJG  DECIMAL(23,10)  COMMENT  '影子价格',
  EN_YBYZJJZ  DECIMAL(19,4)  COMMENT  '原币影子净值',
  EN_YZJJZ  DECIMAL(19,4)  COMMENT  '影子净值',
  EN_YSLX  DECIMAL(19,4)  COMMENT  '应收利息',
  EN_YBYSLX  DECIMAL(19,4)  COMMENT  '原币应收利息',
  L_CCHSID  DECIMAL(4,0)  COMMENT  '持仓核算ID',
  L_GZBZ  STRING  COMMENT  '估值标志',
  L_TQBZ  STRING  COMMENT  '套期保值标志',
  L_HQZQNM  DECIMAL(8,0)  COMMENT  '行情证券内码',
  EN_GZZZSDS  DECIMAL(19,4)  COMMENT  '估值增值所得税',
  EN_YBGZZZSDS  DECIMAL(19,4)  COMMENT  '原币估值增值所得税',
  EN_ZRCESDS  DECIMAL(19,4)  COMMENT  '昨日差额所得税',
  EN_YBZRCESDS  DECIMAL(19,4)  COMMENT  '原币昨日差额所得税',
  L_CCFL  DECIMAL(4,0)  COMMENT  '',
  L_JGCJ  DECIMAL(1,0)  COMMENT  '',
  L_TPBZ  DECIMAL(1,0)  COMMENT  '',
  EN_ETFXZHQ  DECIMAL(25,12)  COMMENT  '',
  D_ETFXZRQ  STRING  COMMENT  '',
  EN_ZSJ  DECIMAL(19,4)  COMMENT  '',
  EN_HSYBHQ  DECIMAL(25,12)  COMMENT  '',
  EN_RZGJQJ  DECIMAL(25,12)  COMMENT  ''
)
COMMENT '估值历史表'
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
                                   , L_ZQNM
                                   , VC_ZQDM
                                   , TO_CHAR(D_RQ,'YYYYMMDD') D_RQ
                                   , L_SL
                                   , EN_CE
                                   , EN_GZZZ
                                   , EN_HQJG
                                   , L_TZLX
                                   , L_SCLB
                                   , VC_GDDM
                                   , VC_XWBH
                                   , L_SDFLAG
                                   , VC_ZQFL
                                   , D_HQRQ
                                   , VC_BZ
                                   , EN_ZQCB
                                   , EN_ZRCE
                                   , EN_DRHL
                                   , EN_YBHQ
                                   , VC_JSBZ
                                   , EN_YBZQCB
                                   , EN_YBZRCE
                                   , EN_YBCE
                                   , EN_YBGZZZ
                                   , VC_KMDM
                                   , L_DKFX
                                   , EN_HYCS
                                   , D_KSTPRQ
                                   , EN_YZJG
                                   , EN_YBYZJJZ
                                   , EN_YZJJZ
                                   , EN_YSLX
                                   , EN_YBYSLX
                                   , L_CCHSID
                                   , L_GZBZ
                                   , L_TQBZ
                                   , L_HQZQNM
                                   , EN_GZZZSDS
                                   , EN_YBGZZZSDS
                                   , EN_ZRCESDS
                                   , EN_YBZRCESDS
                                   , L_CCFL
                                   , L_JGCJ
                                   , L_TPBZ
                                   , EN_ETFXZHQ
                                   , D_ETFXZRQ
                                   , EN_ZSJ
                                   , EN_HSYBHQ
                                   , EN_RZGJQJ
                                FROM ${hsfa_src_schema}.TGZLOG
                                WHERE D_RQ between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_BH", "type": "DOUBLE"}, {"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "L_ZQNM", "type": "DOUBLE"}, {"name": "VC_ZQDM", "type": "STRING"}, {"name": "D_RQ", "type": "STRING"}, {"name": "L_SL", "type": "DOUBLE"}, {"name": "EN_CE", "type": "DOUBLE"}, {"name": "EN_GZZZ", "type": "DOUBLE"}, {"name": "EN_HQJG", "type": "DOUBLE"}, {"name": "L_TZLX", "type": "DOUBLE"}, {"name": "L_SCLB", "type": "DOUBLE"}, {"name": "VC_GDDM", "type": "STRING"}, {"name": "VC_XWBH", "type": "STRING"}, {"name": "L_SDFLAG", "type": "DOUBLE"}, {"name": "VC_ZQFL", "type": "STRING"}, {"name": "D_HQRQ", "type": "STRING"}, {"name": "VC_BZ", "type": "STRING"}, {"name": "EN_ZQCB", "type": "DOUBLE"}, {"name": "EN_ZRCE", "type": "DOUBLE"}, {"name": "EN_DRHL", "type": "DOUBLE"}, {"name": "EN_YBHQ", "type": "DOUBLE"}, {"name": "VC_JSBZ", "type": "STRING"}, {"name": "EN_YBZQCB", "type": "DOUBLE"}, {"name": "EN_YBZRCE", "type": "DOUBLE"}, {"name": "EN_YBCE", "type": "DOUBLE"}, {"name": "EN_YBGZZZ", "type": "DOUBLE"}, {"name": "VC_KMDM", "type": "STRING"}, {"name": "L_DKFX", "type": "DOUBLE"}, {"name": "EN_HYCS", "type": "DOUBLE"}, {"name": "D_KSTPRQ", "type": "STRING"}, {"name": "EN_YZJG", "type": "DOUBLE"}, {"name": "EN_YBYZJJZ", "type": "DOUBLE"}, {"name": "EN_YZJJZ", "type": "DOUBLE"}, {"name": "EN_YSLX", "type": "DOUBLE"}, {"name": "EN_YBYSLX", "type": "DOUBLE"}, {"name": "L_CCHSID", "type": "DOUBLE"}, {"name": "L_GZBZ", "type": "DOUBLE"}, {"name": "L_TQBZ", "type": "DOUBLE"}, {"name": "L_HQZQNM", "type": "DOUBLE"}, {"name": "EN_GZZZSDS", "type": "DOUBLE"}, {"name": "EN_YBGZZZSDS", "type": "DOUBLE"}, {"name": "EN_ZRCESDS", "type": "DOUBLE"}, {"name": "EN_YBZRCESDS", "type": "DOUBLE"}, {"name": "L_CCFL", "type": "DOUBLE"}, {"name": "L_JGCJ", "type": "DOUBLE"}, {"name": "L_TPBZ", "type": "DOUBLE"}, {"name": "EN_ETFXZHQ", "type": "DOUBLE"}, {"name": "D_ETFXZRQ", "type": "STRING"}, {"name": "EN_ZSJ", "type": "DOUBLE"}, {"name": "EN_HSYBHQ", "type": "DOUBLE"}, {"name": "EN_RZGJQJ", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tgzlog_ptd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tgzlog_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tgzlog_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tgzlog_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TGZLOG_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TGZLOG_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tgzlog_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TGZLOG_PTD PARTITION(P_DT)
SELECT
       L_BH
     , L_ZTBH
     , L_ZQNM
     , VC_ZQDM
     , D_RQ
     , L_SL
     , EN_CE
     , EN_GZZZ
     , EN_HQJG
     , L_TZLX
     , L_SCLB
     , VC_GDDM
     , VC_XWBH
     , L_SDFLAG
     , VC_ZQFL
     , D_HQRQ
     , VC_BZ
     , EN_ZQCB
     , EN_ZRCE
     , EN_DRHL
     , EN_YBHQ
     , VC_JSBZ
     , EN_YBZQCB
     , EN_YBZRCE
     , EN_YBCE
     , EN_YBGZZZ
     , VC_KMDM
     , L_DKFX
     , EN_HYCS
     , D_KSTPRQ
     , EN_YZJG
     , EN_YBYZJJZ
     , EN_YZJJZ
     , EN_YSLX
     , EN_YBYSLX
     , L_CCHSID
     , L_GZBZ
     , L_TQBZ
     , L_HQZQNM
     , EN_GZZZSDS
     , EN_YBGZZZSDS
     , EN_ZRCESDS
     , EN_YBZRCESDS
     , L_CCFL
     , L_JGCJ
     , L_TPBZ
     , EN_ETFXZHQ
     , D_ETFXZRQ
     , EN_ZSJ
     , EN_HSYBHQ
     , EN_RZGJQJ
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_RQ,'-','') P_DT
  FROM ODS_XDAY_HSFA.ODS_HSFA_TGZLOG_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TGZLOG_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TGZLOG_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TGZLOG_PTD成功"
      exit 0
   fi
fi
