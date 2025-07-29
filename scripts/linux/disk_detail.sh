#!/bin/env bash

# 查看磁盘信息
# @author tecwds
# @power by ai

SCRIPTS_VERSION="v0.1.0"

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

usage() {
    echo "用法: $0 [选项] [磁盘设备]"
    echo "选项:"
    echo "  -h, --help     显示帮助信息"
    echo "  -v, --version  显示版本信息"
    echo "  -i, --info     显示指定磁盘的详细信息"
    echo "  -a, --all      显示所有物理磁盘的详细信息"
    p_info "依赖:"
    p_info "  1. smartctl"
    p_info "  1. hdparm"
    echo " "
    p_info "功能:"
    p_info "  1. 不带参数时统计系统磁盘数量"
    p_info "  2. 使用 -i 参数显示指定磁盘的详细信息"
    p_info "  3. 使用 -a 参数显示所有物理磁盘的详细信息"
}

# 获取所有物理磁盘列表
get_physical_disks() {
    lsblk -d -e 7,1,253 -n -o NAME 2>/dev/null | grep -v "/"
}

# 统计磁盘数量和基本信息
count_disk() {
    # 功能: 检测并显示系统磁盘信息
    # 输出: 磁盘数量、名称、类型(HDD/SSD/NVMe)、大小和型号
    # 返回值: 0-成功 1-无磁盘设备
    p_step "正在检测系统磁盘..."
    disks=$(lsblk -d -e 7,1,253 -n -o NAME,ROTA,SIZE,MODEL 2>/dev/null | grep -v "/")
    disk_count=$(echo "$disks" | wc -l)
    
    if [ $disk_count -eq 0 ]; then
        p_err "未检测到任何磁盘设备!"
        return 1
    fi
    
    p_ok "系统中共检测到 ${disk_count} 块存储设备"
    p_info "磁盘基础信息:"
    # 处理每个磁盘信息
    echo "$disks" | while read -r name rota size model; do
        # 判断磁盘类型:
        # 1. 名称以nvme开头的是NVMe固态
        # 2. ROTA=0的是SSD固态
        # 3. 其他为机械硬盘(HDD)
        if [[ $name == nvme* ]]; then
            type="NVMe"
        else
            type="HDD"
            [ "$rota" -eq 0 ] && type="SSD"
        fi
        echo -e "  - ${YELLOW}${name}${NC} [${type}] ${size} ${model}"
    done
    
    return 0
}

# 获得磁盘基本信息
# 参数: $1 - 磁盘设备名(如sda, nvme0n1)
disk_info() {
    local disk=$1
    local dev_path="/dev/$disk"
    
    # 检查设备是否存在
    if [ ! -b "$dev_path" ]; then
        p_err "设备 $dev_path 不存在!"
        return 1
    fi
    
    p_step "正在获取磁盘 $disk 的详细信息..."
    
    # 获取基本信息
    local disk_type="HDD"
    local model=$(lsblk -d -o MODEL "$dev_path" | tail -n1 | sed 's/^ *//;s/ *$//')
    local size=$(lsblk -d -o SIZE "$dev_path" | tail -n1 | sed 's/^ *//;s/ *$//')
    
    # 判断磁盘类型
    if [[ $disk == nvme* ]]; then
        disk_type="NVMe"
    else
        local rota=$(lsblk -d -o ROTA "$dev_path" | tail -n1)
        [ "$rota" -eq 0 ] && disk_type="SSD"
    fi
    
    # 获取接口类型
    local interface="unknown"
    if [[ $disk == sd* ]]; then
        interface=$(udevadm info --query=property --name="$dev_path" | grep "ID_BUS=" | cut -d= -f2 | tr '[:lower:]' '[:upper:]')
    elif [[ $disk == nvme* ]]; then
        interface="NVMe"
    fi
    
    # 获取序列号(需要root权限)
    local serial=""
    if [ -x "$(command -v smartctl)" ]; then
        serial=$(sudo smartctl -i "$dev_path" | grep "Serial Number" | awk '{print $3}' 2>/dev/null)
    fi
    
    # 获取缓存大小(需要root权限)
    local cache=""
    if [ -x "$(command -v hdparm)" ]; then
        cache=$(sudo hdparm -I "$dev_path" | grep "Cache" | head -n1 | sed 's/^[ \t]*//;s/[ \t]*$//' 2>/dev/null)
    fi
    
    # 获取分区和挂载信息
    local partitions=$(lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT "$dev_path" | grep -v "$disk" | sed '1d')
    
    # 获取空间使用情况
    local usage=$(df -h | grep "$disk" | awk '{print $6 ": " $3 " used / " $4 " free (" $5 ")"}' | tr '\n' '; ')
    
    # 打印详细信息
    echo -e "${YELLOW}===== 磁盘 $disk 详细信息 =====${NC}"
    echo -e "  - 设备路径: ${dev_path}"
    [ -n "$serial" ] && echo -e "  - 序列号: ${serial}"
    echo -e "  - 型号: ${model}"
    echo -e "  - 类型: ${disk_type}"
    echo -e "  - 接口: ${interface}"
    echo -e "  - 容量: ${size}"
    [ -n "$cache" ] && echo -e "  - 缓存: ${cache}"
    
    if [ -n "$partitions" ]; then
        echo -e "  - 分区情况:"
        echo "$partitions" | while read -r part size fstype mount; do
            echo -e "    - ${part}: ${size} ${fstype} ${mount:+=> $mount}"
        done
    else
        echo -e "  - 分区: 无"
    fi
    
    if [ -n "$usage" ]; then
        echo -e "  - 空间使用:"
        IFS=';' read -ra usages <<< "$usage"
        for u in "${usages[@]}"; do
            [ -n "$u" ] && echo -e "    - ${u}"
        done
    fi
    
    return 0
}

# 显示所有物理磁盘信息
show_all_disks_info() {
    local disks=$(get_physical_disks)
    if [ -z "$disks" ]; then
        p_err "未检测到任何物理磁盘设备!"
        return 1
    fi
    
    for disk in $disks; do
        disk_info "$disk"
        echo ""
    done
}

main() {
    # 解析命令行参数
    local show_info=false
    local show_all=false
    local target_disk=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--version)
                echo "disk_detail.sh ${SCRIPTS_VERSION}"
                exit 0
                ;;
            -i|--info)
                show_info=true
                if [ $# -gt 1 ] && [[ $2 != -* ]]; then
                    target_disk=$2
                    shift
                fi
                ;;
            -a|--all)
                show_all=true
                ;;
            *)
                # 非选项参数视为磁盘设备名
                if [ -z "$target_disk" ] && [[ $1 != -* ]]; then
                    target_disk=$1
                else
                    p_err "未知参数: $1"
                    usage
                    exit 1
                fi
                ;;
        esac
        shift
    done

    if $show_all; then
        show_all_disks_info
        exit $?
    elif $show_info; then
        if [ -z "$target_disk" ]; then
            p_err "请指定要查询的磁盘设备名(如sda, nvme0n1)"
            usage
            exit 1
        fi
        disk_info "$target_disk"
        exit $?
    else
        # 默认执行磁盘统计
        count_disk
        exit $?
    fi
}

main "$@"
