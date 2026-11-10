#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSZTA.ODS_HSZTA_TACCONET_PFD_TMP;
CREATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TACCONET_PFD_TMP(
  C_FUNDACCO  STRING  COMMENT  '基金账号',
  C_AGENCYNO  STRING  COMMENT  '销售商编号',
  C_NETNO  STRING  COMMENT  '网点编号',
  C_TRADEACCO  STRING  COMMENT  '交易账号',
  C_TRADEACCOSTATUS  STRING  COMMENT  '交易账号状态',
  C_BONUSTYPE  STRING  COMMENT  '分红方式',
  C_BANKNO  STRING  COMMENT  '交收行名称',
  C_BANKACCO  STRING  COMMENT  '交收行账号',
  C_NAMEINBANK  STRING  COMMENT  '交收行户名',
  C_CHILDNETNO  STRING  COMMENT  '操作网点编号',
  C_TRADEACCOBAK  STRING  COMMENT  '交易账号备份',
  C_SOLUTIONID  STRING  COMMENT  '计划代码',
  C_SOLUTIONACCO  STRING  COMMENT  '计划账户',
  C_SYSROLE  STRING  COMMENT  '系统角色',
  C_SPECIALACCOFLAG  STRING  COMMENT  '是否特殊账号',
  C_BANKNAME  STRING  COMMENT  '银行名称',
  C_BRANCHBANK  STRING  COMMENT  '分行',
  C_BANKPROVINCE  STRING  COMMENT  '银行省',
  C_BANKCITYNO  STRING  COMMENT  '银行城市',
  C_PARTNERID  STRING  COMMENT  '',
  C_ISENDOWACCO  STRING  COMMENT  '是否赋予账户',
  C_CREDITACCOFLAG  STRING  COMMENT  '信用账户标志',
  C_MANAGERREGISCODE  STRING  COMMENT  '',
  C_VIRTUALTACODE  STRING  COMMENT  '',
  C_ACCTNOOFFMINCLEARINGAGENCY  STRING  COMMENT  '',
  C_MULTIACCTFLAG  STRING  COMMENT  '',
  D_LASTMODIFY  STRING  COMMENT  '最后修改日期',
  D_OPENDATE  STRING  COMMENT  '开户日期',
  C_INVESTCODE  STRING  COMMENT  '',
  C_INVESTFLAG  STRING  COMMENT  '',
  C_CONTYPE  STRING  COMMENT  '',
  C_CONTNO  STRING  COMMENT  '',
  C_CONTACT  STRING  COMMENT  '',
  D_CONTIDNOVALIDDATE  STRING  COMMENT  '',
  C_CONIDCARD18LEN  STRING  COMMENT  '',
  C_PENSION  STRING  COMMENT  '',
  C_FUNDMETHOD  STRING  COMMENT  ''
)
COMMENT '账号可交易网点'
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
            "username": "${hszta_username}",
            "password": "${hszta_password}",
            "connection": [{
              "querySql": ["SELECT  C_FUNDACCO
                                   , C_AGENCYNO
                                   , C_NETNO
                                   , C_TRADEACCO
                                   , C_TRADEACCOSTATUS
                                   , C_BONUSTYPE
                                   , C_BANKNO
                                   , C_BANKACCO
                                   , C_NAMEINBANK
                                   , C_CHILDNETNO
                                   , C_TRADEACCOBAK
                                   , C_SOLUTIONID
                                   , C_SOLUTIONACCO
                                   , C_SYSROLE
                                   , C_SPECIALACCOFLAG
                                   , C_BANKNAME
                                   , C_BRANCHBANK
                                   , C_BANKPROVINCE
                                   , C_BANKCITYNO
                                   , C_PARTNERID
                                   , C_ISENDOWACCO
                                   , C_CREDITACCOFLAG
                                   , C_MANAGERREGISCODE
                                   , C_VIRTUALTACODE
                                   , C_ACCTNOOFFMINCLEARINGAGENCY
                                   , C_MULTIACCTFLAG
                                   , D_LASTMODIFY
                                   , D_OPENDATE
                                   , C_INVESTCODE
                                   , C_INVESTFLAG
                                   , C_CONTYPE
                                   , C_CONTNO
                                   , C_CONTACT
                                   , D_CONTIDNOVALIDDATE
                                   , C_CONIDCARD18LEN
                                   , C_PENSION
                                   , C_FUNDMETHOD
                                FROM ${hszta_src_schema}.TACCONET"],
              "jdbcUrl": ["${hszta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_FUNDACCO", "type": "STRING"}, {"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "C_TRADEACCO", "type": "STRING"}, {"name": "C_TRADEACCOSTATUS", "type": "STRING"}, {"name": "C_BONUSTYPE", "type": "STRING"}, {"name": "C_BANKNO", "type": "STRING"}, {"name": "C_BANKACCO", "type": "STRING"}, {"name": "C_NAMEINBANK", "type": "STRING"}, {"name": "C_CHILDNETNO", "type": "STRING"}, {"name": "C_TRADEACCOBAK", "type": "STRING"}, {"name": "C_SOLUTIONID", "type": "STRING"}, {"name": "C_SOLUTIONACCO", "type": "STRING"}, {"name": "C_SYSROLE", "type": "STRING"}, {"name": "C_SPECIALACCOFLAG", "type": "STRING"}, {"name": "C_BANKNAME", "type": "STRING"}, {"name": "C_BRANCHBANK", "type": "STRING"}, {"name": "C_BANKPROVINCE", "type": "STRING"}, {"name": "C_BANKCITYNO", "type": "STRING"}, {"name": "C_PARTNERID", "type": "STRING"}, {"name": "C_ISENDOWACCO", "type": "STRING"}, {"name": "C_CREDITACCOFLAG", "type": "STRING"}, {"name": "C_MANAGERREGISCODE", "type": "STRING"}, {"name": "C_VIRTUALTACODE", "type": "STRING"}, {"name": "C_ACCTNOOFFMINCLEARINGAGENCY", "type": "STRING"}, {"name": "C_MULTIACCTFLAG", "type": "STRING"}, {"name": "D_LASTMODIFY", "type": "STRING"}, {"name": "D_OPENDATE", "type": "STRING"}, {"name": "C_INVESTCODE", "type": "STRING"}, {"name": "C_INVESTFLAG", "type": "STRING"}, {"name": "C_CONTYPE", "type": "STRING"}, {"name": "C_CONTNO", "type": "STRING"}, {"name": "C_CONTACT", "type": "STRING"}, {"name": "D_CONTIDNOVALIDDATE", "type": "STRING"}, {"name": "C_CONIDCARD18LEN", "type": "STRING"}, {"name": "C_PENSION", "type": "STRING"}, {"name": "C_FUNDMETHOD", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hszta_tacconet_pfd_tmp",
            "fileType": "text",
            "path": "${hszta_path}/ods_hszta_tacconet_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hszta_tacconet_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hszta_tacconet_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSZTA_TACCONET_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSZTA_TACCONET_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hszta_tacconet_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TACCONET_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_FUNDACCO
     , C_AGENCYNO
     , C_NETNO
     , C_TRADEACCO
     , C_TRADEACCOSTATUS
     , C_BONUSTYPE
     , C_BANKNO
     , C_BANKACCO
     , C_NAMEINBANK
     , C_CHILDNETNO
     , C_TRADEACCOBAK
     , C_SOLUTIONID
     , C_SOLUTIONACCO
     , C_SYSROLE
     , C_SPECIALACCOFLAG
     , C_BANKNAME
     , C_BRANCHBANK
     , C_BANKPROVINCE
     , C_BANKCITYNO
     , C_PARTNERID
     , C_ISENDOWACCO
     , C_CREDITACCOFLAG
     , C_MANAGERREGISCODE
     , C_VIRTUALTACODE
     , C_ACCTNOOFFMINCLEARINGAGENCY
     , C_MULTIACCTFLAG
     , D_LASTMODIFY
     , D_OPENDATE
     , C_INVESTCODE
     , C_INVESTFLAG
     , C_CONTYPE
     , C_CONTNO
     , C_CONTACT
     , D_CONTIDNOVALIDDATE
     , C_CONIDCARD18LEN
     , C_PENSION
     , C_FUNDMETHOD
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSZTA.ODS_HSZTA_TACCONET_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSZTA.ODS_HSZTA_TACCONET_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSZTA_TACCONET_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSZTA_TACCONET_PFD成功"
      exit 0
   fi
fi
