# 简介

惠普老式打印机CUPS docker

因为目前CUPS的docker都无法使用，自己封装了一个针对自己环境的docker镜像。有很多内容是写死的，只适用于当前，后续有空了可能更新。

## 使用方法

docker build -t cups_hp:v2 .

docker run -d --name cups_hp --privileged --device /dev/bus/usb -p 631:631 cups_hp:v2 /usr/sbin/cupsd -f

http://宿主机ip:631管理网页的用户名和密码都是root

## OpenWrt配置 Avahi 以广播打印机

```bash
opkg update
opkg install avahi-daemon avahi-utils
```

创建一个 Avahi 服务文件来广播打印机服务。在 `/etc/avahi/services/` 目录下创建一个名为 `airprint.service` 的新文件：

```bash
sudo nano /etc/avahi/services/airprint.service
```

在文件中添加以下内容(注意酌情替换rp、tp、adminurl字段值)：

```xml
<?xml version="1.0" standalone='no'?>
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
  <name>Printer</name>
  <service>
    <type>_ipp._tcp</type>
    <subtype>_universal._sub._ipp._tcp</subtype>
    <port>631</port>
    <txt-record>txtver=1</txt-record>
    <txt-record>qtotal=1</txt-record>
    <txt-record>rp=printers/HP_LaserJet_Professional_M1136_MFP</txt-record>
    <txt-record>ty=HP_LaserJet_Professional_M1136_MFP</txt-record>
    <txt-record>adminurl=http://192.168.100.1:631/printers/HP_LaserJet_Professional_M1136_MFP</txt-record>
    <txt-record>note=HP_LaserJet_Professional_M1136_MFP</txt-record>
    <txt-record>priority=0</txt-record>
    <txt-record>product=(GPL Ghostscript)</txt-record>
    <txt-record>printer-state=3</txt-record>
    <txt-record>printer-type=0x801046</txt-record>
    <txt-record>Transparent=T</txt-record>
    <txt-record>Binary=T</txt-record>
    <txt-record>Fax=F</txt-record>
    <txt-record>Color=T</txt-record>
    <txt-record>Duplex=T</txt-record>
    <txt-record>Staple=F</txt-record>
    <txt-record>Copies=T</txt-record>
    <txt-record>Collate=F</txt-record>
    <txt-record>Punch=F</txt-record>
    <txt-record>Bind=F</txt-record>
    <txt-record>Sort=F</txt-record>
    <txt-record>Scan=F</txt-record>
    <txt-record>pdl=application/octet-stream,application/pdf,application/postscript,image/jpeg,image/png,image/urf</txt-record>
    <txt-record>URF=W8,SRGB24,CP1,RS600</txt-record>
  </service>
</service-group>
```

重启Avahi 服务

```bash
/etc/init.d/avahi-daemon restart
```

## 容器启停跟随打印机机连接与否

我的打印机长时间没有打印任务会自动关机，然后再次开机，会无法执行打印任务，不清楚错误在哪里。索性让容器的启停状态，跟随打印机usb连接与否。

/usr/local/monitor_hp_printer.sh

> ```
> bash
> #!/bin/sh
>
> # 打印机的USB ID，例如：04a9:2228
> PRINTER_USB_ID="03f0:042a"
>
> # Docker容器名称
> DOCKER_CONTAINER_NAME="cups_hp"
>
> # 检查打印机是否已连接
> printer_connected() {
>     lsusb | grep -q "$PRINTER_USB_ID"
> }
>
> # 主循环
> while true; do
>     if printer_connected; then
>         # 如果打印机已连接
>         if ! docker ps | grep -q "$DOCKER_CONTAINER_NAME"; then
>             echo "打印机已连接，启动Docker容器..."
>             docker start "$DOCKER_CONTAINER_NAME"
>         fi
>     else
>         # 如果打印机未连接
>         if docker ps | grep -q "$DOCKER_CONTAINER_NAME"; then
>             echo "打印机已断开，停止Docker容器..."
>             docker stop "$DOCKER_CONTAINER_NAME"
>         fi
>     fi
>     sleep 10  # 每10秒检查一次
> done
> ```

添加可执行权限 chmod +x /usr/local/monitor_hp_printer.sh

启动脚本 /usr/local/monitor_hp_printer.sh &

开机自启动脚本 编辑/etc/rc.local文件，添加 /usr/local/monitor_hp_printer.sh &

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
