#!/bin/env bash
set -e

# 获取当前脚本路径
DIR="$(cd "$(dirname "$0")" && pwd)"
source $DIR/common.sh

# 打印帮助信息
usage() {
    echo "使用方法: $0 [选项] [Harbor版本号]"
    echo "示例: $0 v2.5.0"
    echo "       $0 --online v2.5.0"
    echo "说明:"
    echo "  此脚本用于安装指定版本的 Harbor。"
    echo "选项:"
    echo "  -h, --help    显示此帮助信息"
    echo "  --online      下载在线安装包(默认下载离线安装包)"
    echo "  --no-input    跳过交互式配置"
    echo "  --with-trivy  安装Trivy漏洞扫描器"
}

# ==================================== 安装 ====================================

DEF_VERSION="v2.13.1"

# 只能是 offline 或者 online
DOWN_TYPE="offline"

# 安装路径前缀，例如会解压到 /opt/harbor/
INSTALL_PREFIX="/opt"
INSTALL_PREFIX="${INSTALL_PREFIX%/}"

# 服务名/域名，默认为本机服务名
SERVER_HOST="$(hostname)"

# 端口
SERVER_PORT="80"

# 用户名和密码
ADMIN_PASS="Harbor12345"

# 是否跳过配置
NO_INPUT=false

# 是否安装Trivy扫描器
WITH_TRIVY=false


# 下载 harbor 安装包
download_harbor() {
    local version=$1
    local filename="harbor-${DOWN_TYPE}-installer-${version}.tgz"
    local url="https://github.com/goharbor/harbor/releases/download/${version}/${filename}"

    if check_file_exists "${filename}"; then
        p_ok "文件已存在，跳过下载: ${filename}"
        return 0
    fi
    
    p_step "开始下载Harbor ${version} (${DOWN_TYPE}模式)..."
    
    if ! curl -# -O "${filename}" "${url}"; then
        p_err "下载Harbor ${version} 失败，请检查版本号是否正确或网络连接"
        return 1
    fi
    
    p_ok "成功下载Harbor ${version} (${DOWN_TYPE}模式)"
    return 0
}

# 解压 harbor 安装包
unzip_installer() {
    local version=$1
    local filename="harbor-${DOWN_TYPE}-installer-${version}.tgz"
    local target_dir="${INSTALL_PREFIX}"

    p_step "开始解压Harbor安装包..."

    # 检查安装包是否存在
    if ! check_file_exists "${filename}"; then
        return 1
    fi

    # 检查目标目录是否已存在
    if [[ -d "${target_dir}/harbor" ]]; then
        p_warn "目标目录已存在: ${target_dir}"
        p_warn "请手动处理现有目录后再运行此脚本"
        return 1
    fi

    # 解压安装包
    if ! tar -xzf "${filename}" -C "${INSTALL_PREFIX}"; then
        p_err "解压Harbor安装包失败"
        return 1
    fi

    p_ok "成功解压Harbor安装包到 ${INSTALL_PREFIX}"
    return 0
}

# 配置 harbor 参数
configure_harbor() {
    p_step "开始配置Harbor参数"
    
    # 服务器主机名/域名
    read -e -p "请输入服务器主机名/域名 [默认: ${SERVER_HOST}]: " input
    SERVER_HOST="${input:-$SERVER_HOST}"
    
    # 服务器端口
    read -e -p "请输入服务器端口 [默认: ${SERVER_PORT}]: " input
    SERVER_PORT="${input:-$SERVER_PORT}"
    
    # 管理员密码
    read -e -p "请输入管理员密码 [默认: ${ADMIN_PASS}]: " input
    ADMIN_PASS="${input:-$ADMIN_PASS}"
    
    # 安装路径
    read -e -p "请输入安装路径 [默认: ${INSTALL_PREFIX}]: " input
    INSTALL_PREFIX="${input:-$INSTALL_PREFIX}"
    INSTALL_PREFIX="${INSTALL_PREFIX%/}"  # 确保路径规范化
    
    p_ok "Harbor配置完成"
    echo "配置摘要:"
    echo "服务器地址: ${SERVER_HOST}"
    echo "服务器端口: ${SERVER_PORT}"
    echo "管理员密码: ${ADMIN_PASS}"
    echo "安装路径: ${INSTALL_PREFIX}"
}

