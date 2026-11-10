#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_BOND_CALLPUTINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_BOND_CALLPUTINFO_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  MAINCODE  STRING  COMMENT  '基金主代码',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  OPTYPE  STRING  COMMENT  '行权类型',
  OPPROGRESS  DECIMAL(10,0)  COMMENT  '行权进程',
  OPREMARK  STRING  COMMENT  '权利描述',
  COMMOPAPPLSTDATE  STRING  COMMENT  '行权申请起始日',
  COMMOPAPPLEDDATE  STRING  COMMENT  '行权申请截止日',
  COMMOPTIONDATE  STRING  COMMENT  '行权操作日',
  COMMOPPRICE  DECIMAL(19,4)  COMMENT  '行权价格(含税，元/张)',
  COMMOPPRICETAXED  DECIMAL(19,4)  COMMENT  '行权价格(扣税，元/张)',
  IFINCLUDEINTEREST  DECIMAL(10,0)  COMMENT  '是否包含利息',
  INTEREST  DECIMAL(19,4)  COMMENT  '每百元面值本期利息额(元)(含税)',
  LEASTOPVOL  DECIMAL(19,4)  COMMENT  '最低操作金额(元)',
  IFOPTION  DECIMAL(10,0)  COMMENT  '是否行权',
  CALLORPUTVOL  DECIMAL(19,4)  COMMENT  '被赎回/回售金额(元)',
  ALLOCATINGCALLMONDAY  STRING  COMMENT  '行权后款项到账日',
  OUTSTANDINGBDVOL  DECIMAL(19,4)  COMMENT  '剩余债券金额(元)',
  RATEADDED  DECIMAL(9,4)  COMMENT  '债券剩余部分增加的票面利率(%)',
  UPDATETIME  STRING  COMMENT  '更新时间',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  EXPECTEDEXERCISEDATE  STRING  COMMENT  '权利可能行使日',
  OPTIONREASON  STRING  COMMENT  '行权原因说明',
  FRNREFEXTRAMARGINMAX  DECIMAL(9,6)  COMMENT  '计息额外利差最大值(%)',
  FRNREFEXTRAMARGINMIN  DECIMAL(9,6)  COMMENT  '计息额外利差最小值(%)',
  RECEIVERCODE  STRING  COMMENT  '转让对象企业编号',
  RECEIVERNAME  STRING  COMMENT  '接受股权质押方',
  CALLCODE  STRING  COMMENT  '回售/赎回代码',
  CALLNAME  STRING  COMMENT  '回售/赎回简称',
  COMMOPAPPLSTTIME  STRING  COMMENT  '行权申请受理开始时间',
  COMMOPAPPLEDTIME  STRING  COMMENT  '行权申请受理截止时间',
  OPTYPESECOND  STRING  COMMENT  '行权类型二级',
  CALLREGDATE  STRING  COMMENT  '赎回登记日',
  RESALESTTIME  STRING  COMMENT  '转售起始日',
  RESALEEDTIME  STRING  COMMENT  '转售截止日',
  ESTIMATERESALEVOL  DECIMAL(19,4)  COMMENT  '预计转售金额(元)',
  OPTIONMARK  STRING  COMMENT  '权利标识',
  REVOKESTARTDATE  STRING  COMMENT  '撤销起始日',
  REVOKEENDDATE  STRING  COMMENT  '撤销截止日',
  OFFERPLANSIZE  DECIMAL(19,8)  COMMENT  '计划收购规模(元)',
  LOCKUPDATE  STRING  COMMENT  '标的债券锁定申报截止日期',
  LOCKUPTIME  STRING  COMMENT  '标的债券锁定申报截止时间',
  PURCHASEMETHOD  DECIMAL(10,0)  COMMENT  '收购方式',
  OFFERPRICETYPE  DECIMAL(10,0)  COMMENT  '收购价格方式',
  OBJECTIONSTART  STRING  COMMENT  '要约收购异议提起期间起始',
  OBJECTIONEND  STRING  COMMENT  '要约收购异议提起期间截止',
  OFFERDECLAREVOL  DECIMAL(19,8)  COMMENT  '标的债券申报额(元)',
  OFFERSTATUS  DECIMAL(10,0)  COMMENT  '要约收购公告状态',
  OPBENCHMARK  DECIMAL(10,0)  COMMENT  '权利挂钩基准'
)
COMMENT '含权债回售赎回情况'
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
                                   , INFOPUBLDATE
                                   , OPTYPE
                                   , OPPROGRESS
                                   , OPREMARK
                                   , COMMOPAPPLSTDATE
                                   , COMMOPAPPLEDDATE
                                   , COMMOPTIONDATE
                                   , COMMOPPRICE
                                   , COMMOPPRICETAXED
                                   , IFINCLUDEINTEREST
                                   , INTEREST
                                   , LEASTOPVOL
                                   , IFOPTION
                                   , CALLORPUTVOL
                                   , ALLOCATINGCALLMONDAY
                                   , OUTSTANDINGBDVOL
                                   , RATEADDED
                                   , UPDATETIME
                                   , JSID
                                   , EXPECTEDEXERCISEDATE
                                   , OPTIONREASON
                                   , FRNREFEXTRAMARGINMAX
                                   , FRNREFEXTRAMARGINMIN
                                   , RECEIVERCODE
                                   , RECEIVERNAME
                                   , CALLCODE
                                   , CALLNAME
                                   , COMMOPAPPLSTTIME
                                   , COMMOPAPPLEDTIME
                                   , OPTYPESECOND
                                   , CALLREGDATE
                                   , RESALESTTIME
                                   , RESALEEDTIME
                                   , ESTIMATERESALEVOL
                                   , OPTIONMARK
                                   , REVOKESTARTDATE
                                   , REVOKEENDDATE
                                   , OFFERPLANSIZE
                                   , LOCKUPDATE
                                   , LOCKUPTIME
                                   , PURCHASEMETHOD
                                   , OFFERPRICETYPE
                                   , OBJECTIONSTART
                                   , OBJECTIONEND
                                   , OFFERDECLAREVOL
                                   , OFFERSTATUS
                                   , OPBENCHMARK
                                FROM ${jy_src_schema}.BOND_CALLPUTINFO"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "MAINCODE", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "OPTYPE", "type": "DOUBLE"}, {"name": "OPPROGRESS", "type": "DOUBLE"}, {"name": "OPREMARK", "type": "STRING"}, {"name": "COMMOPAPPLSTDATE", "type": "STRING"}, {"name": "COMMOPAPPLEDDATE", "type": "STRING"}, {"name": "COMMOPTIONDATE", "type": "STRING"}, {"name": "COMMOPPRICE", "type": "DOUBLE"}, {"name": "COMMOPPRICETAXED", "type": "DOUBLE"}, {"name": "IFINCLUDEINTEREST", "type": "DOUBLE"}, {"name": "INTEREST", "type": "DOUBLE"}, {"name": "LEASTOPVOL", "type": "DOUBLE"}, {"name": "IFOPTION", "type": "DOUBLE"}, {"name": "CALLORPUTVOL", "type": "DOUBLE"}, {"name": "ALLOCATINGCALLMONDAY", "type": "STRING"}, {"name": "OUTSTANDINGBDVOL", "type": "DOUBLE"}, {"name": "RATEADDED", "type": "DOUBLE"}, {"name": "UPDATETIME", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "EXPECTEDEXERCISEDATE", "type": "STRING"}, {"name": "OPTIONREASON", "type": "STRING"}, {"name": "FRNREFEXTRAMARGINMAX", "type": "DOUBLE"}, {"name": "FRNREFEXTRAMARGINMIN", "type": "DOUBLE"}, {"name": "RECEIVERCODE", "type": "DOUBLE"}, {"name": "RECEIVERNAME", "type": "STRING"}, {"name": "CALLCODE", "type": "STRING"}, {"name": "CALLNAME", "type": "STRING"}, {"name": "COMMOPAPPLSTTIME", "type": "STRING"}, {"name": "COMMOPAPPLEDTIME", "type": "STRING"}, {"name": "OPTYPESECOND", "type": "DOUBLE"}, {"name": "CALLREGDATE", "type": "STRING"}, {"name": "RESALESTTIME", "type": "STRING"}, {"name": "RESALEEDTIME", "type": "STRING"}, {"name": "ESTIMATERESALEVOL", "type": "DOUBLE"}, {"name": "OPTIONMARK", "type": "DOUBLE"}, {"name": "REVOKESTARTDATE", "type": "STRING"}, {"name": "REVOKEENDDATE", "type": "STRING"}, {"name": "OFFERPLANSIZE", "type": "DOUBLE"}, {"name": "LOCKUPDATE", "type": "STRING"}, {"name": "LOCKUPTIME", "type": "STRING"}, {"name": "PURCHASEMETHOD", "type": "DOUBLE"}, {"name": "OFFERPRICETYPE", "type": "DOUBLE"}, {"name": "OBJECTIONSTART", "type": "STRING"}, {"name": "OBJECTIONEND", "type": "STRING"}, {"name": "OFFERDECLAREVOL", "type": "DOUBLE"}, {"name": "OFFERSTATUS", "type": "DOUBLE"}, {"name": "OPBENCHMARK", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_bond_callputinfo_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_bond_callputinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_bond_callputinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_bond_callputinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_BOND_CALLPUTINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_BOND_CALLPUTINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_bond_callputinfo_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_BOND_CALLPUTINFO_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , MAINCODE
     , INFOPUBLDATE
     , OPTYPE
     , OPPROGRESS
     , OPREMARK
     , COMMOPAPPLSTDATE
     , COMMOPAPPLEDDATE
     , COMMOPTIONDATE
     , COMMOPPRICE
     , COMMOPPRICETAXED
     , IFINCLUDEINTEREST
     , INTEREST
     , LEASTOPVOL
     , IFOPTION
     , CALLORPUTVOL
     , ALLOCATINGCALLMONDAY
     , OUTSTANDINGBDVOL
     , RATEADDED
     , UPDATETIME
     , JSID
     , EXPECTEDEXERCISEDATE
     , OPTIONREASON
     , FRNREFEXTRAMARGINMAX
     , FRNREFEXTRAMARGINMIN
     , RECEIVERCODE
     , RECEIVERNAME
     , CALLCODE
     , CALLNAME
     , COMMOPAPPLSTTIME
     , COMMOPAPPLEDTIME
     , OPTYPESECOND
     , CALLREGDATE
     , RESALESTTIME
     , RESALEEDTIME
     , ESTIMATERESALEVOL
     , OPTIONMARK
     , REVOKESTARTDATE
     , REVOKEENDDATE
     , OFFERPLANSIZE
     , LOCKUPDATE
     , LOCKUPTIME
     , PURCHASEMETHOD
     , OFFERPRICETYPE
     , OBJECTIONSTART
     , OBJECTIONEND
     , OFFERDECLAREVOL
     , OFFERSTATUS
     , OPBENCHMARK
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_BOND_CALLPUTINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_BOND_CALLPUTINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_BOND_CALLPUTINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_BOND_CALLPUTINFO_PFD成功"
      exit 0
   fi
fi
