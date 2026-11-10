  #初始化环境变量：
  begin_date="${p_start_dt}"
  end_date="${p_end_dt}"
  P_BATCH_DT=$begin_date
  echo  $P_BATCH_DT
  while [ $P_BATCH_DT -lt $end_date ]; 
  do
      source /home/dolphinscheduler/hadoop_env
      inceptor_beeline()
      {
          beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
      }

      inceptor_beeline "
      -- **************************************************************************
      -- ** 主题: 事件
      -- ** 描述: 收支结转业务
      -- ** 创建者 :VHHV
      -- ** 创建日期: 20230621
      -- ** 目标表：DWDXDAY.DWD_EVT_IAO_CARRYOVER_BUSIN_PTD    收支结转业务
      -- ** 源表：  ODS_XDAY_HSFA.ODS_HSFA_TQSKJZLS_PTD   科目结转流水表
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
      set mapreduce.job.reduces=2;

      INSERT OVERWRITE TABLE DWDXDAY.DWD_EVT_IAO_CARRYOVER_BUSIN_PTD PARTITION (P_DT = '${P_BATCH_DT}')
      SELECT
          CAST(A1.L_ZTBH AS STRING) AS SFAC_NO -- 账套编号
          ,A10.SFAC_NUM AS SFAC_NUM -- 账套编码
          ,A1.D_DATE AS TRAN_DATE -- 交易日期
          ,A10.PROD_CODE AS PROD_CODE -- 产品代码
          ,A1.VC_JSBZ AS CRRC -- 币种
          ,A5.STD_DICT_CLS_CD_VAL AS BUSIN_CATG -- 业务类别
          ,A1.EN_WBYE AS ORI_CRRC_BAL -- 原币余额
          ,A1.EN_KMYE AS LC_BAL -- 本币余额
          ,A1.EN_WBJZJE AS ORI_CRRC_CARRYOVER_AMT -- 原币结转金额
          ,A1.EN_BWBJZJE AS LC_CARRYOVER_AMT -- 本币结转金额
          ,A1.VC_JFKM AS DBT_CRSE -- 借方科目
          ,A1.VC_DFKM AS LDR_CRSE -- 贷方科目
          ,A1.VC_ZY AS ABS -- 摘要
          ,CAST(A1.L_TS AS STRING) AS DAYS -- 天数
          ,A1.D_YERQ AS BAL_DATE -- 余额日期
          ,CAST(A1.L_CLBZ AS STRING) AS DEAL_FLAG -- 处理标志
          ,A1.VC_JZZQ AS CARRYOVER_PD -- 结转周期
          ,CAST(A1.L_KIND AS STRING) AS CRSE_ORNT -- 科目方向
          ,CAST(A1.L_LBMX AS STRING) AS FEE_CATG -- 费用类别
          ,CAST(A1.L_ID AS STRING) AS DEAL_NO -- 成交编号
          ,CAST(A1.L_BH AS STRING) AS RELA_NO -- 关联编号
          ,A1.EN_ZFBL AS PAY_RATE -- 支付比例
          ,CAST(A1.L_JSFS AS STRING) AS CALCT_MODE -- 计算方式
          ,A1.EN_EXCH AS EXCR -- 汇率
          ,'HSFA' AS SSYS -- 源系统
          ,'ODS_HSFA_TQSKJZLS_PTD' AS SOURCE_TAB -- 源表
          ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS LD_TIME -- 加载时间
          ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss') AS MODIFY_TIME -- 修改时间
      FROM ODS_XDAY_HSFA.ODS_HSFA_TQSKJZLS_PTD A1 -- 科目结转流水表
      LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD A10  -- 帐套编码映射
      ON CAST(A1.L_ZTBH AS STRING) = A10.SFAC_INCD AND A10.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
      LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP A5
      ON A5.SSYS= 'HSFA' AND A5.SRC_DICT_CLS_CD = 'L_YWLB' AND CAST(A1.L_YWLB AS STRING) = A5.SRC_DICT_CLS_CDVAL  AND A5.VALID_FLAG='1'
      WHERE A1.P_DT = '${P_BATCH_DT}'
      ;
      "
      P_BATCH_DT=$(date -d "$P_BATCH_DT+1days" +%Y%m%d)
  done
