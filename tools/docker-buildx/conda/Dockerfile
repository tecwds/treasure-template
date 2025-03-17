# trixie:debian 13 发行版代号
FROM debian:trixie-slim AS downloader
LABEL authors="tecwds"

WORKDIR /tmp

COPY . .

ARG CONDA_PATH=${CONDA_PATH:https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh}

# 下载 miniconda（conda）
RUN if [ -f "$CONDA_PATH" ]; then mv $CONDA_PATH /tmp/conda-install.sh; else curl -s -o /tmp/conda-install.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh; fi

# 安装 miniconda（conda）
RUN sh /tmp/conda-install.sh -b -u -p /conda


FROM debian:trixie-slim

WORKDIR /conda

COPY --from=downloader /conda /conda

ENV PATH=$PATH:/conda/bin

RUN /conda/bin/conda init

VOLUME ["/conda/envs"]

ENTRYPOINT ["bash"]