#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TSQSJYINST_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TSQSJYINST_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '录入日期',
  L_INITDATE  DECIMAL(8,0)  COMMENT  '日切日期',
  L_TRADEORDERNO  STRING  COMMENT  '交易指令编号',
  VC_SRCTRADEID  STRING  COMMENT  '源成交号',
  C_SOURCEFROM  STRING  COMMENT  '交易来源',
  VC_TABLESOURCE  STRING  COMMENT  '表来源',
  C_AUDITSTATUS  STRING  COMMENT  '复核状态',
  C_ORDERSTATUS  STRING  COMMENT  '指令状态',
  VC_TRADEID  STRING  COMMENT  '成交编号',
  L_OPORDERTYPE  DECIMAL(10,0)  COMMENT  '会员操作指令类别',
  C_TRADETYPE  STRING  COMMENT  '交易方式',
  C_CLEARTYPE  STRING  COMMENT  '清算方式',
  VC_PRODUCTCODE  STRING  COMMENT  '产品代码',
  VC_PRODUCTNAME  STRING  COMMENT  '产品简称',
  EN_FACEVALUE  DECIMAL(25,6)  COMMENT  '产品面值',
  VC_BUYERHOLDERACCOUNT  STRING  COMMENT  '买方持有人账号',
  VC_BHOLDERSHORTNAME  STRING  COMMENT  '买方持有人简称',
  VC_BOPERHOLDERACCOUNT  STRING  COMMENT  '买方操作持有人账号',
  VC_SELLERHOLDERACCOUNT  STRING  COMMENT  '卖方持有人账号',
  VC_SHOLDERSHORTNAME  STRING  COMMENT  '卖方持有人简称',
  VC_SOPERHOLDERACCOUNT  STRING  COMMENT  '卖方操作持有人账号',
  EN_SETTLEMENTAMOUNT  DECIMAL(19,2)  COMMENT  '结算金额',
  L_TRADEDATE  DECIMAL(8,0)  COMMENT  '交易日期',
  L_SETTLEMENTDATE  DECIMAL(8,0)  COMMENT  '结算日期',
  C_BUYERSTATUS  STRING  COMMENT  '买方状态',
  C_SELLERSTATUS  STRING  COMMENT  '卖方状态',
  VC_BOPERORDERSTATUS  STRING  COMMENT  '买方指令可操作状态',
  VC_SOPERORDERSTATUS  STRING  COMMENT  '卖方指令可操作状态',
  L_OPERID  DECIMAL(10,0)  COMMENT  '操作员id',
  VC_OPERNAME  STRING  COMMENT  '操作员姓名',
  L_AUDITOPERID  STRING  COMMENT  '复核人编号',
  VC_AUDITOPERNAME  STRING  COMMENT  '复核人姓名',
  L_SETTLEMENTTYPE  DECIMAL(10,0)  COMMENT  '结算方式',
  L_DUESETTLEDATE  DECIMAL(8,0)  COMMENT  '到期结算日期',
  EN_DUESETTLEAMOUNT  DECIMAL(19,2)  COMMENT  '到期结算金额',
  L_DUESETTLEMETHOD  DECIMAL(10,0)  COMMENT  '到期结算方式',
  C_SEND_STATUS  STRING  COMMENT  '发送状态',
  L_SERIAL_NO  DECIMAL(10,0)  COMMENT  '序列号',
  C_MATCH_FLAG  STRING  COMMENT  '成交匹配状态',
  VC_MATCH_ERRMSG  STRING  COMMENT  '匹配返回信息',
  L_CONF_OPERATOR  STRING  COMMENT  '确认人编号',
  VC_CONF_OPERATOR_NAME  STRING  COMMENT  '确认人姓名',
  EN_CLEANPRICE  DECIMAL(19,15)  COMMENT  '净价',
  EN_FULLPRICE  DECIMAL(19,15)  COMMENT  '全价',
  EN_ACCRUEDINTEREST  DECIMAL(19,2)  COMMENT  '应计利息',
  EN_REPODAYS  DECIMAL(10,0)  COMMENT  '回购天数',
  C_DISTRIBUTIONFLAG  STRING  COMMENT  '是否分销',
  VC_REASON  STRING  COMMENT  '失败原因',
  L_ORG_ID  DECIMAL(10,0)  COMMENT  '公司号',
  L_DEPT_ID  DECIMAL(10,0)  COMMENT  '部门号',
  L_FUND_ID  DECIMAL(10,0)  COMMENT  '基金序号',
  L_START_SERIAL_NO  DECIMAL(10,0)  COMMENT  '',
  VC_PRODUCT_CATEGORY  STRING  COMMENT  '',
  VC_PRE_INSTRIDS  STRING  COMMENT  '',
  L_SETTLE_SPEED  DECIMAL(1,0)  COMMENT  '清算速度',
  L_DAILY_INSTRUCTION_NO  DECIMAL(10,0)  COMMENT  '',
  VC_SOURCE_NO  STRING  COMMENT  '',
  C_BUSIN_CLASS  STRING  COMMENT  '业务类别',
  VC_BUYERSTATUS_UPDATETM  STRING  COMMENT  '',
  VC_SELLERSTATUS_UPDATETM  STRING  COMMENT  '',
  VC_UPDATETM  STRING  COMMENT  '',
  VC_REMARK  STRING  COMMENT  '备注',
  C_TRADEDEAL_STATUS  STRING  COMMENT  '',
  EN_RATE  DECIMAL(14,8)  COMMENT  '回购利率'
)
COMMENT '上清所交易指令表'
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
              "querySql": ["SELECT  L_DATE
                                   , L_INITDATE
                                   , L_TRADEORDERNO
                                   , VC_SRCTRADEID
                                   , C_SOURCEFROM
                                   , VC_TABLESOURCE
                                   , C_AUDITSTATUS
                                   , C_ORDERSTATUS
                                   , VC_TRADEID
                                   , L_OPORDERTYPE
                                   , C_TRADETYPE
                                   , C_CLEARTYPE
                                   , VC_PRODUCTCODE
                                   , VC_PRODUCTNAME
                                   , EN_FACEVALUE
                                   , VC_BUYERHOLDERACCOUNT
                                   , VC_BHOLDERSHORTNAME
                                   , VC_BOPERHOLDERACCOUNT
                                   , VC_SELLERHOLDERACCOUNT
                                   , VC_SHOLDERSHORTNAME
                                   , VC_SOPERHOLDERACCOUNT
                                   , EN_SETTLEMENTAMOUNT
                                   , L_TRADEDATE
                                   , L_SETTLEMENTDATE
                                   , C_BUYERSTATUS
                                   , C_SELLERSTATUS
                                   , VC_BOPERORDERSTATUS
                                   , VC_SOPERORDERSTATUS
                                   , L_OPERID
                                   , VC_OPERNAME
                                   , L_AUDITOPERID
                                   , VC_AUDITOPERNAME
                                   , L_SETTLEMENTTYPE
                                   , L_DUESETTLEDATE
                                   , EN_DUESETTLEAMOUNT
                                   , L_DUESETTLEMETHOD
                                   , C_SEND_STATUS
                                   , L_SERIAL_NO
                                   , C_MATCH_FLAG
                                   , VC_MATCH_ERRMSG
                                   , L_CONF_OPERATOR
                                   , VC_CONF_OPERATOR_NAME
                                   , EN_CLEANPRICE
                                   , EN_FULLPRICE
                                   , EN_ACCRUEDINTEREST
                                   , EN_REPODAYS
                                   , C_DISTRIBUTIONFLAG
                                   , VC_REASON
                                   , L_ORG_ID
                                   , L_DEPT_ID
                                   , L_FUND_ID
                                   , L_START_SERIAL_NO
                                   , VC_PRODUCT_CATEGORY
                                   , VC_PRE_INSTRIDS
                                   , L_SETTLE_SPEED
                                   , L_DAILY_INSTRUCTION_NO
                                   , VC_SOURCE_NO
                                   , C_BUSIN_CLASS
                                   , VC_BUYERSTATUS_UPDATETM
                                   , VC_SELLERSTATUS_UPDATETM
                                   , VC_UPDATETM
                                   , VC_REMARK
                                   , C_TRADEDEAL_STATUS
                                   , EN_RATE
                                FROM ${o32_src_schema}.THISSQSJYINST
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_INITDATE", "type": "DOUBLE"}, {"name": "L_TRADEORDERNO", "type": "DOUBLE"}, {"name": "VC_SRCTRADEID", "type": "STRING"}, {"name": "C_SOURCEFROM", "type": "STRING"}, {"name": "VC_TABLESOURCE", "type": "STRING"}, {"name": "C_AUDITSTATUS", "type": "STRING"}, {"name": "C_ORDERSTATUS", "type": "STRING"}, {"name": "VC_TRADEID", "type": "STRING"}, {"name": "L_OPORDERTYPE", "type": "DOUBLE"}, {"name": "C_TRADETYPE", "type": "STRING"}, {"name": "C_CLEARTYPE", "type": "STRING"}, {"name": "VC_PRODUCTCODE", "type": "STRING"}, {"name": "VC_PRODUCTNAME", "type": "STRING"}, {"name": "EN_FACEVALUE", "type": "DOUBLE"}, {"name": "VC_BUYERHOLDERACCOUNT", "type": "STRING"}, {"name": "VC_BHOLDERSHORTNAME", "type": "STRING"}, {"name": "VC_BOPERHOLDERACCOUNT", "type": "STRING"}, {"name": "VC_SELLERHOLDERACCOUNT", "type": "STRING"}, {"name": "VC_SHOLDERSHORTNAME", "type": "STRING"}, {"name": "VC_SOPERHOLDERACCOUNT", "type": "STRING"}, {"name": "EN_SETTLEMENTAMOUNT", "type": "DOUBLE"}, {"name": "L_TRADEDATE", "type": "DOUBLE"}, {"name": "L_SETTLEMENTDATE", "type": "DOUBLE"}, {"name": "C_BUYERSTATUS", "type": "STRING"}, {"name": "C_SELLERSTATUS", "type": "STRING"}, {"name": "VC_BOPERORDERSTATUS", "type": "STRING"}, {"name": "VC_SOPERORDERSTATUS", "type": "STRING"}, {"name": "L_OPERID", "type": "DOUBLE"}, {"name": "VC_OPERNAME", "type": "STRING"}, {"name": "L_AUDITOPERID", "type": "DOUBLE"}, {"name": "VC_AUDITOPERNAME", "type": "STRING"}, {"name": "L_SETTLEMENTTYPE", "type": "DOUBLE"}, {"name": "L_DUESETTLEDATE", "type": "DOUBLE"}, {"name": "EN_DUESETTLEAMOUNT", "type": "DOUBLE"}, {"name": "L_DUESETTLEMETHOD", "type": "DOUBLE"}, {"name": "C_SEND_STATUS", "type": "STRING"}, {"name": "L_SERIAL_NO", "type": "DOUBLE"}, {"name": "C_MATCH_FLAG", "type": "STRING"}, {"name": "VC_MATCH_ERRMSG", "type": "STRING"}, {"name": "L_CONF_OPERATOR", "type": "DOUBLE"}, {"name": "VC_CONF_OPERATOR_NAME", "type": "STRING"}, {"name": "EN_CLEANPRICE", "type": "DOUBLE"}, {"name": "EN_FULLPRICE", "type": "DOUBLE"}, {"name": "EN_ACCRUEDINTEREST", "type": "DOUBLE"}, {"name": "EN_REPODAYS", "type": "DOUBLE"}, {"name": "C_DISTRIBUTIONFLAG", "type": "STRING"}, {"name": "VC_REASON", "type": "STRING"}, {"name": "L_ORG_ID", "type": "DOUBLE"}, {"name": "L_DEPT_ID", "type": "DOUBLE"}, {"name": "L_FUND_ID", "type": "DOUBLE"}, {"name": "L_START_SERIAL_NO", "type": "DOUBLE"}, {"name": "VC_PRODUCT_CATEGORY", "type": "STRING"}, {"name": "VC_PRE_INSTRIDS", "type": "STRING"}, {"name": "L_SETTLE_SPEED", "type": "DOUBLE"}, {"name": "L_DAILY_INSTRUCTION_NO", "type": "DOUBLE"}, {"name": "VC_SOURCE_NO", "type": "STRING"}, {"name": "C_BUSIN_CLASS", "type": "STRING"}, {"name": "VC_BUYERSTATUS_UPDATETM", "type": "STRING"}, {"name": "VC_SELLERSTATUS_UPDATETM", "type": "STRING"}, {"name": "VC_UPDATETM", "type": "STRING"}, {"name": "VC_REMARK", "type": "STRING"}, {"name": "C_TRADEDEAL_STATUS", "type": "STRING"}, {"name": "EN_RATE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tsqsjyinst_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tsqsjyinst_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tsqsjyinst_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tsqsjyinst_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TSQSJYINST_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TSQSJYINST_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tsqsjyinst_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TSQSJYINST_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , L_INITDATE
     , L_TRADEORDERNO
     , VC_SRCTRADEID
     , C_SOURCEFROM
     , VC_TABLESOURCE
     , C_AUDITSTATUS
     , C_ORDERSTATUS
     , VC_TRADEID
     , L_OPORDERTYPE
     , C_TRADETYPE
     , C_CLEARTYPE
     , VC_PRODUCTCODE
     , VC_PRODUCTNAME
     , EN_FACEVALUE
     , VC_BUYERHOLDERACCOUNT
     , VC_BHOLDERSHORTNAME
     , VC_BOPERHOLDERACCOUNT
     , VC_SELLERHOLDERACCOUNT
     , VC_SHOLDERSHORTNAME
     , VC_SOPERHOLDERACCOUNT
     , EN_SETTLEMENTAMOUNT
     , L_TRADEDATE
     , L_SETTLEMENTDATE
     , C_BUYERSTATUS
     , C_SELLERSTATUS
     , VC_BOPERORDERSTATUS
     , VC_SOPERORDERSTATUS
     , L_OPERID
     , VC_OPERNAME
     , L_AUDITOPERID
     , VC_AUDITOPERNAME
     , L_SETTLEMENTTYPE
     , L_DUESETTLEDATE
     , EN_DUESETTLEAMOUNT
     , L_DUESETTLEMETHOD
     , C_SEND_STATUS
     , L_SERIAL_NO
     , C_MATCH_FLAG
     , VC_MATCH_ERRMSG
     , L_CONF_OPERATOR
     , VC_CONF_OPERATOR_NAME
     , EN_CLEANPRICE
     , EN_FULLPRICE
     , EN_ACCRUEDINTEREST
     , EN_REPODAYS
     , C_DISTRIBUTIONFLAG
     , VC_REASON
     , L_ORG_ID
     , L_DEPT_ID
     , L_FUND_ID
     , L_START_SERIAL_NO
     , VC_PRODUCT_CATEGORY
     , VC_PRE_INSTRIDS
     , L_SETTLE_SPEED
     , L_DAILY_INSTRUCTION_NO
     , VC_SOURCE_NO
     , C_BUSIN_CLASS
     , VC_BUYERSTATUS_UPDATETM
     , VC_SELLERSTATUS_UPDATETM
     , VC_UPDATETM
     , VC_REMARK
     , C_TRADEDEAL_STATUS
     , EN_RATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TSQSJYINST_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TSQSJYINST_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TSQSJYINST_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TSQSJYINST_PTD成功"
      exit 0
   fi
fi
