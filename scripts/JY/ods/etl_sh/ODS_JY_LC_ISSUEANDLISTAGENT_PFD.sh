#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_ISSUEANDLISTAGENT_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_ISSUEANDLISTAGENT_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  ISSUEANDLISTTYPE  DECIMAL(10,0)  COMMENT  '发行与上市类别',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  INITIALINFOPUBLDATE  STRING  COMMENT  '首次信息发布日期',
  AGENTTYPE  DECIMAL(10,0)  COMMENT  '机构类别',
  AGENTCODE  STRING  COMMENT  '机构编号',
  FULLNAME  STRING  COMMENT  '机构全称',
  ABBRNAME  STRING  COMMENT  '机构简称',
  LEGALPERSONREPR  STRING  COMMENT  '法人代表',
  ADDRESS  STRING  COMMENT  '住址',
  CODE  STRING  COMMENT  '代码',
  WEBSITE  STRING  COMMENT  '公司网址',
  EMAIL  STRING  COMMENT  '邮箱',
  TEL  STRING  COMMENT  '电话',
  FAX  STRING  COMMENT  '传真',
  CONTACTMAN  STRING  COMMENT  '联系人',
  PERSONINCHARGE  STRING  COMMENT  '经办人',
  UNDERWRITINGVOL  DECIMAL(16,0)  COMMENT  '承销数量(股)',
  UNDERWRITINGSUM  DECIMAL(19,4)  COMMENT  '承销金额(元)',
  UNDERWRITINGRATIO  DECIMAL(9,6)  COMMENT  '承销比例',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  AGENTDATA  DECIMAL(10,0)  COMMENT  '中介类别',
  REPRESENTATIVE  STRING  COMMENT  '代表人',
  IFEFFECTED  DECIMAL(10,0)  COMMENT  '是否有效',
  CANCELDATE  STRING  COMMENT  '取消日期',
  REMARK  STRING  COMMENT  '备注',
  STARTDATE  STRING  COMMENT  '开始日期',
  SERIALNUMBER  DECIMAL(10,0)  COMMENT  '序号',
  DOCRECEPARTY  DECIMAL(10,0)  COMMENT  '核查材料接收方'
)
COMMENT '发行与上市中介机构'
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
                                   , ISSUEANDLISTTYPE
                                   , INNERCODE
                                   , INITIALINFOPUBLDATE
                                   , AGENTTYPE
                                   , AGENTCODE
                                   , FULLNAME
                                   , ABBRNAME
                                   , LEGALPERSONREPR
                                   , ADDRESS
                                   , CODE
                                   , WEBSITE
                                   , EMAIL
                                   , TEL
                                   , FAX
                                   , CONTACTMAN
                                   , PERSONINCHARGE
                                   , UNDERWRITINGVOL
                                   , UNDERWRITINGSUM
                                   , UNDERWRITINGRATIO
                                   , XGRQ
                                   , JSID
                                   , AGENTDATA
                                   , REPRESENTATIVE
                                   , IFEFFECTED
                                   , CANCELDATE
                                   , REMARK
                                   , STARTDATE
                                   , SERIALNUMBER
                                   , DOCRECEPARTY
                                FROM ${jy_src_schema}.LC_ISSUEANDLISTAGENT"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "ISSUEANDLISTTYPE", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "INITIALINFOPUBLDATE", "type": "STRING"}, {"name": "AGENTTYPE", "type": "DOUBLE"}, {"name": "AGENTCODE", "type": "DOUBLE"}, {"name": "FULLNAME", "type": "STRING"}, {"name": "ABBRNAME", "type": "STRING"}, {"name": "LEGALPERSONREPR", "type": "STRING"}, {"name": "ADDRESS", "type": "STRING"}, {"name": "CODE", "type": "STRING"}, {"name": "WEBSITE", "type": "STRING"}, {"name": "EMAIL", "type": "STRING"}, {"name": "TEL", "type": "STRING"}, {"name": "FAX", "type": "STRING"}, {"name": "CONTACTMAN", "type": "STRING"}, {"name": "PERSONINCHARGE", "type": "STRING"}, {"name": "UNDERWRITINGVOL", "type": "DOUBLE"}, {"name": "UNDERWRITINGSUM", "type": "DOUBLE"}, {"name": "UNDERWRITINGRATIO", "type": "DOUBLE"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "AGENTDATA", "type": "DOUBLE"}, {"name": "REPRESENTATIVE", "type": "STRING"}, {"name": "IFEFFECTED", "type": "DOUBLE"}, {"name": "CANCELDATE", "type": "STRING"}, {"name": "REMARK", "type": "STRING"}, {"name": "STARTDATE", "type": "STRING"}, {"name": "SERIALNUMBER", "type": "DOUBLE"}, {"name": "DOCRECEPARTY", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_issueandlistagent_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_issueandlistagent_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_issueandlistagent_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_issueandlistagent_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_ISSUEANDLISTAGENT_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_ISSUEANDLISTAGENT_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_issueandlistagent_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_ISSUEANDLISTAGENT_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , ISSUEANDLISTTYPE
     , INNERCODE
     , INITIALINFOPUBLDATE
     , AGENTTYPE
     , AGENTCODE
     , FULLNAME
     , ABBRNAME
     , LEGALPERSONREPR
     , ADDRESS
     , CODE
     , WEBSITE
     , EMAIL
     , TEL
     , FAX
     , CONTACTMAN
     , PERSONINCHARGE
     , UNDERWRITINGVOL
     , UNDERWRITINGSUM
     , UNDERWRITINGRATIO
     , XGRQ
     , JSID
     , AGENTDATA
     , REPRESENTATIVE
     , IFEFFECTED
     , CANCELDATE
     , REMARK
     , STARTDATE
     , SERIALNUMBER
     , DOCRECEPARTY
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_LC_ISSUEANDLISTAGENT_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_ISSUEANDLISTAGENT_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_ISSUEANDLISTAGENT_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_ISSUEANDLISTAGENT_PFD成功"
      exit 0
   fi
fi
