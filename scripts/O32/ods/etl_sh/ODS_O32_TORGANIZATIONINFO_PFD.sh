#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TORGANIZATIONINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TORGANIZATIONINFO_PFD_TMP(
  L_ORG_ID  DECIMAL(10,0)  COMMENT  '公司序号',
  VC_ORG_CODE  STRING  COMMENT  '公司代码',
  VC_ORG_NAME  STRING  COMMENT  '公司名称',
  VC_ORG_SHORTNAME  STRING  COMMENT  '公司简称',
  VC_ORG_TYPE  STRING  COMMENT  '公司类型',
  VC_ORG_ADDRESS  STRING  COMMENT  '公司地址',
  VC_CONTACTS_NAME1  STRING  COMMENT  '联系人名字1',
  VC_CELLPHONE1  STRING  COMMENT  '联系人手机1',
  VC_PHONE1  STRING  COMMENT  '联系人电话1',
  VC_EMAIL1  STRING  COMMENT  '联系人电子邮件1',
  VC_QQ1  STRING  COMMENT  '联系人qq1',
  VC_CONTACTS_NAME2  STRING  COMMENT  '联系人名字2',
  VC_CELLPHONE2  STRING  COMMENT  '联系人手机2',
  VC_PHONE2  STRING  COMMENT  '联系人电话2',
  VC_EMAIL2  STRING  COMMENT  '联系人电子邮件2',
  VC_QQ2  STRING  COMMENT  '联系人qq2',
  C_STATUS  STRING  COMMENT  '状态',
  L_RC_CONNECT_COUNT  DECIMAL(10,0)  COMMENT  '远程客户端最大连接数',
  L_UFX_CONNECT_COUNT  DECIMAL(10,0)  COMMENT  'ufx接口最大连接数',
  VC_REMARKS  STRING  COMMENT  '备注',
  VC_INVEST_TYPES  STRING  COMMENT  '允许的投资类型',
  VC_BUSIN_CLASSES  STRING  COMMENT  '允许操作的业务分类',
  VC_STOCKTYPE_RIGHT  STRING  COMMENT  '证券类别权限',
  VC_ENTRDIRE_RIGHT  STRING  COMMENT  '允许操作的委托方向',
  VC_PERMIT_MARKET  STRING  COMMENT  '允许操作的交易市场',
  VC_FUTURES_INVEST_TYPES  STRING  COMMENT  '允许的期货投资类型',
  L_HOMES_CONNECT_COUNT  DECIMAL(10,0)  COMMENT  '',
  L_ENTRUST_PUR_SECONDS  DECIMAL(10,0)  COMMENT  '每分钟委托数',
  L_QUERY_PUR_SECONDS  DECIMAL(10,0)  COMMENT  '每分钟查询数',
  L_TOTAL_ENTRUST_DAILY  DECIMAL(10,0)  COMMENT  '单日总委托笔数',
  VC_KJ_CUSTOMER_ACCO  STRING  COMMENT  '',
  VC_KJ_PASSWORD  STRING  COMMENT  '',
  C_APPROVE_TYPE  STRING  COMMENT  '审批方式',
  L_REGISTER_DATE  DECIMAL(8,0)  COMMENT  '注册日期',
  L_CANCEL_DATE  DECIMAL(8,0)  COMMENT  '注销日期',
  L_MOULD_ID  DECIMAL(10,0)  COMMENT  '',
  C_USE_IP_CONTROL  STRING  COMMENT  '',
  VC_TRADE_CODE  STRING  COMMENT  '交易商代码',
  VC_TRADE_NAME  STRING  COMMENT  '交易商名称',
  VC_FISPINVESTMANAGER_CODE  STRING  COMMENT  'fisp投管人代码',
  C_FISPINDORINS  STRING  COMMENT  'fisp个人/机构标志',
  C_FISPCERTIFICATE_TYPE  STRING  COMMENT  'fisp证件类型',
  VC_FISPCERTIFICATE_NO  STRING  COMMENT  'fisp证件号码',
  L_FISPCERTVALID_DATE  DECIMAL(8,0)  COMMENT  'fisp证件有效日期',
  VC_INSTREPRID_TYPE  STRING  COMMENT  '法人代表身份证件类型',
  VC_INSTREPRID_CODE  STRING  COMMENT  '法人代表身份证件代码',
  VC_INSTREPR_NAME  STRING  COMMENT  '法人代表姓名',
  L_IR_CERTVALID_DATE  DECIMAL(8,0)  COMMENT  '法人证件有效期',
  C_TRADE_SERVICE  STRING  COMMENT  '交易服务提供标识',
  VC_STORMCOMPANY_IDS  STRING  COMMENT  '',
  VC_STRATEGY_NAME  STRING  COMMENT  '策略名',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  L_VIRTUAL_KEY  DECIMAL(16,0)  COMMENT  '虚拟主键',
  C_CLIENTRISKRATE  STRING  COMMENT  '客户风险等级',
  VC_ENTERPRISEPROP  STRING  COMMENT  '企业性质反洗钱信息',
  VC_BUSINESSTYPE  STRING  COMMENT  '行业类型反洗钱信息',
  EN_ENROLLEDCAPITCAL  DECIMAL(16,2)  COMMENT  '注册资本万元（反洗钱信息）',
  VC_ORGNO  STRING  COMMENT  '组织机构代码反洗钱信息',
  L_ORGNOVALIDDATE  STRING  COMMENT  '组织代码证有效期反洗钱信息',
  VC_TAXNO  STRING  COMMENT  '税务登记证号码反洗钱信息',
  VC_CONTROLHOLDER  STRING  COMMENT  '控股股东反洗钱信息',
  C_CONHOLDERTYPE  STRING  COMMENT  '控股股东类别反洗钱信息',
  C_CONHOLDERCERTTYPE  STRING  COMMENT  '控股股东证件',
  VC_CONHOLDERCERTNO  STRING  COMMENT  '控股股东证件号码反洗钱信息',
  L_CONHOLDERCERTVALIDDATE  DECIMAL(8,0)  COMMENT  '控股股东证件有效期反洗钱信息',
  VC_CONHOLDERTAXNO  STRING  COMMENT  '控股股东税务登记证号码反洗钱信息',
  VC_CONHOLDERORGNO  STRING  COMMENT  '控股股东组织代码证号码反洗钱信息',
  VC_ACTUALCONTROLLER  STRING  COMMENT  '',
  VC_ACTUALBENEFITER  STRING  COMMENT  '账户实际受益人反洗钱信息',
  VC_INSTREPRMANAGERANGE  STRING  COMMENT  '机构法人经营范围反洗钱信息',
  VC_ANTILAUNDMONEYSPE  STRING  COMMENT  '反洗钱备注反洗钱信息',
  L_QR_CONNECT_COUNT  DECIMAL(10,0)  COMMENT  '',
  VC_MEMBER_ID  STRING  COMMENT  ''
)
COMMENT '公司信息表'
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
              "querySql": ["SELECT  L_ORG_ID
                                   , VC_ORG_CODE
                                   , VC_ORG_NAME
                                   , VC_ORG_SHORTNAME
                                   , VC_ORG_TYPE
                                   , VC_ORG_ADDRESS
                                   , VC_CONTACTS_NAME1
                                   , VC_CELLPHONE1
                                   , VC_PHONE1
                                   , VC_EMAIL1
                                   , VC_QQ1
                                   , VC_CONTACTS_NAME2
                                   , VC_CELLPHONE2
                                   , VC_PHONE2
                                   , VC_EMAIL2
                                   , VC_QQ2
                                   , C_STATUS
                                   , L_RC_CONNECT_COUNT
                                   , L_UFX_CONNECT_COUNT
                                   , VC_REMARKS
                                   , VC_INVEST_TYPES
                                   , VC_BUSIN_CLASSES
                                   , VC_STOCKTYPE_RIGHT
                                   , VC_ENTRDIRE_RIGHT
                                   , VC_PERMIT_MARKET
                                   , VC_FUTURES_INVEST_TYPES
                                   , L_HOMES_CONNECT_COUNT
                                   , L_ENTRUST_PUR_SECONDS
                                   , L_QUERY_PUR_SECONDS
                                   , L_TOTAL_ENTRUST_DAILY
                                   , VC_KJ_CUSTOMER_ACCO
                                   , VC_KJ_PASSWORD
                                   , C_APPROVE_TYPE
                                   , L_REGISTER_DATE
                                   , L_CANCEL_DATE
                                   , L_MOULD_ID
                                   , C_USE_IP_CONTROL
                                   , VC_TRADE_CODE
                                   , VC_TRADE_NAME
                                   , VC_FISPINVESTMANAGER_CODE
                                   , C_FISPINDORINS
                                   , C_FISPCERTIFICATE_TYPE
                                   , VC_FISPCERTIFICATE_NO
                                   , L_FISPCERTVALID_DATE
                                   , VC_INSTREPRID_TYPE
                                   , VC_INSTREPRID_CODE
                                   , VC_INSTREPR_NAME
                                   , L_IR_CERTVALID_DATE
                                   , C_TRADE_SERVICE
                                   , VC_STORMCOMPANY_IDS
                                   , VC_STRATEGY_NAME
                                   , VC_TIMESTAMP
                                   , L_VIRTUAL_KEY
                                   , C_CLIENTRISKRATE
                                   , VC_ENTERPRISEPROP
                                   , VC_BUSINESSTYPE
                                   , EN_ENROLLEDCAPITCAL
                                   , VC_ORGNO
                                   , L_ORGNOVALIDDATE
                                   , VC_TAXNO
                                   , VC_CONTROLHOLDER
                                   , C_CONHOLDERTYPE
                                   , C_CONHOLDERCERTTYPE
                                   , VC_CONHOLDERCERTNO
                                   , L_CONHOLDERCERTVALIDDATE
                                   , VC_CONHOLDERTAXNO
                                   , VC_CONHOLDERORGNO
                                   , VC_ACTUALCONTROLLER
                                   , VC_ACTUALBENEFITER
                                   , VC_INSTREPRMANAGERANGE
                                   , VC_ANTILAUNDMONEYSPE
                                   , L_QR_CONNECT_COUNT
                                   , VC_MEMBER_ID
                                FROM ${o32_src_schema}.TORGANIZATIONINFO"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_ORG_ID", "type": "DOUBLE"}, {"name": "VC_ORG_CODE", "type": "STRING"}, {"name": "VC_ORG_NAME", "type": "STRING"}, {"name": "VC_ORG_SHORTNAME", "type": "STRING"}, {"name": "VC_ORG_TYPE", "type": "STRING"}, {"name": "VC_ORG_ADDRESS", "type": "STRING"}, {"name": "VC_CONTACTS_NAME1", "type": "STRING"}, {"name": "VC_CELLPHONE1", "type": "STRING"}, {"name": "VC_PHONE1", "type": "STRING"}, {"name": "VC_EMAIL1", "type": "STRING"}, {"name": "VC_QQ1", "type": "STRING"}, {"name": "VC_CONTACTS_NAME2", "type": "STRING"}, {"name": "VC_CELLPHONE2", "type": "STRING"}, {"name": "VC_PHONE2", "type": "STRING"}, {"name": "VC_EMAIL2", "type": "STRING"}, {"name": "VC_QQ2", "type": "STRING"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "L_RC_CONNECT_COUNT", "type": "DOUBLE"}, {"name": "L_UFX_CONNECT_COUNT", "type": "DOUBLE"}, {"name": "VC_REMARKS", "type": "STRING"}, {"name": "VC_INVEST_TYPES", "type": "STRING"}, {"name": "VC_BUSIN_CLASSES", "type": "STRING"}, {"name": "VC_STOCKTYPE_RIGHT", "type": "STRING"}, {"name": "VC_ENTRDIRE_RIGHT", "type": "STRING"}, {"name": "VC_PERMIT_MARKET", "type": "STRING"}, {"name": "VC_FUTURES_INVEST_TYPES", "type": "STRING"}, {"name": "L_HOMES_CONNECT_COUNT", "type": "DOUBLE"}, {"name": "L_ENTRUST_PUR_SECONDS", "type": "DOUBLE"}, {"name": "L_QUERY_PUR_SECONDS", "type": "DOUBLE"}, {"name": "L_TOTAL_ENTRUST_DAILY", "type": "DOUBLE"}, {"name": "VC_KJ_CUSTOMER_ACCO", "type": "STRING"}, {"name": "VC_KJ_PASSWORD", "type": "STRING"}, {"name": "C_APPROVE_TYPE", "type": "STRING"}, {"name": "L_REGISTER_DATE", "type": "DOUBLE"}, {"name": "L_CANCEL_DATE", "type": "DOUBLE"}, {"name": "L_MOULD_ID", "type": "DOUBLE"}, {"name": "C_USE_IP_CONTROL", "type": "STRING"}, {"name": "VC_TRADE_CODE", "type": "STRING"}, {"name": "VC_TRADE_NAME", "type": "STRING"}, {"name": "VC_FISPINVESTMANAGER_CODE", "type": "STRING"}, {"name": "C_FISPINDORINS", "type": "STRING"}, {"name": "C_FISPCERTIFICATE_TYPE", "type": "STRING"}, {"name": "VC_FISPCERTIFICATE_NO", "type": "STRING"}, {"name": "L_FISPCERTVALID_DATE", "type": "DOUBLE"}, {"name": "VC_INSTREPRID_TYPE", "type": "STRING"}, {"name": "VC_INSTREPRID_CODE", "type": "STRING"}, {"name": "VC_INSTREPR_NAME", "type": "STRING"}, {"name": "L_IR_CERTVALID_DATE", "type": "DOUBLE"}, {"name": "C_TRADE_SERVICE", "type": "STRING"}, {"name": "VC_STORMCOMPANY_IDS", "type": "STRING"}, {"name": "VC_STRATEGY_NAME", "type": "STRING"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "L_VIRTUAL_KEY", "type": "DOUBLE"}, {"name": "C_CLIENTRISKRATE", "type": "STRING"}, {"name": "VC_ENTERPRISEPROP", "type": "STRING"}, {"name": "VC_BUSINESSTYPE", "type": "STRING"}, {"name": "EN_ENROLLEDCAPITCAL", "type": "DOUBLE"}, {"name": "VC_ORGNO", "type": "STRING"}, {"name": "L_ORGNOVALIDDATE", "type": "DOUBLE"}, {"name": "VC_TAXNO", "type": "STRING"}, {"name": "VC_CONTROLHOLDER", "type": "STRING"}, {"name": "C_CONHOLDERTYPE", "type": "STRING"}, {"name": "C_CONHOLDERCERTTYPE", "type": "STRING"}, {"name": "VC_CONHOLDERCERTNO", "type": "STRING"}, {"name": "L_CONHOLDERCERTVALIDDATE", "type": "DOUBLE"}, {"name": "VC_CONHOLDERTAXNO", "type": "STRING"}, {"name": "VC_CONHOLDERORGNO", "type": "STRING"}, {"name": "VC_ACTUALCONTROLLER", "type": "STRING"}, {"name": "VC_ACTUALBENEFITER", "type": "STRING"}, {"name": "VC_INSTREPRMANAGERANGE", "type": "STRING"}, {"name": "VC_ANTILAUNDMONEYSPE", "type": "STRING"}, {"name": "L_QR_CONNECT_COUNT", "type": "DOUBLE"}, {"name": "VC_MEMBER_ID", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_torganizationinfo_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_torganizationinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_torganizationinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_torganizationinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TORGANIZATIONINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TORGANIZATIONINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_torganizationinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TORGANIZATIONINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_ORG_ID
     , VC_ORG_CODE
     , VC_ORG_NAME
     , VC_ORG_SHORTNAME
     , VC_ORG_TYPE
     , VC_ORG_ADDRESS
     , VC_CONTACTS_NAME1
     , VC_CELLPHONE1
     , VC_PHONE1
     , VC_EMAIL1
     , VC_QQ1
     , VC_CONTACTS_NAME2
     , VC_CELLPHONE2
     , VC_PHONE2
     , VC_EMAIL2
     , VC_QQ2
     , C_STATUS
     , L_RC_CONNECT_COUNT
     , L_UFX_CONNECT_COUNT
     , VC_REMARKS
     , VC_INVEST_TYPES
     , VC_BUSIN_CLASSES
     , VC_STOCKTYPE_RIGHT
     , VC_ENTRDIRE_RIGHT
     , VC_PERMIT_MARKET
     , VC_FUTURES_INVEST_TYPES
     , L_HOMES_CONNECT_COUNT
     , L_ENTRUST_PUR_SECONDS
     , L_QUERY_PUR_SECONDS
     , L_TOTAL_ENTRUST_DAILY
     , VC_KJ_CUSTOMER_ACCO
     , VC_KJ_PASSWORD
     , C_APPROVE_TYPE
     , L_REGISTER_DATE
     , L_CANCEL_DATE
     , L_MOULD_ID
     , C_USE_IP_CONTROL
     , VC_TRADE_CODE
     , VC_TRADE_NAME
     , VC_FISPINVESTMANAGER_CODE
     , C_FISPINDORINS
     , C_FISPCERTIFICATE_TYPE
     , VC_FISPCERTIFICATE_NO
     , L_FISPCERTVALID_DATE
     , VC_INSTREPRID_TYPE
     , VC_INSTREPRID_CODE
     , VC_INSTREPR_NAME
     , L_IR_CERTVALID_DATE
     , C_TRADE_SERVICE
     , VC_STORMCOMPANY_IDS
     , VC_STRATEGY_NAME
     , VC_TIMESTAMP
     , L_VIRTUAL_KEY
     , C_CLIENTRISKRATE
     , VC_ENTERPRISEPROP
     , VC_BUSINESSTYPE
     , EN_ENROLLEDCAPITCAL
     , VC_ORGNO
     , L_ORGNOVALIDDATE
     , VC_TAXNO
     , VC_CONTROLHOLDER
     , C_CONHOLDERTYPE
     , C_CONHOLDERCERTTYPE
     , VC_CONHOLDERCERTNO
     , L_CONHOLDERCERTVALIDDATE
     , VC_CONHOLDERTAXNO
     , VC_CONHOLDERORGNO
     , VC_ACTUALCONTROLLER
     , VC_ACTUALBENEFITER
     , VC_INSTREPRMANAGERANGE
     , VC_ANTILAUNDMONEYSPE
     , L_QR_CONNECT_COUNT
     , VC_MEMBER_ID
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TORGANIZATIONINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TORGANIZATIONINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TORGANIZATIONINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TORGANIZATIONINFO_PFD成功"
      exit 0
   fi
fi
