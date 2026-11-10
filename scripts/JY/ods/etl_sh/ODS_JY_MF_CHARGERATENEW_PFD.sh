#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_JY.ODS_JY_MF_CHARGERATENEW_PFD_TMP;
CREATE TABLE ODS_XDAY_JY.ODS_JY_MF_CHARGERATENEW_PFD_TMP(
  ID  DECIMAL(19,0)  COMMENT  'ID',
  INNERCODE  STRING  COMMENT  '证券内部编码',
  INFOPUBLDATE  STRING  COMMENT  '信息发布日期',
  INFOSOURCE  STRING  COMMENT  '信息来源',
  IFEXECUTED  DECIMAL(10,0)  COMMENT  '是否执行',
  EXCUTEDATE  STRING  COMMENT  '生效日期',
  CANCELDATE  STRING  COMMENT  '取消日期',
  CHARGERATETYPE  DECIMAL(10,0)  COMMENT  '费率类别',
  CHARGERATETYDES  STRING  COMMENT  '费率类别描述',
  CHARGERATECUR  DECIMAL(10,0)  COMMENT  '费率币种',
  CLIENTTYPE  STRING  COMMENT  '适用客户类型',
  SHIFTINTARGET  DECIMAL(10,0)  COMMENT  '转入基金选择',
  MINCHARGERATE  DECIMAL(19,9)  COMMENT  '费率最低值',
  MAXCHARGERATE  DECIMAL(19,9)  COMMENT  '费率最高值',
  FLOCHARGERATE  STRING  COMMENT  '费率计算方式',
  CHARGERATEUNIT  DECIMAL(10,0)  COMMENT  '费率单位',
  CHARGERATEDES  STRING  COMMENT  '费率描述',
  CHARGERATEDIV  DECIMAL(10,0)  COMMENT  '费率划分',
  DIVSTAND1  DECIMAL(10,0)  COMMENT  '费率划分标准Ⅰ',
  DIVSTANDUNIT1  DECIMAL(10,0)  COMMENT  '费率划分标准Ⅰ单位',
  STDIVSTAND1  DECIMAL(19,4)  COMMENT  '费率划分标准范围Ⅰ起始数值',
  ENDIVSTAND1  DECIMAL(19,4)  COMMENT  '费率划分标准范围Ⅰ截止数值',
  IFAPPLYSTART1  DECIMAL(10,0)  COMMENT  '是否包含范围Ⅰ起始点',
  IFAPPLYEND1  DECIMAL(10,0)  COMMENT  '是否包含范围Ⅰ截止点',
  DIVSTAND2  DECIMAL(10,0)  COMMENT  '费率划分标准Ⅱ',
  DIVSTANDUNIT2  DECIMAL(10,0)  COMMENT  '费率划分标准Ⅱ单位',
  STDIVSTAND2  DECIMAL(19,4)  COMMENT  '费率划分标准范围Ⅱ起始数值',
  ENDIVSTAND2  DECIMAL(19,4)  COMMENT  '费率划分标准范围Ⅱ截止数值',
  IFAPPLYSTART2  DECIMAL(10,0)  COMMENT  '是否包含范围Ⅱ起始点',
  IFAPPLYEND2  DECIMAL(10,0)  COMMENT  '是否包含范围Ⅱ截止点',
  DIVSTAND3  DECIMAL(10,0)  COMMENT  '费率划分标准Ⅲ',
  DIVSTANDUNIT3  DECIMAL(10,0)  COMMENT  '费率划分标准Ⅲ单位',
  STDIVSTAND3  DECIMAL(19,4)  COMMENT  '费率划分标准范围Ⅲ起始数值',
  ENDIVSTAND3  DECIMAL(19,4)  COMMENT  '费率划分标准范围Ⅲ截止数值',
  IFAPPLYSTART3  DECIMAL(10,0)  COMMENT  '是否包含范围Ⅲ起始点',
  IFAPPLYEND3  DECIMAL(10,0)  COMMENT  '是否包含范围Ⅲ截止点',
  NOTES  STRING  COMMENT  '备注说明',
  XGRQ  STRING  COMMENT  '修改日期',
  JSID  DECIMAL(19,0)  COMMENT  'JSID',
  DIVINTERVALDES  STRING  COMMENT  '费率划分区间描述',
  INSERTTIME  STRING  COMMENT  '插入时间',
  TRANSCODE  STRING  COMMENT  '基金转型统一编码'
)
COMMENT '基金费率表'
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
                                   , INFOPUBLDATE
                                   , INFOSOURCE
                                   , IFEXECUTED
                                   , EXCUTEDATE
                                   , CANCELDATE
                                   , CHARGERATETYPE
                                   , CHARGERATETYDES
                                   , CHARGERATECUR
                                   , CLIENTTYPE
                                   , SHIFTINTARGET
                                   , MINCHARGERATE
                                   , MAXCHARGERATE
                                   , FLOCHARGERATE
                                   , CHARGERATEUNIT
                                   , CHARGERATEDES
                                   , CHARGERATEDIV
                                   , DIVSTAND1
                                   , DIVSTANDUNIT1
                                   , STDIVSTAND1
                                   , ENDIVSTAND1
                                   , IFAPPLYSTART1
                                   , IFAPPLYEND1
                                   , DIVSTAND2
                                   , DIVSTANDUNIT2
                                   , STDIVSTAND2
                                   , ENDIVSTAND2
                                   , IFAPPLYSTART2
                                   , IFAPPLYEND2
                                   , DIVSTAND3
                                   , DIVSTANDUNIT3
                                   , STDIVSTAND3
                                   , ENDIVSTAND3
                                   , IFAPPLYSTART3
                                   , IFAPPLYEND3
                                   , NOTES
                                   , XGRQ
                                   , JSID
                                   , DIVINTERVALDES
                                   , INSERTTIME
                                   , TRANSCODE
                                FROM ${jy_src_schema}.MF_CHARGERATENEW"],
              "jdbcUrl": ["${jy_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "ID", "type": "DOUBLE"}, {"name": "INNERCODE", "type": "DOUBLE"}, {"name": "INFOPUBLDATE", "type": "STRING"}, {"name": "INFOSOURCE", "type": "STRING"}, {"name": "IFEXECUTED", "type": "DOUBLE"}, {"name": "EXCUTEDATE", "type": "STRING"}, {"name": "CANCELDATE", "type": "STRING"}, {"name": "CHARGERATETYPE", "type": "DOUBLE"}, {"name": "CHARGERATETYDES", "type": "STRING"}, {"name": "CHARGERATECUR", "type": "DOUBLE"}, {"name": "CLIENTTYPE", "type": "DOUBLE"}, {"name": "SHIFTINTARGET", "type": "DOUBLE"}, {"name": "MINCHARGERATE", "type": "DOUBLE"}, {"name": "MAXCHARGERATE", "type": "DOUBLE"}, {"name": "FLOCHARGERATE", "type": "STRING"}, {"name": "CHARGERATEUNIT", "type": "DOUBLE"}, {"name": "CHARGERATEDES", "type": "STRING"}, {"name": "CHARGERATEDIV", "type": "DOUBLE"}, {"name": "DIVSTAND1", "type": "DOUBLE"}, {"name": "DIVSTANDUNIT1", "type": "DOUBLE"}, {"name": "STDIVSTAND1", "type": "DOUBLE"}, {"name": "ENDIVSTAND1", "type": "DOUBLE"}, {"name": "IFAPPLYSTART1", "type": "DOUBLE"}, {"name": "IFAPPLYEND1", "type": "DOUBLE"}, {"name": "DIVSTAND2", "type": "DOUBLE"}, {"name": "DIVSTANDUNIT2", "type": "DOUBLE"}, {"name": "STDIVSTAND2", "type": "DOUBLE"}, {"name": "ENDIVSTAND2", "type": "DOUBLE"}, {"name": "IFAPPLYSTART2", "type": "DOUBLE"}, {"name": "IFAPPLYEND2", "type": "DOUBLE"}, {"name": "DIVSTAND3", "type": "DOUBLE"}, {"name": "DIVSTANDUNIT3", "type": "DOUBLE"}, {"name": "STDIVSTAND3", "type": "DOUBLE"}, {"name": "ENDIVSTAND3", "type": "DOUBLE"}, {"name": "IFAPPLYSTART3", "type": "DOUBLE"}, {"name": "IFAPPLYEND3", "type": "DOUBLE"}, {"name": "NOTES", "type": "STRING"}, {"name": "XGRQ", "type": "STRING"}, {"name": "JSID", "type": "DOUBLE"}, {"name": "DIVINTERVALDES", "type": "STRING"}, {"name": "INSERTTIME", "type": "STRING"}, {"name": "TRANSCODE", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_jy_mf_chargeratenew_pfd_tmp",
            "fileType": "text",
            "path": "${jy_path}/ods_jy_mf_chargeratenew_pfd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_jy_mf_chargeratenew_pfd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_jy_mf_chargeratenew_pfd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_JY_MF_CHARGERATENEW_PFD_TMP表失败"
   exit 1
else
   echo "导入到ODS_JY_MF_CHARGERATENEW_PFD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_jy_mf_chargeratenew_pfd_tmp.json

inceptor_beeline "

set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
INSERT OVERWRITE TABLE ODS_XDAY_JY.ODS_JY_MF_CHARGERATENEW_PFD PARTITION(P_DT='${p_end_dt}')
SELECT
       ID
     , INNERCODE
     , INFOPUBLDATE
     , INFOSOURCE
     , IFEXECUTED
     , EXCUTEDATE
     , CANCELDATE
     , CHARGERATETYPE
     , CHARGERATETYDES
     , CHARGERATECUR
     , CLIENTTYPE
     , SHIFTINTARGET
     , MINCHARGERATE
     , MAXCHARGERATE
     , FLOCHARGERATE
     , CHARGERATEUNIT
     , CHARGERATEDES
     , CHARGERATEDIV
     , DIVSTAND1
     , DIVSTANDUNIT1
     , STDIVSTAND1
     , ENDIVSTAND1
     , IFAPPLYSTART1
     , IFAPPLYEND1
     , DIVSTAND2
     , DIVSTANDUNIT2
     , STDIVSTAND2
     , ENDIVSTAND2
     , IFAPPLYSTART2
     , IFAPPLYEND2
     , DIVSTAND3
     , DIVSTANDUNIT3
     , STDIVSTAND3
     , ENDIVSTAND3
     , IFAPPLYSTART3
     , IFAPPLYEND3
     , NOTES
     , XGRQ
     , JSID
     , DIVINTERVALDES
     , INSERTTIME
     , TRANSCODE
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
  FROM ODS_XDAY_JY.ODS_JY_MF_CHARGERATENEW_PFD_TMP
;
TRUNCATE TABLE ODS_XDAY_JY.ODS_JY_MF_CHARGERATENEW_PFD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_JY_MF_CHARGERATENEW_PFD失败"
      exit 1
   else
      echo "插入到ODS_JY_MF_CHARGERATENEW_PFD成功"
      exit 0
   fi
fi
