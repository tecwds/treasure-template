#!/bin/bash

# 设置默认密码长度
DEFAULT_LENGTH=20

# 检查是否通过管道运行
is_pipe=0
if [ ! -t 1 ]; then
    is_pipe=1
fi

# 如果不是通过管道运行，则显示交互界面
if [ $is_pipe -eq 0 ]; then
    # 清屏
    clear

    # 提示用户输入密码长度
    echo -n "请输入密码长度 (默认 ${DEFAULT_LENGTH}): "
    # shellcheck disable=SC2162
    read length

    # 如果用户没有输入，使用默认值
    if [ -z "$length" ]; then
        length=$DEFAULT_LENGTH
    fi

    # 验证输入是否为正整数
    if ! [[ "$length" =~ ^[0-9]+$ ]]; then
        echo "错误：请输入一个有效的正整数" >&2
        exit 1
    fi

    echo "开始生成 ${length} 位的随机密码..."

    # 显示进度条函数
    show_progress() {
        printf "\r生成进度: %d%%" "" "" "$1" >&2
    }

    # 模拟进度 —— 笑死
    for i in {0..100}; do
        show_progress "$i"
        sleep 0.01
    done
else
    # 通过管道运行时使用默认长度
    length=$DEFAULT_LENGTH
fi

# 生成密码
password=$(openssl rand -base64 $((length * 3/4)) | head -c "$length")

# 根据运行模式输出结果
if [ $is_pipe -eq 0 ]; then
    echo -e "\n生成的密码为: $password"
else
    echo "$password"
fi