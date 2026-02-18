#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# gates/config.sh  (v2.2)
# 你们团队只需要改这一处：
# - 项目目录风格（controller/vo/form 等）
# - DB 迁移目录（Flyway/Liquibase）
# - MyBatis XML 落点
# ============================================================

# ------------------------
# Contract Gate
# ------------------------
# warn: 默认告警（便于增量落地）；block: 阻断
export CURSOR_CONTRACT_GATE_MODE="${CURSOR_CONTRACT_GATE_MODE:-warn}"

# 目录白名单（仅当变更命中这些目录/文件时才触发契约门禁）
# 使用正则（grep -E），多个用 | 连接
# 例：src/main/java/.*/controller/  或  src/main/java/.*/(controller|api)/
export CURSOR_API_DIR_WHITELIST_RE="${CURSOR_API_DIR_WHITELIST_RE:-src/main/java/.*/(controller|api|web|rest|resource)/|src/main/java/.*/(dto|vo|form|request|response)/}"

# 识别 API 文件类型
export CURSOR_API_FILE_RE="${CURSOR_API_FILE_RE:-\.(java|kt)$}"

# OpenAPI 文件识别（允许 contracts/openapi.yaml 或 openapi.yaml）
export CURSOR_OPENAPI_FILE_RE="${CURSOR_OPENAPI_FILE_RE:-(^|/)(contracts/)?openapi\.(ya?ml)$}"

# ------------------------
# DB Gate
# ------------------------
# warn: 默认告警；block: 阻断
export CURSOR_DB_GATE_MODE="${CURSOR_DB_GATE_MODE:-warn}"

# Flyway 迁移目录（常见）
export CURSOR_FLYWAY_DIR_RE="${CURSOR_FLYWAY_DIR_RE:-(^|/)(src/main/resources/)?db/migration/}"

# Liquibase 变更目录（常见）
export CURSOR_LIQUIBASE_DIR_RE="${CURSOR_LIQUIBASE_DIR_RE:-(^|/)(src/main/resources/)?db/changelog/}"

# 其它迁移目录兜底（可按需加）
export CURSOR_MIGRATION_DIR_EXTRA_RE="${CURSOR_MIGRATION_DIR_EXTRA_RE:-(^|/)(migration|migrations)/}"

# MyBatis XML 落点（常见 resources/mapper 或 resources/mybatis）
export CURSOR_MYBATIS_XML_DIR_RE="${CURSOR_MYBATIS_XML_DIR_RE:-(^|/)(src/main/resources/)?(mapper|mappers|mybatis)/}"

# 持久层代码目录/命名识别（Mapper/DAO/Repository/Entity/Model）
export CURSOR_PERSIST_HINT_RE="${CURSOR_PERSIST_HINT_RE:-(mapper|repository|dao|entity|model|persistence|infra|mybatis)}"

# 识别持久层文件类型（Java/Kotlin/XML/SQL）
export CURSOR_PERSIST_FILE_RE="${CURSOR_PERSIST_FILE_RE:-\.(java|kt|xml|sql)$}"


# v2.4：是否在 gate 输出“建议改动落点（候选文件路径）”
export CURSOR_DB_GATE_SUGGEST_FILES="${CURSOR_DB_GATE_SUGGEST_FILES:-1}"  # 1=开启, 0=关闭

# 限制搜索范围，避免大型仓库耗时过长
export CURSOR_DB_GATE_FIND_MAXDEPTH="${CURSOR_DB_GATE_FIND_MAXDEPTH:-8}"
export CURSOR_DB_GATE_MAX_TABLES_HINT="${CURSOR_DB_GATE_MAX_TABLES_HINT:-5}"

# 源码根目录（如需自定义）
export CURSOR_SRC_MAIN_JAVA="${CURSOR_SRC_MAIN_JAVA:-src/main/java}"
export CURSOR_SRC_MAIN_RESOURCES="${CURSOR_SRC_MAIN_RESOURCES:-src/main/resources}"
