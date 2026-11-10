#!/bin/sh
#初始化环境变量：
source /home/dolphinscheduler/hadoop_env
inceptor_beeline()
{
    beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
}

inceptor_beeline "
-- **************************************************************************
-- ** 主题: 产品
-- ** 描述: 产品编码映射
-- ** 创建者 : hejl
-- ** 创建日期: 20230511
-- ** 修改日志:
-- ** 20230511，hejl，新建
-- ** 目标表：DWDXDAY.DWD_PTY_DELR_INFO_PFD 交易员信息
-- ** 源表：  ODS_XDAY_o32.ODS_O32_TRIVALTRADER_PFD 银行间交易对手交易员信息表
-- **         ODS_XDAY_o32.ODS_O32_TSTOCKRIVALTRADER_PFD 银行间交易对手交易员信息表
-- **************************************************************************

set hive.strict.checks.type.safety=false;
set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.merge.mapredfiles=true;
set hive.merge.mapfiles=true;
set hive.merge.smallfiles.avgsize=16000000;
set hive.merge.size.per.task=256000000;
set hive.exec.reducers.bytes.per.reducer=10240000000; 
set mapreduce.job.reduces=3;

INSERT INTO TABLE DWDXDAY.DWD_PTY_DELR_INFO_PFD
SELECT A2.CNTP_NUM                                                             AS CNTP_NUM     --交易对手方编码
   , A1.L_RIVAL_ID                                                             AS CNTP_NO      --交易对手方编号
   , A1.VC_TRADER_NAME                                                         AS DELR_ID      --交易员ID
   , A1.VC_TRADER_ID                                                           AS DELR_NAME    --交易员名称
   , A1.L_ORG_ID                                                               AS BELT_CORP    --所属公司
   , A1.VC_PHONE                                                               AS PHONE        --手机
   , A1.VC_FAX                                                                 AS FAX          --传真
   , A1.VC_EMAIL                                                               AS MAILBOX      --邮箱
   , A1.VC_MSN                                                                 AS MSN          --MSN
   , A1.VC_ADDRESS                                                             AS ADDR         --地址
   , A1.VC_POSTCODE                                                            AS PTCD         --邮政编码
   , '04'                                                                      AS TRAN_MKT     --交易市场
   , 'O32'                                                                     AS SSYS         --源系统
   , 'ODS_O32_TRIVALTRADER_PFD'                                                AS SOURCE_TAB   --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')  AS LD_TIME      --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')  AS MODIFY_TIME  --修改时间
     FROM ODS_XDAY_O32.ODS_O32_TRIVALTRADER_PFD A1  --银行间交易对手交易员信息表
     LEFT JOIN DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_PFD A2  --交易对手方编码映射
       ON A1.L_RIVAL_ID = A2.CNTP_NO
      AND A2.ST_DATE <= '${P_BATCH_DT}'
      AND A2.END_DATE > '${P_BATCH_DT}'
      AND A2.SSYS='O32'
      AND A2.SRC_TAB = 'ODS_O32_TTRADERIVAL_PFD'
      AND A2.VALID_FLAG = '1'
     WHERE A1.P_DT = '${P_BATCH_DT}'
      AND SUBSTR(A1.VC_TIMESTAMP,1,8)='${P_BATCH_DT}';
INSERT INTO TABLE DWDXDAY.DWD_PTY_DELR_INFO_PFD
SELECT A2.CNTP_NUM                                                            AS CNTP_NUM       --交易对手方编码
   , A1.L_RIVAL_ID                                                            AS CNTP_NO        --交易对手方编号
   , A1.VC_TRADER_NAME                                                        AS DELR_ID        --交易员ID
   , A1.VC_TRADER_ID                                                          AS DELR_NAME      --交易员名称
   , A1.L_ORG_ID                                                              AS BELT_CORP      --所属公司
   , A1.VC_PHONE                                                              AS PHONE          --手机
   , A1.VC_FAX                                                                AS FAX            --传真
   , A1.VC_EMAIL                                                              AS MAILBOX        --邮箱
   , A1.VC_MSN                                                                AS MSN            --MSN
   , A1.VC_ADDRESS                                                            AS ADDR           --地址
   , A1.VC_POSTCODE                                                           AS PTCD           --邮政编码
   , A3.STD_DICT_CLS_CD_VAL                                                   AS TRAN_MKT       --交易市场
   , 'O32'                                                                    AS SSYS           --源系统
   , 'ODS_O32_TSTOCKRIVALTRADER_PFD'                                          AS SOURCE_TAB     --源表
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME        --加载时间
   , FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME    --修改时间
     FROM ODS_XDAY_O32.ODS_O32_TSTOCKRIVALTRADER_PFD A1   --交易所交易对手交易员信息表
     LEFT JOIN DWDXDAY.DWD_PTY_CNTP_NUM_MAPP_PFD A2  --交易对手方编码映射
       ON A1.L_RIVAL_ID = A2.CNTP_NO
      AND A2.ST_DATE <= '${P_BATCH_DT}' 
      AND A2.END_DATE > '${P_BATCH_DT}'
      AND A2.SSYS='O32'
      AND A2.SRC_TAB = 'ODS_O32_TTRADERIVAL_PFD' 
      AND A2.VALID_FLAG = '1'
     LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A3  --标准字典码值映射
       ON A3.SRC_DICT_CLS_CD= 'C_MARKET_NO'
      AND A3.SSYS= 'O32' 
      AND A1.C_MARKET_NO = A3.SRC_DICT_CLS_CDVAL 
      AND A3.VALID_FLAG='1'
     WHERE SUBSTR(A1.VC_TIMESTAMP,1,8)='${P_BATCH_DT}'
       AND A1.P_DT='${P_BATCH_DT}';

"
