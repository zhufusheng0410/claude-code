#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_WIND.ODS_WIND_CHINAMUTUALFUNDDESCRIPTION_PFD_TMP;
CREATE TABLE ODS_XDAY_WIND.ODS_WIND_CHINAMUTUALFUNDDESCRIPTION_PFD_TMP(
  OBJECT_ID  STRING  COMMENT  '对象ID',
  F_INFO_WINDCODE  STRING  COMMENT  'Wind代码',
  F_INFO_FRONT_CODE  STRING  COMMENT  '前端代码',
  F_INFO_BACKEND_CODE  STRING  COMMENT  '后端代码',
  F_INFO_FULLNAME  STRING  COMMENT  '名称',
  F_INFO_NAME  STRING  COMMENT  '简称',
  F_INFO_CORP_FUNDMANAGEMENTCOMP  STRING  COMMENT  '管理人',
  F_INFO_CUSTODIANBANK  STRING  COMMENT  '托管人',
  F_INFO_FIRSTINVESTTYPE  STRING  COMMENT  '投资类型',
  F_INFO_SETUPDATE  STRING  COMMENT  '成立日期',
  F_INFO_MATURITYDATE  STRING  COMMENT  '到期日期',
  F_ISSUE_TOTALUNIT  DECIMAL(18,2)  COMMENT  '发行份额',
  F_INFO_MANAGEMENTFEERATIO  DECIMAL(18,2)  COMMENT  '管理费',
  F_INFO_CUSTODIANFEERATIO  DECIMAL(18,2)  COMMENT  '托管费',
  CRNY_CODE  STRING  COMMENT  '货币代码',
  F_INFO_PTMYEAR  DECIMAL(18,2)  COMMENT  '存续期',
  F_ISSUE_OEF_STARTDATEINST  STRING  COMMENT  '机构投资者认购起始日',
  F_ISSUE_OEF_DNDDATEINST  STRING  COMMENT  '机构投资者认购终止日',
  F_INFO_PARVALUE  DECIMAL(18,2)  COMMENT  '面值',
  F_INFO_TRUSTTYPE  STRING  COMMENT  '信托类别',
  F_INFO_TRUSTEE  STRING  COMMENT  '受托人',
  F_PCHREDM_PCHSTARTDATE  STRING  COMMENT  '日常申购起始日',
  F_INFO_REDMSTARTDATE  STRING  COMMENT  '日常赎回起始日',
  F_INFO_MINBUYAMOUNT  DECIMAL(18,2)  COMMENT  '起点金额',
  F_INFO_EXPECTEDRATEOFRETURN  DECIMAL(18,2)  COMMENT  '预期收益率',
  F_INFO_ISSUINGPLACE  STRING  COMMENT  '发行地',
  F_INFO_BENCHMARK  STRING  COMMENT  '业绩比较基准',
  F_INFO_STATUS  DECIMAL(18,2)  COMMENT  '存续状态',
  F_INFO_RESTRICTEDORNOT  STRING  COMMENT  '限定类型',
  F_INFO_STRUCTUREDORNOT  DECIMAL(18,2)  COMMENT  '是否结构化产品',
  F_INFO_EXCHMARKET  STRING  COMMENT  '交易所',
  F_INFO_FIRSTINVESTSTYLE  STRING  COMMENT  '投资风格',
  F_INFO_ISSUEDATE  STRING  COMMENT  '发行日期',
  F_INFO_TYPE  STRING  COMMENT  '基金类型',
  F_INFO_ISINITIAL  DECIMAL(18,2)  COMMENT  '是否为初始基金',
  F_INFO_PINYIN  STRING  COMMENT  '简称拼音',
  F_INFO_INVESTSCOPE  STRING  COMMENT  '投资范围',
  F_INFO_INVESTOBJECT  STRING  COMMENT  '投资目标',
  F_INFO_INVESTCONCEPTION  STRING  COMMENT  '投资理念',
  F_INFO_DECISION_BASIS  STRING  COMMENT  '决策依据',
  IS_INDEXFUND  DECIMAL(18,2)  COMMENT  '是否指数基金',
  F_INFO_DELISTDATE  STRING  COMMENT  '退市日期',
  F_INFO_CORP_FUNDMANAGEMENTID  STRING  COMMENT  '基金管理人ID',
  F_INFO_CUSTODIANBANKID  STRING  COMMENT  '托管人id',
  MAX_NUM_HOLDER  DECIMAL(18,2)  COMMENT  '单一投资者持有份额上限(亿份)',
  MAX_NUM_COLTARGET  DECIMAL(18,2)  COMMENT  '封闭期目标募集数量上限(亿份)',
  INVESTSTRATEGY  STRING  COMMENT  '投资策略',
  RISK_RETURN  STRING  COMMENT  '基金风险收益特征',
  F_PCHREDM_PCHMINAMT  DECIMAL(18,2)  COMMENT  '每次最低申购金额(场外)(万元)',
  F_PCHREDM_PCHMINAMT_EX  DECIMAL(18,2)  COMMENT  '每次最低申购金额(场内) (万元)',
  F_INFO_LISTDATE  STRING  COMMENT  '上市时间',
  F_INFO_ANNDATE  STRING  COMMENT  '公告日期',
  F_CLOSED_OPERATION_PERIOD  DECIMAL(18,2)  COMMENT  '封闭运作期',
  F_CLOSED_OPERATION_INTERVAL  DECIMAL(18,2)  COMMENT  '封闭运作期满开放日间隔',
  F_INFO_REGISTRANT  STRING  COMMENT  '基金注册与过户登记人ID',
  F_PERSONAL_STARTDATEIND  STRING  COMMENT  '个人投资者认购起始日',
  F_PERSONAL_ENDDATEIND  STRING  COMMENT  '个人投资者认购终止日',
  F_INFO_FUND_ID  STRING  COMMENT  '基金品种ID',
  F_SALES_SERVICE_RATE  DECIMAL(18,2)  COMMENT  '销售服务费率',
  F_INVESTMENT_AREA  STRING  COMMENT  '投资区域',
  CLOSE_INSTITU_OEF_DOWN  DECIMAL(18,2)  COMMENT  '封闭期机构投资者认购下限(万元)',
  CLOSE_INSTITU_OEF_UP  DECIMAL(18,2)  COMMENT  '封闭期机构投资者认购上限(万元)',
  S_FELLOW_DISTOR  DECIMAL(18,2)  COMMENT  '总有效申购户数',
  OPDATE  STRING  COMMENT  '',
  OPMODE  STRING  COMMENT  ''
)
COMMENT '中国共同基金基本资料'
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
            "username": "${wind_username}",
            "password": "${wind_password}",
            "connection": [{
              "querySql": ["SELECT  OBJECT_ID
                                   , F_INFO_WINDCODE
                                   , F_INFO_FRONT_CODE
                                   , F_INFO_BACKEND_CODE
                                   , F_INFO_FULLNAME
                                   , F_INFO_NAME
                                   , F_INFO_CORP_FUNDMANAGEMENTCOMP
                                   , F_INFO_CUSTODIANBANK
                                   , F_INFO_FIRSTINVESTTYPE
                                   , F_INFO_SETUPDATE
                                   , F_INFO_MATURITYDATE
                                   , F_ISSUE_TOTALUNIT
                                   , F_INFO_MANAGEMENTFEERATIO
                                   , F_INFO_CUSTODIANFEERATIO
                                   , CRNY_CODE
                                   , F_INFO_PTMYEAR
                                   , F_ISSUE_OEF_STARTDATEINST
                                   , F_ISSUE_OEF_DNDDATEINST
                                   , F_INFO_PARVALUE
                                   , F_INFO_TRUSTTYPE
                                   , F_INFO_TRUSTEE
                                   , F_PCHREDM_PCHSTARTDATE
                                   , F_INFO_REDMSTARTDATE
                                   , F_INFO_MINBUYAMOUNT
                                   , F_INFO_EXPECTEDRATEOFRETURN
                                   , F_INFO_ISSUINGPLACE
                                   , F_INFO_BENCHMARK
                                   , F_INFO_STATUS
                                   , F_INFO_RESTRICTEDORNOT
                                   , F_INFO_STRUCTUREDORNOT
                                   , F_INFO_EXCHMARKET
                                   , F_INFO_FIRSTINVESTSTYLE
                                   , F_INFO_ISSUEDATE
                                   , F_INFO_TYPE
                                   , F_INFO_ISINITIAL
                                   , F_INFO_PINYIN
                                   , F_INFO_INVESTSCOPE
                                   , F_INFO_INVESTOBJECT
                                   , F_INFO_INVESTCONCEPTION
                                   , F_INFO_DECISION_BASIS
                                   , IS_INDEXFUND
                                   , F_INFO_DELISTDATE
                                   , F_INFO_CORP_FUNDMANAGEMENTID
                                   , F_INFO_CUSTODIANBANKID
                                   , MAX_NUM_HOLDER
                                   , MAX_NUM_COLTARGET
                                   , INVESTSTRATEGY
                                   , RISK_RETURN
                                   , F_PCHREDM_PCHMINAMT
                                   , F_PCHREDM_PCHMINAMT_EX
                                   , F_INFO_LISTDATE
                                   , F_INFO_ANNDATE
                                   , F_CLOSED_OPERATION_PERIOD
                                   , F_CLOSED_OPERATION_INTERVAL
                                   , F_INFO_REGISTRANT
                                   , F_PERSONAL_STARTDATEIND
                                   , F_PERSONAL_ENDDATEIND
                                   , F_INFO_FUND_ID
                                   , F_SALES_SERVICE_RATE
                                   , F_INVESTMENT_AREA
                                   , CLOSE_INSTITU_OEF_DOWN
                                   , CLOSE_INSTITU_OEF_UP
                                   , S_FELLOW_DISTOR
                                   , OPDATE
                                   , OPMODE
                                FROM ${wind_src_schema}.CHINAMUTUALFUNDDESCRIPTION"],
              "jdbcUrl": ["${wind_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "OBJECT_ID", "type": "STRING"}, {"name": "F_INFO_WINDCODE", "type": "STRING"}, {"name": "F_INFO_FRONT_CODE", "type": "STRING"}, {"name": "F_INFO_BACKEND_CODE", "type": "STRING"}, {"name": "F_INFO_FULLNAME", "type": "STRING"}, {"name": "F_INFO_NAME", "type": "STRING"}, {"name": "F_INFO_CORP_FUNDMANAGEMENTCOMP", "type": "STRING"}, {"name": "F_INFO_CUSTODIANBANK", "type": "STRING"}, {"name": "F_INFO_FIRSTINVESTTYPE", "type": "STRING"}, {"name": "F_INFO_SETUPDATE", "type": "STRING"}, {"name": "F_INFO_MATURITYDATE", "type": "STRING"}, {"name": "F_ISSUE_TOTALUNIT", "type": "DOUBLE"}, {"name": "F_INFO_MANAGEMENTFEERATIO", "type": "DOUBLE"}, {"name": "F_INFO_CUSTODIANFEERATIO", "type": "DOUBLE"}, {"name": "CRNY_CODE", "type": "STRING"}, {"name": "F_INFO_PTMYEAR", "type": "DOUBLE"}, {"name": "F_ISSUE_OEF_STARTDATEINST", "type": "STRING"}, {"name": "F_ISSUE_OEF_DNDDATEINST", "type": "STRING"}, {"name": "F_INFO_PARVALUE", "type": "DOUBLE"}, {"name": "F_INFO_TRUSTTYPE", "type": "STRING"}, {"name": "F_INFO_TRUSTEE", "type": "STRING"}, {"name": "F_PCHREDM_PCHSTARTDATE", "type": "STRING"}, {"name": "F_INFO_REDMSTARTDATE", "type": "STRING"}, {"name": "F_INFO_MINBUYAMOUNT", "type": "DOUBLE"}, {"name": "F_INFO_EXPECTEDRATEOFRETURN", "type": "DOUBLE"}, {"name": "F_INFO_ISSUINGPLACE", "type": "STRING"}, {"name": "F_INFO_BENCHMARK", "type": "STRING"}, {"name": "F_INFO_STATUS", "type": "DOUBLE"}, {"name": "F_INFO_RESTRICTEDORNOT", "type": "STRING"}, {"name": "F_INFO_STRUCTUREDORNOT", "type": "DOUBLE"}, {"name": "F_INFO_EXCHMARKET", "type": "STRING"}, {"name": "F_INFO_FIRSTINVESTSTYLE", "type": "STRING"}, {"name": "F_INFO_ISSUEDATE", "type": "STRING"}, {"name": "F_INFO_TYPE", "type": "STRING"}, {"name": "F_INFO_ISINITIAL", "type": "DOUBLE"}, {"name": "F_INFO_PINYIN", "type": "STRING"}, {"name": "F_INFO_INVESTSCOPE", "type": "STRING"}, {"name": "F_INFO_INVESTOBJECT", "type": "STRING"}, {"name": "F_INFO_INVESTCONCEPTION", "type": "STRING"}, {"name": "F_INFO_DECISION_BASIS", "type": "STRING"}, {"name": "IS_INDEXFUND", "type": "DOUBLE"}, {"name": "F_INFO_DELISTDATE", "type": "STRING"}, {"name": "F_INFO_CORP_FUNDMANAGEMENTID", "type": "STRING"}, {"name": "F_INFO_CUSTODIANBANKID", "type": "STRING"}, {"name": "MAX_NUM_HOLDER", "type": "DOUBLE"}, {"name": "MAX_NUM_COLTARGET", "type": "DOUBLE"}, {"name": "INVESTSTRATEGY", "type": "STRING"}, {"name": "RISK_RETURN", "type": "STRING"}, {"name": "F_PCHREDM_PCHMINAMT", "type": "DOUBLE"}, {"name": "F_PCHREDM_PCHMINAMT_EX", "type": "DOUBLE"}, {"name": "F_INFO_LISTDATE", "type": "STRING"}, {"name": "F_INFO_ANNDATE", "type": "STRING"}, {"name": "F_CLOSED_OPERATION_PERIOD", "type": "DOUBLE"}, {"name": "F_CLOSED_OPERATION_INTERVAL", "type": "DOUBLE"}, {"name": "F_INFO_REGISTRANT", "type": "STRING"}, {"name": "F_PERSONAL_STARTDATEIND", "type": "STRING"}, {"name": "F_PERSONAL_ENDDATEIND", "type": "STRING"}, {"name": "F_INFO_FUND_ID", "type": "STRING"}, {"name": "F_SALES_SERVICE_RATE", "type": "DOUBLE"}, {"name": "F_INVESTMENT_AREA", "type": "STRING"}, {"name": "CLOSE_INSTITU_OEF_DOWN", "type": "DOUBLE"}, {"name": "CLOSE_INSTITU_OEF_UP", "type": "DOUBLE"}, {"name": "S_FELLOW_DISTOR", "type": "DOUBLE"}, {"name": "OPDATE", "type": "STRING"}, {"name": "OPMODE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_wind_chinamutualfunddescription_pfd_tmp",
            "fileType": "text",
            "path": "${wind_path}/ods_wind_chinamutualfunddescription_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_wind_chinamutualfunddescription_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_wind_chinamutualfunddescription_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_WIND_CHINAMUTUALFUNDDESCRIPTION_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_WIND_CHINAMUTUALFUNDDESCRIPTION_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_wind_chinamutualfunddescription_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_WIND.ODS_WIND_CHINAMUTUALFUNDDESCRIPTION_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       OBJECT_ID
     , F_INFO_WINDCODE
     , F_INFO_FRONT_CODE
     , F_INFO_BACKEND_CODE
     , F_INFO_FULLNAME
     , F_INFO_NAME
     , F_INFO_CORP_FUNDMANAGEMENTCOMP
     , F_INFO_CUSTODIANBANK
     , F_INFO_FIRSTINVESTTYPE
     , F_INFO_SETUPDATE
     , F_INFO_MATURITYDATE
     , F_ISSUE_TOTALUNIT
     , F_INFO_MANAGEMENTFEERATIO
     , F_INFO_CUSTODIANFEERATIO
     , CRNY_CODE
     , F_INFO_PTMYEAR
     , F_ISSUE_OEF_STARTDATEINST
     , F_ISSUE_OEF_DNDDATEINST
     , F_INFO_PARVALUE
     , F_INFO_TRUSTTYPE
     , F_INFO_TRUSTEE
     , F_PCHREDM_PCHSTARTDATE
     , F_INFO_REDMSTARTDATE
     , F_INFO_MINBUYAMOUNT
     , F_INFO_EXPECTEDRATEOFRETURN
     , F_INFO_ISSUINGPLACE
     , F_INFO_BENCHMARK
     , F_INFO_STATUS
     , F_INFO_RESTRICTEDORNOT
     , F_INFO_STRUCTUREDORNOT
     , F_INFO_EXCHMARKET
     , F_INFO_FIRSTINVESTSTYLE
     , F_INFO_ISSUEDATE
     , F_INFO_TYPE
     , F_INFO_ISINITIAL
     , F_INFO_PINYIN
     , F_INFO_INVESTSCOPE
     , F_INFO_INVESTOBJECT
     , F_INFO_INVESTCONCEPTION
     , F_INFO_DECISION_BASIS
     , IS_INDEXFUND
     , F_INFO_DELISTDATE
     , F_INFO_CORP_FUNDMANAGEMENTID
     , F_INFO_CUSTODIANBANKID
     , MAX_NUM_HOLDER
     , MAX_NUM_COLTARGET
     , INVESTSTRATEGY
     , RISK_RETURN
     , F_PCHREDM_PCHMINAMT
     , F_PCHREDM_PCHMINAMT_EX
     , F_INFO_LISTDATE
     , F_INFO_ANNDATE
     , F_CLOSED_OPERATION_PERIOD
     , F_CLOSED_OPERATION_INTERVAL
     , F_INFO_REGISTRANT
     , F_PERSONAL_STARTDATEIND
     , F_PERSONAL_ENDDATEIND
     , F_INFO_FUND_ID
     , F_SALES_SERVICE_RATE
     , F_INVESTMENT_AREA
     , CLOSE_INSTITU_OEF_DOWN
     , CLOSE_INSTITU_OEF_UP
     , S_FELLOW_DISTOR
     , OPDATE
     , OPMODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_WIND.ODS_WIND_CHINAMUTUALFUNDDESCRIPTION_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_WIND.ODS_WIND_CHINAMUTUALFUNDDESCRIPTION_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_WIND_CHINAMUTUALFUNDDESCRIPTION_PFD失败"
      exit 1
   else
      echo "插入到ODS_WIND_CHINAMUTUALFUNDDESCRIPTION_PFD成功"
      exit 0
   fi
fi
