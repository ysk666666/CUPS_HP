#!/usr/bin/expect -f

# 设置超时时间，防止脚本在等待输出时无限期挂起
set timeout 300

# 修改 root 密码
spawn passwd root
expect "New password:"
send "root\r"
expect "Retype new password:"
send "root\r"
expect eof

spawn hp-plugin -i
expect "Enter option (d=download*, p=specify path, q=quit) ?"
send "p\r"
expect -re {Enter the path to the '(.+\.run)' file \(q=quit\) :}
set pluginFileName $expect_out(1,string)
send "q\r"
expect eof

# 构建下载 URL
set baseUrl "https://www.openprinting.org/download/printdriver/auxfiles/HP/plugins"
set fileUrl "$baseUrl/$pluginFileName"
set ascUrl "${fileUrl}.asc"

# 使用 wget 下载文件
spawn wget $fileUrl -O /root/$pluginFileName
expect eof

spawn wget $ascUrl -O /root/${pluginFileName}.asc
expect eof

if { [file exists "/root/$pluginFileName"] } {
    send_user "File $pluginFileName downloaded successfully to /root/\n"
} else {
    send_user "Error: File $pluginFileName not found after download attempt.\n"
}

# 启动 hp-plugin 并选择指定路径
spawn hp-plugin -i
expect "Enter option (d=download*, p=specify path, q=quit) ?"
send "p\r"
expect -re {Enter the path to the 'hplip-.*-plugin\.run' file \(q=quit\) :}
send "/root\r"
expect "Do you accept the license terms for the plug-in (y=yes*, n=no, q=quit) ?"
send "y\r"
expect eof