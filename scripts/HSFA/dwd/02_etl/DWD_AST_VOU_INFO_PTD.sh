#!/bin/sh
#初始化环境变量：
begin_date="${p_start_dt}"
end_date="${p_end_dt}"
P_BATCH_DT=$begin_date
echo  $P_BATCH_DT
while [ $P_BATCH_DT -le $end_date ]; 
do
    source /home/dolphinscheduler/hadoop_env
    inceptor_beeline()
    {
        beeline -u ${hive_jdbc} -n ${hive_username} -p ${hive_password}   -e "$1"
    }
    
    inceptor_beeline "
    -- **************************************************************************
    -- ** 主题: 资产
    -- ** 描述: 凭证信息
    -- ** 创建日期: 20230523
    -- ** 目标表：DWDXDAY.DWD_AST_VOU_INFO_PTD             凭证信息表
    -- ** 源表：  ODS_XDAY_HSFA.ODS_HSFA_TVOUCHER_PTD      凭证主表
    -- **         ODS_XDAY_HSFA.ODS_HSFA_TVOUCHERS_PTD      凭证子表
    -- **         DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD        帐套编码映射
    -- **         ODS_XDAY_HSFA.ODS_HSFA_TFUNDINFO_PFD      基金信息表
    -- **         DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP        标准字典码值映射
    -- **         DWDXDAY.DWD_AST_VOU_INFO_PTD_tmp            凭证信息临时表
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
    
    INSERT OVERWRITE TABLE DWDXDAY.DWD_AST_VOU_INFO_PTD PARTITION (P_DT = '${P_BATCH_DT}')
    SELECT
       D1.SFAC_NO           --账套编号
       ,D1.SFAC_NUM          --账套编码
       ,D1.PROD_CODE         --产品代码
       ,D1.BUSIN_DATE        --业务日期
       ,D1.VOU_NO            --凭证号
       ,D1.SUBNO             --分录号
       ,D1.ACCUT_YEAR        --会计年份
       ,D1.ACCUT_MTH         --会计月份
       ,D1.VOU_ABS           --凭证摘要
       ,D1.CRSE_CODE         --科目代码
       ,D1.CRSE_NAME         --科目名称
       ,D1.DEBC_ORNT         --借贷方向
       ,D1.LC_DBT_AMT        --本币借方金额
       ,D1.LC_LDR_AMT        --本币贷方金额
       ,D1.ORI_CRRC_DBT_AMT  --原币借方金额
       ,D1.ORI_CRRC_LDR_AMT  --原币贷方金额
       ,D1.QTY               --数量
       ,D1.CRRC_CODE         --币种代码
       ,D1.VOU_DATE          --凭证日期
       ,D1.EXCR              --汇率
       ,D1.SCR_INCD          --证券内码
       ,D1.SYMBOL            --证券代码
       ,D1.SCR_TYPE          --证券类型
       ,D1.SCR_DETAIL_TYPE   --证券明细类型
       ,D1.INV_CATG          --投资分类
       ,D1.TRAN_MKT          --交易市场
       ,D1.CASH_ACCT         --现金账户
       ,D1.CRSE_PROP         --科目属性
       ,D1.CRSE_PROP_NAME    --科目属性名称
       ,D1.RULER             --制单人
       ,D1.RULE_TIME         --制单时间
       ,D1.AUDTR             --审核人
       ,D1.AUDT_TIME         --审核时间
       ,D1.ACCOR             --记账人
       ,D1.ACCO_TIME         --记账时间
       ,D1.REVISER           --修改人
       ,D1.SSYS              --源系统
       ,D1.SOURCE_TAB        --源表
       ,D1.LD_TIME           --加载时间
       ,D1.MODIFY_TIME       --修改时间
       ,D1.SCR_NUM  --证券编码
       ,D1.VOU_TYPE --凭证类别
       ,D2.VC_ZQMC AS DPSI_BANK -- 存款银行
    FROM
        (
        SELECT 
            CAST(A1.L_FUNDID AS STRING)                           AS SFAC_NO           --账套编号
           ,A10.SFAC_NUM                                          AS SFAC_NUM          --账套编码
           ,A10.PROD_CODE                                         AS PROD_CODE         --产品代码
           ,A1.D_MAKE                                             AS BUSIN_DATE        --业务日期
           ,CAST(A1.L_NO AS STRING)                               AS VOU_NO            --凭证号
           ,CAST(A3.L_ROW AS STRING)                              AS SUBNO             --分录号
           ,CAST(A3.L_YEAR AS STRING)                             AS ACCUT_YEAR        --会计年份
           ,CAST(A3.L_MONTH AS STRING)                            AS ACCUT_MTH         --会计月份
           ,A3.VC_DIGEST                                          AS VOU_ABS           --凭证摘要
           ,A3.VC_CODE                                            AS CRSE_CODE         --科目代码
           ,A3.VC_FULLNAME                                        AS CRSE_NAME         --科目名称
           ,CAST(A3.L_KMFX AS STRING)                             AS DEBC_ORNT         --借贷方向
           ,A3.EN_DEBIT                                           AS LC_DBT_AMT        --本币借方金额
           ,A3.EN_CREDIT                                          AS LC_LDR_AMT        --本币贷方金额
           ,A3.EN_FOREIGN                                         AS ORI_CRRC_DBT_AMT  --原币借方金额
           ,A3.EN_FOREIGN                                         AS ORI_CRRC_LDR_AMT  --原币贷方金额
           ,A3.EN_QUANTITY                                        AS QTY               --数量
           ,A3.VC_JSBZ                                            AS CRRC_CODE         --币种代码
           ,A3.D_DATE                                             AS VOU_DATE          --凭证日期
           ,A3.EN_EXCH                                            AS EXCR              --汇率
           ,A3.SCR_INCD                                           AS SCR_INCD          --证券内码
           ,A3.SYMBOL                                             AS SYMBOL            --证券代码
           ,CASE WHEN CAST(A3.L_CZBZID AS STRING) ='401' AND LENGTH(A3.SCR_INCD)<>0 THEN '22' ELSE A3.SCR_TYPE END AS SCR_TYPE          --证券类型
           ,CASE WHEN CAST(A3.L_CZBZID AS STRING) ='401' THEN 
                      CASE WHEN A3.VC_NAME_HS LIKE '%定期存款%' THEN '2202'
                           WHEN A3.VC_NAME_HS LIKE '%协议存款%' THEN '2203'
                           WHEN A3.VC_NAME_HS LIKE '%通知存款%' THEN '2204'
                       ELSE '' END
            ELSE A3.SCR_DETAIL_TYPE END  AS SCR_DETAIL_TYPE   --证券明细类型
           ,CAST(A3.L_TZLX AS STRING)                             AS INV_CATG          --投资分类
           ,A3.VC_BOURSE                                          AS TRAN_MKT          --交易市场
           ,A3.VC_INVESTACC                                       AS CASH_ACCT         --现金账户
           ,A3.VC_CODE_HS                                         AS CRSE_PROP         --科目属性
           ,A3.VC_NAME_HS                                         AS CRSE_PROP_NAME    --科目属性名称
           ,A1.VC_MAKER                                           AS RULER             --制单人
           ,A1.D_MAKE                                             AS RULE_TIME         --制单时间
           ,A1.VC_CHECKER                                         AS AUDTR             --审核人
           ,A1.D_CHECKSJ                                          AS AUDT_TIME         --审核时间
           ,A1.VC_BOOKER                                          AS ACCOR             --记账人
           ,A1.D_BOOKSJ                                           AS ACCO_TIME         --记账时间
           ,A1.VC_FHR                                             AS REVISER           --修改人
           ,'HSFA'                                                AS SSYS              --源系统
           ,''        AS SOURCE_TAB        --源表
           ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')  AS LD_TIME           --加载时间
           ,FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyy-MM-dd HH:mm:ss')  AS MODIFY_TIME       --修改时间
           ,A3.SCR_NUM AS SCR_NUM  --证券编码
           ,CAST(A3.L_CZBZID AS STRING) AS VOU_TYPE --凭证类别
           ,CASE WHEN CAST(A3.L_CZBZID AS STRING) ='401' THEN A3.SCR_INCD ELSE '' END AS DPSI_NO  --存单编号
        FROM 
            (
            SELECT L_ID, L_FUNDID, L_YEAR, L_MONTH, L_NO, L_DOCS, D_MAKE, VC_MAKER, VC_CHECKER, VC_BOOKER, VC_CASHIER, VC_ADMIN, L_STATE, L_CONTRA, L_TURN, D_CHECKSJ, D_BOOKSJ,L_ZZGSBH,L_CONTRAFLAG,VC_FHR
            FROM ODS_XDAY_HSFA.ODS_HSFA_TVOUCHER_PTD WHERE L_STATE<>32 AND P_DT = '${P_BATCH_DT}'
            UNION ALL
            SELECT L_ID, L_FUNDID, L_YEAR, L_MONTH, L_NO, L_DOCS, D_MAKE, VC_MAKER, VC_CHECKER, VC_BOOKER, VC_CASHIER, VC_ADMIN, L_STATE, L_CONTRA, L_TURN, D_CHECKSJ, D_BOOKSJ,L_ZZGSBH,L_CONTRAFLAG,VC_FHR
            FROM ODS_XDAY_HSFA.ODS_HSFA_T_H_VOUCHER_PTD WHERE L_STATE<>32 AND P_DT = '${P_BATCH_DT}'
            ) A1     --凭证主表
        LEFT JOIN DWDXDAY.DWD_PROD_SFAC_NUM_MAPP_PFD A10     --帐套编码映射
        ON CAST(A1.L_FUNDID AS STRING)=A10.SFAC_INCD AND A10.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
        LEFT JOIN 
            (SELECT 
               T1.L_FUNDID   --帐套编号
              ,T1.L_ROW    --行号
              ,T1.L_YEAR  --会计年度
              ,T1.L_MONTH  --会计月度
              ,T1.VC_DIGEST  --帐簿摘要
              ,T1.VC_CODE  --会计科目编码
              ,T1.VC_FULLNAME  --会计科目全路径名称
              ,T1.L_KMFX  
              ,T1.EN_DEBIT  --借方金额
              ,T1.EN_CREDIT  --贷方金额
              ,T1.EN_FOREIGN  --外币金额
              ,T1.EN_QUANTITY  --数量
              ,T1.VC_JSBZ  --结算币种
              ,T1.D_DATE    --生成日期
              ,T1.EN_EXCH  --汇率
              ,A11.SCR_NUM AS SCR_NUM  --证券编码
              ,A11.SYMBOL  --证券代码
              ,CAST(T1.L_ZQNM AS STRING) AS SCR_INCD --证券内码
              ,NVL(T4.STD_DICT_CLS_CD_VAL,'2') AS L_TZLX   --投资类型
              ,A11.TRAN_MKT_CODE AS VC_BOURSE --交易市场
              ,T1.D_MAKE  --业务日期
              ,T1.VC_INVESTACC  --险种
              ,T1.L_MAINID  --主表编号
              ,T1.VC_CODE_HS  --科目属性
              ,T2.VC_NAME_HS  --科目属性名称
              ,A11.SCR_TYPE  --证券类别
              ,A11.SCR_DETAIL_TYPE  --证券明细类型
              ,T1.L_CZBZID  --凭证类别
            FROM 
                (
                SELECT L_ID, L_FUNDID, L_MAINID, L_ROW, VC_DIGEST, VC_CODE, VC_FULLNAME, EN_DEBIT, EN_CREDIT, EN_FOREIGN, EN_EXCH, EN_QUANTITY, EN_PRICE, VC_DEPARTMENT, VC_CASH, VC_INSURANCE, VC_CHARGE, VC_BOURSE, VC_DAYS, VC_INVESTACC, VC_SETTLENO, VC_COSTAPPORTION, L_TZLX, L_ZQNM, VC_CODE_HS, VC_JSBZ, D_MAKE, EN_TRADEAMO, EN_FORTRADEAMO, L_STATE, L_CCHSID, D_DATE, L_YEAR, L_MONTH,L_KMFX ,L_CZBZID FROM ODS_XDAY_HSFA.ODS_HSFA_TVOUCHERS_PTD WHERE P_DT = '${P_BATCH_DT}'
                UNION ALL
                SELECT L_ID, L_FUNDID, L_MAINID, L_ROW, VC_DIGEST, VC_CODE, VC_FULLNAME, EN_DEBIT, EN_CREDIT, EN_FOREIGN, EN_EXCH, EN_QUANTITY, EN_PRICE, VC_DEPARTMENT, VC_CASH, VC_INSURANCE, VC_CHARGE, VC_BOURSE, VC_DAYS, VC_INVESTACC, VC_SETTLENO, VC_COSTAPPORTION, L_TZLX, L_ZQNM, VC_CODE_HS, VC_JSBZ, D_MAKE, EN_TRADEAMO, EN_FORTRADEAMO, L_STATE, L_CCHSID, D_DATE, L_YEAR, L_MONTH,L_KMFX ,L_CZBZID FROM ODS_XDAY_HSFA.ODS_HSFA_T_H_VOUCHERS_PTD WHERE P_DT = '${P_BATCH_DT}'
                ) T1   --凭证子表
            LEFT JOIN 
                (SELECT 
                    B1.L_ID AS L_FUNDID  --账套编号
                    ,B2.VC_CODE AS VC_CODE_HS --科目属性
                    ,B2.VC_NAME_HS  --科目属性名称
                    FROM ODS_XDAY_HSFA.ODS_HSFA_TSYSINFO_PFD B1  -- 帐套信息表
                    INNER JOIN 
                    (SELECT 
                        C1.VC_CODE  --科目属性
                        ,C1.VC_NAME_HS  --科目属性名称
                        ,C1.L_ZTBH  --账套模板
                     FROM ODS_XDAY_HSFA.ODS_HSFA_TACCOUNT_HS_PFD C1  --科目属性表
                     WHERE C1.P_DT = '${P_BATCH_DT}'
                    ) B2
                    ON B1.L_TYPE=B2.L_ZTBH AND B1.L_VOID='0' AND B1.P_DT = '${P_BATCH_DT}'
                )T2
            ON T1.VC_CODE_HS=T2.VC_CODE_HS AND T1.L_FUNDID=T2.L_FUNDID
            LEFT JOIN 
                (SELECT
                    C1.SCR_NUM  --证券编码
                    ,C1.SYMBOL  --证券代码
                    ,C1.TRAN_MKT_CODE  --交易市场
                    ,C2.SCR_INCD  --证券内码
                    ,C3.SCR_PRI_CATG_CODE AS SCR_TYPE  --证券类别代码(证券类型)
                    ,C3.SCR_SCD_CATG_CODE AS SCR_DETAIL_TYPE  --分类代码(证券明细类型)
                FROM DWDXDAY.DWD_SCR_SCR_BASIC_INFO_PFD C1 --证券基本信息
                LEFT JOIN DWDXDAY.DWD_SCR_SCR_NUM_MAPP_PFD C2  -- 证券编码映射
                ON C1.SCR_NUM=C2.SCR_NUM AND C2.SSYS= 'HSFA' AND C2.VALID_FLAG=1 AND C2.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
                LEFT JOIN DWDXDAY.DWD_SCR_SCR_CATG_INFO_PFD C3  --证券分类信息
                ON C1.SCR_NUM=C3.SCR_NUM AND C3.CATG_CALIBRE_CODE='HSFA_SCR_CATG_CODE' AND C3.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
                WHERE C1.P_DT = DATE_ADD(FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()),'yyyyMMdd'),-1)
                ) A11  --证券编码映射
            ON CAST(T1.L_ZQNM AS STRING)=A11.SCR_INCD 
            LEFT JOIN DWDXDAY.DWD_CMM_STD_DICT_CDVAL_MAP T4  --标准字典码值映射
            ON CAST(T1.L_TZLX AS STRING) = T4.SRC_DICT_CLS_CDVAL AND T4.SSYS= 'HSFA' AND T4.SRC_DICT_CLS_CD= 'L_TZLX' AND T4.VALID_FLAG='1'
        ) A3 --凭证子表
        ON A1.L_FUNDID=A3.L_FUNDID AND A1.L_ID=A3.L_MAINID
        ) D1
    LEFT JOIN ODS_XDAY_HSFA.ODS_HSFA_TCAP_CKYW_PFD D2
    ON D1.DPSI_NO=D2.L_CKID AND D2.P_DT = '${P_BATCH_DT}'
    ; 
    "
    P_BATCH_DT=$(date -d "$P_BATCH_DT+1days" +%Y%m%d)
done
