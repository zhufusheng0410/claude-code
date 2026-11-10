#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_BASICINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_BASICINFO_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  MAINCODE  STRING  COMMENT  '基金主代码',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  BONDFULLNAME  STRING  COMMENT  '债券全称',
  BONDFORM  DECIMAL(10,0)  COMMENT  '债券形式',
  BONDNATURE  DECIMAL(10,0)  COMMENT  '债券性质',
  OPTIONTYPE  STRING  COMMENT  '选择权类型',
  IFSTRIPS  DECIMAL(10,0)  COMMENT  '是否可分离债',
  ISSUER  STRING  COMMENT  '发行人',
  ISSUERNATURE  DECIMAL(10,0)  COMMENT  '发行人性质',
  GUARANTOR  STRING  COMMENT  '担保方',
  LEADUNDERWRITER  STRING  COMMENT  '主承销商',
  INITIALINFOPUBLDATE  STRING  COMMENT  '首次信息发布日期',
  CREDITRATING  STRING  COMMENT  '债券信用级别(字母)',
  CRAS  STRING  COMMENT  '评级机构',
  ACTUALISSUESIZE  DECIMAL(19,4)  COMMENT  '实际发行规模(元)',
  MATURITY  DECIMAL(9,4)  COMMENT  '存续期限',
  PARVALUE  DECIMAL(19,4)  COMMENT  '面值(人民币)',
  ISSUEPRICE  DECIMAL(19,4)  COMMENT  '实际发行价(元)',
  CURRENCYUNIT  DECIMAL(10,0)  COMMENT  '货币单位',
  ISSUEREFYTM  DECIMAL(10,6)  COMMENT  '参考收益率',
  COMPOUNDMETHOD  DECIMAL(10,0)  COMMENT  '计息方式',
  INTPAYMENTMETHOD  DECIMAL(10,0)  COMMENT  '付息方式',
  PMREMARK  STRING  COMMENT  '*利息支付方式说明/支付机制说明',
  COUPONRATE  DECIMAL(9,6)  COMMENT  '票面利率',
  MINANNUALRATE  DECIMAL(9,6)  COMMENT  '债券保底利率(%)',
  FRNREFRATEPER  DECIMAL(9,6)  COMMENT  '本期浮动利率计息基准利率',
  FRNREFRATESELECRREMARK  DECIMAL(10,0)  COMMENT  '浮动利率债券基础利率选择说明',
  FRNMARGIN  DECIMAL(9,6)  COMMENT  '浮动利率计息基准利差',
  PAYINTERESTEFFENCY  DECIMAL(10,0)  COMMENT  '付息频率(次/年)',
  BIDDATE  STRING  COMMENT  '招标日',
  ISSUEDATE  STRING  COMMENT  '发行日期',
  TRANSFERDATE  STRING  COMMENT  '转权日',
  VALUEDATE  STRING  COMMENT  '起息日',
  REGDATE  STRING  COMMENT  '权益登记日',
  LISTEDDATE  STRING  COMMENT  '上市日期',
  DELISTDATE  STRING  COMMENT  '停止交易日',
  ENDDATE  STRING  COMMENT  '日期',
  REDEMPTIONDATE  STRING  COMMENT  '兑付日',
  REMARK  STRING  COMMENT  '备注',
  CREATORG  STRING  COMMENT  '*发起机构',
  ABSLEVEL  DECIMAL(10,0)  COMMENT  '*分层级别',
  ABSLEVELRATIO  DECIMAL(19,8)  COMMENT  '*规模分层占比(%)',
  INTERESTCAP  STRING  COMMENT  '*利率上限说明',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  MULTIGUARANTOR  STRING  COMMENT  '再担保人',
  SPONSOR  STRING  COMMENT  '保荐机构',
  INTERESTITEM  STRING  COMMENT  '利息条款描述',
  INTERESTFORMULA  DECIMAL(10,0)  COMMENT  '利息计算公式',
  RATEIFFLOAT  DECIMAL(10,0)  COMMENT  '利率是否浮动',
  RATEADJUSTMODE  DECIMAL(10,0)  COMMENT  '利率调整模式',
  CUSTODYCODE  STRING  COMMENT  '托管人代码',
  REDEMPTIONMETHOD  DECIMAL(10,0)  COMMENT  '兑付方式',
  EARLYMATURITYDATE  STRING  COMMENT  '提前到期日',
  INITIALINVESTORNUM  DECIMAL(10,0)  COMMENT  '初始投资人数量',
  PRIVATEINVESTORNUM  DECIMAL(10,0)  COMMENT  '定向投资人数量',
  INTERESTFORMULAHS  DECIMAL(10,0)  COMMENT  '*利息计算公式(沪深)',
  BASICASSETTYPE  STRING  COMMENT  '*基础资产类型',
  ABSLEVELY  DECIMAL(10,0)  COMMENT  '*分层级别细分',
  OPMATURITY  STRING  COMMENT  '含权券特殊期限',
  LEGALENDDATE  STRING  COMMENT  '*法定到期日',
  PRIMALPRICINGDATE  STRING  COMMENT  '首个定价日'
)
COMMENT '债券要素表'
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
                                   , MAINCODE
                                   , INNERCODE
                                   , BONDFULLNAME
                                   , BONDFORM
                                   , BONDNATURE
                                   , OPTIONTYPE
                                   , IFSTRIPS
                                   , ISSUER
                                   , ISSUERNATURE
                                   , GUARANTOR
                                   , LEADUNDERWRITER
                                   , INITIALINFOPUBLDATE
                                   , CREDITRATING
                                   , CRAS
                                   , ACTUALISSUESIZE
                                   , MATURITY
                                   , PARVALUE
                                   , ISSUEPRICE
                                   , CURRENCYUNIT
                                   , ISSUEREFYTM
                                   , COMPOUNDMETHOD
                                   , INTPAYMENTMETHOD
                                   , PMREMARK
                                   , COUPONRATE
                                   , MINANNUALRATE
                                   , FRNREFRATEPER
                                   , FRNREFRATESELECRREMARK
                                   , FRNMARGIN
                                   , PAYINTERESTEFFENCY
                                   , BIDDATE
                                   , ISSUEDATE
                                   , TRANSFERDATE
                                   , VALUEDATE
                                   , REGDATE
                                   , LISTEDDATE
                                   , DELISTDATE
                                   , ENDDATE
                                   , REDEMPTIONDATE
                                   , REMARK
                                   , CREATORG
                                   , ABSLEVEL
                                   , ABSLEVELRATIO
                                   , INTERESTCAP
                                   , UPDATETIME
                                   , JSID
                                   , MULTIGUARANTOR
                                   , SPONSOR
                                   , INTERESTITEM
                                   , INTERESTFORMULA
                                   , RATEIFFLOAT
                                   , RATEADJUSTMODE
                                   , CUSTODYCODE
                                   , REDEMPTIONMETHOD
                                   , EARLYMATURITYDATE
                                   , INITIALINVESTORNUM
                                   , PRIVATEINVESTORNUM
                                   , INTERESTFORMULAHS
                                   , BASICASSETTYPE
                                   , ABSLEVELY
                                   , OPMATURITY
                                   , LEGALENDDATE
                                   , PRIMALPRICINGDATE
                                FROM ${jy_src_schema}.BOND_BASICINFO"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "MAINCODE", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "BONDFULLNAME", "type": "STRING"}, {"name": "BONDFORM", "type": "DOUBLE"}, {"name": "BONDNATURE", "type": "DOUBLE"}, {"name": "OPTIONTYPE", "type": "STRING"}, {"name": "IFSTRIPS", "type": "DOUBLE"}, {"name": "ISSUER", "type": "STRING"}, {"name": "ISSUERNATURE", "type": "DOUBLE"}, {"name": "GUARANTOR", "type": "STRING"}, {"name": "LEADUNDERWRITER", "type": "STRING"}, {"name": "INITIALINFOPUBLDATE", "type": "STRING"}, {"name": "CREDITRATING", "type": "STRING"}, {"name": "CRAS", "type": "STRING"}, {"name": "ACTUALISSUESIZE", "type": "DOUBLE"}, {"name": "MATURITY", "type": "DOUBLE"}, {"name": "PARVALUE", "type": "DOUBLE"}, {"name": "ISSUEPRICE", "type": "DOUBLE"}, {"name": "CURRENCYUNIT", "type": "DOUBLE"}, {"name": "ISSUEREFYTM", "type": "DOUBLE"}, {"name": "COMPOUNDMETHOD", "type": "DOUBLE"}, {"name": "INTPAYMENTMETHOD", "type": "DOUBLE"}, {"name": "PMREMARK", "type": "STRING"}, {"name": "COUPONRATE", "type": "DOUBLE"}, {"name": "MINANNUALRATE", "type": "DOUBLE"}, {"name": "FRNREFRATEPER", "type": "DOUBLE"}, {"name": "FRNREFRATESELECRREMARK", "type": "DOUBLE"}, {"name": "FRNMARGIN", "type": "DOUBLE"}, {"name": "PAYINTERESTEFFENCY", "type": "DOUBLE"}, {"name": "BIDDATE", "type": "STRING"}, {"name": "ISSUEDATE", "type": "STRING"}, {"name": "TRANSFERDATE", "type": "STRING"}, {"name": "VALUEDATE", "type": "STRING"}, {"name": "REGDATE", "type": "STRING"}, {"name": "LISTEDDATE", "type": "STRING"}, {"name": "DELISTDATE", "type": "STRING"}, {"name": "ENDDATE", "type": "STRING"}, {"name": "REDEMPTIONDATE", "type": "STRING"}, {"name": "REMARK", "type": "STRING"}, {"name": "CREATORG", "type": "STRING"}, {"name": "ABSLEVEL", "type": "DOUBLE"}, {"name": "ABSLEVELRATIO", "type": "DOUBLE"}, {"name": "INTERESTCAP", "type": "STRING"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "MULTIGUARANTOR", "type": "STRING"}, {"name": "SPONSOR", "type": "STRING"}, {"name": "INTERESTITEM", "type": "STRING"}, {"name": "INTERESTFORMULA", "type": "DOUBLE"}, {"name": "RATEIFFLOAT", "type": "DOUBLE"}, {"name": "RATEADJUSTMODE", "type": "DOUBLE"}, {"name": "CUSTODYCODE", "type": "STRING"}, {"name": "REDEMPTIONMETHOD", "type": "DOUBLE"}, {"name": "EARLYMATURITYDATE", "type": "STRING"}, {"name": "INITIALINVESTORNUM", "type": "DOUBLE"}, {"name": "PRIVATEINVESTORNUM", "type": "DOUBLE"}, {"name": "INTERESTFORMULAHS", "type": "DOUBLE"}, {"name": "BASICASSETTYPE", "type": "DOUBLE"}, {"name": "ABSLEVELY", "type": "DOUBLE"}, {"name": "OPMATURITY", "type": "STRING"}, {"name": "LEGALENDDATE", "type": "STRING"}, {"name": "PRIMALPRICINGDATE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_basicinfo_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_basicinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_basicinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_basicinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_BASICINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_BASICINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_basicinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_BASICINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , MAINCODE
     , INNERCODE
     , BONDFULLNAME
     , BONDFORM
     , BONDNATURE
     , OPTIONTYPE
     , IFSTRIPS
     , ISSUER
     , ISSUERNATURE
     , GUARANTOR
     , LEADUNDERWRITER
     , INITIALINFOPUBLDATE
     , CREDITRATING
     , CRAS
     , ACTUALISSUESIZE
     , MATURITY
     , PARVALUE
     , ISSUEPRICE
     , CURRENCYUNIT
     , ISSUEREFYTM
     , COMPOUNDMETHOD
     , INTPAYMENTMETHOD
     , PMREMARK
     , COUPONRATE
     , MINANNUALRATE
     , FRNREFRATEPER
     , FRNREFRATESELECRREMARK
     , FRNMARGIN
     , PAYINTERESTEFFENCY
     , BIDDATE
     , ISSUEDATE
     , TRANSFERDATE
     , VALUEDATE
     , REGDATE
     , LISTEDDATE
     , DELISTDATE
     , ENDDATE
     , REDEMPTIONDATE
     , REMARK
     , CREATORG
     , ABSLEVEL
     , ABSLEVELRATIO
     , INTERESTCAP
     , UPDATETIME
     , JSID
     , MULTIGUARANTOR
     , SPONSOR
     , INTERESTITEM
     , INTERESTFORMULA
     , RATEIFFLOAT
     , RATEADJUSTMODE
     , CUSTODYCODE
     , REDEMPTIONMETHOD
     , EARLYMATURITYDATE
     , INITIALINVESTORNUM
     , PRIVATEINVESTORNUM
     , INTERESTFORMULAHS
     , BASICASSETTYPE
     , ABSLEVELY
     , OPMATURITY
     , LEGALENDDATE
     , PRIMALPRICINGDATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_BOND_BASICINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_BASICINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_BASICINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_BASICINFO_PFD成功"
      exit 0
   fi
fi
