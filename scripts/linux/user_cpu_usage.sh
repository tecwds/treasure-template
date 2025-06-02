#!/usr/bin/env bash

# 统计活跃用户 CPU 使用脚本

echo "用户            CPU 使用率 (%)"
echo "=============================="

# 获取进程信息并统计每个用户的总 CPU 使用率
# 用户(user)、CPU使用率(%cpu)、命令名(comm)、主要缺页数(maj_flt)、常驻内存集大小(rss)
ps -eo user,%cpu,comm,maj_flt,rss | awk '
    NR > 1 {
      # 忽略第一行（标题行），从第二行开始处理
      # cpu[$1] += $2: 将每个进程的 CPU 使用率按照用户名累加
      cpu[$1] += $2
    }
    END {
      # 在最后阶段遍历所有用户名，并输出其累计的 CPU 使用率
      for (user in cpu) {
        # %-16s 表示左对齐并占用16个字符宽度，%.2f 表示保留两位小数的浮点数
        printf("%-16s %.2f\n", user, cpu[user])
      }
    }
' | sort -k2 -rn