#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TSHARECLASS_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TSHARECLASS_PFD_TMP(
  C_FUNDCODE  STRING  COMMENT  '基金代码',
  C_SHARECLASS  STRING  COMMENT  '份额级别',
  C_CLASSNAME  STRING  COMMENT  '级别名称',
  F_MIN  DECIMAL(16,2)  COMMENT  '区间最小份额',
  F_MAX  DECIMAL(16,2)  COMMENT  '区间最大份额',
  C_GRADEFUND  STRING  COMMENT  '分级基金代码',
  F_SPLITRATIO  DECIMAL(10,0)  COMMENT  '',
  F_MINSPLITSHARES  DECIMAL(16,2)  COMMENT  '',
  F_MINMERGESHARES  DECIMAL(16,2)  COMMENT  '',
  F_NETVALUE1  DECIMAL(7,4)  COMMENT  '',
  F_NETVALUE2  DECIMAL(7,4)  COMMENT  '',
  C_SIGNFLAG  STRING  COMMENT  '',
  C_VASTCALTYPE  STRING  COMMENT  '',
  C_ISBASICFUND  STRING  COMMENT  '',
  F_DIVIDENDRATIO  DECIMAL(7,4)  COMMENT  '',
  C_CALCTOTALASSET  STRING  COMMENT  '是否自动计算总净值',
  D_BEGSPLITMEGERDATE  STRING  COMMENT  '',
  F_TRANSFERRATIO  DECIMAL(15,14)  COMMENT  '',
  C_ALLOWFRCRDM  STRING  COMMENT  '',
  F_DIVIDENDMINRATIO  DECIMAL(10,0)  COMMENT  '',
  C_SUBTYPE  STRING  COMMENT  '',
  C_CLASSTYPE  STRING  COMMENT  '分级方式',
  F_MAXBALA  DECIMAL(16,2)  COMMENT  '最高募集金额',
  F_FARERATIO  DECIMAL(5,4)  COMMENT  '费率(%)',
  C_SCALEMODE  STRING  COMMENT  '',
  C_LITTLEFRCCHANGE  STRING  COMMENT  '',
  C_ISSUETYPE  STRING  COMMENT  '配售方式',
  C_RATIOTYPE  STRING  COMMENT  '收益率方式',
  C_MERGERACCOLIMIT  STRING  COMMENT  '',
  C_EXPKJMERGER  STRING  COMMENT  '清算数据是否合并导出',
  F_MINDAY  DECIMAL(10,0)  COMMENT  '最小天数',
  F_MAXDAY  DECIMAL(10,0)  COMMENT  '最大天数',
  C_IMPKJSPLIT  STRING  COMMENT  '',
  C_FIRSTINVESTMERGERJUDGE  STRING  COMMENT  '',
  C_ISESHARESFUND  STRING  COMMENT  '',
  C_PROMISERDMFUNDCODE  STRING  COMMENT  '',
  C_ISCONTROLTRADE  STRING  COMMENT  '',
  C_ISINCLUDEINCOME  STRING  COMMENT  '',
  C_ISCHECKVAST  STRING  COMMENT  '',
  C_SPLITALLMAINSHARES  STRING  COMMENT  '',
  C_CNTAILDEALTYPE  STRING  COMMENT  '',
  C_CNSPLITTYPE  STRING  COMMENT  '',
  C_UNITEXPWEBBANK  STRING  COMMENT  '',
  C_ISCHECKTHRESHOLD  STRING  COMMENT  '',
  F_SHARERATIO  DECIMAL(9,8)  COMMENT  '',
  C_TZJYCODE  STRING  COMMENT  '投资交易合并导出代码',
  C_EXPTZJYMERGER  STRING  COMMENT  '',
  C_LARGEEXCEEDCOMCTL  STRING  COMMENT  '',
  C_VASTMERGSHARECLASS  STRING  COMMENT  '',
  C_CUSTMAXBALACOMCTL  STRING  COMMENT  ''
)
COMMENT '基金份额级别定义'
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
            "username": "${hsfta_username}",
            "password": "${hsfta_password}",
            "connection": [{
              "querySql": ["SELECT  C_FUNDCODE
                                   , C_SHARECLASS
                                   , C_CLASSNAME
                                   , F_MIN
                                   , F_MAX
                                   , C_GRADEFUND
                                   , F_SPLITRATIO
                                   , F_MINSPLITSHARES
                                   , F_MINMERGESHARES
                                   , F_NETVALUE1
                                   , F_NETVALUE2
                                   , C_SIGNFLAG
                                   , C_VASTCALTYPE
                                   , C_ISBASICFUND
                                   , F_DIVIDENDRATIO
                                   , C_CALCTOTALASSET
                                   , D_BEGSPLITMEGERDATE
                                   , F_TRANSFERRATIO
                                   , C_ALLOWFRCRDM
                                   , F_DIVIDENDMINRATIO
                                   , C_SUBTYPE
                                   , C_CLASSTYPE
                                   , F_MAXBALA
                                   , F_FARERATIO
                                   , C_SCALEMODE
                                   , C_LITTLEFRCCHANGE
                                   , C_ISSUETYPE
                                   , C_RATIOTYPE
                                   , C_MERGERACCOLIMIT
                                   , C_EXPKJMERGER
                                   , F_MINDAY
                                   , F_MAXDAY
                                   , C_IMPKJSPLIT
                                   , C_FIRSTINVESTMERGERJUDGE
                                   , C_ISESHARESFUND
                                   , C_PROMISERDMFUNDCODE
                                   , C_ISCONTROLTRADE
                                   , C_ISINCLUDEINCOME
                                   , C_ISCHECKVAST
                                   , C_SPLITALLMAINSHARES
                                   , C_CNTAILDEALTYPE
                                   , C_CNSPLITTYPE
                                   , C_UNITEXPWEBBANK
                                   , C_ISCHECKTHRESHOLD
                                   , F_SHARERATIO
                                   , C_TZJYCODE
                                   , C_EXPTZJYMERGER
                                   , C_LARGEEXCEEDCOMCTL
                                   , C_VASTMERGSHARECLASS
                                   , C_CUSTMAXBALACOMCTL
                                FROM ${hsfta_src_schema}.TSHARECLASS"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDCODE", "type": "STRING"}, {"name": "C_SHARECLASS", "type": "STRING"}, {"name": "C_CLASSNAME", "type": "STRING"}, {"name": "F_MIN", "type": "DOUBLE"}, {"name": "F_MAX", "type": "DOUBLE"}, {"name": "C_GRADEFUND", "type": "STRING"}, {"name": "F_SPLITRATIO", "type": "DOUBLE"}, {"name": "F_MINSPLITSHARES", "type": "DOUBLE"}, {"name": "F_MINMERGESHARES", "type": "DOUBLE"}, {"name": "F_NETVALUE1", "type": "DOUBLE"}, {"name": "F_NETVALUE2", "type": "DOUBLE"}, {"name": "C_SIGNFLAG", "type": "STRING"}, {"name": "C_VASTCALTYPE", "type": "STRING"}, {"name": "C_ISBASICFUND", "type": "STRING"}, {"name": "F_DIVIDENDRATIO", "type": "DOUBLE"}, {"name": "C_CALCTOTALASSET", "type": "STRING"}, {"name": "D_BEGSPLITMEGERDATE", "type": "STRING"}, {"name": "F_TRANSFERRATIO", "type": "DOUBLE"}, {"name": "C_ALLOWFRCRDM", "type": "STRING"}, {"name": "F_DIVIDENDMINRATIO", "type": "DOUBLE"}, {"name": "C_SUBTYPE", "type": "STRING"}, {"name": "C_CLASSTYPE", "type": "STRING"}, {"name": "F_MAXBALA", "type": "DOUBLE"}, {"name": "F_FARERATIO", "type": "DOUBLE"}, {"name": "C_SCALEMODE", "type": "STRING"}, {"name": "C_LITTLEFRCCHANGE", "type": "STRING"}, {"name": "C_ISSUETYPE", "type": "STRING"}, {"name": "C_RATIOTYPE", "type": "STRING"}, {"name": "C_MERGERACCOLIMIT", "type": "STRING"}, {"name": "C_EXPKJMERGER", "type": "STRING"}, {"name": "F_MINDAY", "type": "DOUBLE"}, {"name": "F_MAXDAY", "type": "DOUBLE"}, {"name": "C_IMPKJSPLIT", "type": "STRING"}, {"name": "C_FIRSTINVESTMERGERJUDGE", "type": "STRING"}, {"name": "C_ISESHARESFUND", "type": "STRING"}, {"name": "C_PROMISERDMFUNDCODE", "type": "STRING"}, {"name": "C_ISCONTROLTRADE", "type": "STRING"}, {"name": "C_ISINCLUDEINCOME", "type": "STRING"}, {"name": "C_ISCHECKVAST", "type": "STRING"}, {"name": "C_SPLITALLMAINSHARES", "type": "STRING"}, {"name": "C_CNTAILDEALTYPE", "type": "STRING"}, {"name": "C_CNSPLITTYPE", "type": "STRING"}, {"name": "C_UNITEXPWEBBANK", "type": "STRING"}, {"name": "C_ISCHECKTHRESHOLD", "type": "STRING"}, {"name": "F_SHARERATIO", "type": "DOUBLE"}, {"name": "C_TZJYCODE", "type": "STRING"}, {"name": "C_EXPTZJYMERGER", "type": "STRING"}, {"name": "C_LARGEEXCEEDCOMCTL", "type": "STRING"}, {"name": "C_VASTMERGSHARECLASS", "type": "STRING"}, {"name": "C_CUSTMAXBALACOMCTL", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_tshareclass_pfd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_tshareclass_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_tshareclass_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_tshareclass_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TSHARECLASS_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TSHARECLASS_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_tshareclass_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TSHARECLASS_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_FUNDCODE
     , C_SHARECLASS
     , C_CLASSNAME
     , F_MIN
     , F_MAX
     , C_GRADEFUND
     , F_SPLITRATIO
     , F_MINSPLITSHARES
     , F_MINMERGESHARES
     , F_NETVALUE1
     , F_NETVALUE2
     , C_SIGNFLAG
     , C_VASTCALTYPE
     , C_ISBASICFUND
     , F_DIVIDENDRATIO
     , C_CALCTOTALASSET
     , D_BEGSPLITMEGERDATE
     , F_TRANSFERRATIO
     , C_ALLOWFRCRDM
     , F_DIVIDENDMINRATIO
     , C_SUBTYPE
     , C_CLASSTYPE
     , F_MAXBALA
     , F_FARERATIO
     , C_SCALEMODE
     , C_LITTLEFRCCHANGE
     , C_ISSUETYPE
     , C_RATIOTYPE
     , C_MERGERACCOLIMIT
     , C_EXPKJMERGER
     , F_MINDAY
     , F_MAXDAY
     , C_IMPKJSPLIT
     , C_FIRSTINVESTMERGERJUDGE
     , C_ISESHARESFUND
     , C_PROMISERDMFUNDCODE
     , C_ISCONTROLTRADE
     , C_ISINCLUDEINCOME
     , C_ISCHECKVAST
     , C_SPLITALLMAINSHARES
     , C_CNTAILDEALTYPE
     , C_CNSPLITTYPE
     , C_UNITEXPWEBBANK
     , C_ISCHECKTHRESHOLD
     , F_SHARERATIO
     , C_TZJYCODE
     , C_EXPTZJYMERGER
     , C_LARGEEXCEEDCOMCTL
     , C_VASTMERGSHARECLASS
     , C_CUSTMAXBALACOMCTL
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TSHARECLASS_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TSHARECLASS_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TSHARECLASS_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TSHARECLASS_PFD成功"
      exit 0
   fi
fi
