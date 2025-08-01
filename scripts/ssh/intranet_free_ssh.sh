#!/bin/env bash

# 为内网机器配置免密登录
# @author tecwds
# @power by ai

# 功能点：
# 1. 远程配置主机名
# 2. 远程配置 ssh
# 3. 远程配置 hosts
# 4. 远程配置 ssh config
# 5. 生成 ssh-key
# 6. 远程分发公钥
# 7. 可选分发私钥
# 8. 测试连接

# 步骤：
# 输入远程地址 [ip]空格[ip]
# 主机名设置规则： 输入的主机名+ip第四位, eg: tecwds50, tecwds55

SCRIPTS_VERSION="v0.1.0"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # 重置颜色

CURRENT_USER=$(whoami)
KEY_PATH="/home/${CURRENT_USER}/.ssh/gen"


# 打印错误信息（红色）
p_err() {
    echo -e "${RED}[错误]${NC} $1" >&2
}

# 打印普通信息（黄色）
p_info() {
    echo -e "${YELLOW}[信息]${NC} $1"
}

p_ok() {
    echo -e "${GREEN}[成功]${NC} $1"
}

# 使用帮助
usage() {
    echo "内网机器免密登录配置工具 ${SCRIPTS_VERSION}"
    echo "用法: $0 [选项]"
    echo
    echo "选项:"
    echo "  -h, --help     显示帮助信息"
    echo "  -v, --version  显示版本信息"
    echo "  -k, --key      分发私钥到目标机器"
    echo
    echo "示例:"
    echo "  $0                     # 交互式配置"
    echo "  $0 -k                  # 交互式配置并分发私钥"
    echo
    echo "注意:"
    echo "  1. 需要目标机器的SSH密码"
    echo "  2. 需要安装sshpass工具"
}

# 打印前置提醒，每次调用脚本都会执行
# 脚本默认使用当前用户作为工作路径，后续的 ssh 产生的密钥保存在当前用户家目录
pre_tips() {
    p_info "该脚本的使用提示"
    p_info "0. 使用 -h 查看帮助信息"
    p_info "1. 目标服务器用户的密码设置且能够登录"
    p_info "2. 目标服务器用户拥有 sudo 权限"
    p_info "3. 本机 ssh-keygen 生成目录默认存放在 ~/.ssh/gen"
}

# 远程执行脚本，用于配置 ssh 允许/禁止 root 登录（若是禁止登录，则）
remote_configure_root_ssh() {
    ### sed 操作 /etc/ssh/sshd_config

}

# 设置 config
setup_config() {
    ### cat 操作生成 ~/.ssh/config

    # Host 一般是主机名
    #   Hostname 对应内网IP
    #   Port 22
    #   User root
    #   Identityfile /root/.ssh/id_rsa

}
7
# 设置 hosts
setup_hosts() {
    ### cat 操作生成 /etc/hosts

    # ip servername
    # 192.168.x.x servername
}

# 生成 ssh-key，使用 ssh-keygen
# 默认保存在 ~/.ssh/gen/{id_rsa, id_rsa.pub}
setup_key() {
    p_info "正在生成SSH密钥对..."
    
    # 创建密钥目录
    mkdir -p "${KEY_PATH}" || {
        p_err "创建密钥目录失败: ${KEY_PATH}"
        return 1
    }
    
    # 生成密钥对
    ssh-keygen -t rsa -b 4096 -f "${KEY_PATH}/id_rsa" -N "" -q <<< y >/dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        p_ok "SSH密钥对已生成: ${KEY_PATH}/id_rsa"
        return 0
    else
        p_err "SSH密钥对生成失败"
        return 1
    fi
}

# 设置 authorized_keys
deploy_authorized_keys() {
    local ip=$1
    local hostname=$2
    
    read -s -p "请输入${ip}的SSH密码: " ssh_pass
    echo
    
    p_info "正在向${hostname}(${ip})分发公钥..."
    
    # 使用sshpass传递密码
    if ! command -v sshpass &> /dev/null; then
        p_err "请先安装sshpass: sudo apt install sshpass"
        return 1
    fi
    
    SSH_ASKPASS=/bin/false sshpass -p "${ssh_pass}" \
        ssh-copy-id -i "${KEY_PATH}/id_rsa.pub" \
        -o StrictHostKeyChecking=no \
        -o ConnectTimeout=5 \
        "${CURRENT_USER}@${ip}" >/dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        p_ok "公钥已成功分发到${hostname}(${ip})"
        return 0
    else
        p_err "公钥分发到${hostname}(${ip})失败"
        return 1
    fi
}

