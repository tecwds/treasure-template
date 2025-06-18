## 💎 Treasure Template

> 使用容器一键启动开发环境，告别配置地狱！

### 🚀 项目是什么？

项目是为了快速部署开发时所需的软件环境，如 `MySQL`、`MongoDB`、`Redis` 等。统一各种开发环境，专治各种 “在我机器上可以运行” 综合症！

```bash
# 极致的快乐
docker compose -f compose.yml up -d
```

> **须知：**
> 本项目深度依赖 Docker（就像咖啡依赖咖啡因☕）,
> 同时需要 compose v2 语法，一般来说新版 docker 已经默认集成，  
> 不过对于某些系统，例如 Archlinux：
> 
> ```bash
> pacman -S docker docker-compose docker-buildx
> ```

### 🛠️ 支持的服务清单

| 服务                          | 状态 | 特点                    |
|-----------------------------|----|-----------------------|
| MySQL 8                     | ✅  | 关系型数据库首选              |
| Redis (Server + RedisStack) | ✅  | 缓存与数据结构服务             |
| MongoDB（MongoExpress）       | ✅  | 文档数据库                 |
| RabbitMQ                    | ✅  | 消息队列                  |
| Minio                       | ✅  | 对象存储（Apache协议版+最新版）   |
| GLP监控套件                     | ✅  | Grafana+Loki+Promtail |
| Gitlab-ce                   | ✅  | 自托管Git解决方案            |

### ⚡特殊镜像

#### 1. Conda 环境 🐍


> 位于 `tools/docker-buildx/conda` 文件夹中，需要手动构建

graph LR
    A[PyCharm] -->|SSH连接| B[Conda 容器]
    B --> C[流畅开发]
    C --> D[😊 HappyCoding]

> 此镜像用于在 `Pycharm` 中设置远程工具链（SSH 方式）。
> 
> 在 Pycharm 中，使用容器形式有莫名 BUG，使用 SSH 方式则稳定很多。

#### 2. Gitlab 

学习/测试专用，生产环境请绕行（除非你想体验深夜救火🔥）。使用方法，在顶层 compose 文件中引入即可。

#### 3. nginx

用于自定义构建 nginx，采用 docker 构建。

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

**版本策略：**

不定期更新，就像你的代码需求一样不可预测 🔮

**使用警告：**

⚠️ 本项目可能导致开发效率提升，请做好工作量增加的准备 ⚠️

```diff
最新战绩：节省环境配置时间 ≈ 咖啡杯数 * 3小时
```

Happy coding! 愿你的代码少些bug，多些优雅 ✨
