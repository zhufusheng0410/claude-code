#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TOPERATOR_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TOPERATOR_PFD_TMP(
  L_OPERATOR_NO  STRING  COMMENT  '操作员代码',
  VC_OPERATOR_NAME  STRING  COMMENT  '姓名',
  VC_PASSWORD  STRING  COMMENT  '密码',
  VC_DOMAIN_NAME  STRING  COMMENT  '域用户名',
  VC_ADDRESS  STRING  COMMENT  '联系地址',
  VC_EMAIL  STRING  COMMENT  'e-mail',
  VC_TEL_NO  STRING  COMMENT  '电话',
  C_CARD_TYPE  STRING  COMMENT  '证件类别',
  VC_CARD_NO  STRING  COMMENT  '证件号码',
  C_PASSWORD_TYPE  STRING  COMMENT  '密码强度类型',
  L_MODI_PASSWORD  DECIMAL(8,0)  COMMENT  '最近密码修改日期',
  L_EXPIRE_DAYS  DECIMAL(3,0)  COMMENT  '密码有效天数',
  C_OPERATOR_STATUS  STRING  COMMENT  '操作员状态',
  VC_MANAGE_RIGHT  STRING  COMMENT  '*证券类别权限',
  L_REGISTER_DATE  DECIMAL(8,0)  COMMENT  '注册日期',
  L_CANCEL_DATE  DECIMAL(8,0)  COMMENT  '注销日期',
  C_FORCE_CHG_PASSWORD  STRING  COMMENT  '下次登录修改密码',
  VC_OPERATOR_NO  STRING  COMMENT  '#操作员编号',
  C_CONNECT_TYPE  STRING  COMMENT  '＃应用服务器连接方式',
  VC_BUSIN_CLASSES  STRING  COMMENT  '允许操作的业务分类',
  L_PASSWORD_MINLENGTH  DECIMAL(2,0)  COMMENT  '密码最小长度',
  L_LAST_LOGIN_DATE  DECIMAL(8,0)  COMMENT  '上次登录日期',
  C_STOCKCODE_TYPE  STRING  COMMENT  '使用的境外证券代码类型',
  VC_FAX  STRING  COMMENT  '传真',
  VC_STAMP  STRING  COMMENT  '签章文件名',
  L_FUND_VALIDITY  DECIMAL(8,0)  COMMENT  '开基经办有效日期',
  VC_PRE_STAMP  STRING  COMMENT  '预留签章',
  L_TRANSACTOR_NO  DECIMAL(8,0)  COMMENT  '开基经办人',
  C_REF_SHM  STRING  COMMENT  '刷新后台共享内存权限',
  VC_TELLER_CODE  STRING  COMMENT  '柜员号',
  C_LOGIN_TYPE  STRING  COMMENT  '登录类型',
  VC_FUND_DEF_RIGHTS  STRING  COMMENT  '基金默认权限',
  L_ORG_ID  DECIMAL(10,0)  COMMENT  '所属公司',
  C_COMBI_ASSET_RIGHTS  STRING  COMMENT  '基金组合权限',
  C_FIRST_LOGIN  STRING  COMMENT  '首次登录',
  VC_ADD_STOCKPOOL_RIGHTS  STRING  COMMENT  '增加股票池权限',
  VC_ADD_STOCKPOOL_TYPE  STRING  COMMENT  '增加股票池类型',
  L_DEPT_ID  DECIMAL(10,0)  COMMENT  '所属部门',
  C_ISADMIN  STRING  COMMENT  '人员属性',
  C_CARIGHTADDBYF  STRING  COMMENT  '赋予基金权限时同步赋予组合和资产单元权限',
  L_ORGANIZE_ID  STRING  COMMENT  '机构编号',
  VC_JJT_ACCOUNT  STRING  COMMENT  '',
  L_PASSWORDERRORNO  DECIMAL(2,0)  COMMENT  '密码错误次数',
  C_ALLOW_SENDINMSG  STRING  COMMENT  '是否允许发送内部信息',
  VC_STAYNO  STRING  COMMENT  '预留信息',
  VC_LASTLOGINMSG  STRING  COMMENT  '上次登录信息',
  L_MOULD_ID  DECIMAL(10,0)  COMMENT  '',
  VC_OPERAPTOR_POSTION  STRING  COMMENT  '操作员位置',
  C_CANMOBILEAPP  STRING  COMMENT  '是否有移动app权限',
  VC_LOGINSTATUS  STRING  COMMENT  '人员允许登陆的系统状态',
  C_ALLOW_DOWNFILE  STRING  COMMENT  '是否允许下载文件',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  C_ALLOW_FAIS  STRING  COMMENT  '是否对接fais终端',
  C_FLOW_MANAGER  STRING  COMMENT  '流向管理',
  VC_GMPASSWORD  STRING  COMMENT  '',
  C_REPORT_TERMINALINFO  STRING  COMMENT  '',
  L_FROZEN_TO_DATE  DECIMAL(8,0)  COMMENT  '冻结日期',
  L_FROZEN_TO_TIME  DECIMAL(8,0)  COMMENT  '冻结时间',
  VC_CA_STAMP  STRING  COMMENT  '',
  VC_OPERA_REMARK  STRING  COMMENT  '操作标记',
  VC_CASHFLOW_OPRIGHTS  STRING  COMMENT  '',
  L_FROZEN_DATE  DECIMAL(8,0)  COMMENT  '冻结日期'
)
COMMENT '操作员表'
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
              "querySql": ["SELECT  L_OPERATOR_NO
                                   , VC_OPERATOR_NAME
                                   , VC_PASSWORD
                                   , VC_DOMAIN_NAME
                                   , VC_ADDRESS
                                   , VC_EMAIL
                                   , VC_TEL_NO
                                   , C_CARD_TYPE
                                   , VC_CARD_NO
                                   , C_PASSWORD_TYPE
                                   , L_MODI_PASSWORD
                                   , L_EXPIRE_DAYS
                                   , C_OPERATOR_STATUS
                                   , VC_MANAGE_RIGHT
                                   , L_REGISTER_DATE
                                   , L_CANCEL_DATE
                                   , C_FORCE_CHG_PASSWORD
                                   , VC_OPERATOR_NO
                                   , C_CONNECT_TYPE
                                   , VC_BUSIN_CLASSES
                                   , L_PASSWORD_MINLENGTH
                                   , L_LAST_LOGIN_DATE
                                   , C_STOCKCODE_TYPE
                                   , VC_FAX
                                   , VC_STAMP
                                   , L_FUND_VALIDITY
                                   , VC_PRE_STAMP
                                   , L_TRANSACTOR_NO
                                   , C_REF_SHM
                                   , VC_TELLER_CODE
                                   , C_LOGIN_TYPE
                                   , VC_FUND_DEF_RIGHTS
                                   , L_ORG_ID
                                   , C_COMBI_ASSET_RIGHTS
                                   , C_FIRST_LOGIN
                                   , VC_ADD_STOCKPOOL_RIGHTS
                                   , VC_ADD_STOCKPOOL_TYPE
                                   , L_DEPT_ID
                                   , C_ISADMIN
                                   , C_CARIGHTADDBYF
                                   , L_ORGANIZE_ID
                                   , VC_JJT_ACCOUNT
                                   , L_PASSWORDERRORNO
                                   , C_ALLOW_SENDINMSG
                                   , VC_STAYNO
                                   , VC_LASTLOGINMSG
                                   , L_MOULD_ID
                                   , VC_OPERAPTOR_POSTION
                                   , C_CANMOBILEAPP
                                   , VC_LOGINSTATUS
                                   , C_ALLOW_DOWNFILE
                                   , VC_TIMESTAMP
                                   , C_ALLOW_FAIS
                                   , C_FLOW_MANAGER
                                   , VC_GMPASSWORD
                                   , C_REPORT_TERMINALINFO
                                   , L_FROZEN_TO_DATE
                                   , L_FROZEN_TO_TIME
                                   , VC_CA_STAMP
                                   , VC_OPERA_REMARK
                                   , VC_CASHFLOW_OPRIGHTS
                                   , L_FROZEN_DATE
                                FROM ${o32_src_schema}.TOPERATOR"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_OPERATOR_NO", "type": "DOUBLE"}, {"name": "VC_OPERATOR_NAME", "type": "STRING"}, {"name": "VC_PASSWORD", "type": "STRING"}, {"name": "VC_DOMAIN_NAME", "type": "STRING"}, {"name": "VC_ADDRESS", "type": "STRING"}, {"name": "VC_EMAIL", "type": "STRING"}, {"name": "VC_TEL_NO", "type": "STRING"}, {"name": "C_CARD_TYPE", "type": "STRING"}, {"name": "VC_CARD_NO", "type": "STRING"}, {"name": "C_PASSWORD_TYPE", "type": "STRING"}, {"name": "L_MODI_PASSWORD", "type": "DOUBLE"}, {"name": "L_EXPIRE_DAYS", "type": "DOUBLE"}, {"name": "C_OPERATOR_STATUS", "type": "STRING"}, {"name": "VC_MANAGE_RIGHT", "type": "STRING"}, {"name": "L_REGISTER_DATE", "type": "DOUBLE"}, {"name": "L_CANCEL_DATE", "type": "DOUBLE"}, {"name": "C_FORCE_CHG_PASSWORD", "type": "STRING"}, {"name": "VC_OPERATOR_NO", "type": "STRING"}, {"name": "C_CONNECT_TYPE", "type": "STRING"}, {"name": "VC_BUSIN_CLASSES", "type": "STRING"}, {"name": "L_PASSWORD_MINLENGTH", "type": "DOUBLE"}, {"name": "L_LAST_LOGIN_DATE", "type": "DOUBLE"}, {"name": "C_STOCKCODE_TYPE", "type": "STRING"}, {"name": "VC_FAX", "type": "STRING"}, {"name": "VC_STAMP", "type": "STRING"}, {"name": "L_FUND_VALIDITY", "type": "DOUBLE"}, {"name": "VC_PRE_STAMP", "type": "STRING"}, {"name": "L_TRANSACTOR_NO", "type": "DOUBLE"}, {"name": "C_REF_SHM", "type": "STRING"}, {"name": "VC_TELLER_CODE", "type": "STRING"}, {"name": "C_LOGIN_TYPE", "type": "STRING"}, {"name": "VC_FUND_DEF_RIGHTS", "type": "STRING"}, {"name": "L_ORG_ID", "type": "DOUBLE"}, {"name": "C_COMBI_ASSET_RIGHTS", "type": "STRING"}, {"name": "C_FIRST_LOGIN", "type": "STRING"}, {"name": "VC_ADD_STOCKPOOL_RIGHTS", "type": "STRING"}, {"name": "VC_ADD_STOCKPOOL_TYPE", "type": "STRING"}, {"name": "L_DEPT_ID", "type": "DOUBLE"}, {"name": "C_ISADMIN", "type": "STRING"}, {"name": "C_CARIGHTADDBYF", "type": "STRING"}, {"name": "L_ORGANIZE_ID", "type": "DOUBLE"}, {"name": "VC_JJT_ACCOUNT", "type": "STRING"}, {"name": "L_PASSWORDERRORNO", "type": "DOUBLE"}, {"name": "C_ALLOW_SENDINMSG", "type": "STRING"}, {"name": "VC_STAYNO", "type": "STRING"}, {"name": "VC_LASTLOGINMSG", "type": "STRING"}, {"name": "L_MOULD_ID", "type": "DOUBLE"}, {"name": "VC_OPERAPTOR_POSTION", "type": "STRING"}, {"name": "C_CANMOBILEAPP", "type": "STRING"}, {"name": "VC_LOGINSTATUS", "type": "STRING"}, {"name": "C_ALLOW_DOWNFILE", "type": "STRING"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "C_ALLOW_FAIS", "type": "STRING"}, {"name": "C_FLOW_MANAGER", "type": "STRING"}, {"name": "VC_GMPASSWORD", "type": "STRING"}, {"name": "C_REPORT_TERMINALINFO", "type": "STRING"}, {"name": "L_FROZEN_TO_DATE", "type": "DOUBLE"}, {"name": "L_FROZEN_TO_TIME", "type": "DOUBLE"}, {"name": "VC_CA_STAMP", "type": "STRING"}, {"name": "VC_OPERA_REMARK", "type": "STRING"}, {"name": "VC_CASHFLOW_OPRIGHTS", "type": "STRING"}, {"name": "L_FROZEN_DATE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_toperator_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_toperator_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_toperator_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_toperator_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TOPERATOR_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TOPERATOR_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_toperator_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TOPERATOR_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       L_OPERATOR_NO
     , VC_OPERATOR_NAME
     , VC_PASSWORD
     , VC_DOMAIN_NAME
     , VC_ADDRESS
     , VC_EMAIL
     , VC_TEL_NO
     , C_CARD_TYPE
     , VC_CARD_NO
     , C_PASSWORD_TYPE
     , L_MODI_PASSWORD
     , L_EXPIRE_DAYS
     , C_OPERATOR_STATUS
     , VC_MANAGE_RIGHT
     , L_REGISTER_DATE
     , L_CANCEL_DATE
     , C_FORCE_CHG_PASSWORD
     , VC_OPERATOR_NO
     , C_CONNECT_TYPE
     , VC_BUSIN_CLASSES
     , L_PASSWORD_MINLENGTH
     , L_LAST_LOGIN_DATE
     , C_STOCKCODE_TYPE
     , VC_FAX
     , VC_STAMP
     , L_FUND_VALIDITY
     , VC_PRE_STAMP
     , L_TRANSACTOR_NO
     , C_REF_SHM
     , VC_TELLER_CODE
     , C_LOGIN_TYPE
     , VC_FUND_DEF_RIGHTS
     , L_ORG_ID
     , C_COMBI_ASSET_RIGHTS
     , C_FIRST_LOGIN
     , VC_ADD_STOCKPOOL_RIGHTS
     , VC_ADD_STOCKPOOL_TYPE
     , L_DEPT_ID
     , C_ISADMIN
     , C_CARIGHTADDBYF
     , L_ORGANIZE_ID
     , VC_JJT_ACCOUNT
     , L_PASSWORDERRORNO
     , C_ALLOW_SENDINMSG
     , VC_STAYNO
     , VC_LASTLOGINMSG
     , L_MOULD_ID
     , VC_OPERAPTOR_POSTION
     , C_CANMOBILEAPP
     , VC_LOGINSTATUS
     , C_ALLOW_DOWNFILE
     , VC_TIMESTAMP
     , C_ALLOW_FAIS
     , C_FLOW_MANAGER
     , VC_GMPASSWORD
     , C_REPORT_TERMINALINFO
     , L_FROZEN_TO_DATE
     , L_FROZEN_TO_TIME
     , VC_CA_STAMP
     , VC_OPERA_REMARK
     , VC_CASHFLOW_OPRIGHTS
     , L_FROZEN_DATE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_O32.ODS_O32_TOPERATOR_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TOPERATOR_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TOPERATOR_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TOPERATOR_PFD成功"
      exit 0
   fi
fi
