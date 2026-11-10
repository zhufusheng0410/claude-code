#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TSUBCONTRACTINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TSUBCONTRACTINFO_PFD_TMP(
  VC_SUBCONTRACT_NO  STRING  COMMENT  '子合同编号',
  VC_CONTRACT_NO  STRING  COMMENT  '主合同编号',
  EN_SUBCONTRACT_DURATION  DECIMAL(16,8)  COMMENT  '子合同期限',
  L_SUBCONTRACT_BEGIN_DATE  DECIMAL(8,0)  COMMENT  '子合同开始日期',
  L_SUBCONTRACT_END_DATE  DECIMAL(8,0)  COMMENT  '子合同结束日期',
  L_ACCOUNT_ID  DECIMAL(10,0)  COMMENT  '专户产品序号',
  VC_CURRENCY_NO  STRING  COMMENT  '子合同币种',
  EN_SUBCONTRACT_BALANCE  DECIMAL(16,2)  COMMENT  '子合同金额',
  L_ESTABLISH_BEGIN_DATE  DECIMAL(8,0)  COMMENT  '建仓开始日期',
  L_ESTABLISH_END_DATE  DECIMAL(8,0)  COMMENT  '建仓结束日期',
  VC_INVEST_LIMIT  STRING  COMMENT  '投资限制',
  EN_MGNT_FEE_RATE  DECIMAL(9,8)  COMMENT  '管理费费率',
  EN_MGNT_LEAST_FEE  DECIMAL(16,2)  COMMENT  '管理费最低收费金额',
  EN_HOST_FEE_RATE  DECIMAL(9,8)  COMMENT  '托管费费率',
  VC_DIVID_FEE_RATE  STRING  COMMENT  '绩效分成费率',
  VC_DIVID_FEE_DATE  STRING  COMMENT  '绩效分成收到日期',
  VC_DIVID_FEE_CALC  STRING  COMMENT  '绩效分成计算方法',
  VC_OTHER_FEE  STRING  COMMENT  '其他收费',
  C_CUSTOMER_INSTRUCTION  STRING  COMMENT  '客户指示',
  C_RISK_TYPE  STRING  COMMENT  '客户组合风险收益特征',
  C_RISK_MASK_TYPE  STRING  COMMENT  '风险匹配状况',
  C_AGREE_RISK  STRING  COMMENT  '是否签同意书',
  VC_AUTHORIZE_ID  STRING  COMMENT  '授权办理人序号',
  C_REPORT_MAIL_TYPE  STRING  COMMENT  '报表邮寄类型',
  VC_REMARK  STRING  COMMENT  '合同备注',
  C_REPORT_INTERVAL  STRING  COMMENT  '客户报告期间',
  C_STATUS  STRING  COMMENT  '合同状态',
  L_SIGN_DATE  DECIMAL(8,0)  COMMENT  '签署日期',
  VC_CAPITAL_ACCOUNT  STRING  COMMENT  '资金账户号',
  VC_CAPITAL_NAME  STRING  COMMENT  '资金账户名称'
)
COMMENT '子合同信息表'
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
              "querySql": ["SELECT  VC_SUBCONTRACT_NO
                                   , VC_CONTRACT_NO
                                   , EN_SUBCONTRACT_DURATION
                                   , L_SUBCONTRACT_BEGIN_DATE
                                   , L_SUBCONTRACT_END_DATE
                                   , L_ACCOUNT_ID
                                   , VC_CURRENCY_NO
                                   , EN_SUBCONTRACT_BALANCE
                                   , L_ESTABLISH_BEGIN_DATE
                                   , L_ESTABLISH_END_DATE
                                   , VC_INVEST_LIMIT
                                   , EN_MGNT_FEE_RATE
                                   , EN_MGNT_LEAST_FEE
                                   , EN_HOST_FEE_RATE
                                   , VC_DIVID_FEE_RATE
                                   , VC_DIVID_FEE_DATE
                                   , VC_DIVID_FEE_CALC
                                   , VC_OTHER_FEE
                                   , C_CUSTOMER_INSTRUCTION
                                   , C_RISK_TYPE
                                   , C_RISK_MASK_TYPE
                                   , C_AGREE_RISK
                                   , VC_AUTHORIZE_ID
                                   , C_REPORT_MAIL_TYPE
                                   , VC_REMARK
                                   , C_REPORT_INTERVAL
                                   , C_STATUS
                                   , L_SIGN_DATE
                                   , VC_CAPITAL_ACCOUNT
                                   , VC_CAPITAL_NAME
                                FROM ${o32_src_schema}.TSUBCONTRACTINFO"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "VC_SUBCONTRACT_NO", "type": "STRING"}, {"name": "VC_CONTRACT_NO", "type": "STRING"}, {"name": "EN_SUBCONTRACT_DURATION", "type": "DOUBLE"}, {"name": "L_SUBCONTRACT_BEGIN_DATE", "type": "DOUBLE"}, {"name": "L_SUBCONTRACT_END_DATE", "type": "DOUBLE"}, {"name": "L_ACCOUNT_ID", "type": "DOUBLE"}, {"name": "VC_CURRENCY_NO", "type": "STRING"}, {"name": "EN_SUBCONTRACT_BALANCE", "type": "DOUBLE"}, {"name": "L_ESTABLISH_BEGIN_DATE", "type": "DOUBLE"}, {"name": "L_ESTABLISH_END_DATE", "type": "DOUBLE"}, {"name": "VC_INVEST_LIMIT", "type": "STRING"}, {"name": "EN_MGNT_FEE_RATE", "type": "DOUBLE"}, {"name": "EN_MGNT_LEAST_FEE", "type": "DOUBLE"}, {"name": "EN_HOST_FEE_RATE", "type": "DOUBLE"}, {"name": "VC_DIVID_FEE_RATE", "type": "STRING"}, {"name": "VC_DIVID_FEE_DATE", "type": "STRING"}, {"name": "VC_DIVID_FEE_CALC", "type": "STRING"}, {"name": "VC_OTHER_FEE", "type": "STRING"}, {"name": "C_CUSTOMER_INSTRUCTION", "type": "STRING"}, {"name": "C_RISK_TYPE", "type": "STRING"}, {"name": "C_RISK_MASK_TYPE", "type": "STRING"}, {"name": "C_AGREE_RISK", "type": "STRING"}, {"name": "VC_AUTHORIZE_ID", "type": "STRING"}, {"name": "C_REPORT_MAIL_TYPE", "type": "STRING"}, {"name": "VC_REMARK", "type": "STRING"}, {"name": "C_REPORT_INTERVAL", "type": "STRING"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "L_SIGN_DATE", "type": "DOUBLE"}, {"name": "VC_CAPITAL_ACCOUNT", "type": "STRING"}, {"name": "VC_CAPITAL_NAME", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tsubcontractinfo_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tsubcontractinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tsubcontractinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tsubcontractinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TSUBCONTRACTINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TSUBCONTRACTINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tsubcontractinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TSUBCONTRACTINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       VC_SUBCONTRACT_NO
     , VC_CONTRACT_NO
     , EN_SUBCONTRACT_DURATION
     , L_SUBCONTRACT_BEGIN_DATE
     , L_SUBCONTRACT_END_DATE
     , L_ACCOUNT_ID
     , VC_CURRENCY_NO
     , EN_SUBCONTRACT_BALANCE
     , L_ESTABLISH_BEGIN_DATE
     , L_ESTABLISH_END_DATE
     , VC_INVEST_LIMIT
     , EN_MGNT_FEE_RATE
     , EN_MGNT_LEAST_FEE
     , EN_HOST_FEE_RATE
     , VC_DIVID_FEE_RATE
     , VC_DIVID_FEE_DATE
     , VC_DIVID_FEE_CALC
     , VC_OTHER_FEE
     , C_CUSTOMER_INSTRUCTION
     , C_RISK_TYPE
     , C_RISK_MASK_TYPE
     , C_AGREE_RISK
     , VC_AUTHORIZE_ID
     , C_REPORT_MAIL_TYPE
     , VC_REMARK
     , C_REPORT_INTERVAL
     , C_STATUS
     , L_SIGN_DATE
     , VC_CAPITAL_ACCOUNT
     , VC_CAPITAL_NAME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TSUBCONTRACTINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TSUBCONTRACTINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TSUBCONTRACTINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TSUBCONTRACTINFO_PFD成功"
      exit 0
   fi
fi
