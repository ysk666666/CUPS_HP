# 使用 Debian 最新版作为基础镜像
FROM debian:latest

# 设置维护者信息
LABEL maintainer="ysk666666@126.com"

# 将配置文件复制到镜像中指定路径
COPY cupsd.conf /root/cupsd.conf
COPY hplip-3.22.10-plugin.run /root/hplip-3.22.10-plugin.run
COPY hplip-3.22.10-plugin.run.asc /root/hplip-3.22.10-plugin.run.asc
COPY install_hp_plugin.sh /root/install_hp_plugin.sh


# 更新包管理器并安装需要的软件（如果需要）
RUN apt update && \
    apt install -y hplip && \
    apt install -y gnupg && \
    apt install -y expect
    

# 给予脚本执行权限
RUN chmod +x /root/install_hp_plugin.sh

# 安装hp-plugin
RUN expect /root/install_hp_plugin.sh

# 安装cups
RUN apt install -y cups && \
    apt clean

# 使用拷贝的cups配置文件, 所有权限放开
COPY cupsd.conf /etc/cups/cupsd.conf

# 暴露 CUPS 默认端口
EXPOSE 631

# 设置启动命令
CMD ["/usr/sbin/cupsd", "-f"]