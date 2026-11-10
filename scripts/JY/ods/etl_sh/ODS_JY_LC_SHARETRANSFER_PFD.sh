#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_SHARETRANSFER_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_SHARETRANSFER_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  COMPANYCODE  STRING  COMMENT  '公司代码',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  INFOSOURCE  STRING  COMMENT  '信息来源',
  CONTRACTSIGNDATE  STRING  COMMENT  '股权转让协议签署日',
  APPROVEDDATE  STRING  COMMENT  '转让批准日期',
  TRANDATE  STRING  COMMENT  '股权正式变动日期/过户日期',
  TRANSFERERNAME  STRING  COMMENT  '股权出让方名称',
  TANSFERERECONATURE  DECIMAL(10,0)  COMMENT  '股权出让方经济性质',
  TRANSHARETYPE  DECIMAL(10,0)  COMMENT  '出让股权性质',
  SUMBEFORETRAN  DECIMAL(16,0)  COMMENT  '出让前持股数量(股)',
  PCTBEFORETRAN  DECIMAL(19,8)  COMMENT  '出让前持股比例',
  SUMAFTERTRAN  DECIMAL(16,0)  COMMENT  '出让后持股数量(股)',
  PCTAFTERTRAN  DECIMAL(19,8)  COMMENT  '出让后持股比例',
  RECEIVERNAME  STRING  COMMENT  '接受股权质押方',
  RECEIVERECONATURE  DECIMAL(10,0)  COMMENT  '股权受让方经济性质',
  SUMAFTERRECE  DECIMAL(16,0)  COMMENT  '受让后持股数量(股)',
  PCTAFTERRECE  DECIMAL(19,8)  COMMENT  '受让后持股比例',
  TRANMODE  DECIMAL(10,0)  COMMENT  '股权转让方式',
  INVOLVEDSUM  DECIMAL(16,0)  COMMENT  '涉及股数(股)',
  PCTOFTANSFERER  DECIMAL(19,8)  COMMENT  '占出让方原持股数比例',
  PCTOFTOTALSHARES  DECIMAL(19,8)  COMMENT  '占总股本比例',
  DEALPRICE  DECIMAL(19,4)  COMMENT  '交易价格(元/股)',
  DEALTURNOVER  DECIMAL(19,4)  COMMENT  '交易金额(元)',
  VALIDCONDITION  STRING  COMMENT  '生效条件',
  TRANSTATEMENT  STRING  COMMENT  '事项描述与进展说明',
  IFSUSPENDED  DECIMAL(10,0)  COMMENT  '是否终止实施',
  SUSPENDEDPUBLDATE  STRING  COMMENT  '终止实施公告日期',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  SNBEFORETRAN  DECIMAL(5,0)  COMMENT  '出让前股东序号',
  SNAFTERTRAN  DECIMAL(5,0)  COMMENT  '出让后股东序号',
  SNAFTERRECE  DECIMAL(5,0)  COMMENT  '受让后股东序号',
  IFSPBLOCKTRADECODE  STRING  COMMENT  '是否专场大宗交易代码',
  IFSPBLOCKTRADE  STRING  COMMENT  '是否专场大宗交易',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  RESSUMAFTERTRAN  DECIMAL(16,0)  COMMENT  '其中:出让后有限售股数(股)',
  NONRESSUMAFTERTRAN  DECIMAL(16,0)  COMMENT  '其中:出让后无限售股数(股)',
  RESSUMAFTERRECE  DECIMAL(16,0)  COMMENT  '其中:受让后有限售股数(股)',
  NONRESSUMAFTERRECE  DECIMAL(16,0)  COMMENT  '其中:受让后无限售股数(股)',
  INITIALINFOPUBLDATE  STRING  COMMENT  '首次信息发布日期',
  TRANSFERERATTRIBUTE  DECIMAL(10,0)  COMMENT  '股权出让方所属性质',
  TRANSFERERCODE  STRING  COMMENT  '股权出让方编码',
  RECEIVERATTRIBUTE  DECIMAL(10,0)  COMMENT  '股权受让方所属性质',
  RECEIVERCODE  STRING  COMMENT  '股权受让方编码',
  INSERTTIME  STRING  COMMENT  '发布时间',
  SUMBEFORERECE  DECIMAL(16,0)  COMMENT  '受让前持股数量(股)',
  PCTBEFORERRECE  DECIMAL(19,8)  COMMENT  '受让前持股比例(%)',
  TRANSTARTDATE  STRING  COMMENT  '股权变动起始日',
  SERIALNUMBER  DECIMAL(10,0)  COMMENT  '序号'
)
COMMENT '股东股权变动'
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
            "username": "${jy_username}",
            "password": "${jy_password}",
            "connection": [{
              "querySql": ["SELECT  ID
                                   , COMPANYCODE
                                   , INFOPUBLDATE
                                   , INFOSOURCE
                                   , CONTRACTSIGNDATE
                                   , APPROVEDDATE
                                   , TRANDATE
                                   , TRANSFERERNAME
                                   , TANSFERERECONATURE
                                   , TRANSHARETYPE
                                   , SUMBEFORETRAN
                                   , PCTBEFORETRAN
                                   , SUMAFTERTRAN
                                   , PCTAFTERTRAN
                                   , RECEIVERNAME
                                   , RECEIVERECONATURE
                                   , SUMAFTERRECE
                                   , PCTAFTERRECE
                                   , TRANMODE
                                   , INVOLVEDSUM
                                   , PCTOFTANSFERER
                                   , PCTOFTOTALSHARES
                                   , DEALPRICE
                                   , DEALTURNOVER
                                   , VALIDCONDITION
                                   , TRANSTATEMENT
                                   , IFSUSPENDED
                                   , SUSPENDEDPUBLDATE
                                   , XGRQ
                                   , JSID
                                   , SNBEFORETRAN
                                   , SNAFTERTRAN
                                   , SNAFTERRECE
                                   , IFSPBLOCKTRADECODE
                                   , IFSPBLOCKTRADE
                                   , INNERCODE
                                   , RESSUMAFTERTRAN
                                   , NONRESSUMAFTERTRAN
                                   , RESSUMAFTERRECE
                                   , NONRESSUMAFTERRECE
                                   , INITIALINFOPUBLDATE
                                   , TRANSFERERATTRIBUTE
                                   , TRANSFERERCODE
                                   , RECEIVERATTRIBUTE
                                   , RECEIVERCODE
                                   , INSERTTIME
                                   , SUMBEFORERECE
                                   , PCTBEFORERRECE
                                   , TRANSTARTDATE
                                   , SERIALNUMBER
                                FROM ${jy_src_schema}.LC_SHARETRANSFER"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "COMPANYCODE", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "INFOSOURCE", "type": "STRING"}, {"name": "CONTRACTSIGNDATE", "type": "STRING"}, {"name": "APPROVEDDATE", "type": "STRING"}, {"name": "TRANDATE", "type": "STRING"}, {"name": "TRANSFERERNAME", "type": "STRING"}, {"name": "TANSFERERECONATURE", "type": "DOUBLE"}, {"name": "TRANSHARETYPE", "type": "DOUBLE"}, {"name": "SUMBEFORETRAN", "type": "DOUBLE"}, {"name": "PCTBEFORETRAN", "type": "DOUBLE"}, {"name": "SUMAFTERTRAN", "type": "DOUBLE"}, {"name": "PCTAFTERTRAN", "type": "DOUBLE"}, {"name": "RECEIVERNAME", "type": "STRING"}, {"name": "RECEIVERECONATURE", "type": "DOUBLE"}, {"name": "SUMAFTERRECE", "type": "DOUBLE"}, {"name": "PCTAFTERRECE", "type": "DOUBLE"}, {"name": "TRANMODE", "type": "DOUBLE"}, {"name": "INVOLVEDSUM", "type": "DOUBLE"}, {"name": "PCTOFTANSFERER", "type": "DOUBLE"}, {"name": "PCTOFTOTALSHARES", "type": "DOUBLE"}, {"name": "DEALPRICE", "type": "DOUBLE"}, {"name": "DEALTURNOVER", "type": "DOUBLE"}, {"name": "VALIDCONDITION", "type": "STRING"}, {"name": "TRANSTATEMENT", "type": "STRING"}, {"name": "IFSUSPENDED", "type": "DOUBLE"}, {"name": "SUSPENDEDPUBLDATE", "type": "STRING"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "SNBEFORETRAN", "type": "DOUBLE"}, {"name": "SNAFTERTRAN", "type": "DOUBLE"}, {"name": "SNAFTERRECE", "type": "DOUBLE"}, {"name": "IFSPBLOCKTRADECODE", "type": "DOUBLE"}, {"name": "IFSPBLOCKTRADE", "type": "STRING"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "RESSUMAFTERTRAN", "type": "DOUBLE"}, {"name": "NONRESSUMAFTERTRAN", "type": "DOUBLE"}, {"name": "RESSUMAFTERRECE", "type": "DOUBLE"}, {"name": "NONRESSUMAFTERRECE", "type": "DOUBLE"}, {"name": "INITIALINFOPUBLDATE", "type": "STRING"}, {"name": "TRANSFERERATTRIBUTE", "type": "DOUBLE"}, {"name": "TRANSFERERCODE", "type": "DOUBLE"}, {"name": "RECEIVERATTRIBUTE", "type": "DOUBLE"}, {"name": "RECEIVERCODE", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}, {"name": "SUMBEFORERECE", "type": "DOUBLE"}, {"name": "PCTBEFORERRECE", "type": "DOUBLE"}, {"name": "TRANSTARTDATE", "type": "STRING"}, {"name": "SERIALNUMBER", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_sharetransfer_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_sharetransfer_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_sharetransfer_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_sharetransfer_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_SHARETRANSFER_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_SHARETRANSFER_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_sharetransfer_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_SHARETRANSFER_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , COMPANYCODE
     , INFOPUBLDATE
     , INFOSOURCE
     , CONTRACTSIGNDATE
     , APPROVEDDATE
     , TRANDATE
     , TRANSFERERNAME
     , TANSFERERECONATURE
     , TRANSHARETYPE
     , SUMBEFORETRAN
     , PCTBEFORETRAN
     , SUMAFTERTRAN
     , PCTAFTERTRAN
     , RECEIVERNAME
     , RECEIVERECONATURE
     , SUMAFTERRECE
     , PCTAFTERRECE
     , TRANMODE
     , INVOLVEDSUM
     , PCTOFTANSFERER
     , PCTOFTOTALSHARES
     , DEALPRICE
     , DEALTURNOVER
     , VALIDCONDITION
     , TRANSTATEMENT
     , IFSUSPENDED
     , SUSPENDEDPUBLDATE
     , XGRQ
     , JSID
     , SNBEFORETRAN
     , SNAFTERTRAN
     , SNAFTERRECE
     , IFSPBLOCKTRADECODE
     , IFSPBLOCKTRADE
     , INNERCODE
     , RESSUMAFTERTRAN
     , NONRESSUMAFTERTRAN
     , RESSUMAFTERRECE
     , NONRESSUMAFTERRECE
     , INITIALINFOPUBLDATE
     , TRANSFERERATTRIBUTE
     , TRANSFERERCODE
     , RECEIVERATTRIBUTE
     , RECEIVERCODE
     , INSERTTIME
     , SUMBEFORERECE
     , PCTBEFORERRECE
     , TRANSTARTDATE
     , SERIALNUMBER
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_LC_SHARETRANSFER_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_SHARETRANSFER_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_SHARETRANSFER_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_SHARETRANSFER_PFD成功"
      exit 0
   fi
fi
