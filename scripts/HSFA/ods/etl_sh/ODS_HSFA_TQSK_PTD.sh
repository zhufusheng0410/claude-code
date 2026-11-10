#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}
inceptor_beeline "
DROP TABLE IF EXISTS ODS_XDAY_HSFA.ODS_HSFA_TQSK_PTD_TMP;
CREATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TQSK_PTD_TMP(
  L_BH  STRING  COMMENT  '编号',
  L_ZTBH  STRING  COMMENT  '帐套编号',
  D_RQ  STRING  COMMENT  '日期',
  L_ZQNM  DECIMAL(8,0)  COMMENT  '证券内码',
  VC_XWDM  STRING  COMMENT  '席位代码',
  VC_GDDM  STRING  COMMENT  '股东代码',
  VC_ZQDM  STRING  COMMENT  '证券代码',
  L_YWLB  DECIMAL(4,0)  COMMENT  '业务类别',
  L_SCLB  DECIMAL(4,0)  COMMENT  '市场类别',
  L_MRSL  DECIMAL(19,4)  COMMENT  '买入数量',
  EN_MRJE  DECIMAL(19,4)  COMMENT  '买入金额',
  L_MCSL  DECIMAL(19,4)  COMMENT  '卖出数量',
  EN_MCJE  DECIMAL(19,4)  COMMENT  '卖出金额',
  EN_MRYHS  DECIMAL(15,4)  COMMENT  '买入印花税',
  EN_MCYHS  DECIMAL(15,4)  COMMENT  '卖出印花税',
  EN_MRJSF  DECIMAL(15,4)  COMMENT  '买入经手费',
  EN_MCJSF  DECIMAL(15,4)  COMMENT  '卖出经手费',
  EN_MRGHF  DECIMAL(15,4)  COMMENT  '买入过户费',
  EN_MCGHF  DECIMAL(15,4)  COMMENT  '卖出过户费',
  EN_MRZGF  DECIMAL(15,4)  COMMENT  '买入证管费',
  EN_MCZGF  DECIMAL(15,4)  COMMENT  '卖出证管费',
  EN_MRSXF  DECIMAL(15,4)  COMMENT  '买入手续费',
  EN_MCSXF  DECIMAL(15,4)  COMMENT  '卖出手续费',
  EN_MRQTFY  DECIMAL(15,4)  COMMENT  '买入其他费用',
  EN_MCQTFY  DECIMAL(15,4)  COMMENT  '卖出其他费用',
  EN_MRYJ  DECIMAL(15,4)  COMMENT  '买入佣金',
  EN_MCYJ  DECIMAL(15,4)  COMMENT  '卖出佣金',
  EN_MRLX  DECIMAL(15,4)  COMMENT  '买入利息',
  EN_MCLX  DECIMAL(15,4)  COMMENT  '卖出利息',
  L_TZLX  STRING  COMMENT  '投资类型',
  EN_MCCB  DECIMAL(19,4)  COMMENT  '卖出成本',
  VC_GZZ  STRING  COMMENT  '工作组代码',
  L_YWLBMX  DECIMAL(10,0)  COMMENT  '业务类别明细',
  L_MRPZID  STRING  COMMENT  '买入凭证编号',
  L_MCPZID  STRING  COMMENT  '卖出凭证编号',
  VC_BZ  STRING  COMMENT  '备注',
  VC_SQBH  STRING  COMMENT  '申请编号',
  EN_MCGYJZBD  DECIMAL(23,4)  COMMENT  '卖出公允价值变动',
  EN_MCGYJZBDSY  DECIMAL(23,4)  COMMENT  '卖出公允价值变动收益',
  VC_JSBZ  STRING  COMMENT  '结算币种',
  EN_EXCH  DECIMAL(18,14)  COMMENT  '汇率',
  EN_MCBWBCB  DECIMAL(23,4)  COMMENT  '卖出本位币成本',
  EN_MCBWBGYJZBD  DECIMAL(23,4)  COMMENT  '卖出本位币公允价值变动',
  EN_MCBWBGYJZBDSY  DECIMAL(23,4)  COMMENT  '卖出本位币公允价值变动收益',
  VC_QSBH  STRING  COMMENT  '券商编号',
  L_DKFX  STRING  COMMENT  '多空方向',
  L_CLBZ  STRING  COMMENT  '处理标志',
  EN_MCZYJ  DECIMAL(23,4)  COMMENT  '卖出折溢价',
  EN_MCBWBZYJ  DECIMAL(23,4)  COMMENT  '卖出本位币折溢价',
  EN_MRZYJ  DECIMAL(23,4)  COMMENT  '买入折溢价',
  EN_MRBWBZYJ  DECIMAL(23,4)  COMMENT  '买入本位币折溢价',
  EN_LXS  DECIMAL(19,4)  COMMENT  '利息税',
  L_QSSD  DECIMAL(2,0)  COMMENT  '清算速度',
  EN_MCYSGL  DECIMAL(23,4)  COMMENT  '卖出应收股利',
  VC_JYDS  STRING  COMMENT  '交易对手',
  EN_MCBWBYSGL  DECIMAL(23,4)  COMMENT  '卖出本位币应收股利',
  EN_QSJE  DECIMAL(19,4)  COMMENT  '清算金额',
  L_GLBH  STRING  COMMENT  '关联编号',
  VC_LLR  STRING  COMMENT  '录入人',
  VC_FHR  STRING  COMMENT  '复核人',
  VC_ZHDM  STRING  COMMENT  '账户代码',
  EN_ZRGZZZ  DECIMAL(19,4)  COMMENT  '转入估值增值',
  D_SJQRRQ  STRING  COMMENT  '实际确认日期',
  VC_BFZH  STRING  COMMENT  '本方账号',
  C_XWLX  STRING  COMMENT  '席位类型',
  L_DZJYBZ  STRING  COMMENT  '大宗交易标志',
  EN_CJJE  DECIMAL(19,4)  COMMENT  '成交金额',
  EN_BZJL  DECIMAL(10,4)  COMMENT  '保证金率',
  EN_MCJZZB  DECIMAL(19,4)  COMMENT  '卖出减值准备',
  EN_MCBWBJZZB  DECIMAL(19,4)  COMMENT  '卖出本位币减值准备',
  L_TQBZ  STRING  COMMENT  '套期保值标志',
  EN_MRZDGHF  DECIMAL(15,4)  COMMENT  '买入中登过户费',
  EN_MCZDGHF  DECIMAL(15,4)  COMMENT  '卖出中登过户费',
  L_SFJZSY  DECIMAL(1,0)  COMMENT  '赎回货币基金是否结转收益',
  D_JSRQ  STRING  COMMENT  '理论交收日期',
  EN_MRFXJ  DECIMAL(15,4)  COMMENT  '买入风险金',
  EN_MCFXJ  DECIMAL(15,4)  COMMENT  '卖出风险金',
  L_CJHBBH  DECIMAL(18,2)  COMMENT  '成交回报编号',
  VC_QSBSLX  STRING  COMMENT  '券商标识类型',
  VC_QSBSDM  STRING  COMMENT  '券商标识代码',
  VC_QSZH  STRING  COMMENT  '券商账户',
  VC_QSDLJGBSLX  STRING  COMMENT  '清算代理机构标识类型',
  VC_QSDLJGBSDM  STRING  COMMENT  '清算代理机构标识代码',
  VC_QSDLJGZH  STRING  COMMENT  '清算代理机构账户',
  VC_QSJGBIC  STRING  COMMENT  '清算机构BIC码',
  EN_SXFFH  DECIMAL(19,4)  COMMENT  '手续费返回',
  EN_MRYSGL  DECIMAL(23,4)  COMMENT  '卖出应收股利',
  EN_MRLXSDS  DECIMAL(19,4)  COMMENT  '买入利息所得税',
  EN_MCLXSDS  DECIMAL(19,4)  COMMENT  '卖出利息所得税',
  EN_MCGZSDS  DECIMAL(19,4)  COMMENT  '卖出估值所得税',
  EN_MCBWBGZSDS  DECIMAL(19,4)  COMMENT  '卖出本位币估值所得税',
  L_SCJSFS  DECIMAL(4,0)  COMMENT  '',
  L_CCFL  DECIMAL(4,0)  COMMENT  '',
  D_SJCJRQ  STRING  COMMENT  '',
  VC_DSFZH  STRING  COMMENT  '',
  VC_QSBZ  STRING  COMMENT  '',
  EN_QSHL  DECIMAL(18,14)  COMMENT  '',
  VC_SJLY  STRING  COMMENT  '',
  L_YTHWHGLBH  DECIMAL(10,0)  COMMENT  '',
  EN_MCJTFYJ  DECIMAL(19,4)  COMMENT  '',
  EN_YFDTFXYYJE  DECIMAL(19,4)  COMMENT  '',
  VC_CBKM  STRING  COMMENT  '',
  L_JSJG  DECIMAL(1,0)  COMMENT  '',
  EN_MRXTSYF  DECIMAL(30,15)  COMMENT  '',
  EN_MCXTSYF  DECIMAL(30,15)  COMMENT  '',
  L_XSQBZ  DECIMAL(1,0)  COMMENT  '',
  L_SHLX  DECIMAL(1,0)  COMMENT  '',
  L_XQSBFS  DECIMAL(1,0)  COMMENT  '',
  L_CJLX  DECIMAL(1,0)  COMMENT  '',
  D_MODIFY  STRING  COMMENT  '',
  VC_XYZJZH  STRING  COMMENT  '',
  L_SFZJLT  DECIMAL(1,0)  COMMENT  '',
  L_CEJYS  DECIMAL(1,0)  COMMENT  '',
  EN_CJJG  DECIMAL(25,12)  COMMENT  '',
  D_CJSJ  STRING  COMMENT  '',
  EN_MRCHJZF  DECIMAL(15,4)  COMMENT  '',
  EN_MCCHJZF  DECIMAL(15,4)  COMMENT  ''
)
COMMENT '清算库'
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
            "username": "${hsfa_username}",
            "password": "${hsfa_password}",
            "connection": [{
              "querySql": ["SELECT  L_BH
                                   , L_ZTBH
                                   , TO_CHAR(D_RQ,'YYYYMMDD') D_RQ
                                   , L_ZQNM
                                   , VC_XWDM
                                   , VC_GDDM
                                   , VC_ZQDM
                                   , L_YWLB
                                   , L_SCLB
                                   , L_MRSL
                                   , EN_MRJE
                                   , L_MCSL
                                   , EN_MCJE
                                   , EN_MRYHS
                                   , EN_MCYHS
                                   , EN_MRJSF
                                   , EN_MCJSF
                                   , EN_MRGHF
                                   , EN_MCGHF
                                   , EN_MRZGF
                                   , EN_MCZGF
                                   , EN_MRSXF
                                   , EN_MCSXF
                                   , EN_MRQTFY
                                   , EN_MCQTFY
                                   , EN_MRYJ
                                   , EN_MCYJ
                                   , EN_MRLX
                                   , EN_MCLX
                                   , L_TZLX
                                   , EN_MCCB
                                   , VC_GZZ
                                   , L_YWLBMX
                                   , L_MRPZID
                                   , L_MCPZID
                                   , VC_BZ
                                   , VC_SQBH
                                   , EN_MCGYJZBD
                                   , EN_MCGYJZBDSY
                                   , VC_JSBZ
                                   , EN_EXCH
                                   , EN_MCBWBCB
                                   , EN_MCBWBGYJZBD
                                   , EN_MCBWBGYJZBDSY
                                   , VC_QSBH
                                   , L_DKFX
                                   , L_CLBZ
                                   , EN_MCZYJ
                                   , EN_MCBWBZYJ
                                   , EN_MRZYJ
                                   , EN_MRBWBZYJ
                                   , EN_LXS
                                   , L_QSSD
                                   , EN_MCYSGL
                                   , VC_JYDS
                                   , EN_MCBWBYSGL
                                   , EN_QSJE
                                   , L_GLBH
                                   , VC_LLR
                                   , VC_FHR
                                   , VC_ZHDM
                                   , EN_ZRGZZZ
                                   , D_SJQRRQ
                                   , VC_BFZH
                                   , C_XWLX
                                   , L_DZJYBZ
                                   , EN_CJJE
                                   , EN_BZJL
                                   , EN_MCJZZB
                                   , EN_MCBWBJZZB
                                   , L_TQBZ
                                   , EN_MRZDGHF
                                   , EN_MCZDGHF
                                   , L_SFJZSY
                                   , D_JSRQ
                                   , EN_MRFXJ
                                   , EN_MCFXJ
                                   , L_CJHBBH
                                   , VC_QSBSLX
                                   , VC_QSBSDM
                                   , VC_QSZH
                                   , VC_QSDLJGBSLX
                                   , VC_QSDLJGBSDM
                                   , VC_QSDLJGZH
                                   , VC_QSJGBIC
                                   , EN_SXFFH
                                   , EN_MRYSGL
                                   , EN_MRLXSDS
                                   , EN_MCLXSDS
                                   , EN_MCGZSDS
                                   , EN_MCBWBGZSDS
                                   , L_SCJSFS
                                   , L_CCFL
                                   , D_SJCJRQ
                                   , VC_DSFZH
                                   , VC_QSBZ
                                   , EN_QSHL
                                   , VC_SJLY
                                   , L_YTHWHGLBH
                                   , EN_MCJTFYJ
                                   , EN_YFDTFXYYJE
                                   , VC_CBKM
                                   , L_JSJG
                                   , EN_MRXTSYF
                                   , EN_MCXTSYF
                                   , L_XSQBZ
                                   , L_SHLX
                                   , L_XQSBFS
                                   , L_CJLX
                                   , D_MODIFY
                                   , VC_XYZJZH
                                   , L_SFZJLT
                                   , L_CEJYS
                                   , EN_CJJG
                                   , D_CJSJ
                                   , EN_MRCHJZF
                                   , EN_MCCHJZF
                                FROM ${hsfa_src_schema}.T_H_QSK
                                WHERE D_RQ between TO_DATE('${p_start_dt}','YYYYMMDD') and TO_DATE('${p_end_dt}','YYYYMMDD')"],
              "jdbcUrl": ["${hsfa_jdbc}"]
            }]
          }
        },
        "writer": {
          "name": "${hdfswriter}",
          "parameter": {
            "column": [{"name": "L_BH", "type": "DOUBLE"}, {"name": "L_ZTBH", "type": "DOUBLE"}, {"name": "D_RQ", "type": "STRING"}, {"name": "L_ZQNM", "type": "DOUBLE"}, {"name": "VC_XWDM", "type": "STRING"}, {"name": "VC_GDDM", "type": "STRING"}, {"name": "VC_ZQDM", "type": "STRING"}, {"name": "L_YWLB", "type": "DOUBLE"}, {"name": "L_SCLB", "type": "DOUBLE"}, {"name": "L_MRSL", "type": "DOUBLE"}, {"name": "EN_MRJE", "type": "DOUBLE"}, {"name": "L_MCSL", "type": "DOUBLE"}, {"name": "EN_MCJE", "type": "DOUBLE"}, {"name": "EN_MRYHS", "type": "DOUBLE"}, {"name": "EN_MCYHS", "type": "DOUBLE"}, {"name": "EN_MRJSF", "type": "DOUBLE"}, {"name": "EN_MCJSF", "type": "DOUBLE"}, {"name": "EN_MRGHF", "type": "DOUBLE"}, {"name": "EN_MCGHF", "type": "DOUBLE"}, {"name": "EN_MRZGF", "type": "DOUBLE"}, {"name": "EN_MCZGF", "type": "DOUBLE"}, {"name": "EN_MRSXF", "type": "DOUBLE"}, {"name": "EN_MCSXF", "type": "DOUBLE"}, {"name": "EN_MRQTFY", "type": "DOUBLE"}, {"name": "EN_MCQTFY", "type": "DOUBLE"}, {"name": "EN_MRYJ", "type": "DOUBLE"}, {"name": "EN_MCYJ", "type": "DOUBLE"}, {"name": "EN_MRLX", "type": "DOUBLE"}, {"name": "EN_MCLX", "type": "DOUBLE"}, {"name": "L_TZLX", "type": "DOUBLE"}, {"name": "EN_MCCB", "type": "DOUBLE"}, {"name": "VC_GZZ", "type": "STRING"}, {"name": "L_YWLBMX", "type": "DOUBLE"}, {"name": "L_MRPZID", "type": "DOUBLE"}, {"name": "L_MCPZID", "type": "DOUBLE"}, {"name": "VC_BZ", "type": "STRING"}, {"name": "VC_SQBH", "type": "STRING"}, {"name": "EN_MCGYJZBD", "type": "DOUBLE"}, {"name": "EN_MCGYJZBDSY", "type": "DOUBLE"}, {"name": "VC_JSBZ", "type": "STRING"}, {"name": "EN_EXCH", "type": "DOUBLE"}, {"name": "EN_MCBWBCB", "type": "DOUBLE"}, {"name": "EN_MCBWBGYJZBD", "type": "DOUBLE"}, {"name": "EN_MCBWBGYJZBDSY", "type": "DOUBLE"}, {"name": "VC_QSBH", "type": "STRING"}, {"name": "L_DKFX", "type": "DOUBLE"}, {"name": "L_CLBZ", "type": "DOUBLE"}, {"name": "EN_MCZYJ", "type": "DOUBLE"}, {"name": "EN_MCBWBZYJ", "type": "DOUBLE"}, {"name": "EN_MRZYJ", "type": "DOUBLE"}, {"name": "EN_MRBWBZYJ", "type": "DOUBLE"}, {"name": "EN_LXS", "type": "DOUBLE"}, {"name": "L_QSSD", "type": "DOUBLE"}, {"name": "EN_MCYSGL", "type": "DOUBLE"}, {"name": "VC_JYDS", "type": "STRING"}, {"name": "EN_MCBWBYSGL", "type": "DOUBLE"}, {"name": "EN_QSJE", "type": "DOUBLE"}, {"name": "L_GLBH", "type": "STRING"}, {"name": "VC_LLR", "type": "STRING"}, {"name": "VC_FHR", "type": "STRING"}, {"name": "VC_ZHDM", "type": "STRING"}, {"name": "EN_ZRGZZZ", "type": "DOUBLE"}, {"name": "D_SJQRRQ", "type": "STRING"}, {"name": "VC_BFZH", "type": "STRING"}, {"name": "C_XWLX", "type": "STRING"}, {"name": "L_DZJYBZ", "type": "DOUBLE"}, {"name": "EN_CJJE", "type": "DOUBLE"}, {"name": "EN_BZJL", "type": "DOUBLE"}, {"name": "EN_MCJZZB", "type": "DOUBLE"}, {"name": "EN_MCBWBJZZB", "type": "DOUBLE"}, {"name": "L_TQBZ", "type": "DOUBLE"}, {"name": "EN_MRZDGHF", "type": "DOUBLE"}, {"name": "EN_MCZDGHF", "type": "DOUBLE"}, {"name": "L_SFJZSY", "type": "DOUBLE"}, {"name": "D_JSRQ", "type": "STRING"}, {"name": "EN_MRFXJ", "type": "DOUBLE"}, {"name": "EN_MCFXJ", "type": "DOUBLE"}, {"name": "L_CJHBBH", "type": "DOUBLE"}, {"name": "VC_QSBSLX", "type": "STRING"}, {"name": "VC_QSBSDM", "type": "STRING"}, {"name": "VC_QSZH", "type": "STRING"}, {"name": "VC_QSDLJGBSLX", "type": "STRING"}, {"name": "VC_QSDLJGBSDM", "type": "STRING"}, {"name": "VC_QSDLJGZH", "type": "STRING"}, {"name": "VC_QSJGBIC", "type": "STRING"}, {"name": "EN_SXFFH", "type": "DOUBLE"}, {"name": "EN_MRYSGL", "type": "DOUBLE"}, {"name": "EN_MRLXSDS", "type": "DOUBLE"}, {"name": "EN_MCLXSDS", "type": "DOUBLE"}, {"name": "EN_MCGZSDS", "type": "DOUBLE"}, {"name": "EN_MCBWBGZSDS", "type": "DOUBLE"}, {"name": "L_SCJSFS", "type": "DOUBLE"}, {"name": "L_CCFL", "type": "DOUBLE"}, {"name": "D_SJCJRQ", "type": "STRING"}, {"name": "VC_DSFZH", "type": "STRING"}, {"name": "VC_QSBZ", "type": "STRING"}, {"name": "EN_QSHL", "type": "DOUBLE"}, {"name": "VC_SJLY", "type": "STRING"}, {"name": "L_YTHWHGLBH", "type": "DOUBLE"}, {"name": "EN_MCJTFYJ", "type": "DOUBLE"}, {"name": "EN_YFDTFXYYJE", "type": "DOUBLE"}, {"name": "VC_CBKM", "type": "STRING"}, {"name": "L_JSJG", "type": "DOUBLE"}, {"name": "EN_MRXTSYF", "type": "DOUBLE"}, {"name": "EN_MCXTSYF", "type": "DOUBLE"}, {"name": "L_XSQBZ", "type": "DOUBLE"}, {"name": "L_SHLX", "type": "DOUBLE"}, {"name": "L_XQSBFS", "type": "DOUBLE"}, {"name": "L_CJLX", "type": "DOUBLE"}, {"name": "D_MODIFY", "type": "STRING"}, {"name": "VC_XYZJZH", "type": "STRING"}, {"name": "L_SFZJLT", "type": "DOUBLE"}, {"name": "L_CEJYS", "type": "DOUBLE"}, {"name": "EN_CJJG", "type": "DOUBLE"}, {"name": "D_CJSJ", "type": "STRING"}, {"name": "EN_MRCHJZF", "type": "DOUBLE"}, {"name": "EN_MCCHJZF", "type": "DOUBLE"}],
            "compress": "",
            "defaultFS": "${defaultFS}",
            "hadoopConfig": {
              "dfs.data.transfer.protection": "authentication",
              "dfs.client.use.datanode.hostname": "true"
            },
            "fieldDelimiter": "\\u0001",
            "fileName": "ods_hsfa_tqsk_ptd_tmp",
            "fileType": "text",
            "path": "${hsfa_path}/ods_hsfa_tqsk_ptd_tmp",
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

sudo -u ${ds_user} echo $json_obj>${json_path}ods_hsfa_tqsk_ptd_tmp.json

sudo -u ${ds_user} python ${datax_path} -j "-Xms384m -Xmx2g" ${json_path}ods_hsfa_tqsk_ptd_tmp.json

if [ $? -ne 0 ]; then
   echo "导入到ODS_HSFA_TQSK_PTD_TMP表失败"
   exit 1
else
   echo "导入到ODS_HSFA_TQSK_PTD_TMP表成功"
   sudo -u ${ds_user} rm -f ${json_path}ods_hsfa_tqsk_ptd_tmp.json

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
INSERT OVERWRITE TABLE ODS_XDAY_HSFA.ODS_HSFA_TQSK_PTD PARTITION(P_DT)
SELECT
       L_BH
     , L_ZTBH
     , D_RQ
     , L_ZQNM
     , VC_XWDM
     , VC_GDDM
     , VC_ZQDM
     , L_YWLB
     , L_SCLB
     , L_MRSL
     , EN_MRJE
     , L_MCSL
     , EN_MCJE
     , EN_MRYHS
     , EN_MCYHS
     , EN_MRJSF
     , EN_MCJSF
     , EN_MRGHF
     , EN_MCGHF
     , EN_MRZGF
     , EN_MCZGF
     , EN_MRSXF
     , EN_MCSXF
     , EN_MRQTFY
     , EN_MCQTFY
     , EN_MRYJ
     , EN_MCYJ
     , EN_MRLX
     , EN_MCLX
     , L_TZLX
     , EN_MCCB
     , VC_GZZ
     , L_YWLBMX
     , L_MRPZID
     , L_MCPZID
     , VC_BZ
     , VC_SQBH
     , EN_MCGYJZBD
     , EN_MCGYJZBDSY
     , VC_JSBZ
     , EN_EXCH
     , EN_MCBWBCB
     , EN_MCBWBGYJZBD
     , EN_MCBWBGYJZBDSY
     , VC_QSBH
     , L_DKFX
     , L_CLBZ
     , EN_MCZYJ
     , EN_MCBWBZYJ
     , EN_MRZYJ
     , EN_MRBWBZYJ
     , EN_LXS
     , L_QSSD
     , EN_MCYSGL
     , VC_JYDS
     , EN_MCBWBYSGL
     , EN_QSJE
     , L_GLBH
     , VC_LLR
     , VC_FHR
     , VC_ZHDM
     , EN_ZRGZZZ
     , D_SJQRRQ
     , VC_BFZH
     , C_XWLX
     , L_DZJYBZ
     , EN_CJJE
     , EN_BZJL
     , EN_MCJZZB
     , EN_MCBWBJZZB
     , L_TQBZ
     , EN_MRZDGHF
     , EN_MCZDGHF
     , L_SFJZSY
     , D_JSRQ
     , EN_MRFXJ
     , EN_MCFXJ
     , L_CJHBBH
     , VC_QSBSLX
     , VC_QSBSDM
     , VC_QSZH
     , VC_QSDLJGBSLX
     , VC_QSDLJGBSDM
     , VC_QSDLJGZH
     , VC_QSJGBIC
     , EN_SXFFH
     , EN_MRYSGL
     , EN_MRLXSDS
     , EN_MCLXSDS
     , EN_MCGZSDS
     , EN_MCBWBGZSDS
     , L_SCJSFS
     , L_CCFL
     , D_SJCJRQ
     , VC_DSFZH
     , VC_QSBZ
     , EN_QSHL
     , VC_SJLY
     , L_YTHWHGLBH
     , EN_MCJTFYJ
     , EN_YFDTFXYYJE
     , VC_CBKM
     , L_JSJG
     , EN_MRXTSYF
     , EN_MCXTSYF
     , L_XSQBZ
     , L_SHLX
     , L_XQSBFS
     , L_CJLX
     , D_MODIFY
     , VC_XYZJZH
     , L_SFZJLT
     , L_CEJYS
     , EN_CJJG
     , D_CJSJ
     , EN_MRCHJZF
     , EN_MCCHJZF
     , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') LD_TIME
     , REPLACE(D_RQ,'-','') P_DT
  FROM ODS_XDAY_HSFA.ODS_HSFA_TQSK_PTD_TMP
;
TRUNCATE TABLE ODS_XDAY_HSFA.ODS_HSFA_TQSK_PTD_TMP;"
if [ $? -ne 0 ]; then
      echo "插入到ODS_HSFA_TQSK_PTD失败"
      exit 1
   else
      echo "插入到ODS_HSFA_TQSK_PTD成功"
      exit 0
   fi
fi
