# 简介

惠普老式打印机CUPS docker

因为目前CUPS的docker都无法使用，自己封装了一个针对自己环境的docker镜像。有很多内容是写死的，只适用于当前，后续有空了可能更新。

后续可能更新支持通过配置 Avahi广播到打印机本地网络，以支持AirPrint。

## 使用方法

docker build -t cups_hp:v1 .

docker run -d --name cups_hp --privileged --device /dev/bus/usb -p 631:631 cups_hp:v1 /usr/sbin/cupsd -f


631管理网页的用户名和密码都是root

# 感谢

原理：https://enita.cn/2022/0622/9bfa6627568d/

虚拟机安装：
https://post.smzdm.com/p/a905p290/
https://www.zhoujie218.top/archives/2537.html

HPLIP 下载：
https://developers.hp.com/hp-linux-imaging-and-printing/gethplip
https://sourceforge.net/projects/hplip/files/hplip/

HPLIP Plugin：
https://www.openprinting.org/download/printdriver/auxfiles/HP/plugins/

用公司电脑，周末搞出来的这个仓库。
