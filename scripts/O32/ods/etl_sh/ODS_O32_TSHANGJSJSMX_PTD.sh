#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_O32.ODS_O32_TSHANGJSJSMX_PTD_TMP;
CREATE TABLE ODS_XDAY_O32.ODS_O32_TSHANGJSJSMX_PTD_TMP(
  L_DATE  DECIMAL(8,0)  COMMENT  '日期',
  SCDM  STRING  COMMENT  '市场代码',
  JLLX  STRING  COMMENT  '记录类型',
  JYFS  STRING  COMMENT  '交易方式',
  JSFS  STRING  COMMENT  '交收方式',
  YWLX  STRING  COMMENT  '业务类型',
  QSBZ  STRING  COMMENT  '清算标志',
  GHLX  STRING  COMMENT  '过户类型',
  JSBH  STRING  COMMENT  '交收编号',
  CJBH  STRING  COMMENT  '成交编号',
  SQBH  STRING  COMMENT  '申请编号',
  WTBH  STRING  COMMENT  '委托编号',
  JYRQ  STRING  COMMENT  '交易日期',
  QSRQ  STRING  COMMENT  '清算日期',
  JSRQ  STRING  COMMENT  '交收日期',
  QTRQ  STRING  COMMENT  '其它日期',
  WTSJ  STRING  COMMENT  '委托时间',
  CJSJ  STRING  COMMENT  '成交时间',
  XWH1  STRING  COMMENT  '席位号1',
  XWH2  STRING  COMMENT  '席位���2',
  XWHY  STRING  COMMENT  '席位会员',
  JSHY  STRING  COMMENT  '结算会员',
  TGHY  STRING  COMMENT  '托管会员',
  ZQZH  STRING  COMMENT  '证券帐号',
  ZQDM1  STRING  COMMENT  '证券代码1',
  ZQDM2  STRING  COMMENT  '证券代码2',
  ZQLB  STRING  COMMENT  '证券类别',
  LTLX  STRING  COMMENT  '流通类型',
  QYLB  STRING  COMMENT  '权益类别',
  GPNF  STRING  COMMENT  '挂牌年份',
  MMBZ  STRING  COMMENT  '买卖标志',
  SL  STRING  COMMENT  '交收数量',
  CJSL  STRING  COMMENT  '成交数量',
  ZJZH  STRING  COMMENT  '��金���号',
  BZ  STRING  COMMENT  '币种',
  JG1  STRING  COMMENT  '价格1',
  JG2  STRING  COMMENT  '价格2',
  QSJE  STRING  COMMENT  '清算金额',
  YHS  STRING  COMMENT  '印花税',
  JSF  STRING  COMMENT  '经手费',
  GHF  STRING  COMMENT  '过户费',
  ZGF  STRING  COMMENT  '证管费',
  SXF  STRING  COMMENT  '手���费',
  QTJE1  STRING  COMMENT  '其它金���1',
  QTJE2  STRING  COMMENT  '��它金额2',
  QTJE3  STRING  COMMENT  '其它金额3',
  SJSF  STRING  COMMENT  '实际收付',
  JGDM  STRING  COMMENT  '结果代码',
  FJSM  STRING  COMMENT  '附加说明',
  CLBZ  STRING  COMMENT  '处��标志',
  VC_SOURCE_FILE  STRING  COMMENT  '文件名称',
  L_SECURITIES_BRANCH  DECIMAL(10,0)  COMMENT  '分仓营业部'
)
COMMENT '上交所结算jsmx表'
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
              "querySql": ["SELECT  L_DATE
                                   , SCDM
                                   , JLLX
                                   , JYFS
                                   , JSFS
                                   , YWLX
                                   , QSBZ
                                   , GHLX
                                   , JSBH
                                   , CJBH
                                   , SQBH
                                   , WTBH
                                   , JYRQ
                                   , QSRQ
                                   , JSRQ
                                   , QTRQ
                                   , WTSJ
                                   , CJSJ
                                   , XWH1
                                   , XWH2
                                   , XWHY
                                   , JSHY
                                   , TGHY
                                   , ZQZH
                                   , ZQDM1
                                   , ZQDM2
                                   , ZQLB
                                   , LTLX
                                   , QYLB
                                   , GPNF
                                   , MMBZ
                                   , SL
                                   , CJSL
                                   , ZJZH
                                   , BZ
                                   , JG1
                                   , JG2
                                   , QSJE
                                   , YHS
                                   , JSF
                                   , GHF
                                   , ZGF
                                   , SXF
                                   , QTJE1
                                   , QTJE2
                                   , QTJE3
                                   , SJSF
                                   , JGDM
                                   , FJSM
                                   , CLBZ
                                   , VC_SOURCE_FILE
                                   , L_SECURITIES_BRANCH
                                FROM ${o32_src_schema}.THISSHANGJSJSMX
                                WHERE L_DATE between '${p_start_dt}' and '${p_end_dt}'"],
              "jdbcUrl": ["${o32_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_DATE", "type": "DOUBLE"}, {"name": "SCDM", "type": "STRING"}, {"name": "JLLX", "type": "STRING"}, {"name": "JYFS", "type": "STRING"}, {"name": "JSFS", "type": "STRING"}, {"name": "YWLX", "type": "STRING"}, {"name": "QSBZ", "type": "STRING"}, {"name": "GHLX", "type": "STRING"}, {"name": "JSBH", "type": "STRING"}, {"name": "CJBH", "type": "STRING"}, {"name": "SQBH", "type": "STRING"}, {"name": "WTBH", "type": "STRING"}, {"name": "JYRQ", "type": "STRING"}, {"name": "QSRQ", "type": "STRING"}, {"name": "JSRQ", "type": "STRING"}, {"name": "QTRQ", "type": "STRING"}, {"name": "WTSJ", "type": "STRING"}, {"name": "CJSJ", "type": "STRING"}, {"name": "XWH1", "type": "STRING"}, {"name": "XWH2", "type": "STRING"}, {"name": "XWHY", "type": "STRING"}, {"name": "JSHY", "type": "STRING"}, {"name": "TGHY", "type": "STRING"}, {"name": "ZQZH", "type": "STRING"}, {"name": "ZQDM1", "type": "STRING"}, {"name": "ZQDM2", "type": "STRING"}, {"name": "ZQLB", "type": "STRING"}, {"name": "LTLX", "type": "STRING"}, {"name": "QYLB", "type": "STRING"}, {"name": "GPNF", "type": "STRING"}, {"name": "MMBZ", "type": "STRING"}, {"name": "SL", "type": "STRING"}, {"name": "CJSL", "type": "STRING"}, {"name": "ZJZH", "type": "STRING"}, {"name": "BZ", "type": "STRING"}, {"name": "JG1", "type": "STRING"}, {"name": "JG2", "type": "STRING"}, {"name": "QSJE", "type": "STRING"}, {"name": "YHS", "type": "STRING"}, {"name": "JSF", "type": "STRING"}, {"name": "GHF", "type": "STRING"}, {"name": "ZGF", "type": "STRING"}, {"name": "SXF", "type": "STRING"}, {"name": "QTJE1", "type": "STRING"}, {"name": "QTJE2", "type": "STRING"}, {"name": "QTJE3", "type": "STRING"}, {"name": "SJSF", "type": "STRING"}, {"name": "JGDM", "type": "STRING"}, {"name": "FJSM", "type": "STRING"}, {"name": "CLBZ", "type": "STRING"}, {"name": "VC_SOURCE_FILE", "type": "STRING"}, {"name": "L_SECURITIES_BRANCH", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_o32_tshangjsjsmx_ptd_tmp",
            "fileType": "text",
            "path": "${o32_path}/ods_o32_tshangjsjsmx_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_o32_tshangjsjsmx_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_o32_tshangjsjsmx_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_O32_TSHANGJSJSMX_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_O32_TSHANGJSJSMX_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_o32_tshangjsjsmx_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_O32.ODS_O32_TSHANGJSJSMX_PTD PARTITION(P_DT)
SELECT
       L_DATE
     , SCDM
     , JLLX
     , JYFS
     , JSFS
     , YWLX
     , QSBZ
     , GHLX
     , JSBH
     , CJBH
     , SQBH
     , WTBH
     , JYRQ
     , QSRQ
     , JSRQ
     , QTRQ
     , WTSJ
     , CJSJ
     , XWH1
     , XWH2
     , XWHY
     , JSHY
     , TGHY
     , ZQZH
     , ZQDM1
     , ZQDM2
     , ZQLB
     , LTLX
     , QYLB
     , GPNF
     , MMBZ
     , SL
     , CJSL
     , ZJZH
     , BZ
     , JG1
     , JG2
     , QSJE
     , YHS
     , JSF
     , GHF
     , ZGF
     , SXF
     , QTJE1
     , QTJE2
     , QTJE3
     , SJSF
     , JGDM
     , FJSM
     , CLBZ
     , VC_SOURCE_FILE
     , L_SECURITIES_BRANCH
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , CAST(L_DATE AS STRING) P_DT
  FROM ODS_XDAY_O32.ODS_O32_TSHANGJSJSMX_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_O32.ODS_O32_TSHANGJSJSMX_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_O32_TSHANGJSJSMX_PTD失败"
      exit 1
   else
      echo "插入到ODS_O32_TSHANGJSJSMX_PTD成功"
      exit 0
   fi
fi
