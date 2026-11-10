#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_ABSBASICINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_ABSBASICINFO_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  BONDFULLNAME  STRING  COMMENT  '债券全称',
  INITIALPUBDATE  STRING  COMMENT  '首次信息发布日期',
  CSRCAPPROVALDATE  STRING  COMMENT  '证监会审核日期',
  ORIGINALBENEFICIARY  STRING  COMMENT  '原始权益人',
  MANAGER  STRING  COMMENT  '基金经理',
  CUSTODY  STRING  COMMENT  '托管人',
  CRAS  STRING  COMMENT  '评级机构',
  GUARANTOR  STRING  COMMENT  '担保方',
  GUARANTMETHOD  STRING  COMMENT  '担保方式',
  BASICASSET  STRING  COMMENT  '基础资产',
  CREDITRATING  STRING  COMMENT  '债券信用级别(字母)',
  CRREMARK  STRING  COMMENT  '信用级别释义',
  PARVALUE  DECIMAL(19,4)  COMMENT  '面值(人民币)',
  ACTUALISSUESIZE  DECIMAL(19,4)  COMMENT  '实际发行规模(元)',
  EXPANBEYIELD  DECIMAL(19,8)  COMMENT  '预期年收益率起始(%)',
  EXANENYIELD  DECIMAL(19,8)  COMMENT  '预期年收益率截止(%)',
  MATURITYSTDATE  STRING  COMMENT  '存续起始日',
  EXPECTMATURITY  DECIMAL(10,2)  COMMENT  '预期存续期',
  MATURITYUNIT  DECIMAL(10,0)  COMMENT  '存续期单位',
  PAYMENTMETHODREMARK  STRING  COMMENT  '支付机制说明',
  PAYMENTMETHOD  DECIMAL(10,0)  COMMENT  '支付方式',
  ISSUEPUBDATE  STRING  COMMENT  '募集说明书发布日期',
  POPULARIZESTDATE  STRING  COMMENT  '推广期起始日',
  POPULARIZEEDDATE  STRING  COMMENT  '推广期截止日',
  ISSUEOBJECT  STRING  COMMENT  '发行对象',
  ISSUREPRICE  DECIMAL(19,4)  COMMENT  '发行价格(元/份)',
  LEASTBUYSUM  DECIMAL(19,4)  COMMENT  '最低认购金额',
  SUBSCRIPTIONUNIT  DECIMAL(19,4)  COMMENT  '认购数额单位',
  INCEPTIONDATE  STRING  COMMENT  '设立日期',
  REGORG  STRING  COMMENT  '登记机构',
  TRANSFERSTDATE  STRING  COMMENT  '转让服务起始日(上市日)',
  TRANSFEREDDATE  STRING  COMMENT  '转让服务截止日',
  LEASTTRANSUM  DECIMAL(18,2)  COMMENT  '最低转让份数',
  TRANSFERUNIT  DECIMAL(18,2)  COMMENT  '转让数量单位',
  \`EXCHANGE\`  DECIMAL(10,0)  COMMENT  '上市地点',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  MATURITYENDDATE  STRING  COMMENT  '存续截止日',
  PROJECTTYPE  STRING  COMMENT  '计划类型',
  REDEMPTIONREGDATE  STRING  COMMENT  '兑付登记日',
  REDEMPTIONDATE  STRING  COMMENT  '兑付日',
  PRIORITYLEVEL  DECIMAL(10,0)  COMMENT  '分层级别',
  EARLYMDATE  STRING  COMMENT  '提前到期日',
  BASICASSETTYPE  STRING  COMMENT  '基础资产类型',
  PRIORITYLEVELY  DECIMAL(10,0)  COMMENT  '分层级别细分1',
  OPMATURITY  STRING  COMMENT  '含权券特殊期限',
  RATEADJUSTMODE  DECIMAL(10,0)  COMMENT  '利率调整模式',
  FRNMARGIN  DECIMAL(9,6)  COMMENT  '基准利差(%)',
  FRNREFRATEPER  DECIMAL(9,6)  COMMENT  '初始基准利率(%)',
  FRNREFRATETEXT  DECIMAL(10,0)  COMMENT  '浮动利率债券基础利率选择说明1',
  COMPOUNDMETHOD  DECIMAL(10,0)  COMMENT  '计息方式',
  INTERESTFORMULA  DECIMAL(10,0)  COMMENT  '利息计算公式',
  INTERESTITEM  STRING  COMMENT  '利息条款描述',
  CURRENCYUNIT  DECIMAL(10,0)  COMMENT  '货币单位',
  BIDENDDATE  STRING  COMMENT  '招标日/薄记建档日截止日',
  CONENDDATEOFFLINE  STRING  COMMENT  '网下缴款日截止日',
  LEGALENDDATE  STRING  COMMENT  '法定到期日',
  INSERTTIME  STRING  COMMENT  '发布时间',
  REDEMPTIONMETHOD  DECIMAL(10,0)  COMMENT  ''
)
COMMENT '券商专项资产收益计划表'
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
                                   , INNERCODE
                                   , BONDFULLNAME
                                   , INITIALPUBDATE
                                   , CSRCAPPROVALDATE
                                   , ORIGINALBENEFICIARY
                                   , MANAGER
                                   , CUSTODY
                                   , CRAS
                                   , GUARANTOR
                                   , GUARANTMETHOD
                                   , BASICASSET
                                   , CREDITRATING
                                   , CRREMARK
                                   , PARVALUE
                                   , ACTUALISSUESIZE
                                   , EXPANBEYIELD
                                   , EXANENYIELD
                                   , MATURITYSTDATE
                                   , EXPECTMATURITY
                                   , MATURITYUNIT
                                   , PAYMENTMETHODREMARK
                                   , PAYMENTMETHOD
                                   , ISSUEPUBDATE
                                   , POPULARIZESTDATE
                                   , POPULARIZEEDDATE
                                   , ISSUEOBJECT
                                   , ISSUREPRICE
                                   , LEASTBUYSUM
                                   , SUBSCRIPTIONUNIT
                                   , INCEPTIONDATE
                                   , REGORG
                                   , TRANSFERSTDATE
                                   , TRANSFEREDDATE
                                   , LEASTTRANSUM
                                   , TRANSFERUNIT
                                   , EXCHANGE
                                   , UPDATETIME
                                   , JSID
                                   , MATURITYENDDATE
                                   , PROJECTTYPE
                                   , REDEMPTIONREGDATE
                                   , REDEMPTIONDATE
                                   , PRIORITYLEVEL
                                   , EARLYMDATE
                                   , BASICASSETTYPE
                                   , PRIORITYLEVELY
                                   , OPMATURITY
                                   , RATEADJUSTMODE
                                   , FRNMARGIN
                                   , FRNREFRATEPER
                                   , FRNREFRATETEXT
                                   , COMPOUNDMETHOD
                                   , INTERESTFORMULA
                                   , INTERESTITEM
                                   , CURRENCYUNIT
                                   , BIDENDDATE
                                   , CONENDDATEOFFLINE
                                   , LEGALENDDATE
                                   , INSERTTIME
                                   , REDEMPTIONMETHOD
                                FROM ${jy_src_schema}.BOND_ABSBASICINFO"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "BONDFULLNAME", "type": "STRING"}, {"name": "INITIALPUBDATE", "type": "STRING"}, {"name": "CSRCAPPROVALDATE", "type": "STRING"}, {"name": "ORIGINALBENEFICIARY", "type": "STRING"}, {"name": "MANAGER", "type": "STRING"}, {"name": "CUSTODY", "type": "STRING"}, {"name": "CRAS", "type": "STRING"}, {"name": "GUARANTOR", "type": "STRING"}, {"name": "GUARANTMETHOD", "type": "STRING"}, {"name": "BASICASSET", "type": "STRING"}, {"name": "CREDITRATING", "type": "STRING"}, {"name": "CRREMARK", "type": "STRING"}, {"name": "PARVALUE", "type": "DOUBLE"}, {"name": "ACTUALISSUESIZE", "type": "DOUBLE"}, {"name": "EXPANBEYIELD", "type": "DOUBLE"}, {"name": "EXANENYIELD", "type": "DOUBLE"}, {"name": "MATURITYSTDATE", "type": "STRING"}, {"name": "EXPECTMATURITY", "type": "DOUBLE"}, {"name": "MATURITYUNIT", "type": "DOUBLE"}, {"name": "PAYMENTMETHODREMARK", "type": "STRING"}, {"name": "PAYMENTMETHOD", "type": "DOUBLE"}, {"name": "ISSUEPUBDATE", "type": "STRING"}, {"name": "POPULARIZESTDATE", "type": "STRING"}, {"name": "POPULARIZEEDDATE", "type": "STRING"}, {"name": "ISSUEOBJECT", "type": "STRING"}, {"name": "ISSUREPRICE", "type": "DOUBLE"}, {"name": "LEASTBUYSUM", "type": "DOUBLE"}, {"name": "SUBSCRIPTIONUNIT", "type": "DOUBLE"}, {"name": "INCEPTIONDATE", "type": "STRING"}, {"name": "REGORG", "type": "STRING"}, {"name": "TRANSFERSTDATE", "type": "STRING"}, {"name": "TRANSFEREDDATE", "type": "STRING"}, {"name": "LEASTTRANSUM", "type": "DOUBLE"}, {"name": "TRANSFERUNIT", "type": "DOUBLE"}, {"name": "EXCHANGE", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "MATURITYENDDATE", "type": "STRING"}, {"name": "PROJECTTYPE", "type": "DOUBLE"}, {"name": "REDEMPTIONREGDATE", "type": "STRING"}, {"name": "REDEMPTIONDATE", "type": "STRING"}, {"name": "PRIORITYLEVEL", "type": "DOUBLE"}, {"name": "EARLYMDATE", "type": "STRING"}, {"name": "BASICASSETTYPE", "type": "DOUBLE"}, {"name": "PRIORITYLEVELY", "type": "DOUBLE"}, {"name": "OPMATURITY", "type": "STRING"}, {"name": "RATEADJUSTMODE", "type": "DOUBLE"}, {"name": "FRNMARGIN", "type": "DOUBLE"}, {"name": "FRNREFRATEPER", "type": "DOUBLE"}, {"name": "FRNREFRATETEXT", "type": "DOUBLE"}, {"name": "COMPOUNDMETHOD", "type": "DOUBLE"}, {"name": "INTERESTFORMULA", "type": "DOUBLE"}, {"name": "INTERESTITEM", "type": "STRING"}, {"name": "CURRENCYUNIT", "type": "DOUBLE"}, {"name": "BIDENDDATE", "type": "STRING"}, {"name": "CONENDDATEOFFLINE", "type": "STRING"}, {"name": "LEGALENDDATE", "type": "STRING"}, {"name": "INSERTTIME", "type": "STRING"}, {"name": "REDEMPTIONMETHOD", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_absbasicinfo_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_absbasicinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_absbasicinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_absbasicinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_ABSBASICINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_ABSBASICINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_absbasicinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_ABSBASICINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , BONDFULLNAME
     , INITIALPUBDATE
     , CSRCAPPROVALDATE
     , ORIGINALBENEFICIARY
     , MANAGER
     , CUSTODY
     , CRAS
     , GUARANTOR
     , GUARANTMETHOD
     , BASICASSET
     , CREDITRATING
     , CRREMARK
     , PARVALUE
     , ACTUALISSUESIZE
     , EXPANBEYIELD
     , EXANENYIELD
     , MATURITYSTDATE
     , EXPECTMATURITY
     , MATURITYUNIT
     , PAYMENTMETHODREMARK
     , PAYMENTMETHOD
     , ISSUEPUBDATE
     , POPULARIZESTDATE
     , POPULARIZEEDDATE
     , ISSUEOBJECT
     , ISSUREPRICE
     , LEASTBUYSUM
     , SUBSCRIPTIONUNIT
     , INCEPTIONDATE
     , REGORG
     , TRANSFERSTDATE
     , TRANSFEREDDATE
     , LEASTTRANSUM
     , TRANSFERUNIT
     , \`EXCHANGE\`
     , UPDATETIME
     , JSID
     , MATURITYENDDATE
     , PROJECTTYPE
     , REDEMPTIONREGDATE
     , REDEMPTIONDATE
     , PRIORITYLEVEL
     , EARLYMDATE
     , BASICASSETTYPE
     , PRIORITYLEVELY
     , OPMATURITY
     , RATEADJUSTMODE
     , FRNMARGIN
     , FRNREFRATEPER
     , FRNREFRATETEXT
     , COMPOUNDMETHOD
     , INTERESTFORMULA
     , INTERESTITEM
     , CURRENCYUNIT
     , BIDENDDATE
     , CONENDDATEOFFLINE
     , LEGALENDDATE
     , INSERTTIME
     , REDEMPTIONMETHOD
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_BOND_ABSBASICINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_ABSBASICINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_ABSBASICINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_ABSBASICINFO_PFD成功"
      exit 0
   fi
fi
