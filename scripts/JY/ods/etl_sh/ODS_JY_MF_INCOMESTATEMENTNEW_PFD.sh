#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_MF_INCOMESTATEMENTNEW_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_MF_INCOMESTATEMENTNEW_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  INFOSOURCE  STRING  COMMENT  '信息来源',
  BULLETINTYPE  DECIMAL(10,0)  COMMENT  '公告类别',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  COMPANYCODE  STRING  COMMENT  '公司代码',
  ENDDATE  STRING  COMMENT  '日期',
  MARK  DECIMAL(10,0)  COMMENT  '备注说明',
  ACCOUNTINGSTANDARDS  DECIMAL(10,0)  COMMENT  '会计准则',
  INTERESTINCOME  DECIMAL(19,4)  COMMENT  '其中:利息收入(元)',
  DEPOSITINTERESTINCOME  DECIMAL(19,4)  COMMENT  '存款利息收入(元)',
  BONDINTERESTINCOME  DECIMAL(19,4)  COMMENT  '取得债券利息收入所收到的现金(元)',
  ABSINTERESTINCOME  DECIMAL(19,4)  COMMENT  '资产支持证券利息收入',
  SELLBACKASSETSINCOME  DECIMAL(19,4)  COMMENT  '买入返售金融资产收入',
  OTHERINTERESTINCOME  DECIMAL(19,4)  COMMENT  '其他利息收入',
  INVESTMENTINCOME  DECIMAL(19,4)  COMMENT  '投资收益(元)',
  STOCKINVESTMENTINCOME  DECIMAL(19,4)  COMMENT  '其中：股票投资收益',
  BONDINVESTMENTINCOME  DECIMAL(19,4)  COMMENT  '债券投资收益',
  ABSINVESTMENTINCOME  DECIMAL(19,4)  COMMENT  '资产支持证券投资收益',
  DERIVATIVEINVESTINCOME  DECIMAL(19,4)  COMMENT  '衍生工具收益',
  DIVIDENDINCOME  DECIMAL(19,4)  COMMENT  '股利收入(元)',
  OTHERINVESTMENTINCOME  DECIMAL(19,4)  COMMENT  '其他投资收益(元)',
  FAIRVALUECHANGEINCOME  DECIMAL(19,4)  COMMENT  '公允价值变动净收益',
  OTHERINCOME  DECIMAL(19,4)  COMMENT  '其他收入(元)',
  INCOMEEXCEPTIONALITEMS  DECIMAL(19,4)  COMMENT  '##收入特殊项目',
  INCOMEADJUSTMENTITEMS  DECIMAL(19,4)  COMMENT  '##收入调整项目',
  TOTALREVENUE  DECIMAL(19,4)  COMMENT  '收入合计',
  MANGEMENTEXPENSE  DECIMAL(19,4)  COMMENT  '1.管理人报酬',
  TRUSTEEEXPENSE  DECIMAL(19,4)  COMMENT  '2.托管费',
  SALEEXPENSE  DECIMAL(19,4)  COMMENT  '销售费用(元)',
  TRANSACTIONEXPENSE  DECIMAL(19,4)  COMMENT  '4.交易费用',
  INTERESTEXPENSE  DECIMAL(19,4)  COMMENT  '其中:利息支出(元)',
  SOLDREPOSECUEXPENSE  DECIMAL(19,4)  COMMENT  '卖出回购证券支出(元)',
  OTHEREXPENSE  DECIMAL(19,4)  COMMENT  '其他费用(元)',
  EXPENSEEXCEPTIONALITEMS  DECIMAL(19,4)  COMMENT  '##费用特殊项目',
  EXPENSEADJUSTMENTITEMS  DECIMAL(19,4)  COMMENT  '##费用调整项目',
  TOTALEXPENSE  DECIMAL(19,4)  COMMENT  '费用合计(元)',
  PASTPROFITANDLOSS  DECIMAL(19,4)  COMMENT  '(净收益)以前年度损益调整',
  PROFITEXCEPTIONALITEMS  DECIMAL(19,4)  COMMENT  '##利润特殊项目',
  PROFITADJUSTMENTITEMS  DECIMAL(19,4)  COMMENT  '##利润调整项目',
  TOTALPROFIT  DECIMAL(19,4)  COMMENT  '利润总额(元)',
  SPECIALFIELDREMARK  STRING  COMMENT  '特殊字段说明',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  STARTDATE  STRING  COMMENT  '起始日期',
  FUNDINVESTINCOME  DECIMAL(19,4)  COMMENT  '基金投资收益',
  EXCHANGEINCOME  DECIMAL(19,4)  COMMENT  '4.汇兑收益',
  RMETALINVESTMENTINCOME  DECIMAL(19,4)  COMMENT  '贵金属投资收益',
  TAXSURCHARGES  DECIMAL(19,4)  COMMENT  '6.税金及附加',
  INCOMETAXCOST  DECIMAL(19,4)  COMMENT  '减:所得税费用',
  NETPROFIT  DECIMAL(19,4)  COMMENT  '净利润',
  INSERTTIME  STRING  COMMENT  '插入时间',
  TRANSCODE  STRING  COMMENT  '基金转型统一编码'
)
COMMENT '公募基金利润表_新会计准则'
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
                                   , INTERESTINCOME
                                   , DEPOSITINTERESTINCOME
                                   , BONDINTERESTINCOME
                                   , ABSINTERESTINCOME
                                   , SELLBACKASSETSINCOME
                                   , OTHERINTERESTINCOME
                                   , INVESTMENTINCOME
                                   , STOCKINVESTMENTINCOME
                                   , BONDINVESTMENTINCOME
                                   , ABSINVESTMENTINCOME
                                   , DERIVATIVEINVESTINCOME
                                   , DIVIDENDINCOME
                                   , OTHERINVESTMENTINCOME
                                   , FAIRVALUECHANGEINCOME
                                   , OTHERINCOME
                                   , INCOMEEXCEPTIONALITEMS
                                   , INCOMEADJUSTMENTITEMS
                                   , TOTALREVENUE
                                   , MANGEMENTEXPENSE
                                   , TRUSTEEEXPENSE
                                   , SALEEXPENSE
                                   , TRANSACTIONEXPENSE
                                   , INTERESTEXPENSE
                                   , SOLDREPOSECUEXPENSE
                                   , OTHEREXPENSE
                                   , EXPENSEEXCEPTIONALITEMS
                                   , EXPENSEADJUSTMENTITEMS
                                   , TOTALEXPENSE
                                   , PASTPROFITANDLOSS
                                   , PROFITEXCEPTIONALITEMS
                                   , PROFITADJUSTMENTITEMS
                                   , TOTALPROFIT
                                   , SPECIALFIELDREMARK
                                   , UPDATETIME
                                   , JSID
                                   , STARTDATE
                                   , FUNDINVESTINCOME
                                   , EXCHANGEINCOME
                                   , RMETALINVESTMENTINCOME
                                   , TAXSURCHARGES
                                   , INCOMETAXCOST
                                   , NETPROFIT
                                   , INSERTTIME
                                   , TRANSCODE
                                FROM ${jy_src_schema}.MF_INCOMESTATEMENTNEW"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "INFOSOURCE", "type": "STRING"}, {"name": "BULLETINTYPE", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "COMPANYCODE", "type": "DOUBLE"}, {"name": "ENDDATE", "type": "STRING"}, {"name": "MARK", "type": "DOUBLE"}, {"name": "ACCOUNTINGSTANDARDS", "type": "DOUBLE"}, {"name": "INTERESTINCOME", "type": "DOUBLE"}, {"name": "DEPOSITINTERESTINCOME", "type": "DOUBLE"}, {"name": "BONDINTERESTINCOME", "type": "DOUBLE"}, {"name": "ABSINTERESTINCOME", "type": "DOUBLE"}, {"name": "SELLBACKASSETSINCOME", "type": "DOUBLE"}, {"name": "OTHERINTERESTINCOME", "type": "DOUBLE"}, {"name": "INVESTMENTINCOME", "type": "DOUBLE"}, {"name": "STOCKINVESTMENTINCOME", "type": "DOUBLE"}, {"name": "BONDINVESTMENTINCOME", "type": "DOUBLE"}, {"name": "ABSINVESTMENTINCOME", "type": "DOUBLE"}, {"name": "DERIVATIVEINVESTINCOME", "type": "DOUBLE"}, {"name": "DIVIDENDINCOME", "type": "DOUBLE"}, {"name": "OTHERINVESTMENTINCOME", "type": "DOUBLE"}, {"name": "FAIRVALUECHANGEINCOME", "type": "DOUBLE"}, {"name": "OTHERINCOME", "type": "DOUBLE"}, {"name": "INCOMEEXCEPTIONALITEMS", "type": "DOUBLE"}, {"name": "INCOMEADJUSTMENTITEMS", "type": "DOUBLE"}, {"name": "TOTALREVENUE", "type": "DOUBLE"}, {"name": "MANGEMENTEXPENSE", "type": "DOUBLE"}, {"name": "TRUSTEEEXPENSE", "type": "DOUBLE"}, {"name": "SALEEXPENSE", "type": "DOUBLE"}, {"name": "TRANSACTIONEXPENSE", "type": "DOUBLE"}, {"name": "INTERESTEXPENSE", "type": "DOUBLE"}, {"name": "SOLDREPOSECUEXPENSE", "type": "DOUBLE"}, {"name": "OTHEREXPENSE", "type": "DOUBLE"}, {"name": "EXPENSEEXCEPTIONALITEMS", "type": "DOUBLE"}, {"name": "EXPENSEADJUSTMENTITEMS", "type": "DOUBLE"}, {"name": "TOTALEXPENSE", "type": "DOUBLE"}, {"name": "PASTPROFITANDLOSS", "type": "DOUBLE"}, {"name": "PROFITEXCEPTIONALITEMS", "type": "DOUBLE"}, {"name": "PROFITADJUSTMENTITEMS", "type": "DOUBLE"}, {"name": "TOTALPROFIT", "type": "DOUBLE"}, {"name": "SPECIALFIELDREMARK", "type": "STRING"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "STARTDATE", "type": "STRING"}, {"name": "FUNDINVESTINCOME", "type": "DOUBLE"}, {"name": "EXCHANGEINCOME", "type": "DOUBLE"}, {"name": "RMETALINVESTMENTINCOME", "type": "DOUBLE"}, {"name": "TAXSURCHARGES", "type": "DOUBLE"}, {"name": "INCOMETAXCOST", "type": "DOUBLE"}, {"name": "NETPROFIT", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}, {"name": "TRANSCODE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_mf_incomestatementnew_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_mf_incomestatementnew_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_mf_incomestatementnew_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_mf_incomestatementnew_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_MF_INCOMESTATEMENTNEW_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_MF_INCOMESTATEMENTNEW_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_mf_incomestatementnew_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_MF_INCOMESTATEMENTNEW_PFD PARTITION(P_DT='${p_end_dt}')
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
     , INTERESTINCOME
     , DEPOSITINTERESTINCOME
     , BONDINTERESTINCOME
     , ABSINTERESTINCOME
     , SELLBACKASSETSINCOME
     , OTHERINTERESTINCOME
     , INVESTMENTINCOME
     , STOCKINVESTMENTINCOME
     , BONDINVESTMENTINCOME
     , ABSINVESTMENTINCOME
     , DERIVATIVEINVESTINCOME
     , DIVIDENDINCOME
     , OTHERINVESTMENTINCOME
     , FAIRVALUECHANGEINCOME
     , OTHERINCOME
     , INCOMEEXCEPTIONALITEMS
     , INCOMEADJUSTMENTITEMS
     , TOTALREVENUE
     , MANGEMENTEXPENSE
     , TRUSTEEEXPENSE
     , SALEEXPENSE
     , TRANSACTIONEXPENSE
     , INTERESTEXPENSE
     , SOLDREPOSECUEXPENSE
     , OTHEREXPENSE
     , EXPENSEEXCEPTIONALITEMS
     , EXPENSEADJUSTMENTITEMS
     , TOTALEXPENSE
     , PASTPROFITANDLOSS
     , PROFITEXCEPTIONALITEMS
     , PROFITADJUSTMENTITEMS
     , TOTALPROFIT
     , SPECIALFIELDREMARK
     , UPDATETIME
     , JSID
     , STARTDATE
     , FUNDINVESTINCOME
     , EXCHANGEINCOME
     , RMETALINVESTMENTINCOME
     , TAXSURCHARGES
     , INCOMETAXCOST
     , NETPROFIT
     , INSERTTIME
     , TRANSCODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_MF_INCOMESTATEMENTNEW_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_MF_INCOMESTATEMENTNEW_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_MF_INCOMESTATEMENTNEW_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_MF_INCOMESTATEMENTNEW_PFD成功"
      exit 0
   fi
fi
