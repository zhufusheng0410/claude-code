#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_LC_FSDERIVEDDATA_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_LC_FSDERIVEDDATA_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  COMPANYCODE  STRING  COMMENT  '公司代码',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  INFOSOURCE  STRING  COMMENT  '信息来源',
  BULLETINTYPE  STRING  COMMENT  '公告类别',
  ENDDATE  STRING  COMMENT  '日期',
  IFADJUSTED  DECIMAL(10,0)  COMMENT  '是否调整',
  ACCOUNTINGSTANDARDS  DECIMAL(10,0)  COMMENT  '会计准则',
  INTERESTFREECLIABILITIES  DECIMAL(19,4)  COMMENT  '无息流动负债',
  INTERESTFREENONCL  DECIMAL(19,4)  COMMENT  '无息非流动负债',
  INTERESTBEARDEBT  DECIMAL(19,4)  COMMENT  '带息债务',
  NETDEBT  DECIMAL(19,4)  COMMENT  '净债务',
  TOTALPAIDINCAPITAL  DECIMAL(19,4)  COMMENT  '全部投入资本',
  WORKINGCAITAL  DECIMAL(19,4)  COMMENT  '营运资本',
  NETWORKINGCAITAL  DECIMAL(19,4)  COMMENT  '净营运资本',
  NETTANGIBLEASSETS  DECIMAL(19,4)  COMMENT  '有形资产净值',
  RETAINEDEARNINGS  DECIMAL(19,4)  COMMENT  '留存收益',
  NONRECURRINGPROFITLOSS  DECIMAL(19,4)  COMMENT  '非经常性损益(元)',
  NPDEDUCTNONRECURRINGPL  DECIMAL(19,4)  COMMENT  '扣除非经常性损益后的净利润',
  GROSSPROFIT  DECIMAL(19,4)  COMMENT  '主营业务利润(元)',
  NETINCOMEFROMOPERATING  DECIMAL(19,4)  COMMENT  '经营活动净收益',
  NETINCOMEFROMVALUECHANGE  DECIMAL(19,4)  COMMENT  '价值变动净收益',
  EBIT  DECIMAL(19,4)  COMMENT  '息税前利润(元)',
  EBITDA  DECIMAL(19,4)  COMMENT  '息税折旧摊销前利润(元)',
  TOTALOPERATINGREVENUETTM  DECIMAL(19,4)  COMMENT  '营业总收入(TTM)',
  TOTALOPERATINGCOSTTTM  DECIMAL(19,4)  COMMENT  '营业总成本(TTM)',
  OPERATINGREVENUETTM  DECIMAL(19,4)  COMMENT  '营业收入(TTM)',
  OPERATINGCOSTTTM  DECIMAL(19,4)  COMMENT  '营业成本-非金融类(TTM)',
  OPERATINGPAYOUTTTM  DECIMAL(19,4)  COMMENT  '营业支出-金融类(TTM)',
  GROSSPROFITTTM  DECIMAL(19,4)  COMMENT  '毛利(TTM)',
  OPERATINGEXPENSETTM  DECIMAL(19,4)  COMMENT  '销售费用(TTM)',
  ADMINISTRATIONEXPENSETTM  DECIMAL(19,4)  COMMENT  '管理费用(TTM)',
  FINANCIALEXPENSETTM  DECIMAL(19,4)  COMMENT  '财务费用(TTM)',
  ASSETIMPAIRMENTLOSSTTM  DECIMAL(19,4)  COMMENT  '资产减值损失(TTM)',
  NIFROMOPERATINGTTM  DECIMAL(19,4)  COMMENT  '经营活动净收益(TTM)',
  NIFROMVALUECHANGETTM  DECIMAL(19,4)  COMMENT  '价值变动净收益(TTM)',
  OPERATINGPROFITTTM  DECIMAL(19,4)  COMMENT  '营业利润(TTM)',
  NONOPERATINGNETINCOMETTM  DECIMAL(19,4)  COMMENT  '营业外收支净额(TTM)',
  EBITTTM  DECIMAL(19,4)  COMMENT  '息税前利润(TTM)',
  TOTALPROFITTTM  DECIMAL(19,4)  COMMENT  '利润总额(TTM)',
  NETPROFITTTM  DECIMAL(19,4)  COMMENT  '净利润(TTM)',
  NPPARENTCOMPANYOWNERSTTM  DECIMAL(19,4)  COMMENT  '归属母公司股东的净利润(TTM)',
  FCFF  DECIMAL(19,4)  COMMENT  '企业自由现金流量FCFF',
  FCFE  DECIMAL(19,4)  COMMENT  '股权自由现金流量FCFE',
  CURRENTACCRUEDDA  DECIMAL(19,4)  COMMENT  '当期计提折旧与摊销',
  SALESERVICERENDERCASHTTM  DECIMAL(19,4)  COMMENT  '销售商品提供劳务收到的现金(TTM)',
  NETOPERATECASHFLOWTTM  DECIMAL(19,4)  COMMENT  '经营活动现金净流量(TTM)',
  NETINVESTCASHFLOWTTM  DECIMAL(19,4)  COMMENT  '投资活动现金净流量(TTM)',
  NETFINANCECASHFLOWTTM  DECIMAL(19,4)  COMMENT  '筹资活动现金净流量(TTM)',
  NETCASHFLOWTTM  DECIMAL(19,4)  COMMENT  '现金净流量(TTM)',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  RANDDTTM  DECIMAL(19,4)  COMMENT  '研发费用(TTM)',
  INSERTTIME  STRING  COMMENT  '发布时间'
)
COMMENT '公司衍生报表数据_新会计准则（新）'
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
                                   , BULLETINTYPE
                                   , ENDDATE
                                   , IFADJUSTED
                                   , ACCOUNTINGSTANDARDS
                                   , INTERESTFREECLIABILITIES
                                   , INTERESTFREENONCL
                                   , INTERESTBEARDEBT
                                   , NETDEBT
                                   , TOTALPAIDINCAPITAL
                                   , WORKINGCAITAL
                                   , NETWORKINGCAITAL
                                   , NETTANGIBLEASSETS
                                   , RETAINEDEARNINGS
                                   , NONRECURRINGPROFITLOSS
                                   , NPDEDUCTNONRECURRINGPL
                                   , GROSSPROFIT
                                   , NETINCOMEFROMOPERATING
                                   , NETINCOMEFROMVALUECHANGE
                                   , EBIT
                                   , EBITDA
                                   , TOTALOPERATINGREVENUETTM
                                   , TOTALOPERATINGCOSTTTM
                                   , OPERATINGREVENUETTM
                                   , OPERATINGCOSTTTM
                                   , OPERATINGPAYOUTTTM
                                   , GROSSPROFITTTM
                                   , OPERATINGEXPENSETTM
                                   , ADMINISTRATIONEXPENSETTM
                                   , FINANCIALEXPENSETTM
                                   , ASSETIMPAIRMENTLOSSTTM
                                   , NIFROMOPERATINGTTM
                                   , NIFROMVALUECHANGETTM
                                   , OPERATINGPROFITTTM
                                   , NONOPERATINGNETINCOMETTM
                                   , EBITTTM
                                   , TOTALPROFITTTM
                                   , NETPROFITTTM
                                   , NPPARENTCOMPANYOWNERSTTM
                                   , FCFF
                                   , FCFE
                                   , CURRENTACCRUEDDA
                                   , SALESERVICERENDERCASHTTM
                                   , NETOPERATECASHFLOWTTM
                                   , NETINVESTCASHFLOWTTM
                                   , NETFINANCECASHFLOWTTM
                                   , NETCASHFLOWTTM
                                   , UPDATETIME
                                   , JSID
                                   , RANDDTTM
                                   , INSERTTIME
                                FROM ${jy_src_schema}.LC_FSDERIVEDDATA"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "COMPANYCODE", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "INFOSOURCE", "type": "STRING"}, {"name": "BULLETINTYPE", "type": "STRING"}, {"name": "ENDDATE", "type": "STRING"}, {"name": "IFADJUSTED", "type": "DOUBLE"}, {"name": "ACCOUNTINGSTANDARDS", "type": "DOUBLE"}, {"name": "INTERESTFREECLIABILITIES", "type": "DOUBLE"}, {"name": "INTERESTFREENONCL", "type": "DOUBLE"}, {"name": "INTERESTBEARDEBT", "type": "DOUBLE"}, {"name": "NETDEBT", "type": "DOUBLE"}, {"name": "TOTALPAIDINCAPITAL", "type": "DOUBLE"}, {"name": "WORKINGCAITAL", "type": "DOUBLE"}, {"name": "NETWORKINGCAITAL", "type": "DOUBLE"}, {"name": "NETTANGIBLEASSETS", "type": "DOUBLE"}, {"name": "RETAINEDEARNINGS", "type": "DOUBLE"}, {"name": "NONRECURRINGPROFITLOSS", "type": "DOUBLE"}, {"name": "NPDEDUCTNONRECURRINGPL", "type": "DOUBLE"}, {"name": "GROSSPROFIT", "type": "DOUBLE"}, {"name": "NETINCOMEFROMOPERATING", "type": "DOUBLE"}, {"name": "NETINCOMEFROMVALUECHANGE", "type": "DOUBLE"}, {"name": "EBIT", "type": "DOUBLE"}, {"name": "EBITDA", "type": "DOUBLE"}, {"name": "TOTALOPERATINGREVENUETTM", "type": "DOUBLE"}, {"name": "TOTALOPERATINGCOSTTTM", "type": "DOUBLE"}, {"name": "OPERATINGREVENUETTM", "type": "DOUBLE"}, {"name": "OPERATINGCOSTTTM", "type": "DOUBLE"}, {"name": "OPERATINGPAYOUTTTM", "type": "DOUBLE"}, {"name": "GROSSPROFITTTM", "type": "DOUBLE"}, {"name": "OPERATINGEXPENSETTM", "type": "DOUBLE"}, {"name": "ADMINISTRATIONEXPENSETTM", "type": "DOUBLE"}, {"name": "FINANCIALEXPENSETTM", "type": "DOUBLE"}, {"name": "ASSETIMPAIRMENTLOSSTTM", "type": "DOUBLE"}, {"name": "NIFROMOPERATINGTTM", "type": "DOUBLE"}, {"name": "NIFROMVALUECHANGETTM", "type": "DOUBLE"}, {"name": "OPERATINGPROFITTTM", "type": "DOUBLE"}, {"name": "NONOPERATINGNETINCOMETTM", "type": "DOUBLE"}, {"name": "EBITTTM", "type": "DOUBLE"}, {"name": "TOTALPROFITTTM", "type": "DOUBLE"}, {"name": "NETPROFITTTM", "type": "DOUBLE"}, {"name": "NPPARENTCOMPANYOWNERSTTM", "type": "DOUBLE"}, {"name": "FCFF", "type": "DOUBLE"}, {"name": "FCFE", "type": "DOUBLE"}, {"name": "CURRENTACCRUEDDA", "type": "DOUBLE"}, {"name": "SALESERVICERENDERCASHTTM", "type": "DOUBLE"}, {"name": "NETOPERATECASHFLOWTTM", "type": "DOUBLE"}, {"name": "NETINVESTCASHFLOWTTM", "type": "DOUBLE"}, {"name": "NETFINANCECASHFLOWTTM", "type": "DOUBLE"}, {"name": "NETCASHFLOWTTM", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "RANDDTTM", "type": "DOUBLE"}, {"name": "INSERTTIME", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_lc_fsderiveddata_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_lc_fsderiveddata_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_lc_fsderiveddata_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_lc_fsderiveddata_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_LC_FSDERIVEDDATA_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_LC_FSDERIVEDDATA_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_lc_fsderiveddata_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_LC_FSDERIVEDDATA_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , COMPANYCODE
     , INFOPUBLDATE
     , INFOSOURCE
     , BULLETINTYPE
     , ENDDATE
     , IFADJUSTED
     , ACCOUNTINGSTANDARDS
     , INTERESTFREECLIABILITIES
     , INTERESTFREENONCL
     , INTERESTBEARDEBT
     , NETDEBT
     , TOTALPAIDINCAPITAL
     , WORKINGCAITAL
     , NETWORKINGCAITAL
     , NETTANGIBLEASSETS
     , RETAINEDEARNINGS
     , NONRECURRINGPROFITLOSS
     , NPDEDUCTNONRECURRINGPL
     , GROSSPROFIT
     , NETINCOMEFROMOPERATING
     , NETINCOMEFROMVALUECHANGE
     , EBIT
     , EBITDA
     , TOTALOPERATINGREVENUETTM
     , TOTALOPERATINGCOSTTTM
     , OPERATINGREVENUETTM
     , OPERATINGCOSTTTM
     , OPERATINGPAYOUTTTM
     , GROSSPROFITTTM
     , OPERATINGEXPENSETTM
     , ADMINISTRATIONEXPENSETTM
     , FINANCIALEXPENSETTM
     , ASSETIMPAIRMENTLOSSTTM
     , NIFROMOPERATINGTTM
     , NIFROMVALUECHANGETTM
     , OPERATINGPROFITTTM
     , NONOPERATINGNETINCOMETTM
     , EBITTTM
     , TOTALPROFITTTM
     , NETPROFITTTM
     , NPPARENTCOMPANYOWNERSTTM
     , FCFF
     , FCFE
     , CURRENTACCRUEDDA
     , SALESERVICERENDERCASHTTM
     , NETOPERATECASHFLOWTTM
     , NETINVESTCASHFLOWTTM
     , NETFINANCECASHFLOWTTM
     , NETCASHFLOWTTM
     , UPDATETIME
     , JSID
     , RANDDTTM
     , INSERTTIME
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_LC_FSDERIVEDDATA_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_LC_FSDERIVEDDATA_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_LC_FSDERIVEDDATA_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_LC_FSDERIVEDDATA_PFD成功"
      exit 0
   fi
fi
