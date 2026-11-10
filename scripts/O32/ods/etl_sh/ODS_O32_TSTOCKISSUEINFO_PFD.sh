#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TSTOCKISSUEINFO_PFD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TSTOCKISSUEINFO_PFD_TMP(
  VC_INTER_CODE  STRING  COMMENT  '证券内码',
  EN_EARNEST_RATIO  DECIMAL(5,4)  COMMENT  '定金比例',
  EN_LOWER_PRICE  DECIMAL(20,8)  COMMENT  '价格下限',
  EN_UPPER_PRICE  DECIMAL(20,8)  COMMENT  '价格上限',
  VC_ISSUE_TERM  STRING  COMMENT  '发行时间区间',
  L_PAY_LIMIT_DATE  DECIMAL(8,0)  COMMENT  '缴款截止日',
  L_LOT_DATE  DECIMAL(8,0)  COMMENT  '中签日',
  VC_LOCKEDDATE_CONTENT  STRING  COMMENT  '锁定期信息',
  C_ASSURE_TYPE  STRING  COMMENT  '担保方式',
  C_ATTACH_WARRANT  STRING  COMMENT  '附送权证',
  VC_WARRANT_CODE  STRING  COMMENT  '权证代码',
  EN_LOWER_APPLYAMOUNT  DECIMAL(16,0)  COMMENT  '网下申购数量下限',
  EN_UPPER_APPLYAMOUNT  DECIMAL(16,0)  COMMENT  '网下申购数量上限',
  L_UNIT_AMOUNT  DECIMAL(8,0)  COMMENT  '累进单位数量',
  EN_ISSUE_RATE  DECIMAL(11,10)  COMMENT  '发行费率',
  L_REPAY_DAY  DECIMAL(8,0)  COMMENT  '手续费返还到帐天数',
  C_BID_TYPE  STRING  COMMENT  '招标方式',
  VC_APPRAISE_ORGAN  STRING  COMMENT  '外部评级机构',
  C_APPRAISE  STRING  COMMENT  '综合评级',
  L_END_BID_DATE  DECIMAL(8,0)  COMMENT  '招标结束日期',
  L_END_BID_TIME  DECIMAL(6,0)  COMMENT  '招标结束时间',
  L_PUBLISH_DATE  DECIMAL(8,0)  COMMENT  '发行日期',
  C_STATUS  STRING  COMMENT  '状态',
  L_PRICE_COUNT_LJ  DECIMAL(10,0)  COMMENT  '累计询价价位个数',
  EN_ISSUEAMOUNT_MULTIPLE  DECIMAL(16,4)  COMMENT  '发行倍数',
  EN_PRICE_UNIT_LJ  DECIMAL(16,8)  COMMENT  '累计询价最小累进价格',
  VC_OFFERING_CODE  STRING  COMMENT  '发行代码',
  L_WARRANT_PER_HAND  DECIMAL(10,0)  COMMENT  '初步询价每手附赠权证数量',
  C_PURCHASING_TYPE  STRING  COMMENT  '申购类型',
  C_BID_TARGET  STRING  COMMENT  '招标标的',
  L_ISSUE_AMOUNT  DECIMAL(12,0)  COMMENT  '发行总量',
  EN_BID_RATIO  DECIMAL(13,12)  COMMENT  '中签率',
  C_APPLY_TYPE  STRING  COMMENT  '网下申购类别',
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  L_BEGIN_BID_DATE  DECIMAL(8,0)  COMMENT  '投标开始日期',
  L_BEGIN_BID_TIME  DECIMAL(8,0)  COMMENT  '投标开始时间',
  EN_EARNEST_BALANCE  DECIMAL(16,2)  COMMENT  '定金金额',
  EN_TBBWC  DECIMAL(16,8)  COMMENT  '标位差',
  L_TBBWLJSL  DECIMAL(10,0)  COMMENT  '标位最小累进数量',
  L_RGSL_ZJ  DECIMAL(12,0)  COMMENT  '追加认购数量',
  L_FXL_ZJ  DECIMAL(12,0)  COMMENT  '追加发行量',
  EN_ZBBW  DECIMAL(16,8)  COMMENT  '中标标位',
  EN_BJBW  DECIMAL(16,8)  COMMENT  '边际标位',
  L_SCZBSL  DECIMAL(12,0)  COMMENT  '全市场中标数量',
  L_SCZBSL_ZJ  DECIMAL(12,0)  COMMENT  '全市场追加中标数量',
  L_RGBS  DECIMAL(16,2)  COMMENT  '认购倍数',
  L_RGBS_ZJ  DECIMAL(16,2)  COMMENT  '追加认购倍数',
  EN_LOWER_TBAMOUNT  DECIMAL(16,2)  COMMENT  '最低投标量',
  EN_UPPER_TBAMOUNT  DECIMAL(16,2)  COMMENT  '最高投标量',
  EN_LOWER_DYBWAMOUNT  DECIMAL(16,2)  COMMENT  '单一标位最低投标限额',
  EN_UPPER_DYBWAMOUNT  DECIMAL(16,2)  COMMENT  '单一标位最高投标限额',
  C_APPLY_MUST  STRING  COMMENT  '询价成功必须申购',
  L_SECONDARY_DATE  DECIMAL(8,0)  COMMENT  '续发日期',
  L_BJZBBS  DECIMAL(16,2)  COMMENT  '边际中标倍数',
  L_SUPERVENTION_NO  DECIMAL(4,0)  COMMENT  '续发期数',
  EN_ELIMINATE_PRICE  DECIMAL(16,8)  COMMENT  '剔除报价',
  VC_REMARK  STRING  COMMENT  '备注',
  EN_SXFL  DECIMAL(9,6)  COMMENT  '手续费率%',
  C_AMOUNTCONTROL_MODE  STRING  COMMENT  '数量控制模式',
  C_BASIC_INTEREST_TYPE  STRING  COMMENT  '基准利率类型',
  VC_TIMESTAMP  STRING  COMMENT  '时间戳',
  L_VIRTUAL_KEY  DECIMAL(16,0)  COMMENT  '虚拟主键',
  L_REFUND_DATE  DECIMAL(8,0)  COMMENT  '',
  EN_YJ_FEE_RATIO  DECIMAL(15,8)  COMMENT  '',
  EN_LOWER_BUYBALANCE  DECIMAL(16,2)  COMMENT  '',
  EN_UPPER_BUYBALANCE  DECIMAL(16,2)  COMMENT  '',
  EN_UNIT_BALANCE  DECIMAL(16,2)  COMMENT  '',
  C_RESTRICTED_PRECISION_MODE  STRING  COMMENT  ''
)
COMMENT '证券发行信息表'
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
              "querySql": ["SELECT  VC_INTER_CODE
                                   , EN_EARNEST_RATIO
                                   , EN_LOWER_PRICE
                                   , EN_UPPER_PRICE
                                   , VC_ISSUE_TERM
                                   , L_PAY_LIMIT_DATE
                                   , L_LOT_DATE
                                   , VC_LOCKEDDATE_CONTENT
                                   , C_ASSURE_TYPE
                                   , C_ATTACH_WARRANT
                                   , VC_WARRANT_CODE
                                   , EN_LOWER_APPLYAMOUNT
                                   , EN_UPPER_APPLYAMOUNT
                                   , L_UNIT_AMOUNT
                                   , EN_ISSUE_RATE
                                   , L_REPAY_DAY
                                   , C_BID_TYPE
                                   , VC_APPRAISE_ORGAN
                                   , C_APPRAISE
                                   , L_END_BID_DATE
                                   , L_END_BID_TIME
                                   , L_PUBLISH_DATE
                                   , C_STATUS
                                   , L_PRICE_COUNT_LJ
                                   , EN_ISSUEAMOUNT_MULTIPLE
                                   , EN_PRICE_UNIT_LJ
                                   , VC_OFFERING_CODE
                                   , L_WARRANT_PER_HAND
                                   , C_PURCHASING_TYPE
                                   , C_BID_TARGET
                                   , L_ISSUE_AMOUNT
                                   , EN_BID_RATIO
                                   , C_APPLY_TYPE
                                   , L_DATE
                                   , L_BEGIN_BID_DATE
                                   , L_BEGIN_BID_TIME
                                   , EN_EARNEST_BALANCE
                                   , EN_TBBWC
                                   , L_TBBWLJSL
                                   , L_RGSL_ZJ
                                   , L_FXL_ZJ
                                   , EN_ZBBW
                                   , EN_BJBW
                                   , L_SCZBSL
                                   , L_SCZBSL_ZJ
                                   , L_RGBS
                                   , L_RGBS_ZJ
                                   , EN_LOWER_TBAMOUNT
                                   , EN_UPPER_TBAMOUNT
                                   , EN_LOWER_DYBWAMOUNT
                                   , EN_UPPER_DYBWAMOUNT
                                   , C_APPLY_MUST
                                   , L_SECONDARY_DATE
                                   , L_BJZBBS
                                   , L_SUPERVENTION_NO
                                   , EN_ELIMINATE_PRICE
                                   , VC_REMARK
                                   , EN_SXFL
                                   , C_AMOUNTCONTROL_MODE
                                   , C_BASIC_INTEREST_TYPE
                                   , VC_TIMESTAMP
                                   , L_VIRTUAL_KEY
                                   , L_REFUND_DATE
                                   , EN_YJ_FEE_RATIO
                                   , EN_LOWER_BUYBALANCE
                                   , EN_UPPER_BUYBALANCE
                                   , EN_UNIT_BALANCE
                                   , C_RESTRICTED_PRECISION_MODE
                                FROM ${o32_src_schema}.THISSTOCKISSUEINFO
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "VC_INTER_CODE", "type": "STRING"}, {"name": "EN_EARNEST_RATIO", "type": "DOUBLE"}, {"name": "EN_LOWER_PRICE", "type": "DOUBLE"}, {"name": "EN_UPPER_PRICE", "type": "DOUBLE"}, {"name": "VC_ISSUE_TERM", "type": "STRING"}, {"name": "L_PAY_LIMIT_DATE", "type": "DOUBLE"}, {"name": "L_LOT_DATE", "type": "DOUBLE"}, {"name": "VC_LOCKEDDATE_CONTENT", "type": "STRING"}, {"name": "C_ASSURE_TYPE", "type": "STRING"}, {"name": "C_ATTACH_WARRANT", "type": "STRING"}, {"name": "VC_WARRANT_CODE", "type": "STRING"}, {"name": "EN_LOWER_APPLYAMOUNT", "type": "DOUBLE"}, {"name": "EN_UPPER_APPLYAMOUNT", "type": "DOUBLE"}, {"name": "L_UNIT_AMOUNT", "type": "DOUBLE"}, {"name": "EN_ISSUE_RATE", "type": "DOUBLE"}, {"name": "L_REPAY_DAY", "type": "DOUBLE"}, {"name": "C_BID_TYPE", "type": "STRING"}, {"name": "VC_APPRAISE_ORGAN", "type": "STRING"}, {"name": "C_APPRAISE", "type": "STRING"}, {"name": "L_END_BID_DATE", "type": "DOUBLE"}, {"name": "L_END_BID_TIME", "type": "DOUBLE"}, {"name": "L_PUBLISH_DATE", "type": "DOUBLE"}, {"name": "C_STATUS", "type": "STRING"}, {"name": "L_PRICE_COUNT_LJ", "type": "DOUBLE"}, {"name": "EN_ISSUEAMOUNT_MULTIPLE", "type": "DOUBLE"}, {"name": "EN_PRICE_UNIT_LJ", "type": "DOUBLE"}, {"name": "VC_OFFERING_CODE", "type": "STRING"}, {"name": "L_WARRANT_PER_HAND", "type": "DOUBLE"}, {"name": "C_PURCHASING_TYPE", "type": "STRING"}, {"name": "C_BID_TARGET", "type": "STRING"}, {"name": "L_ISSUE_AMOUNT", "type": "DOUBLE"}, {"name": "EN_BID_RATIO", "type": "DOUBLE"}, {"name": "C_APPLY_TYPE", "type": "STRING"}, {"name": "L_DATE", "type": "DOUBLE"}, {"name": "L_BEGIN_BID_DATE", "type": "DOUBLE"}, {"name": "L_BEGIN_BID_TIME", "type": "DOUBLE"}, {"name": "EN_EARNEST_BALANCE", "type": "DOUBLE"}, {"name": "EN_TBBWC", "type": "DOUBLE"}, {"name": "L_TBBWLJSL", "type": "DOUBLE"}, {"name": "L_RGSL_ZJ", "type": "DOUBLE"}, {"name": "L_FXL_ZJ", "type": "DOUBLE"}, {"name": "EN_ZBBW", "type": "DOUBLE"}, {"name": "EN_BJBW", "type": "DOUBLE"}, {"name": "L_SCZBSL", "type": "DOUBLE"}, {"name": "L_SCZBSL_ZJ", "type": "DOUBLE"}, {"name": "L_RGBS", "type": "DOUBLE"}, {"name": "L_RGBS_ZJ", "type": "DOUBLE"}, {"name": "EN_LOWER_TBAMOUNT", "type": "DOUBLE"}, {"name": "EN_UPPER_TBAMOUNT", "type": "DOUBLE"}, {"name": "EN_LOWER_DYBWAMOUNT", "type": "DOUBLE"}, {"name": "EN_UPPER_DYBWAMOUNT", "type": "DOUBLE"}, {"name": "C_APPLY_MUST", "type": "STRING"}, {"name": "L_SECONDARY_DATE", "type": "DOUBLE"}, {"name": "L_BJZBBS", "type": "DOUBLE"}, {"name": "L_SUPERVENTION_NO", "type": "DOUBLE"}, {"name": "EN_ELIMINATE_PRICE", "type": "DOUBLE"}, {"name": "VC_REMARK", "type": "STRING"}, {"name": "EN_SXFL", "type": "DOUBLE"}, {"name": "C_AMOUNTCONTROL_MODE", "type": "STRING"}, {"name": "C_BASIC_INTEREST_TYPE", "type": "STRING"}, {"name": "VC_TIMESTAMP", "type": "STRING"}, {"name": "L_VIRTUAL_KEY", "type": "DOUBLE"}, {"name": "L_REFUND_DATE", "type": "DOUBLE"}, {"name": "EN_YJ_FEE_RATIO", "type": "DOUBLE"}, {"name": "EN_LOWER_BUYBALANCE", "type": "DOUBLE"}, {"name": "EN_UPPER_BUYBALANCE", "type": "DOUBLE"}, {"name": "EN_UNIT_BALANCE", "type": "DOUBLE"}, {"name": "C_RESTRICTED_PRECISION_MODE", "type": "STRING"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tstockissueinfo_pfd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tstockissueinfo_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tstockissueinfo_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tstockissueinfo_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TSTOCKISSUEINFO_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TSTOCKISSUEINFO_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tstockissueinfo_pfd_tmp.json

inceptor_beeline "
set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions.pernode=10000;
set hive.exec.max.dynamic.partitions=10000;
set hive.exec.max.created.files=10000;
set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TSTOCKISSUEINFO_PFD PARTITION(P_DT)
SELECT
       VC_INTER_CODE
     , EN_EARNEST_RATIO
     , EN_LOWER_PRICE
     , EN_UPPER_PRICE
     , VC_ISSUE_TERM
     , L_PAY_LIMIT_DATE
     , L_LOT_DATE
     , VC_LOCKEDDATE_CONTENT
     , C_ASSURE_TYPE
     , C_ATTACH_WARRANT
     , VC_WARRANT_CODE
     , EN_LOWER_APPLYAMOUNT
     , EN_UPPER_APPLYAMOUNT
     , L_UNIT_AMOUNT
     , EN_ISSUE_RATE
     , L_REPAY_DAY
     , C_BID_TYPE
     , VC_APPRAISE_ORGAN
     , C_APPRAISE
     , L_END_BID_DATE
     , L_END_BID_TIME
     , L_PUBLISH_DATE
     , C_STATUS
     , L_PRICE_COUNT_LJ
     , EN_ISSUEAMOUNT_MULTIPLE
     , EN_PRICE_UNIT_LJ
     , VC_OFFERING_CODE
     , L_WARRANT_PER_HAND
     , C_PURCHASING_TYPE
     , C_BID_TARGET
     , L_ISSUE_AMOUNT
     , EN_BID_RATIO
     , C_APPLY_TYPE
     , L_DATE
     , L_BEGIN_BID_DATE
     , L_BEGIN_BID_TIME
     , EN_EARNEST_BALANCE
     , EN_TBBWC
     , L_TBBWLJSL
     , L_RGSL_ZJ
     , L_FXL_ZJ
     , EN_ZBBW
     , EN_BJBW
     , L_SCZBSL
     , L_SCZBSL_ZJ
     , L_RGBS
     , L_RGBS_ZJ
     , EN_LOWER_TBAMOUNT
     , EN_UPPER_TBAMOUNT
     , EN_LOWER_DYBWAMOUNT
     , EN_UPPER_DYBWAMOUNT
     , C_APPLY_MUST
     , L_SECONDARY_DATE
     , L_BJZBBS
     , L_SUPERVENTION_NO
     , EN_ELIMINATE_PRICE
     , VC_REMARK
     , EN_SXFL
     , C_AMOUNTCONTROL_MODE
     , C_BASIC_INTEREST_TYPE
     , VC_TIMESTAMP
     , L_VIRTUAL_KEY
     , L_REFUND_DATE
     , EN_YJ_FEE_RATIO
     , EN_LOWER_BUYBALANCE
     , EN_UPPER_BUYBALANCE
     , EN_UNIT_BALANCE
     , C_RESTRICTED_PRECISION_MODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TSTOCKISSUEINFO_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TSTOCKISSUEINFO_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TSTOCKISSUEINFO_PFD失败"
      exit 1
   else
      echo "插入到ODS_O32_TSTOCKISSUEINFO_PFD成功"
      exit 0
   fi
fi
