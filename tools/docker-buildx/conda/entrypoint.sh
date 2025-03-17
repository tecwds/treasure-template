#!/bin/bash

# from https://github.com/oceanbase/miniob/blob/main/docker/bin/

echo "root:root" | chpasswd

if [ -f /etc/ssh/sshd_config ]; then
  echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
  service ssh restart
fi

/usr/sbin/sshd

tail -f /dev/null