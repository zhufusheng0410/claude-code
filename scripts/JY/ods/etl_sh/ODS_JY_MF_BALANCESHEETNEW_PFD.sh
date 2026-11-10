#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_MF_BALANCESHEETNEW_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_MF_BALANCESHEETNEW_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  INFOSOURCE  STRING  COMMENT  '信息来源',
  BULLETINTYPE  DECIMAL(10,0)  COMMENT  '公告类别',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  COMPANYCODE  STRING  COMMENT  '公司代码',
  ENDDATE  STRING  COMMENT  '日期',
  MARK  DECIMAL(10,0)  COMMENT  '备注说明',
  ACCOUNTINGSTANDARDS  DECIMAL(10,0)  COMMENT  '会计准则',
  DEPOSIT  DECIMAL(19,4)  COMMENT  '吸收存款(元)',
  SETTLEMENTPROVI  DECIMAL(19,4)  COMMENT  '结算备付金(元)',
  REFUNDABLEDEPOSIT  DECIMAL(19,4)  COMMENT  '存出保证金',
  TRADINGASSETS  DECIMAL(19,4)  COMMENT  '交易性金融资产(元)',
  STOCKINVESTMENT  DECIMAL(19,4)  COMMENT  '其中：股票投资',
  BONDINVESTMENT  DECIMAL(19,4)  COMMENT  '债券投资',
  ABSINVESTMENT  DECIMAL(19,4)  COMMENT  '资产支持证券投资',
  FUNDINVESTMENT  DECIMAL(19,4)  COMMENT  '基金投资',
  WARRENTINVESTMENT  DECIMAL(19,4)  COMMENT  '权证投资',
  DERIVATIVEASSETS  DECIMAL(19,4)  COMMENT  '衍生金融资产',
  BOUGHTSELLBACKASSETS  DECIMAL(19,4)  COMMENT  '买入返售金融资产',
  SECUSETTLEMENTRECEIVABLES  DECIMAL(19,4)  COMMENT  '应收证券清算款',
  INTERESTRECEIVABLES  DECIMAL(19,4)  COMMENT  '应收利息(元)',
  DIVIDENDRECEIVABLES  DECIMAL(19,4)  COMMENT  '应收股利(元)',
  APPLYINGRECEIVABLES  DECIMAL(19,4)  COMMENT  '应收申购款',
  ACCOUNTRECEIVABLES  DECIMAL(19,4)  COMMENT  '应收帐款原值(元)',
  OTHERRECEIVABLES  DECIMAL(19,4)  COMMENT  '其他应收款(元)',
  DEFERRREDEXPENSE  DECIMAL(19,4)  COMMENT  '待摊费用(元)',
  OTHERASSETS  DECIMAL(19,4)  COMMENT  '其他资产(元)',
  AEXCEPTIONALITEMS  DECIMAL(19,4)  COMMENT  '##资产特殊项目',
  AADJUSTMENTITEMS  DECIMAL(19,4)  COMMENT  '##资产调整项目',
  TOTALASSETS  DECIMAL(19,4)  COMMENT  '资产总计(元)',
  SHORTTERMLOAN  DECIMAL(19,4)  COMMENT  '短期借款(元)',
  TRADINGLIABILITY  DECIMAL(19,4)  COMMENT  '交易性金融负债',
  DERIVATIVELIABILITY  DECIMAL(19,4)  COMMENT  '衍生金融负债',
  SOLDBUYBACKSECUPROCEEDS  DECIMAL(19,4)  COMMENT  '卖出回购证券款(元)',
  SECUSETTLEMENTPAYABLES  DECIMAL(19,4)  COMMENT  '应付证券清算款',
  REDEMPTIONMONEYPAYABLE  DECIMAL(19,4)  COMMENT  '应付赎回款',
  REDEMPTIONFEEPAYABLE  DECIMAL(19,4)  COMMENT  '应付赎回费',
  MANAGEMENTFEEPAYABLE  DECIMAL(19,4)  COMMENT  '应付管理人报酬',
  TRUSTFEEPAYABLE  DECIMAL(19,4)  COMMENT  '应付托管费',
  SALESFEEPAYABLE  DECIMAL(19,4)  COMMENT  '应付销售服务费',
  TRANSACTIONFEEPAYABLE  DECIMAL(19,4)  COMMENT  '应付交易费用',
  TAXSPAYABLE  DECIMAL(19,4)  COMMENT  '应交税费(元)',
  INTERESTPAYABLE  DECIMAL(19,4)  COMMENT  '应付利息(元)',
  PROFITPAYABLE  DECIMAL(19,4)  COMMENT  '应付收益',
  ACCOUNTPAYABLE  DECIMAL(19,4)  COMMENT  '应付帐款',
  OTHERPAYABLE  DECIMAL(19,4)  COMMENT  '其他应付款(元)',
  ACCRUEDEXPENSE  DECIMAL(19,4)  COMMENT  '预提费用(元)',
  OTHERLIABILITY  DECIMAL(19,4)  COMMENT  '其他负债(元)',
  LEXCEPTIONALITEMS  DECIMAL(19,4)  COMMENT  '##负债特殊项目',
  LADJUSTMENTITEMS  DECIMAL(19,4)  COMMENT  '##负债调整项目',
  TOTALLIABILITY  DECIMAL(19,4)  COMMENT  '负债合计(元)',
  PAIDINCAPITAL  DECIMAL(19,4)  COMMENT  '实收资本(或股本)(元)',
  RETAINEDPROFIT  DECIMAL(19,4)  COMMENT  '未分配利润(元)',
  OTHEREQUITY  DECIMAL(19,4)  COMMENT  '其他权益',
  SEEXCEPTIONALITEMS  DECIMAL(19,4)  COMMENT  '##所有者权益特殊项目',
  SEADJUSTMENTITEMS  DECIMAL(19,4)  COMMENT  '##所有者权益调整项目',
  TOTALSHAREHOLDEREQUITY  DECIMAL(19,4)  COMMENT  '股东权益合计(元)',
  LEEXCEPTIONALITEMS  DECIMAL(19,4)  COMMENT  '##负债和权益特殊项目',
  LEADJUSTMENTITEMS  DECIMAL(19,4)  COMMENT  '##负债和权益调整项目',
  TOTALLIABILITYANDEQUITY  DECIMAL(19,4)  COMMENT  '负债及股东权益总计(元)',
  TOTALFUNDSHARES  DECIMAL(19,4)  COMMENT  '基金份额总额(份)',
  UNITNV  DECIMAL(19,4)  COMMENT  '单位净值',
  SPECIALFIELDREMARK  STRING  COMMENT  '特殊字段说明',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  DEFERREDTAXASSETS  DECIMAL(19,4)  COMMENT  '递延所得税资产',
  DEFERREDTAXLIABILITY  DECIMAL(19,4)  COMMENT  '递延所得税负债',
  INSERTTIME  STRING  COMMENT  '插入时间',
  TRANSCODE  STRING  COMMENT  '基金转型统一编码'
)
COMMENT '公募基金资产负债表_新会计准则'
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
                                   , INFOPUBLDATE
                                   , INFOSOURCE
                                   , BULLETINTYPE
                                   , INNERCODE
                                   , COMPANYCODE
                                   , ENDDATE
                                   , MARK
                                   , ACCOUNTINGSTANDARDS
                                   , DEPOSIT
                                   , SETTLEMENTPROVI
                                   , REFUNDABLEDEPOSIT
                                   , TRADINGASSETS
                                   , STOCKINVESTMENT
                                   , BONDINVESTMENT
                                   , ABSINVESTMENT
                                   , FUNDINVESTMENT
                                   , WARRENTINVESTMENT
                                   , DERIVATIVEASSETS
                                   , BOUGHTSELLBACKASSETS
                                   , SECUSETTLEMENTRECEIVABLES
                                   , INTERESTRECEIVABLES
                                   , DIVIDENDRECEIVABLES
                                   , APPLYINGRECEIVABLES
                                   , ACCOUNTRECEIVABLES
                                   , OTHERRECEIVABLES
                                   , DEFERRREDEXPENSE
                                   , OTHERASSETS
                                   , AEXCEPTIONALITEMS
                                   , AADJUSTMENTITEMS
                                   , TOTALASSETS
                                   , SHORTTERMLOAN
                                   , TRADINGLIABILITY
                                   , DERIVATIVELIABILITY
                                   , SOLDBUYBACKSECUPROCEEDS
                                   , SECUSETTLEMENTPAYABLES
                                   , REDEMPTIONMONEYPAYABLE
                                   , REDEMPTIONFEEPAYABLE
                                   , MANAGEMENTFEEPAYABLE
                                   , TRUSTFEEPAYABLE
                                   , SALESFEEPAYABLE
                                   , TRANSACTIONFEEPAYABLE
                                   , TAXSPAYABLE
                                   , INTERESTPAYABLE
                                   , PROFITPAYABLE
                                   , ACCOUNTPAYABLE
                                   , OTHERPAYABLE
                                   , ACCRUEDEXPENSE
                                   , OTHERLIABILITY
                                   , LEXCEPTIONALITEMS
                                   , LADJUSTMENTITEMS
                                   , TOTALLIABILITY
                                   , PAIDINCAPITAL
                                   , RETAINEDPROFIT
                                   , OTHEREQUITY
                                   , SEEXCEPTIONALITEMS
                                   , SEADJUSTMENTITEMS
                                   , TOTALSHAREHOLDEREQUITY
                                   , LEEXCEPTIONALITEMS
                                   , LEADJUSTMENTITEMS
                                   , TOTALLIABILITYANDEQUITY
                                   , TOTALFUNDSHARES
                                   , UNITNV
                                   , SPECIALFIELDREMARK
                                   , UPDATETIME
                                   , JSID
                                   , DEFERREDTAXASSETS
                                   , DEFERREDTAXLIABILITY
                                   , INSERTTIME
                                   , TRANSCODE
                                FROM ${jy_src_schema}.MF_BALANCESHEETNEW"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "INFOSOURCE", "type": "STRING"}, {"name": "BULLETINTYPE", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "COMPANYCODE", "type": "DOUBLE"}, {"name": "ENDDATE", "type": "STRING"}, {"name": "MARK", "type": "DOUBLE"}, {"name": "ACCOUNTINGSTANDARDS", "type": "DOUBLE"}, {"name": "DEPOSIT", "type": "DOUBLE"}, {"name": "SETTLEMENTPROVI", "type": "DOUBLE"}, {"name": "REFUNDABLEDEPOSIT", "type": "DOUBLE"}, {"name": "TRADINGASSETS", "type": "DOUBLE"}, {"name": "STOCKINVESTMENT", "type": "DOUBLE"}, {"name": "BONDINVESTMENT", "type": "DOUBLE"}, {"name": "ABSINVESTMENT", "type": "DOUBLE"}, {"name": "FUNDINVESTMENT", "type": "DOUBLE"}, {"name": "WARRENTINVESTMENT", "type": "DOUBLE"}, {"name": "DERIVATIVEASSETS", "type": "DOUBLE"}, {"name": "BOUGHTSELLBACKASSETS", "type": "DOUBLE"}, {"name": "SECUSETTLEMENTRECEIVABLES", "type": "DOUBLE"}, {"name": "INTERESTRECEIVABLES", "type": "DOUBLE"}, {"name": "DIVIDENDRECEIVABLES", "type": "DOUBLE"}, {"name": "APPLYINGRECEIVABLES", "type": "DOUBLE"}, {"name": "ACCOUNTRECEIVABLES", "type": "DOUBLE"}, {"name": "OTHERRECEIVABLES", "type": "DOUBLE"}, {"name": "DEFERRREDEXPENSE", "type": "DOUBLE"}, {"name": "OTHERASSETS", "type": "DOUBLE"}, {"name": "AEXCEPTIONALITEMS", "type": "DOUBLE"}, {"name": "AADJUSTMENTITEMS", "type": "DOUBLE"}, {"name": "TOTALASSETS", "type": "DOUBLE"}, {"name": "SHORTTERMLOAN", "type": "DOUBLE"}, {"name": "TRADINGLIABILITY", "type": "DOUBLE"}, {"name": "DERIVATIVELIABILITY", "type": "DOUBLE"}, {"name": "SOLDBUYBACKSECUPROCEEDS", "type": "DOUBLE"}, {"name": "SECUSETTLEMENTPAYABLES", "type": "DOUBLE"}, {"name": "REDEMPTIONMONEYPAYABLE", "type": "DOUBLE"}, {"name": "REDEMPTIONFEEPAYABLE", "type": "DOUBLE"}, {"name": "MANAGEMENTFEEPAYABLE", "type": "DOUBLE"}, {"name": "TRUSTFEEPAYABLE", "type": "DOUBLE"}, {"name": "SALESFEEPAYABLE", "type": "DOUBLE"}, {"name": "TRANSACTIONFEEPAYABLE", "type": "DOUBLE"}, {"name": "TAXSPAYABLE", "type": "DOUBLE"}, {"name": "INTERESTPAYABLE", "type": "DOUBLE"}, {"name": "PROFITPAYABLE", "type": "DOUBLE"}, {"name": "ACCOUNTPAYABLE", "type": "DOUBLE"}, {"name": "OTHERPAYABLE", "type": "DOUBLE"}, {"name": "ACCRUEDEXPENSE", "type": "DOUBLE"}, {"name": "OTHERLIABILITY", "type": "DOUBLE"}, {"name": "LEXCEPTIONALITEMS", "type": "DOUBLE"}, {"name": "LADJUSTMENTITEMS", "type": "DOUBLE"}, {"name": "TOTALLIABILITY", "type": "DOUBLE"}, {"name": "PAIDINCAPITAL", "type": "DOUBLE"}, {"name": "RETAINEDPROFIT", "type": "DOUBLE"}, {"name": "OTHEREQUITY", "type": "DOUBLE"}, {"name": "SEEXCEPTIONALITEMS", "type": "DOUBLE"}, {"name": "SEADJUSTMENTITEMS", "type": "DOUBLE"}, {"name": "TOTALSHAREHOLDEREQUITY", "type": "DOUBLE"}, {"name": "LEEXCEPTIONALITEMS", "type": "DOUBLE"}, {"name": "LEADJUSTMENTITEMS", "type": "DOUBLE"}, {"name": "TOTALLIABILITYANDEQUITY", "type": "DOUBLE"}, {"name": "TOTALFUNDSHARES", "type": "DOUBLE"}, {"name": "UNITNV", "type": "DOUBLE"}, {"name": "SPECIALFIELDREMARK", "type": "STRING"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "DEFERREDTAXASSETS", "type": "DOUBLE"}, {"name": "DEFERREDTAXLIABILITY", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}, {"name": "TRANSCODE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_mf_balancesheetnew_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_mf_balancesheetnew_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_mf_balancesheetnew_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_mf_balancesheetnew_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_MF_BALANCESHEETNEW_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_MF_BALANCESHEETNEW_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_mf_balancesheetnew_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_MF_BALANCESHEETNEW_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INFOPUBLDATE
     , INFOSOURCE
     , BULLETINTYPE
     , INNERCODE
     , COMPANYCODE
     , ENDDATE
     , MARK
     , ACCOUNTINGSTANDARDS
     , DEPOSIT
     , SETTLEMENTPROVI
     , REFUNDABLEDEPOSIT
     , TRADINGASSETS
     , STOCKINVESTMENT
     , BONDINVESTMENT
     , ABSINVESTMENT
     , FUNDINVESTMENT
     , WARRENTINVESTMENT
     , DERIVATIVEASSETS
     , BOUGHTSELLBACKASSETS
     , SECUSETTLEMENTRECEIVABLES
     , INTERESTRECEIVABLES
     , DIVIDENDRECEIVABLES
     , APPLYINGRECEIVABLES
     , ACCOUNTRECEIVABLES
     , OTHERRECEIVABLES
     , DEFERRREDEXPENSE
     , OTHERASSETS
     , AEXCEPTIONALITEMS
     , AADJUSTMENTITEMS
     , TOTALASSETS
     , SHORTTERMLOAN
     , TRADINGLIABILITY
     , DERIVATIVELIABILITY
     , SOLDBUYBACKSECUPROCEEDS
     , SECUSETTLEMENTPAYABLES
     , REDEMPTIONMONEYPAYABLE
     , REDEMPTIONFEEPAYABLE
     , MANAGEMENTFEEPAYABLE
     , TRUSTFEEPAYABLE
     , SALESFEEPAYABLE
     , TRANSACTIONFEEPAYABLE
     , TAXSPAYABLE
     , INTERESTPAYABLE
     , PROFITPAYABLE
     , ACCOUNTPAYABLE
     , OTHERPAYABLE
     , ACCRUEDEXPENSE
     , OTHERLIABILITY
     , LEXCEPTIONALITEMS
     , LADJUSTMENTITEMS
     , TOTALLIABILITY
     , PAIDINCAPITAL
     , RETAINEDPROFIT
     , OTHEREQUITY
     , SEEXCEPTIONALITEMS
     , SEADJUSTMENTITEMS
     , TOTALSHAREHOLDEREQUITY
     , LEEXCEPTIONALITEMS
     , LEADJUSTMENTITEMS
     , TOTALLIABILITYANDEQUITY
     , TOTALFUNDSHARES
     , UNITNV
     , SPECIALFIELDREMARK
     , UPDATETIME
     , JSID
     , DEFERREDTAXASSETS
     , DEFERREDTAXLIABILITY
     , INSERTTIME
     , TRANSCODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_MF_BALANCESHEETNEW_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_MF_BALANCESHEETNEW_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_MF_BALANCESHEETNEW_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_MF_BALANCESHEETNEW_PFD成功"
      exit 0
   fi
fi
