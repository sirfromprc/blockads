#!/bin/bash

# 设置 URL 和输出文件名
URL="https://raw.githubusercontent.com/Elysian-Realme/FuGfConfig/refs/heads/main/ConfigFile/DataFile/FuckRogueSoftware/domain.txt"
INPUT_FILE="domain.txt"
OUTPUT_FILE="smartdns_blocklist.conf"

# 下载源文件
curl -sSL "$URL" -o "$INPUT_FILE"

# 清洗并生成配置文件
awk '
  BEGIN { OFS = "" }
  {
    gsub(/^[ \t]+|[ \t]+$/, "", $0)
    if ($0 == "" || $0 ~ /^[#;]/) next
    sub(/#.*/, "", $0)
    if ($0 == "") next
    gsub(/^\./, "", $0)
    print "address /", $0, "/#"
  }
' "$INPUT_FILE" > "$OUTPUT_FILE"

# 清理中间文件
rm "$INPUT_FILE"

# 统计行数
TOTAL_LINES=$(grep -c '^address /' "$OUTPUT_FILE")

# 生成时间戳
TIMESTAMP=$(TZ=Asia/Shanghai date '+%Y-%m-%d %H:%M:%S')

sed -i "1i# TOTAL_LINES=$TOTAL_LINES" "$OUTPUT_FILE"
sed -i "1i# 生成时间: $TIMESTAMP" "$OUTPUT_FILE"
sed -i "1i# 源自 https://github.com/Elysian-Realme/FuGfConfig" "$OUTPUT_FILE"