# 准备 harbor 配置文件
prepare_harbor() {
    p_step "准备Harbor配置文件"
    
    local harbor_dir="${INSTALL_PREFIX}/harbor"
    local template_file="${harbor_dir}/harbor.yml.tmpl"
    local config_file="${harbor_dir}/harbor.yml"
    
    # 检查模板文件是否存在
    if [[ ! -f "${template_file}" ]]; then
        p_err "模板文件不存在: ${template_file}"
        return 1
    fi
    
    # 复制模板文件
    cp "${template_file}" "${config_file}"
    
    # 修改配置文件
    sed -i "s/hostname:.*/hostname: ${SERVER_HOST}/" "${config_file}"
    sed -i "s/port: 80.*/port: ${SERVER_PORT}/" "${config_file}"
    sed -i "s/harbor_admin_password:.*/harbor_admin_password: ${ADMIN_PASS}/" "${config_file}"
    sed -i "s|data_volume:.*|data_volume: ${INSTALL_PREFIX}/data|" "${config_file}"
    
    # 注释掉https配置中的特定行
    sed -i '/^ *https:/s/^/#/' "${config_file}"
    sed -i '/^ *port: 443/s/^/#/' "${config_file}"
    sed -i '/^ *certificate:/s/^/#/' "${config_file}"
    sed -i '/^ *private_key:/s/^/#/' "${config_file}"
    
    p_ok "Harbor配置文件已生成: ${config_file}"
}

# 安装 harbor
install_harbor() {
    p_step "开始安装Harbor..."
    
    local harbor_dir="${INSTALL_PREFIX}/harbor"
    local install_script="${harbor_dir}/install.sh"
    
    # 检查安装脚本是否存在
    if [[ ! -f "${install_script}" ]]; then
        p_err "安装脚本不存在: ${install_script}"
        return 1
    fi
    
    # 进入Harbor目录执行安装
    pushd "${harbor_dir}" > /dev/null
    
    # 根据WITH_TRIVY选项添加参数
    local install_cmd="./install.sh"
    if $WITH_TRIVY; then
        install_cmd+=" --with-trivy"
        p_step "将使用Trivy扫描器安装Harbor"
    fi
    
    if ! $install_cmd; then
        p_err "Harbor安装失败"
        popd > /dev/null
        return 1
    fi
    
    popd > /dev/null
    p_ok "Harbor安装成功"
    
    # 显示访问信息
    echo ""
    echo "Harbor已成功安装"
    echo "访问地址: http://${SERVER_HOST}:${SERVER_PORT}"
    echo "管理员账号: admin"
    echo "管理员密码: ${ADMIN_PASS}"
}

# 主函数
main() {
    # 处理选项参数
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            --online)
                DOWN_TYPE="online"
                shift
                ;;
            --no-input)
                NO_INPUT=true
                shift
                ;;
            --with-trivy)
                WITH_TRIVY=true
                shift
                ;;
            *)
                break
                ;;
        esac
    done

    # 处理版本号参数
    if [[ -z "$1" || ! "$1" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        p_warn "未指定版本号，将使用默认版本: ${DEF_VERSION}"
        version="${DEF_VERSION}"
    else
        version="$1"
    fi

    if ! download_harbor "${version}"; then
        exit 1
    fi
    
    if ! unzip_installer "${version}"; then
        exit 1
    fi
    
    if ! $NO_INPUT; then
        configure_harbor
    fi
    
    prepare_harbor
    
    install_harbor
    
    exit 0
}

main "$@"
