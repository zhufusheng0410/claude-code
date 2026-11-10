#!/bin/sh
#=====================================================================
# ★★★ 占位作业（2026-10-11 建）★★★
#
# 背景：DWD 层 6 个脚本引用 ODS_XDAY_MANUAL.ODS_MANUAL_SPEBA_MANUAL_INFO_PFD，
#   但 MANUAL 源库里没有对应的物理表，上游也一直没提供抽数口径。
#
# 处置：本作业**不做任何抽数**，只作为 DWD 依赖配置的上游锚点存在
#   —— DWD 的 DEPENDENT 节点要能指向一个"真实存在的工作流"，
#      否则依赖配置过不去、整条 DWD 工作流建不起来。
#
# 表结构：列清单由 6 个 DWD 脚本的 T1./T12. 字段引用并集推导，
#   见 scripts/MANUAL/ods/ddl/ODS_MANUAL_SPEBA_MANUAL_INFO_PFD.sql
#   （类型尽量对齐 DWD 目标表 DDL，减少 JOIN 时的隐式转换）。
#
# 后续若要接真数据，只需把下面 echo 段换成标准 ODS 抽数模板
#   （DROP/CREATE _TMP → DataX json → INSERT OVERWRITE → TRUNCATE），
#   并同步 DDL 的列类型。
#=====================================================================
echo "[占位] ODS_MANUAL_SPEBA_MANUAL_INFO_PFD 无源数据，本作业不执行抽数。"
echo "[占位] DWD 依赖锚点作业，正常退出。"
exit 0
