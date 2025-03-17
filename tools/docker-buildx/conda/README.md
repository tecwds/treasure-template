# miniconda (conda)

> 用于 `Pycharm` 设置工具链（SSH方式）
> 用户： `root`
> 密码： `root`

## 参数说明

| ARG | NOTE                                                |
| --- |-----------------------------------------------------|
| CONDA_PATH | 在Dockerfile同目录下的 conda 安装文件，设置此变量可以跳过构建中从网络下载 conda |

## 构建示例

有 `conda` 安装文件

```shell
docker buildx build --build-arg CONDA_PATH=Miniconda3-latest-Linux-x86_64.sh -t miniconda3 .
```


无 `conda` 安装文件

```shell
docker buildx build -t miniconda3 .
```
