#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFTA.ODS_HSFTA_TAGENCYINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TAGENCYINFO_PFD_TMP(
  C_AGENCYNO  STRING  COMMENT  '销售商编号',
  C_AGENCYNAME  STRING  COMMENT  '销售商名称',
  C_FULLNAME  STRING  COMMENT  '销售商全称',
  C_AGNCYADDRESS  STRING  COMMENT  '总部地址',
  C_AGNCYZIPCODE  STRING  COMMENT  '邮政编码',
  C_AGNCYCONTACT  STRING  COMMENT  '销售商联系人',
  C_AGNCYPHONE  STRING  COMMENT  '销售商联系电话',
  C_AGNCYFAXNO  STRING  COMMENT  '销售商传真号码',
  C_AGNCYMAIL  STRING  COMMENT  '销售商Email',
  C_AGNCYBANKNO  STRING  COMMENT  '销售商银行代码',
  C_AGNCYBANKACCO  STRING  COMMENT  '销售商银行帐号',
  C_AGNCYBANKNAME  STRING  COMMENT  '银行户名',
  D_AGNCYREGDATE  STRING  COMMENT  '销售商登记日期',
  C_AGNCYSTATUS  STRING  COMMENT  '销售商状态',
  D_LASTDATE  STRING  COMMENT  '数据最后导入日期',
  C_AGENCYTYPE  STRING  COMMENT  '销售商类型',
  C_DETAIL  STRING  COMMENT  '是否有份额明细',
  C_RIGHT  STRING  COMMENT  '销售权限',
  C_ZDCODE  STRING  COMMENT  '中国证券登记中心代码',
  L_LIQUIDATEREDEEM  DECIMAL(10,0)  COMMENT  '赎回清算天数',
  L_LIQUIDATEALLOT  DECIMAL(10,0)  COMMENT  '申购清算天数',
  L_LIQUIDATEBONUS  DECIMAL(10,0)  COMMENT  '分红清算天数',
  L_LIQUIDATESUB  DECIMAL(10,0)  COMMENT  '认购计息天数',
  C_SHARETYPES  STRING  COMMENT  '支持份额分类',
  F_AGIO  DECIMAL(5,4)  COMMENT  '认购申购最大折扣',
  C_ZTGONESTEP  STRING  COMMENT  '支持单步转托管入',
  C_PREASSIGN  STRING  COMMENT  '账号预分配',
  L_CSERIALNO  DECIMAL(10,0)  COMMENT  '当前确认序号',
  C_COMPARETYPE  STRING  COMMENT  '对账方式',
  C_LIQUIDATETYPE  STRING  COMMENT  '认购款到账日期方式',
  C_MULTITRADEACCO  STRING  COMMENT  '是否支持多交易账号',
  C_IVERSION  STRING  COMMENT  '接口配置版本',
  C_IMODE  STRING  COMMENT  '接口模式',
  C_CHANGEONSTEP  STRING  COMMENT  '基金转换确认方式',
  F_OUTAGIO  DECIMAL(5,4)  COMMENT  '赎回转换最大折扣',
  F_AGIOHINT  DECIMAL(5,4)  COMMENT  '认购申购折扣异常',
  F_OUTAGIOHINT  DECIMAL(5,4)  COMMENT  '赎回转换折扣异常',
  C_ALLOTLIQTYPE  STRING  COMMENT  '申购资金交收方式',
  C_REDEEMLIQTYPE  STRING  COMMENT  '赎回资金交收方式',
  C_CENTERFLAG  STRING  COMMENT  '是否大集中',
  C_NETNO  STRING  COMMENT  '对应托管网点代码',
  C_LITTLEDEALTYPE  STRING  COMMENT  '小份额处理方式',
  C_OVERTIMEDEAL  STRING  COMMENT  '申请超时处理方式',
  D_LASTINPUTTIME  STRING  COMMENT  '最后导入时间',
  F_INTERESTRATE  DECIMAL(6,5)  COMMENT  '年利率',
  C_CLEARSITE  STRING  COMMENT  '中登清算点',
  C_ISDEAL  STRING  COMMENT  '是否已经登记过户处理',
  C_AGENCYENGLISHNAME  STRING  COMMENT  '销售商英文简称',
  L_FUNDACCONO  DECIMAL(10,0)  COMMENT  '当前基金帐号序列',
  C_RATIONFLAG  STRING  COMMENT  '定期定额上传协议',
  C_INTERESTTYPE  STRING  COMMENT  '利率类型',
  C_CLTINTERESTMODE  STRING  COMMENT  '',
  C_CALINTEREST  STRING  COMMENT  '赎回是否计息',
  D_SZLASTINPUTTIME  STRING  COMMENT  '',
  D_SZLASTDATE  STRING  COMMENT  '',
  C_REGMODIFYINFO  STRING  COMMENT  '账户登记是否修改客户资料',
  C_ISCROSSTACHG  STRING  COMMENT  '',
  C_EXPPARAMFILES  STRING  COMMENT  '导出参数文件(C1~C5)',
  C_FINALRATIOLIMITCUSTTYPE  STRING  COMMENT  '',
  C_ISRECEIVEBROADCAST  STRING  COMMENT  '',
  C_SHORTCFRDMPARTCFM  STRING  COMMENT  '短期理财违约赎回部分确认方式',
  C_ISDEPOSIT  STRING  COMMENT  '',
  D_DEPOSITAGCREQ  STRING  COMMENT  '',
  D_DEPOSITENDAGM  STRING  COMMENT  '',
  C_INDIVIDUALCANTOPEN  STRING  COMMENT  '',
  C_INSTITUTIONCANTOPEN  STRING  COMMENT  '',
  C_SCFRDMDEALTYPE  STRING  COMMENT  '短期理财基金赎回方式',
  C_ISCREDITREDEEM  STRING  COMMENT  '',
  C_FORMAT03  STRING  COMMENT  '',
  C_MANUALFAILINTEREST  STRING  COMMENT  '',
  C_MANUALFAILSEND  STRING  COMMENT  '',
  C_SPLITFLAG  STRING  COMMENT  '',
  C_TACODE  STRING  COMMENT  'TA代码',
  C_EXPORTBYNEWAPPOINT  STRING  COMMENT  '',
  C_SCFCOMPARETYPE  STRING  COMMENT  '短期理财明细对账方式',
  C_NEEDQUOTEFILE  STRING  COMMENT  '',
  D_IMPECNTRCTDATE  STRING  COMMENT  '',
  C_LIMITDAYRDMPARTCFM  STRING  COMMENT  '',
  C_MONEYFUNDT0LIQFRCRDM  STRING  COMMENT  '',
  C_MANAGERCODE  STRING  COMMENT  '',
  C_ISOTC  STRING  COMMENT  '是否OTC产品',
  C_THIRDPARTAGENCY  STRING  COMMENT  '',
  C_OPENCASHUNIONSTOCK  STRING  COMMENT  '',
  C_ACCODEALREALTIME  STRING  COMMENT  '',
  D_IMPSTOCKREQCFM  STRING  COMMENT  '',
  D_EXPSTOCKREQCFM  STRING  COMMENT  '',
  C_EXPRESTINCOME  STRING  COMMENT  '',
  F_EXPNEWINCOME  STRING  COMMENT  '',
  C_EXPCONFILEMODE  STRING  COMMENT  '',
  C_TRANSFERCLASSDEALTYPE  STRING  COMMENT  '',
  C_IMPECNTRCT  STRING  COMMENT  '导入电子合同',
  C_CONFIRMCANUSE  STRING  COMMENT  'T日确认的份额T+1日可用',
  C_SUPPORTESHARES  STRING  COMMENT  '现金宝转托管入处理',
  C_FROZENREALTIME  STRING  COMMENT  '',
  C_FEDJJDTALAUNCH  STRING  COMMENT  '份额冻结解冻由TA发起',
  D_HOLIDAYT0RDM  STRING  COMMENT  '',
  C_RDMNOSHAREDEALTYPE  STRING  COMMENT  '赎回确认可用份额不足处理方式',
  C_EXPZHENDDATE  STRING  COMMENT  '行情导出专户申赎预约截止日',
  C_EXPNATURALINCOME  STRING  COMMENT  '',
  C_ABCONFREQUESTNO  STRING  COMMENT  '',
  C_ABCONFDATE  STRING  COMMENT  '',
  C_ECNTRCTVERSION  STRING  COMMENT  '电子合同接口版本',
  C_TRADEACCODIFFNETNO  STRING  COMMENT  '',
  C_CANCELCHKTRADEACCO  STRING  COMMENT  '销户时检查交易账号是否登记',
  C_EXPFUNDDATETYPE  STRING  COMMENT  '',
  C_ISSTANDARD400  STRING  COMMENT  '',
  C_SUPPEARLYLIQUID  STRING  COMMENT  '',
  C_AGEREGION  STRING  COMMENT  '销售商所属国家地区',
  C_HKEXPTOTALNETVALUE  STRING  COMMENT  '',
  F_MINPCSRATIO  DECIMAL(6,5)  COMMENT  '',
  C_AGECREDITCODE  STRING  COMMENT  '销售机构社会信用代码',
  C_DELIVERYTYPE  STRING  COMMENT  '',
  C_CHECK098BALANCE  STRING  COMMENT  '',
  D_IMP098BALANCE  STRING  COMMENT  '',
  C_SHORTCYCLE26FILEEXPTYPE  STRING  COMMENT  '',
  C_OUTAGENCYNO  STRING  COMMENT  '',
  C_SYFILEEXPDETAILDATA  STRING  COMMENT  '',
  C_COMPFILETYPE  STRING  COMMENT  '',
  C_SCFALLOWRDMDATETYPE  STRING  COMMENT  '',
  C_OUTPUTFILEPATHDATETYPE  STRING  COMMENT  '',
  C_SUPPORTNEW400  STRING  COMMENT  '',
  C_SUPPORTR2  STRING  COMMENT  '',
  C_SALECHANNEL  STRING  COMMENT  '',
  C_CONFILEDISBATCHNO  STRING  COMMENT  '',
  C_EXPNEW400ADDFIELD  STRING  COMMENT  '',
  C_BOURSEIMPFLAG  STRING  COMMENT  '',
  C_SHRDETAILCOMP  STRING  COMMENT  '',
  C_COMPMODE  STRING  COMMENT  '',
  C_AMLLIMITTYPE  STRING  COMMENT  '',
  C_FIXEDFAREAGIO  STRING  COMMENT  '',
  C_EXPANTSFEEFILE  STRING  COMMENT  '',
  C_AGENCYORGANNO  STRING  COMMENT  '',
  C_UNGUARANTEEDDELIVERY  STRING  COMMENT  ''
)
COMMENT '销售商信息'
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
            "username": "${hsfta_username}",
            "password": "${hsfta_password}",
            "connection": [{
              "querySql": ["SELECT  C_AGENCYNO
                                   , C_AGENCYNAME
                                   , C_FULLNAME
                                   , C_AGNCYADDRESS
                                   , C_AGNCYZIPCODE
                                   , C_AGNCYCONTACT
                                   , C_AGNCYPHONE
                                   , C_AGNCYFAXNO
                                   , C_AGNCYMAIL
                                   , C_AGNCYBANKNO
                                   , C_AGNCYBANKACCO
                                   , C_AGNCYBANKNAME
                                   , D_AGNCYREGDATE
                                   , C_AGNCYSTATUS
                                   , D_LASTDATE
                                   , C_AGENCYTYPE
                                   , C_DETAIL
                                   , C_RIGHT
                                   , C_ZDCODE
                                   , L_LIQUIDATEREDEEM
                                   , L_LIQUIDATEALLOT
                                   , L_LIQUIDATEBONUS
                                   , L_LIQUIDATESUB
                                   , C_SHARETYPES
                                   , F_AGIO
                                   , C_ZTGONESTEP
                                   , C_PREASSIGN
                                   , L_CSERIALNO
                                   , C_COMPARETYPE
                                   , C_LIQUIDATETYPE
                                   , C_MULTITRADEACCO
                                   , C_IVERSION
                                   , C_IMODE
                                   , C_CHANGEONSTEP
                                   , F_OUTAGIO
                                   , F_AGIOHINT
                                   , F_OUTAGIOHINT
                                   , C_ALLOTLIQTYPE
                                   , C_REDEEMLIQTYPE
                                   , C_CENTERFLAG
                                   , C_NETNO
                                   , C_LITTLEDEALTYPE
                                   , C_OVERTIMEDEAL
                                   , D_LASTINPUTTIME
                                   , F_INTERESTRATE
                                   , C_CLEARSITE
                                   , C_ISDEAL
                                   , C_AGENCYENGLISHNAME
                                   , L_FUNDACCONO
                                   , C_RATIONFLAG
                                   , C_INTERESTTYPE
                                   , C_CLTINTERESTMODE
                                   , C_CALINTEREST
                                   , D_SZLASTINPUTTIME
                                   , D_SZLASTDATE
                                   , C_REGMODIFYINFO
                                   , C_ISCROSSTACHG
                                   , C_EXPPARAMFILES
                                   , C_FINALRATIOLIMITCUSTTYPE
                                   , C_ISRECEIVEBROADCAST
                                   , C_SHORTCFRDMPARTCFM
                                   , C_ISDEPOSIT
                                   , D_DEPOSITAGCREQ
                                   , D_DEPOSITENDAGM
                                   , C_INDIVIDUALCANTOPEN
                                   , C_INSTITUTIONCANTOPEN
                                   , C_SCFRDMDEALTYPE
                                   , C_ISCREDITREDEEM
                                   , C_FORMAT03
                                   , C_MANUALFAILINTEREST
                                   , C_MANUALFAILSEND
                                   , C_SPLITFLAG
                                   , C_TACODE
                                   , C_EXPORTBYNEWAPPOINT
                                   , C_SCFCOMPARETYPE
                                   , C_NEEDQUOTEFILE
                                   , D_IMPECNTRCTDATE
                                   , C_LIMITDAYRDMPARTCFM
                                   , C_MONEYFUNDT0LIQFRCRDM
                                   , C_MANAGERCODE
                                   , C_ISOTC
                                   , C_THIRDPARTAGENCY
                                   , C_OPENCASHUNIONSTOCK
                                   , C_ACCODEALREALTIME
                                   , D_IMPSTOCKREQCFM
                                   , D_EXPSTOCKREQCFM
                                   , C_EXPRESTINCOME
                                   , F_EXPNEWINCOME
                                   , C_EXPCONFILEMODE
                                   , C_TRANSFERCLASSDEALTYPE
                                   , C_IMPECNTRCT
                                   , C_CONFIRMCANUSE
                                   , C_SUPPORTESHARES
                                   , C_FROZENREALTIME
                                   , C_FEDJJDTALAUNCH
                                   , D_HOLIDAYT0RDM
                                   , C_RDMNOSHAREDEALTYPE
                                   , C_EXPZHENDDATE
                                   , C_EXPNATURALINCOME
                                   , C_ABCONFREQUESTNO
                                   , C_ABCONFDATE
                                   , C_ECNTRCTVERSION
                                   , C_TRADEACCODIFFNETNO
                                   , C_CANCELCHKTRADEACCO
                                   , C_EXPFUNDDATETYPE
                                   , C_ISSTANDARD400
                                   , C_SUPPEARLYLIQUID
                                   , C_AGEREGION
                                   , C_HKEXPTOTALNETVALUE
                                   , F_MINPCSRATIO
                                   , C_AGECREDITCODE
                                   , C_DELIVERYTYPE
                                   , C_CHECK098BALANCE
                                   , D_IMP098BALANCE
                                   , C_SHORTCYCLE26FILEEXPTYPE
                                   , C_OUTAGENCYNO
                                   , C_SYFILEEXPDETAILDATA
                                   , C_COMPFILETYPE
                                   , C_SCFALLOWRDMDATETYPE
                                   , C_OUTPUTFILEPATHDATETYPE
                                   , C_SUPPORTNEW400
                                   , C_SUPPORTR2
                                   , C_SALECHANNEL
                                   , C_CONFILEDISBATCHNO
                                   , C_EXPNEW400ADDFIELD
                                   , C_BOURSEIMPFLAG
                                   , C_SHRDETAILCOMP
                                   , C_COMPMODE
                                   , C_AMLLIMITTYPE
                                   , C_FIXEDFAREAGIO
                                   , C_EXPANTSFEEFILE
                                   , C_AGENCYORGANNO
                                   , C_UNGUARANTEEDDELIVERY
                                FROM ${hsfta_src_schema}.TAGENCYINFO"],
              "jdbcUrl": ["${hsfta_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "C_AGENCYNO", "type": "STRING"}, {"name": "C_AGENCYNAME", "type": "STRING"}, {"name": "C_FULLNAME", "type": "STRING"}, {"name": "C_AGNCYADDRESS", "type": "STRING"}, {"name": "C_AGNCYZIPCODE", "type": "STRING"}, {"name": "C_AGNCYCONTACT", "type": "STRING"}, {"name": "C_AGNCYPHONE", "type": "STRING"}, {"name": "C_AGNCYFAXNO", "type": "STRING"}, {"name": "C_AGNCYMAIL", "type": "STRING"}, {"name": "C_AGNCYBANKNO", "type": "STRING"}, {"name": "C_AGNCYBANKACCO", "type": "STRING"}, {"name": "C_AGNCYBANKNAME", "type": "STRING"}, {"name": "D_AGNCYREGDATE", "type": "STRING"}, {"name": "C_AGNCYSTATUS", "type": "STRING"}, {"name": "D_LASTDATE", "type": "STRING"}, {"name": "C_AGENCYTYPE", "type": "STRING"}, {"name": "C_DETAIL", "type": "STRING"}, {"name": "C_RIGHT", "type": "STRING"}, {"name": "C_ZDCODE", "type": "STRING"}, {"name": "L_LIQUIDATEREDEEM", "type": "DOUBLE"}, {"name": "L_LIQUIDATEALLOT", "type": "DOUBLE"}, {"name": "L_LIQUIDATEBONUS", "type": "DOUBLE"}, {"name": "L_LIQUIDATESUB", "type": "DOUBLE"}, {"name": "C_SHARETYPES", "type": "STRING"}, {"name": "F_AGIO", "type": "DOUBLE"}, {"name": "C_ZTGONESTEP", "type": "STRING"}, {"name": "C_PREASSIGN", "type": "STRING"}, {"name": "L_CSERIALNO", "type": "DOUBLE"}, {"name": "C_COMPARETYPE", "type": "STRING"}, {"name": "C_LIQUIDATETYPE", "type": "STRING"}, {"name": "C_MULTITRADEACCO", "type": "STRING"}, {"name": "C_IVERSION", "type": "STRING"}, {"name": "C_IMODE", "type": "STRING"}, {"name": "C_CHANGEONSTEP", "type": "STRING"}, {"name": "F_OUTAGIO", "type": "DOUBLE"}, {"name": "F_AGIOHINT", "type": "DOUBLE"}, {"name": "F_OUTAGIOHINT", "type": "DOUBLE"}, {"name": "C_ALLOTLIQTYPE", "type": "STRING"}, {"name": "C_REDEEMLIQTYPE", "type": "STRING"}, {"name": "C_CENTERFLAG", "type": "STRING"}, {"name": "C_NETNO", "type": "STRING"}, {"name": "C_LITTLEDEALTYPE", "type": "STRING"}, {"name": "C_OVERTIMEDEAL", "type": "STRING"}, {"name": "D_LASTINPUTTIME", "type": "STRING"}, {"name": "F_INTERESTRATE", "type": "DOUBLE"}, {"name": "C_CLEARSITE", "type": "STRING"}, {"name": "C_ISDEAL", "type": "STRING"}, {"name": "C_AGENCYENGLISHNAME", "type": "STRING"}, {"name": "L_FUNDACCONO", "type": "DOUBLE"}, {"name": "C_RATIONFLAG", "type": "STRING"}, {"name": "C_INTERESTTYPE", "type": "STRING"}, {"name": "C_CLTINTERESTMODE", "type": "STRING"}, {"name": "C_CALINTEREST", "type": "STRING"}, {"name": "D_SZLASTINPUTTIME", "type": "STRING"}, {"name": "D_SZLASTDATE", "type": "STRING"}, {"name": "C_REGMODIFYINFO", "type": "STRING"}, {"name": "C_ISCROSSTACHG", "type": "STRING"}, {"name": "C_EXPPARAMFILES", "type": "STRING"}, {"name": "C_FINALRATIOLIMITCUSTTYPE", "type": "STRING"}, {"name": "C_ISRECEIVEBROADCAST", "type": "STRING"}, {"name": "C_SHORTCFRDMPARTCFM", "type": "STRING"}, {"name": "C_ISDEPOSIT", "type": "STRING"}, {"name": "D_DEPOSITAGCREQ", "type": "STRING"}, {"name": "D_DEPOSITENDAGM", "type": "STRING"}, {"name": "C_INDIVIDUALCANTOPEN", "type": "STRING"}, {"name": "C_INSTITUTIONCANTOPEN", "type": "STRING"}, {"name": "C_SCFRDMDEALTYPE", "type": "STRING"}, {"name": "C_ISCREDITREDEEM", "type": "STRING"}, {"name": "C_FORMAT03", "type": "STRING"}, {"name": "C_MANUALFAILINTEREST", "type": "STRING"}, {"name": "C_MANUALFAILSEND", "type": "STRING"}, {"name": "C_SPLITFLAG", "type": "STRING"}, {"name": "C_TACODE", "type": "STRING"}, {"name": "C_EXPORTBYNEWAPPOINT", "type": "STRING"}, {"name": "C_SCFCOMPARETYPE", "type": "STRING"}, {"name": "C_NEEDQUOTEFILE", "type": "STRING"}, {"name": "D_IMPECNTRCTDATE", "type": "STRING"}, {"name": "C_LIMITDAYRDMPARTCFM", "type": "STRING"}, {"name": "C_MONEYFUNDT0LIQFRCRDM", "type": "STRING"}, {"name": "C_MANAGERCODE", "type": "STRING"}, {"name": "C_ISOTC", "type": "STRING"}, {"name": "C_THIRDPARTAGENCY", "type": "STRING"}, {"name": "C_OPENCASHUNIONSTOCK", "type": "STRING"}, {"name": "C_ACCODEALREALTIME", "type": "STRING"}, {"name": "D_IMPSTOCKREQCFM", "type": "STRING"}, {"name": "D_EXPSTOCKREQCFM", "type": "STRING"}, {"name": "C_EXPRESTINCOME", "type": "STRING"}, {"name": "F_EXPNEWINCOME", "type": "STRING"}, {"name": "C_EXPCONFILEMODE", "type": "STRING"}, {"name": "C_TRANSFERCLASSDEALTYPE", "type": "STRING"}, {"name": "C_IMPECNTRCT", "type": "STRING"}, {"name": "C_CONFIRMCANUSE", "type": "STRING"}, {"name": "C_SUPPORTESHARES", "type": "STRING"}, {"name": "C_FROZENREALTIME", "type": "STRING"}, {"name": "C_FEDJJDTALAUNCH", "type": "STRING"}, {"name": "D_HOLIDAYT0RDM", "type": "STRING"}, {"name": "C_RDMNOSHAREDEALTYPE", "type": "STRING"}, {"name": "C_EXPZHENDDATE", "type": "STRING"}, {"name": "C_EXPNATURALINCOME", "type": "STRING"}, {"name": "C_ABCONFREQUESTNO", "type": "STRING"}, {"name": "C_ABCONFDATE", "type": "STRING"}, {"name": "C_ECNTRCTVERSION", "type": "STRING"}, {"name": "C_TRADEACCODIFFNETNO", "type": "STRING"}, {"name": "C_CANCELCHKTRADEACCO", "type": "STRING"}, {"name": "C_EXPFUNDDATETYPE", "type": "STRING"}, {"name": "C_ISSTANDARD400", "type": "STRING"}, {"name": "C_SUPPEARLYLIQUID", "type": "STRING"}, {"name": "C_AGEREGION", "type": "STRING"}, {"name": "C_HKEXPTOTALNETVALUE", "type": "STRING"}, {"name": "F_MINPCSRATIO", "type": "DOUBLE"}, {"name": "C_AGECREDITCODE", "type": "STRING"}, {"name": "C_DELIVERYTYPE", "type": "STRING"}, {"name": "C_CHECK098BALANCE", "type": "STRING"}, {"name": "D_IMP098BALANCE", "type": "STRING"}, {"name": "C_SHORTCYCLE26FILEEXPTYPE", "type": "STRING"}, {"name": "C_OUTAGENCYNO", "type": "STRING"}, {"name": "C_SYFILEEXPDETAILDATA", "type": "STRING"}, {"name": "C_COMPFILETYPE", "type": "STRING"}, {"name": "C_SCFALLOWRDMDATETYPE", "type": "STRING"}, {"name": "C_OUTPUTFILEPATHDATETYPE", "type": "STRING"}, {"name": "C_SUPPORTNEW400", "type": "STRING"}, {"name": "C_SUPPORTR2", "type": "STRING"}, {"name": "C_SALECHANNEL", "type": "STRING"}, {"name": "C_CONFILEDISBATCHNO", "type": "STRING"}, {"name": "C_EXPNEW400ADDFIELD", "type": "STRING"}, {"name": "C_BOURSEIMPFLAG", "type": "STRING"}, {"name": "C_SHRDETAILCOMP", "type": "STRING"}, {"name": "C_COMPMODE", "type": "STRING"}, {"name": "C_AMLLIMITTYPE", "type": "STRING"}, {"name": "C_FIXEDFAREAGIO", "type": "STRING"}, {"name": "C_EXPANTSFEEFILE", "type": "STRING"}, {"name": "C_AGENCYORGANNO", "type": "STRING"}, {"name": "C_UNGUARANTEEDDELIVERY", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfta_tagencyinfo_pfd_tmp",
            "fileType": "text",
            "path": "${hsfta_path}/ods_hsfta_tagencyinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfta_tagencyinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfta_tagencyinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFTA_TAGENCYINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFTA_TAGENCYINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfta_tagencyinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TAGENCYINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       C_AGENCYNO
     , C_AGENCYNAME
     , C_FULLNAME
     , C_AGNCYADDRESS
     , C_AGNCYZIPCODE
     , C_AGNCYCONTACT
     , C_AGNCYPHONE
     , C_AGNCYFAXNO
     , C_AGNCYMAIL
     , C_AGNCYBANKNO
     , C_AGNCYBANKACCO
     , C_AGNCYBANKNAME
     , D_AGNCYREGDATE
     , C_AGNCYSTATUS
     , D_LASTDATE
     , C_AGENCYTYPE
     , C_DETAIL
     , C_RIGHT
     , C_ZDCODE
     , L_LIQUIDATEREDEEM
     , L_LIQUIDATEALLOT
     , L_LIQUIDATEBONUS
     , L_LIQUIDATESUB
     , C_SHARETYPES
     , F_AGIO
     , C_ZTGONESTEP
     , C_PREASSIGN
     , L_CSERIALNO
     , C_COMPARETYPE
     , C_LIQUIDATETYPE
     , C_MULTITRADEACCO
     , C_IVERSION
     , C_IMODE
     , C_CHANGEONSTEP
     , F_OUTAGIO
     , F_AGIOHINT
     , F_OUTAGIOHINT
     , C_ALLOTLIQTYPE
     , C_REDEEMLIQTYPE
     , C_CENTERFLAG
     , C_NETNO
     , C_LITTLEDEALTYPE
     , C_OVERTIMEDEAL
     , D_LASTINPUTTIME
     , F_INTERESTRATE
     , C_CLEARSITE
     , C_ISDEAL
     , C_AGENCYENGLISHNAME
     , L_FUNDACCONO
     , C_RATIONFLAG
     , C_INTERESTTYPE
     , C_CLTINTERESTMODE
     , C_CALINTEREST
     , D_SZLASTINPUTTIME
     , D_SZLASTDATE
     , C_REGMODIFYINFO
     , C_ISCROSSTACHG
     , C_EXPPARAMFILES
     , C_FINALRATIOLIMITCUSTTYPE
     , C_ISRECEIVEBROADCAST
     , C_SHORTCFRDMPARTCFM
     , C_ISDEPOSIT
     , D_DEPOSITAGCREQ
     , D_DEPOSITENDAGM
     , C_INDIVIDUALCANTOPEN
     , C_INSTITUTIONCANTOPEN
     , C_SCFRDMDEALTYPE
     , C_ISCREDITREDEEM
     , C_FORMAT03
     , C_MANUALFAILINTEREST
     , C_MANUALFAILSEND
     , C_SPLITFLAG
     , C_TACODE
     , C_EXPORTBYNEWAPPOINT
     , C_SCFCOMPARETYPE
     , C_NEEDQUOTEFILE
     , D_IMPECNTRCTDATE
     , C_LIMITDAYRDMPARTCFM
     , C_MONEYFUNDT0LIQFRCRDM
     , C_MANAGERCODE
     , C_ISOTC
     , C_THIRDPARTAGENCY
     , C_OPENCASHUNIONSTOCK
     , C_ACCODEALREALTIME
     , D_IMPSTOCKREQCFM
     , D_EXPSTOCKREQCFM
     , C_EXPRESTINCOME
     , F_EXPNEWINCOME
     , C_EXPCONFILEMODE
     , C_TRANSFERCLASSDEALTYPE
     , C_IMPECNTRCT
     , C_CONFIRMCANUSE
     , C_SUPPORTESHARES
     , C_FROZENREALTIME
     , C_FEDJJDTALAUNCH
     , D_HOLIDAYT0RDM
     , C_RDMNOSHAREDEALTYPE
     , C_EXPZHENDDATE
     , C_EXPNATURALINCOME
     , C_ABCONFREQUESTNO
     , C_ABCONFDATE
     , C_ECNTRCTVERSION
     , C_TRADEACCODIFFNETNO
     , C_CANCELCHKTRADEACCO
     , C_EXPFUNDDATETYPE
     , C_ISSTANDARD400
     , C_SUPPEARLYLIQUID
     , C_AGEREGION
     , C_HKEXPTOTALNETVALUE
     , F_MINPCSRATIO
     , C_AGECREDITCODE
     , C_DELIVERYTYPE
     , C_CHECK098BALANCE
     , D_IMP098BALANCE
     , C_SHORTCYCLE26FILEEXPTYPE
     , C_OUTAGENCYNO
     , C_SYFILEEXPDETAILDATA
     , C_COMPFILETYPE
     , C_SCFALLOWRDMDATETYPE
     , C_OUTPUTFILEPATHDATETYPE
     , C_SUPPORTNEW400
     , C_SUPPORTR2
     , C_SALECHANNEL
     , C_CONFILEDISBATCHNO
     , C_EXPNEW400ADDFIELD
     , C_BOURSEIMPFLAG
     , C_SHRDETAILCOMP
     , C_COMPMODE
     , C_AMLLIMITTYPE
     , C_FIXEDFAREAGIO
     , C_EXPANTSFEEFILE
     , C_AGENCYORGANNO
     , C_UNGUARANTEEDDELIVERY
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_HSFTA.ODS_HSFTA_TAGENCYINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFTA.ODS_HSFTA_TAGENCYINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFTA_TAGENCYINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_HSFTA_TAGENCYINFO_PFD成功"
      exit 0
   fi
fi
