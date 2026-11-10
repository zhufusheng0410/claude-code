#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_INSTIARCHIVE_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_INSTIARCHIVE_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  COMPANYCODE  STRING  COMMENT  '公司代码',
  PARENTCOMPANY  DECIMAL(10,0)  COMMENT  '所属公司',
  LISTEDCODE  STRING  COMMENT  '上市公司代码',
  INVESTADVISORNAME  DECIMAL(10,0)  COMMENT  '基金管理人名称',
  TRUSTEENAME  DECIMAL(10,0)  COMMENT  '基金托管人名称',
  CHINAME  STRING  COMMENT  '中文名称',
  ABBRCHINAME  STRING  COMMENT  '中文简称',
  NAMECHISPELLING  STRING  COMMENT  '中文拼音简称',
  ENGNAME  STRING  COMMENT  '英文名称',
  ABBRENGNAME  STRING  COMMENT  '英文简称',
  REGCAPITAL  DECIMAL(19,4)  COMMENT  '注册资本(元)',
  CURRENCYUNIT  DECIMAL(10,0)  COMMENT  '货币单位',
  ESTABLISHMENTDATE  STRING  COMMENT  '公司成立日期',
  ECONOMICNATURE  DECIMAL(10,0)  COMMENT  '经济性质',
  COMPANYNATURE  DECIMAL(10,0)  COMMENT  '企业性质',
  COMPANYTYPE  DECIMAL(10,0)  COMMENT  '企业类别',
  REGADDR  STRING  COMMENT  '公司注册地址',
  REGZIP  STRING  COMMENT  '注册地址邮编',
  REGCITY  DECIMAL(10,0)  COMMENT  '注册所在城市',
  OFFICEADDR  STRING  COMMENT  '公司办公地址',
  CONTACTADDR  STRING  COMMENT  '公司联系地址',
  CONTACTZIP  STRING  COMMENT  '联系地址邮编',
  CONTACTCITY  DECIMAL(10,0)  COMMENT  '联系所在城市',
  EMAIL  STRING  COMMENT  '邮箱',
  WEBSITE  STRING  COMMENT  '公司网址',
  LEGALPERSONREPR  STRING  COMMENT  '法人代表',
  GENERALMANAGER  STRING  COMMENT  '总经理',
  OTHERMANAGER  STRING  COMMENT  '其它负责人',
  CONTACTMAN  STRING  COMMENT  '联系人',
  TEL  STRING  COMMENT  '电话',
  FAX  STRING  COMMENT  '传真',
  BRIEFINTROTEXT  STRING  COMMENT  '公司简介',
  BUSINESSMAJOR  STRING  COMMENT  '经营范围-主营',
  INDUSTRY  DECIMAL(10,0)  COMMENT  '所属行业',
  STARTDATE  STRING  COMMENT  '起始日期',
  CLOSEDATE  STRING  COMMENT  '存续截止日',
  CLOSEREASON  DECIMAL(10,0)  COMMENT  '存续截止原因',
  IFEXISTED  DECIMAL(10,0)  COMMENT  '是否存在',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  ORGANIZATIONCODE  STRING  COMMENT  '评级机构代码',
  COMPANYCVAL  DECIMAL(10,0)  COMMENT  '公司属性',
  CREDITCODE  STRING  COMMENT  '统一社会信用代码',
  REGAREA  DECIMAL(10,0)  COMMENT  '注册地城市',
  REGORG  STRING  COMMENT  '登记机构',
  REGSTATUS  DECIMAL(10,0)  COMMENT  '登记状态'
)
COMMENT '机构基本资料'
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
                                   , PARENTCOMPANY
                                   , LISTEDCODE
                                   , INVESTADVISORNAME
                                   , TRUSTEENAME
                                   , CHINAME
                                   , ABBRCHINAME
                                   , NAMECHISPELLING
                                   , ENGNAME
                                   , ABBRENGNAME
                                   , REGCAPITAL
                                   , CURRENCYUNIT
                                   , ESTABLISHMENTDATE
                                   , ECONOMICNATURE
                                   , COMPANYNATURE
                                   , COMPANYTYPE
                                   , REGADDR
                                   , REGZIP
                                   , REGCITY
                                   , OFFICEADDR
                                   , CONTACTADDR
                                   , CONTACTZIP
                                   , CONTACTCITY
                                   , EMAIL
                                   , WEBSITE
                                   , LEGALPERSONREPR
                                   , GENERALMANAGER
                                   , OTHERMANAGER
                                   , CONTACTMAN
                                   , TEL
                                   , FAX
                                   , BRIEFINTROTEXT
                                   , BUSINESSMAJOR
                                   , INDUSTRY
                                   , STARTDATE
                                   , CLOSEDATE
                                   , CLOSEREASON
                                   , IFEXISTED
                                   , XGRQ
                                   , JSID
                                   , ORGANIZATIONCODE
                                   , COMPANYCVAL
                                   , CREDITCODE
                                   , REGAREA
                                   , REGORG
                                   , REGSTATUS
                                FROM ${jy_src_schema}.LC_INSTIARCHIVE"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "COMPANYCODE", "type": "DOUBLE"}, {"name": "PARENTCOMPANY", "type": "DOUBLE"}, {"name": "LISTEDCODE", "type": "DOUBLE"}, {"name": "INVESTADVISORNAME", "type": "DOUBLE"}, {"name": "TRUSTEENAME", "type": "DOUBLE"}, {"name": "CHINAME", "type": "STRING"}, {"name": "ABBRCHINAME", "type": "STRING"}, {"name": "NAMECHISPELLING", "type": "STRING"}, {"name": "ENGNAME", "type": "STRING"}, {"name": "ABBRENGNAME", "type": "STRING"}, {"name": "REGCAPITAL", "type": "DOUBLE"}, {"name": "CURRENCYUNIT", "type": "DOUBLE"}, {"name": "ESTABLISHMENTDATE", "type": "STRING"}, {"name": "ECONOMICNATURE", "type": "DOUBLE"}, {"name": "COMPANYNATURE", "type": "DOUBLE"}, {"name": "COMPANYTYPE", "type": "DOUBLE"}, {"name": "REGADDR", "type": "STRING"}, {"name": "REGZIP", "type": "STRING"}, {"name": "REGCITY", "type": "DOUBLE"}, {"name": "OFFICEADDR", "type": "STRING"}, {"name": "CONTACTADDR", "type": "STRING"}, {"name": "CONTACTZIP", "type": "STRING"}, {"name": "CONTACTCITY", "type": "DOUBLE"}, {"name": "EMAIL", "type": "STRING"}, {"name": "WEBSITE", "type": "STRING"}, {"name": "LEGALPERSONREPR", "type": "STRING"}, {"name": "GENERALMANAGER", "type": "STRING"}, {"name": "OTHERMANAGER", "type": "STRING"}, {"name": "CONTACTMAN", "type": "STRING"}, {"name": "TEL", "type": "STRING"}, {"name": "FAX", "type": "STRING"}, {"name": "BRIEFINTROTEXT", "type": "STRING"}, {"name": "BUSINESSMAJOR", "type": "STRING"}, {"name": "INDUSTRY", "type": "DOUBLE"}, {"name": "STARTDATE", "type": "STRING"}, {"name": "CLOSEDATE", "type": "STRING"}, {"name": "CLOSEREASON", "type": "DOUBLE"}, {"name": "IFEXISTED", "type": "DOUBLE"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "ORGANIZATIONCODE", "type": "STRING"}, {"name": "COMPANYCVAL", "type": "DOUBLE"}, {"name": "CREDITCODE", "type": "STRING"}, {"name": "REGAREA", "type": "DOUBLE"}, {"name": "REGORG", "type": "STRING"}, {"name": "REGSTATUS", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_instiarchive_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_instiarchive_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_instiarchive_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_instiarchive_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_INSTIARCHIVE_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_INSTIARCHIVE_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_instiarchive_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_INSTIARCHIVE_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , COMPANYCODE
     , PARENTCOMPANY
     , LISTEDCODE
     , INVESTADVISORNAME
     , TRUSTEENAME
     , CHINAME
     , ABBRCHINAME
     , NAMECHISPELLING
     , ENGNAME
     , ABBRENGNAME
     , REGCAPITAL
     , CURRENCYUNIT
     , ESTABLISHMENTDATE
     , ECONOMICNATURE
     , COMPANYNATURE
     , COMPANYTYPE
     , REGADDR
     , REGZIP
     , REGCITY
     , OFFICEADDR
     , CONTACTADDR
     , CONTACTZIP
     , CONTACTCITY
     , EMAIL
     , WEBSITE
     , LEGALPERSONREPR
     , GENERALMANAGER
     , OTHERMANAGER
     , CONTACTMAN
     , TEL
     , FAX
     , BRIEFINTROTEXT
     , BUSINESSMAJOR
     , INDUSTRY
     , STARTDATE
     , CLOSEDATE
     , CLOSEREASON
     , IFEXISTED
     , XGRQ
     , JSID
     , ORGANIZATIONCODE
     , COMPANYCVAL
     , CREDITCODE
     , REGAREA
     , REGORG
     , REGSTATUS
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_LC_INSTIARCHIVE_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_INSTIARCHIVE_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_INSTIARCHIVE_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_INSTIARCHIVE_PFD成功"
      exit 0
   fi
fi
