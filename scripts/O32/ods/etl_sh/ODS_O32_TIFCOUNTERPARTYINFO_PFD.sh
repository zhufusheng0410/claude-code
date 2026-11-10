#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TIFCOUNTERPARTYINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TIFCOUNTERPARTYINFO_PFD_TMP(
  DSMC  STRING  COMMENT  '对手名称',
  DSQC  STRING  COMMENT  '对手全称',
  SCLX  STRING  COMMENT  '市场类型',
  DSLX  STRING  COMMENT  '对手类型',
  WBPJ  STRING  COMMENT  '外部评级',
  NBPJ  STRING  COMMENT  '内部评级',
  ZHPJ  STRING  COMMENT  '综合评级',
  MRJSFS  STRING  COMMENT  '买入结算方式',
  MCJSFS  STRING  COMMENT  '卖出结算方式',
  SYYW  STRING  COMMENT  '适用业务',
  KZJSFSYW  STRING  COMMENT  '控制结算方式业务',
  DZ  STRING  COMMENT  '地址',
  LXR  STRING  COMMENT  '联系人',
  DH  STRING  COMMENT  '电话',
  CZ  STRING  COMMENT  '传真',
  BZ  STRING  COMMENT  '备注',
  YHJID  DECIMAL(10,0)  COMMENT  '银行间id',
  JJDM  STRING  COMMENT  '基金代码',
  DSBH  STRING  COMMENT  '对手编号',
  ZBJ  DECIMAL(16,2)  COMMENT  '资本金',
  ZZC  DECIMAL(16,2)  COMMENT  '总资产',
  JZC  DECIMAL(16,2)  COMMENT  '净资产',
  YHZH  STRING  COMMENT  '银行总行名称',
  CBDVP  STRING  COMMENT  '中债登dvp资格',
  SCDVP  STRING  COMMENT  '上清所dvp资格',
  GLFX  STRING  COMMENT  '关联发行人',
  JYDSZT  STRING  COMMENT  '',
  ZJGLGM  DECIMAL(16,2)  COMMENT  '',
  ZZDTGZH  STRING  COMMENT  '',
  ZZDTGZHJC  STRING  COMMENT  '',
  SQSTGZH  STRING  COMMENT  '',
  SQSTGZHJC  STRING  COMMENT  '',
  ZSSLX  STRING  COMMENT  '',
  YHJJGDM  STRING  COMMENT  '',
  GDSYJYSDM  STRING  COMMENT  '',
  DSSX  STRING  COMMENT  '',
  SPVBM  STRING  COMMENT  '',
  ZJDSFL  STRING  COMMENT  '',
  ZCGXLX  STRING  COMMENT  '',
  ZJG  STRING  COMMENT  '',
  SZJYSDM  STRING  COMMENT  '',
  SZJYZTDM  STRING  COMMENT  '',
  SZJYZTMC  STRING  COMMENT  '',
  SZJYZTLX  STRING  COMMENT  '',
  JWJG  STRING  COMMENT  '',
  CPLDSFL  STRING  COMMENT  ''
)
COMMENT '交易对手信息接口表'
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
            "username": "${o32_username}",
            "password": "${o32_password}",
            "connection": [{
              "querySql": ["SELECT  DSMC
                                   , DSQC
                                   , SCLX
                                   , DSLX
                                   , WBPJ
                                   , NBPJ
                                   , ZHPJ
                                   , MRJSFS
                                   , MCJSFS
                                   , SYYW
                                   , KZJSFSYW
                                   , DZ
                                   , LXR
                                   , DH
                                   , CZ
                                   , BZ
                                   , YHJID
                                   , JJDM
                                   , DSBH
                                   , ZBJ
                                   , ZZC
                                   , JZC
                                   , YHZH
                                   , CBDVP
                                   , SCDVP
                                   , GLFX
                                   , JYDSZT
                                   , ZJGLGM
                                   , ZZDTGZH
                                   , ZZDTGZHJC
                                   , SQSTGZH
                                   , SQSTGZHJC
                                   , ZSSLX
                                   , YHJJGDM
                                   , GDSYJYSDM
                                   , DSSX
                                   , SPVBM
                                   , ZJDSFL
                                   , ZCGXLX
                                   , ZJG
                                   , SZJYSDM
                                   , SZJYZTDM
                                   , SZJYZTMC
                                   , SZJYZTLX
                                   , JWJG
                                   , CPLDSFL
                                FROM ${o32_src_schema}.TIFCOUNTERPARTYINFO"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "DSMC", "type": "STRING"}, {"name": "DSQC", "type": "STRING"}, {"name": "SCLX", "type": "STRING"}, {"name": "DSLX", "type": "STRING"}, {"name": "WBPJ", "type": "STRING"}, {"name": "NBPJ", "type": "STRING"}, {"name": "ZHPJ", "type": "STRING"}, {"name": "MRJSFS", "type": "STRING"}, {"name": "MCJSFS", "type": "STRING"}, {"name": "SYYW", "type": "STRING"}, {"name": "KZJSFSYW", "type": "STRING"}, {"name": "DZ", "type": "STRING"}, {"name": "LXR", "type": "STRING"}, {"name": "DH", "type": "STRING"}, {"name": "CZ", "type": "STRING"}, {"name": "BZ", "type": "STRING"}, {"name": "YHJID", "type": "DOUBLE"}, {"name": "JJDM", "type": "STRING"}, {"name": "DSBH", "type": "STRING"}, {"name": "ZBJ", "type": "DOUBLE"}, {"name": "ZZC", "type": "DOUBLE"}, {"name": "JZC", "type": "DOUBLE"}, {"name": "YHZH", "type": "STRING"}, {"name": "CBDVP", "type": "STRING"}, {"name": "SCDVP", "type": "STRING"}, {"name": "GLFX", "type": "STRING"}, {"name": "JYDSZT", "type": "STRING"}, {"name": "ZJGLGM", "type": "DOUBLE"}, {"name": "ZZDTGZH", "type": "STRING"}, {"name": "ZZDTGZHJC", "type": "STRING"}, {"name": "SQSTGZH", "type": "STRING"}, {"name": "SQSTGZHJC", "type": "STRING"}, {"name": "ZSSLX", "type": "STRING"}, {"name": "YHJJGDM", "type": "STRING"}, {"name": "GDSYJYSDM", "type": "STRING"}, {"name": "DSSX", "type": "STRING"}, {"name": "SPVBM", "type": "STRING"}, {"name": "ZJDSFL", "type": "STRING"}, {"name": "ZCGXLX", "type": "STRING"}, {"name": "ZJG", "type": "STRING"}, {"name": "SZJYSDM", "type": "STRING"}, {"name": "SZJYZTDM", "type": "STRING"}, {"name": "SZJYZTMC", "type": "STRING"}, {"name": "SZJYZTLX", "type": "STRING"}, {"name": "JWJG", "type": "STRING"}, {"name": "CPLDSFL", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tifcounterpartyinfo_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tifcounterpartyinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tifcounterpartyinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tifcounterpartyinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TIFCOUNTERPARTYINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TIFCOUNTERPARTYINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tifcounterpartyinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TIFCOUNTERPARTYINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       DSMC
     , DSQC
     , SCLX
     , DSLX
     , WBPJ
     , NBPJ
     , ZHPJ
     , MRJSFS
     , MCJSFS
     , SYYW
     , KZJSFSYW
     , DZ
     , LXR
     , DH
     , CZ
     , BZ
     , YHJID
     , JJDM
     , DSBH
     , ZBJ
     , ZZC
     , JZC
     , YHZH
     , CBDVP
     , SCDVP
     , GLFX
     , JYDSZT
     , ZJGLGM
     , ZZDTGZH
     , ZZDTGZHJC
     , SQSTGZH
     , SQSTGZHJC
     , ZSSLX
     , YHJJGDM
     , GDSYJYSDM
     , DSSX
     , SPVBM
     , ZJDSFL
     , ZCGXLX
     , ZJG
     , SZJYSDM
     , SZJYZTDM
     , SZJYZTMC
     , SZJYZTLX
     , JWJG
     , CPLDSFL
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TIFCOUNTERPARTYINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TIFCOUNTERPARTYINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TIFCOUNTERPARTYINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TIFCOUNTERPARTYINFO_PFD成功"
      exit 0
   fi
fi
