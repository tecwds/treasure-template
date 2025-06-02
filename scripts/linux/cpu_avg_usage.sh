#!/usr/bin/env bash

# 脚本说明：从 /proc/stat 中计算 CPU 使用率并实时显示
# 参数说明：脚本接受一个参数作为刷新间隔时间（秒）

# PREV_TOTAL: 存储上一次的 CPU 总时间
# PREV_IDLE: 存储上一次的 CPU 空闲时间
# ARG_REFRESH_TIME: 用户传入的刷新间隔时间，如果没有传参则默认为 1 秒

PREV_TOTAL=0
PREV_IDLE=0
ARG_REFRESH_TIME=$1

while true; do
  # IDLE: 当前空闲时间 (取第4个值)
  # TOTAL: 初始化当前 CPU 总时间

  # DIFF_IDLE: 计算空闲时间差值
  # DIFF_TOTAL: 计算总时间差值
  # DIFF_USAGE: 根据差值计算 CPU 使用率百分比 (保留一位小数)

  # 获取 /proc/stat 中 cpu 行的数据，并去掉行首的 "cpu" 字符
  CPU=($(sed -n 's/^cpu\s//p' /proc/stat))
  IDLE=${CPU[3]}
  TOTAL=0

  # 遍历 CPU 时间数组中的前8个值来计算总使用时间
  for VALUE in "${CPU[@]:0:8}"; do
    TOTAL=$((TOTAL+VALUE))
  done

  DIFF_IDLE=$((IDLE-PREV_IDLE))
  DIFF_TOTAL=$((TOTAL-PREV_TOTAL))

  # 计算 CPU 使用率百分比（保留一位小数）
  # 公式说明：
  # 1. DIFF_TOTAL-DIFF_IDLE：计算非空闲时间差值（即实际使用时间）
  # 2. 乘以 1000 并除以 DIFF_TOTAL：先放大结果避免整数除法丢失精度，再计算使用率
  # 3. +5 再除以 10：实现四舍五入保留一位小数的效果
  DIFF_USAGE=$(((1000*(DIFF_TOTAL-DIFF_IDLE)/DIFF_TOTAL+5)/10))

  echo -en "\rCPU: $DIFF_USAGE%  \b\b"

  PREV_TOTAL="$TOTAL"
  PREV_IDLE="$IDLE"

  sleep "${ARG_REFRESH_TIME:-1}"
done
