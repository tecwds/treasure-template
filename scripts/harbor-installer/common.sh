#!/bin/env bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # 重置颜色

# 打印错误信息（红色）
p_err() {
    echo -e "${RED}[错误]${NC} $1" >&2
}

# 打印成功信息（绿色）
p_ok() {
    echo -e "${GREEN}[成功]${NC} $1"
}

# 打印警告信息（黄色）
p_warn() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

# 打印普通信息（蓝色）
p_info() {
    echo -e "${BLUE}[信息]${NC} $1"
}

# 打印调试信息（紫色）
p_debug() {
    echo -e "${PURPLE}[调试]${NC} $1"
}

# 打印步骤信息（青色）
p_step() {
    echo -e "${CYAN}[信息]${NC} $1"
}

# 检查文件是否存在
check_file_exists() {
    local file_path="$1"
    if [[ -f "$file_path" ]]; then
        echo -e "${CYAN}[检查]${NC} 文件存在: ${file_path}"
        return 0
    else
        p_err "文件不存在: ${file_path}"
        return 1
    fi
}
