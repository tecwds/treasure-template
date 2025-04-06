## Treasure template

这个项目是为了快速部署开发时所需的软件环境，如 `MySQL`、`MongoDB`、`Redis` 等。

## 说明

    不定时更新

项目高度依赖 `docker` 。


>  **备注:**
> 
> `compose v2` 中已经集成 `docker compose`，但对于部分操作系统来说，仍需单独安装，例如 `ArchLinux` 中:
> ``` shell
>  pacman -S docker docker-compose docker-buildx
> ```

## 支持列表

- [x] MySQL8
- [x] Redis (Server + RedisStack)
- [x] MongoDB (MongoDB + MongoExpress)
- [x] Minio (最后 Apache 版本 + 最新版)
- [x] GLP (grafana + loki + promtail) 监控三件套
- [x] Gitlab-ce

## 特殊镜像

### 1. Conda 环境

> 位于 `tools/docker-buildx/conda` 文件夹中，需要手动构建

此镜像用于在 `Pycharm` 中设置远程工具链（SSH 方式）。

    在 Pycharm 中，使用容器形式有莫名 BUG，使用 SSH 方式则稳定很多。

### 2. Gitlab 

用于快速部署一个 `gitlab-ce` 服务用于测试（学习），不可用于生产环境。

## 未来计划

### 镜像支持

- [ ] Kafka
- [ ] Rabbitmq
- [ ] Nacos
- [ ] Postgres
- [ ] 待添加

### 其他

- [ ] 快速构建 `SpringBoot` 后端
- [ ] 提供 `JetBrains` 开发容器
- [ ] 提供 `vscode` 开发容器