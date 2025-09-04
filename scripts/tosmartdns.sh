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

# 排除域名和增加屏蔽域名
awk -v white=../domain/white -v black=../domain/black '
    BEGIN {
        while ((getline < white) > 0) {
            sub(/#.*/, ""); gsub(/^[ \t]+|[ \t]+$/, "")
            if ($0 != "") w[$0] = 1
        }
        close(white)
    }

    FILENAME == ARGV[1] {
        for (d in w) {
            if ($0 ~ d) next 
        }
        if (!seen[$0]++) print
        next
    }

    FILENAME == black {
        sub(/#.*/, ""); gsub(/^[ \t]+|[ \t]+$/, "")
        if ($0 != "") {
            line = "address /" $0 "/#"
            if (!seen[line]++) print line
        }
        next
    }
' "$OUTPUT_FILE" ../domain/black > "$OUTPUT_FILE.new" && mv "$OUTPUT_FILE.new" "$OUTPUT_FILE"

# 统计行数
TOTAL_LINES=$(grep -c '^address /' "$OUTPUT_FILE")

# 生成时间戳
TIMESTAMP=$(TZ=Asia/Shanghai date '+%Y-%m-%d %H:%M:%S')

sed -i "1i# TOTAL_LINES=$TOTAL_LINES" "$OUTPUT_FILE"
sed -i "1i# 生成时间: $TIMESTAMP" "$OUTPUT_FILE"
sed -i "1i# 源自 https://github.com/Elysian-Realme/FuGfConfig" "$OUTPUT_FILE"
