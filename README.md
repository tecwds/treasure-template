## 💎 Treasure Template

> 常见容器部署模板、Linux常用脚本

### 🚀 项目是什么？

- 快速启动 `MySQL`、`Redis` 容器，方便快速开发。
- 一些 Linux 会用到的脚本。

```bash
# 修改 compose.yml 后快速启动
docker compose -f compose.yml up -d
```

> **须知：**
> docker 需要支持 compose v2 语法，一般来说新版 docker 已经默认集成，  
> 不过对于某些系统，例如 Archlinux：
> 
> ```bash
> pacman -S docker docker-compose docker-buildx
> ```
>
> 对于所有系统，可以尝试：
> 
> ```bash
> # 快速安装
> bash <(curl -sSL https:linuxmirrors.cn/docker.sh)
> ```

### 🛠️ 支持的服务清单

#### 镜像

| 服务                          | 状态 | 特点                    |
|-----------------------------|----|-----------------------|
| MySQL 8                     | ✅  | 关系型数据库首选              |
| Redis (Server + RedisStack) | ✅  | 缓存与数据结构服务             |
| MongoDB（MongoExpress）       | ✅  | 文档数据库                 |
| RabbitMQ                    | ✅  | 消息队列                  |
| Minio                       | ✅  | 对象存储（Apache协议版+最新版）   |
| GLP监控套件                     | ✅  | Grafana+Loki+Promtail |
| Gitlab-ce                   | ✅  | 自托管Git解决方案            |

#### 脚本

- [x] Harbor 一键安装脚本
- [x] 数据快速备份
- [x] 显示磁盘信息
- [x] 通过 fd 恢复已删除的文件
- [x] 统计每个用户的 CPU 使用率
- [x] 计算 CPU 使用率
- [x] 通过 openssl 生成密钥

### ⚡特殊镜像

#### 1. Conda 环境 🐍


位于 `tools/docker-buildx/conda` 文件夹中，需要手动构建

此镜像用于在 `Pycharm` 中设置远程工具链（SSH 方式）。
 
在 Pycharm 中，使用容器形式有莫名 BUG，使用 SSH 方式则稳定很多。

#### 2. Gitlab 

学习/测试用。使用方法，在顶层 compose 文件中引入即可。

### 未来计划

#### 镜像支持

- [ ] Kafka
- [ ] Nacos
- [ ] Postgres
- [ ] 待添加

#### 其他

- [ ] 快速构建 `SpringBoot` 后端
- [ ] 提供 `JetBrains` 开发容器
- [ ] 提供 `vscode` 开发容器
- [ ] nginx 构建添加脚本形式构建

**更新：**
不定期更新
