#!/usr/bin/env bash

# 获取当前时间，格式为年月日时分
NOW=$(date +%Y%m%d%H%M)

# 获取昨天的日期，格式为年月日
YESTERDAY=$(date -d -1day +%Y%m%d)

### 配置备份系统文件结构 ###
# 定义备份主目录，所有备份相关的文件和目录都在此路径下
BACKUP_HOME="/srv/backups"

# 定义一个符号链接，指向最新的快照目录
CURRENT_LINK="$BACKUP_HOME/current"

# 快照目录，用于存储每次备份生成的增量快照
SNAPSHOT_DIR=" $BACKUP_HOME/snapshots"

# 存档目录，用于存放压缩归档的备份文件
ARCHIVES_DIR="$BACKUP_HOME/archives"

### 要备份的文件夹 ###
# 从脚本的第一个参数获取需要备份的源目录
BACKUP_SOURCE_DIR=$1

### 创建文件架构 ###
# 创建快照目录与存档目录，如果它们不存在，则隐藏输出信息
mkdir -p $SNAPSHOT_DIR $ARCHIVES_DIR &> /dev/null

### 使用 rsync 进行备份 ###
# 使用 rsync 命令进行增量备份：
# -a 归档模式，保留权限、时间戳
# -z 压缩传输数据
# -H 保留硬链接
# --link-dest 指定上次备份的目录，以便创建硬链接节省空间
# 最后通过 ln 创建一个新的符号链接指向最新备份目录
rsync -azH --link-dest=$CURRENT_LINK $BACKUP_SOURCE_DIR $SNAPSHOT_DIR/$NOW \
  && ln -snf $(ls -1d $SNAPSHOT_DIR/* | tail -n1) $CURRENT_LINK

### 归档 ###
# 如果存在昨天的快照，则将其打包压缩成 .tar.gz 文件并删除原始快照
if [ $(ls -d $SNAPSHOT_DIR/$YESTERDAY* 2> /dev/null | wc -l) -ne "0" ]; then
  # 使用 tar 将昨日快照打包并压缩
  # 压缩成功后，删除原始快照目录
  tar -czf $ARCHIVES_DIR/$YESTERDAY.tar.gz $SNAPSHOP_DIR/$YESTERDAY* \
    && rm -rf $SNAPSHOP_DIR/$YESTERDAY*
fi