# 分发私钥
deploy_secret_key() {
    local ip=$1
    local hostname=$2
    
    p_info "正在向${hostname}(${ip})分发私钥..."
    
    scp -i "${KEY_PATH}/id_rsa" \
        -o StrictHostKeyChecking=no \
        -o ConnectTimeout=5 \
        "${KEY_PATH}/id_rsa" \
        "${CURRENT_USER}@${ip}:~/.ssh/id_rsa" >/dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        p_ok "私钥已成功分发到${hostname}(${ip})"
        return 0
    else
        p_err "私钥分发到${hostname}(${ip})失败"
        return 1
    fi
}

# 测试连接
test_connect() {
    local ip=$1
    local hostname=$2
    
    p_info "正在测试到${hostname}(${ip})的SSH连接..."
    
    ssh -i "${KEY_PATH}/id_rsa" \
        -o StrictHostKeyChecking=no \
        -o ConnectTimeout=5 \
        -o BatchMode=yes \
        "${CURRENT_USER}@${ip}" exit >/dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        p_ok "SSH连接测试成功: ${hostname}(${ip})"
        return 0
    else
        p_err "SSH连接测试失败: ${hostname}(${ip})"
        return 1
    fi
}


# 验证IP格式
validate_ip() {
    local ip=$1
    if [[ ! $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        p_err "无效IP地址: $ip"
        return 1
    fi
    return 0
}

# 生成主机名
generate_hostname() {
    local ip=$1
    local base_name=$2
    local last_octet=$(echo $ip | awk -F. '{print $4}')
    echo "${base_name}${last_octet}"
}

# 全局统计变量
TOTAL_HOSTS=0
SUCCESS_HOSTS=0
FAILED_HOSTS=0

# 处理IP列表输入
process_ip_list() {
    read -p "请输入IP列表(空格分隔): " ip_list
    read -p "请输入基础主机名(如tecwds): " base_name
    
    for ip in $ip_list; do
        if ! validate_ip $ip; then
            continue
        fi
        
        local hostname=$(generate_hostname $ip $base_name)
        p_info "处理IP: $ip, 主机名: $hostname"
        
        # 生成密钥
        if ! setup_key; then
            p_err "无法为${ip}生成密钥，跳过此主机"
            continue
        fi
        
        # 分发公钥
        if ! deploy_authorized_keys "$ip" "$hostname"; then
            p_err "无法为${hostname}(${ip})配置免密登录"
            continue
        fi
        
        # 测试连接
        if ! test_connect "$ip" "$hostname"; then
            p_err "免密登录配置存在问题，请检查"
            continue
        fi
        
        p_ok "主机${hostname}(${ip})免密登录配置完成"
        ((SUCCESS_HOSTS++))
        
        # 分发私钥(如果指定了-k参数)
        if [ "${DEPLOY_KEY}" = true ]; then
            if ! deploy_secret_key "$ip" "$hostname"; then
                p_err "私钥分发失败，但免密登录已配置"
                ((FAILED_HOSTS++))
            fi
        fi
        ((TOTAL_HOSTS++))
    done
}

# 解析参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--version)
                echo "版本: ${SCRIPTS_VERSION}"
                exit 0
                ;;
            -k|--key)
                DEPLOY_KEY=true
                shift
                ;;
            *)
                p_err "未知参数: $1"
                usage
                exit 1
                ;;
        esac
    done
}

main() {
    local start_time=$(date +%s)
    
    parse_args "$@"
    pre_tips
    process_ip_list
    
    # 显示执行总结
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo
    p_info "执行完成，耗时: ${duration}秒"
    p_info "总处理主机: ${TOTAL_HOSTS}"
    p_ok "成功配置: ${SUCCESS_HOSTS}"
    p_err "失败配置: ${FAILED_HOSTS}"
    
    if [ ${FAILED_HOSTS} -gt 0 ]; then
        exit 1
    fi
}

main "$@"
