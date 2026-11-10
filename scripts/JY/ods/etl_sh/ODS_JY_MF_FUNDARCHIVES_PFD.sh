#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_MF_FUNDARCHIVES_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_MF_FUNDARCHIVES_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  ESTABLISHMENTDATE  STRING  COMMENT  '公司成立日期',
  LISTEDDATE  STRING  COMMENT  '上市日期',
  DURATION  DECIMAL(18,2)  COMMENT  '麦考利久期',
  STARTDATE  STRING  COMMENT  '起始日期',
  EXPIREDATE  STRING  COMMENT  '存续期截止日',
  MANAGER  STRING  COMMENT  '基金经理',
  INVESTADVISORCODE  STRING  COMMENT  '基金公司代码',
  TRUSTEECODE  STRING  COMMENT  '基金托管人编号',
  WARRANTOR  STRING  COMMENT  '保本担保机构',
  TYPE  DECIMAL(10,0)  COMMENT  '类别',
  INVESTMENTTYPE  STRING  COMMENT  '投资类型',
  INVESTSTYLE  DECIMAL(10,0)  COMMENT  '基金投资风格',
  FOUNDEDSIZE  DECIMAL(18,2)  COMMENT  '基金设立规模(份)',
  INVESTORIENTATION  STRING  COMMENT  '基金投资方向',
  INVESTTARGET  STRING  COMMENT  '投资标的',
  PERFORMANCEBENCHMARK  STRING  COMMENT  '业绩比较基准',
  PROFITDISTRIBUTIONRULE  STRING  COMMENT  '收益分配原则',
  INVESTFIELD  STRING  COMMENT  '投向领域',
  BRIEFINTRO  STRING  COMMENT  '基金简介',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  APPLYINGCODEFRONT  STRING  COMMENT  '前端申购代码',
  APPLYINGCODEBACK  STRING  COMMENT  '后端申购代码',
  GUARANTEEDPERIOD  DECIMAL(18,2)  COMMENT  '保本型基金保本期(月)',
  RISKRETURNCHARACTER  STRING  COMMENT  '风险收益特征',
  LOWESTSUMSUBSCRIBING  STRING  COMMENT  '最低认购申购金额描述',
  LOWESTSUMREDEMPTION  DECIMAL(16,6)  COMMENT  '最低赎回份额(份)',
  LSFRDESCRIPTION  STRING  COMMENT  '最低赎回份额描述',
  LOWESTSUMFORHOLDING  DECIMAL(16,6)  COMMENT  '最低持有份额(份)',
  LSFHDESCRIPTION  STRING  COMMENT  '最低持有份额描述',
  FUNDNATURE  DECIMAL(10,0)  COMMENT  '基金性质',
  FUNDTYPECODE  STRING  COMMENT  '基金类别代码',
  FUNDTYPE  STRING  COMMENT  '基金类别',
  CARRYOVERDATE  DECIMAL(10,0)  COMMENT  '货币基金结转日',
  CARRYOVERDATEREMARK  STRING  COMMENT  '货币基金结转日说明',
  CARRYOVERTYPE  DECIMAL(10,0)  COMMENT  '货币基金收益分配方式(份额结转方式)',
  REGINSTCODE  STRING  COMMENT  '注册登记机构(TA类型)',
  SECURITYCODE  STRING  COMMENT  '基金交易代码(交易所交易代码)',
  DELIVERYDAYS  DECIMAL(10,0)  COMMENT  '赎回款到账天数',
  RISKRETURNCODE  STRING  COMMENT  '风险收益特征代码',
  FLOATTYPE  DECIMAL(10,0)  COMMENT  '发售方式',
  CUSTODYMARKET  DECIMAL(10,0)  COMMENT  '转托管市场',
  OPERATIONPERIOD  DECIMAL(9,2)  COMMENT  '运作期',
  OPERATIONPDUNITCODE  STRING  COMMENT  '运作期单位代码',
  OPERATIONPDUNITNAME  STRING  COMMENT  '运作期单位名称',
  IFINITIATINGFUND  DECIMAL(10,0)  COMMENT  '是否发起式基金',
  CLASSIFICATIONFUNDTYPE  DECIMAL(10,0)  COMMENT  '分级基金类别',
  AGRBENCHMKRATEOFSHAREA  STRING  COMMENT  'A份额约定年基准收益率表达式',
  AGRBENCHMKRATEOFSHAREANOTES  STRING  COMMENT  'A份额约定年基准收益率表达式备注',
  REGULARSHARECONVERSIONNOTES  STRING  COMMENT  '定期份额折算说明',
  NONREGULARSHARECONVERSIONNOTES  STRING  COMMENT  '不定期份额折算说明',
  EXAPPLYINGMARKET  DECIMAL(10,0)  COMMENT  '场内申购赎回场所',
  EXAPPLYINGCODE  STRING  COMMENT  '场内申购赎回代码',
  EXAPPLYINGABBR  STRING  COMMENT  '场内申购赎回简称',
  SHAREPROPERTIES  DECIMAL(10,0)  COMMENT  '份额属性',
  STCLEARINGDATE  STRING  COMMENT  '清算起始日',
  ENCLEARINGDATE  STRING  COMMENT  '清算截止日',
  LOWESTSUMSUBLL  DECIMAL(19,4)  COMMENT  '最低认购金额下限(元)',
  LOWESTSUMPURLL  DECIMAL(19,4)  COMMENT  '最低申购金额下限(元)',
  MAINCODE  STRING  COMMENT  '基金主代码',
  EXPROFITDISTRI  DECIMAL(10,0)  COMMENT  '场内收益分配方式',
  OTCPROFITDISTRI  DECIMAL(10,0)  COMMENT  '场外收益分配方式',
  IFFOF  DECIMAL(10,0)  COMMENT  '是否FOF',
  IFPENSIONTARGET  DECIMAL(10,0)  COMMENT  '是否养老目标基金',
  PRCONFIRMATIONDATE  DECIMAL(10,0)  COMMENT  '申赎确认日',
  ESTABLISHMENTDATEII  STRING  COMMENT  '转型前设立日期',
  INSERTTIME  STRING  COMMENT  '插入时间',
  TRANSCODE  STRING  COMMENT  '基金转型统一编码',
  LARGEREDEMPTIONRATIO  DECIMAL(19,6)  COMMENT  '巨额赎回认定比例',
  LASTOPERATIONDATE  STRING  COMMENT  '最后运作日'
)
COMMENT '基金概况'
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
                                   , ESTABLISHMENTDATE
                                   , LISTEDDATE
                                   , DURATION
                                   , STARTDATE
                                   , EXPIREDATE
                                   , MANAGER
                                   , INVESTADVISORCODE
                                   , TRUSTEECODE
                                   , WARRANTOR
                                   , \"TYPE\"
                                   , INVESTMENTTYPE
                                   , INVESTSTYLE
                                   , FOUNDEDSIZE
                                   , INVESTORIENTATION
                                   , INVESTTARGET
                                   , PERFORMANCEBENCHMARK
                                   , PROFITDISTRIBUTIONRULE
                                   , INVESTFIELD
                                   , BRIEFINTRO
                                   , XGRQ
                                   , JSID
                                   , APPLYINGCODEFRONT
                                   , APPLYINGCODEBACK
                                   , GUARANTEEDPERIOD
                                   , RISKRETURNCHARACTER
                                   , LOWESTSUMSUBSCRIBING
                                   , LOWESTSUMREDEMPTION
                                   , LSFRDESCRIPTION
                                   , LOWESTSUMFORHOLDING
                                   , LSFHDESCRIPTION
                                   , FUNDNATURE
                                   , FUNDTYPECODE
                                   , FUNDTYPE
                                   , CARRYOVERDATE
                                   , CARRYOVERDATEREMARK
                                   , CARRYOVERTYPE
                                   , REGINSTCODE
                                   , SECURITYCODE
                                   , DELIVERYDAYS
                                   , RISKRETURNCODE
                                   , FLOATTYPE
                                   , CUSTODYMARKET
                                   , OPERATIONPERIOD
                                   , OPERATIONPDUNITCODE
                                   , OPERATIONPDUNITNAME
                                   , IFINITIATINGFUND
                                   , CLASSIFICATIONFUNDTYPE
                                   , AGRBENCHMKRATEOFSHAREA
                                   , AGRBENCHMKRATEOFSHAREANOTES
                                   , REGULARSHARECONVERSIONNOTES
                                   , NONREGULARSHARECONVERSIONNOTES
                                   , EXAPPLYINGMARKET
                                   , EXAPPLYINGCODE
                                   , EXAPPLYINGABBR
                                   , SHAREPROPERTIES
                                   , STCLEARINGDATE
                                   , ENCLEARINGDATE
                                   , LOWESTSUMSUBLL
                                   , LOWESTSUMPURLL
                                   , MAINCODE
                                   , EXPROFITDISTRI
                                   , OTCPROFITDISTRI
                                   , IFFOF
                                   , IFPENSIONTARGET
                                   , PRCONFIRMATIONDATE
                                   , ESTABLISHMENTDATEII
                                   , INSERTTIME
                                   , TRANSCODE
                                   , LARGEREDEMPTIONRATIO
                                   , LASTOPERATIONDATE
                                FROM ${jy_src_schema}.MF_FUNDARCHIVES"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "ESTABLISHMENTDATE", "type": "STRING"}, {"name": "LISTEDDATE", "type": "STRING"}, {"name": "DURATION", "type": "DOUBLE"}, {"name": "STARTDATE", "type": "STRING"}, {"name": "EXPIREDATE", "type": "STRING"}, {"name": "MANAGER", "type": "STRING"}, {"name": "INVESTADVISORCODE", "type": "DOUBLE"}, {"name": "TRUSTEECODE", "type": "DOUBLE"}, {"name": "WARRANTOR", "type": "STRING"}, {"name": "TYPE", "type": "DOUBLE"}, {"name": "INVESTMENTTYPE", "type": "DOUBLE"}, {"name": "INVESTSTYLE", "type": "DOUBLE"}, {"name": "FOUNDEDSIZE", "type": "DOUBLE"}, {"name": "INVESTORIENTATION", "type": "STRING"}, {"name": "INVESTTARGET", "type": "STRING"}, {"name": "PERFORMANCEBENCHMARK", "type": "STRING"}, {"name": "PROFITDISTRIBUTIONRULE", "type": "STRING"}, {"name": "INVESTFIELD", "type": "STRING"}, {"name": "BRIEFINTRO", "type": "STRING"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "APPLYINGCODEFRONT", "type": "STRING"}, {"name": "APPLYINGCODEBACK", "type": "STRING"}, {"name": "GUARANTEEDPERIOD", "type": "DOUBLE"}, {"name": "RISKRETURNCHARACTER", "type": "STRING"}, {"name": "LOWESTSUMSUBSCRIBING", "type": "STRING"}, {"name": "LOWESTSUMREDEMPTION", "type": "DOUBLE"}, {"name": "LSFRDESCRIPTION", "type": "STRING"}, {"name": "LOWESTSUMFORHOLDING", "type": "DOUBLE"}, {"name": "LSFHDESCRIPTION", "type": "STRING"}, {"name": "FUNDNATURE", "type": "DOUBLE"}, {"name": "FUNDTYPECODE", "type": "DOUBLE"}, {"name": "FUNDTYPE", "type": "STRING"}, {"name": "CARRYOVERDATE", "type": "DOUBLE"}, {"name": "CARRYOVERDATEREMARK", "type": "STRING"}, {"name": "CARRYOVERTYPE", "type": "DOUBLE"}, {"name": "REGINSTCODE", "type": "DOUBLE"}, {"name": "SECURITYCODE", "type": "STRING"}, {"name": "DELIVERYDAYS", "type": "DOUBLE"}, {"name": "RISKRETURNCODE", "type": "DOUBLE"}, {"name": "FLOATTYPE", "type": "DOUBLE"}, {"name": "CUSTODYMARKET", "type": "DOUBLE"}, {"name": "OPERATIONPERIOD", "type": "DOUBLE"}, {"name": "OPERATIONPDUNITCODE", "type": "DOUBLE"}, {"name": "OPERATIONPDUNITNAME", "type": "STRING"}, {"name": "IFINITIATINGFUND", "type": "DOUBLE"}, {"name": "CLASSIFICATIONFUNDTYPE", "type": "DOUBLE"}, {"name": "AGRBENCHMKRATEOFSHAREA", "type": "STRING"}, {"name": "AGRBENCHMKRATEOFSHAREANOTES", "type": "STRING"}, {"name": "REGULARSHARECONVERSIONNOTES", "type": "STRING"}, {"name": "NONREGULARSHARECONVERSIONNOTES", "type": "STRING"}, {"name": "EXAPPLYINGMARKET", "type": "DOUBLE"}, {"name": "EXAPPLYINGCODE", "type": "STRING"}, {"name": "EXAPPLYINGABBR", "type": "STRING"}, {"name": "SHAREPROPERTIES", "type": "DOUBLE"}, {"name": "STCLEARINGDATE", "type": "STRING"}, {"name": "ENCLEARINGDATE", "type": "STRING"}, {"name": "LOWESTSUMSUBLL", "type": "DOUBLE"}, {"name": "LOWESTSUMPURLL", "type": "DOUBLE"}, {"name": "MAINCODE", "type": "STRING"}, {"name": "EXPROFITDISTRI", "type": "DOUBLE"}, {"name": "OTCPROFITDISTRI", "type": "DOUBLE"}, {"name": "IFFOF", "type": "DOUBLE"}, {"name": "IFPENSIONTARGET", "type": "DOUBLE"}, {"name": "PRCONFIRMATIONDATE", "type": "DOUBLE"}, {"name": "ESTABLISHMENTDATEII", "type": "STRING"}, {"name": "INSERTTIME", "type": "STRING"}, {"name": "TRANSCODE", "type": "DOUBLE"}, {"name": "LARGEREDEMPTIONRATIO", "type": "DOUBLE"}, {"name": "LASTOPERATIONDATE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_mf_fundarchives_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_mf_fundarchives_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_mf_fundarchives_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_mf_fundarchives_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_MF_FUNDARCHIVES_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_MF_FUNDARCHIVES_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_mf_fundarchives_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_MF_FUNDARCHIVES_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , ESTABLISHMENTDATE
     , LISTEDDATE
     , DURATION
     , STARTDATE
     , EXPIREDATE
     , MANAGER
     , INVESTADVISORCODE
     , TRUSTEECODE
     , WARRANTOR
     , TYPE
     , INVESTMENTTYPE
     , INVESTSTYLE
     , FOUNDEDSIZE
     , INVESTORIENTATION
     , INVESTTARGET
     , PERFORMANCEBENCHMARK
     , PROFITDISTRIBUTIONRULE
     , INVESTFIELD
     , BRIEFINTRO
     , XGRQ
     , JSID
     , APPLYINGCODEFRONT
     , APPLYINGCODEBACK
     , GUARANTEEDPERIOD
     , RISKRETURNCHARACTER
     , LOWESTSUMSUBSCRIBING
     , LOWESTSUMREDEMPTION
     , LSFRDESCRIPTION
     , LOWESTSUMFORHOLDING
     , LSFHDESCRIPTION
     , FUNDNATURE
     , FUNDTYPECODE
     , FUNDTYPE
     , CARRYOVERDATE
     , CARRYOVERDATEREMARK
     , CARRYOVERTYPE
     , REGINSTCODE
     , SECURITYCODE
     , DELIVERYDAYS
     , RISKRETURNCODE
     , FLOATTYPE
     , CUSTODYMARKET
     , OPERATIONPERIOD
     , OPERATIONPDUNITCODE
     , OPERATIONPDUNITNAME
     , IFINITIATINGFUND
     , CLASSIFICATIONFUNDTYPE
     , AGRBENCHMKRATEOFSHAREA
     , AGRBENCHMKRATEOFSHAREANOTES
     , REGULARSHARECONVERSIONNOTES
     , NONREGULARSHARECONVERSIONNOTES
     , EXAPPLYINGMARKET
     , EXAPPLYINGCODE
     , EXAPPLYINGABBR
     , SHAREPROPERTIES
     , STCLEARINGDATE
     , ENCLEARINGDATE
     , LOWESTSUMSUBLL
     , LOWESTSUMPURLL
     , MAINCODE
     , EXPROFITDISTRI
     , OTCPROFITDISTRI
     , IFFOF
     , IFPENSIONTARGET
     , PRCONFIRMATIONDATE
     , ESTABLISHMENTDATEII
     , INSERTTIME
     , TRANSCODE
     , LARGEREDEMPTIONRATIO
     , LASTOPERATIONDATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_MF_FUNDARCHIVES_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_MF_FUNDARCHIVES_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_MF_FUNDARCHIVES_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_MF_FUNDARCHIVES_PFD成功"
      exit 0
   fi
fi
