# Harbor 安装脚本

这是一个用于自动化安装 [Harbor](https://goharbor.io/) 私有容器镜像仓库的 Bash 脚本。

## 功能特性

- 自动下载指定版本的 Harbor 安装包（支持在线和离线模式）
- 交互式配置 Harbor 参数
- 自动生成 Harbor 配置文件
- 支持安装 Trivy 漏洞扫描器
- 彩色日志输出，便于识别不同级别的信息

## 系统要求

- Linux 系统
- Bash 4.0+
- curl 命令（用于下载安装包）
- tar 命令（用于解压安装包）
- Docker 和 Docker Compose（Harbor 运行依赖）

## 安装方法

### 基本用法

```bash
./harbor.sh [Harbor版本号]
```

示例：
```bash
./harbor.sh v2.5.0
```

### 选项参数

| 选项 | 描述 |
|------|------|
| `-h`, `--help` | 显示帮助信息 |
| `--online` | 下载在线安装包（默认下载离线安装包） |
| `--no-input` | 跳过交互式配置，使用默认值 |
| `--with-trivy` | 安装 Trivy 漏洞扫描器 |

### 默认配置

- 默认版本: `v2.13.1`
- 默认安装路径: `/opt/harbor`
- 默认主机名: 当前主机名 (`$(hostname)`)
- 默认端口: `80`
- 默认管理员密码: `Harbor12345`

## 使用示例

1. 安装指定版本的 Harbor（离线模式）：
```bash
./harbor.sh v2.5.0
```

2. 安装在线版本的 Harbor：
```bash
./harbor.sh --online v2.5.0
```

3. 使用 Trivy 扫描器安装 Harbor：
```bash
./harbor.sh --with-trivy v2.5.0
```

4. 使用默认配置快速安装（跳过交互）：
```bash
./harbor.sh --no-input v2.5.0
```

## 日志输出说明

脚本使用彩色输出显示不同级别的信息：

- ![红色] 错误信息
- ![绿色] 成功信息
- ![黄色] 警告信息
- ![蓝色] 普通信息
- ![紫色] 调试信息
- ![青色] 步骤信息

## 注意事项

1. 安装前请确保系统满足 [Harbor 官方要求](https://goharbor.io/docs/2.0.0/install-config/)
2. 默认使用 HTTP 协议，生产环境建议配置 HTTPS
3. 安装路径需要有写入权限
4. 如果目标目录已存在，脚本会报错退出

## 安装后访问

安装完成后，可以通过以下方式访问 Harbor：

- 地址: `http://[主机名]:[端口]`
- 用户名: `admin`
- 密码: 安装时设置的密码（默认为 `Harbor12345`）

## 卸载

要卸载 Harbor，可以执行以下命令：

```bash
cd /opt/harbor
docker-compose down -v
rm -rf /opt/harbor
```

