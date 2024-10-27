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

# 启动 hp-plugin 并选择指定路径
spawn hp-plugin -i
expect "Enter option (d=download*, p=specify path, q=quit) ?"
send "p\r"
expect "Enter the path to the 'hplip-3.22.10-plugin.run' file (q=quit) :"
send "/root\r"
expect "Do you accept the license terms for the plug-in (y=yes*, n=no, q=quit) ?"
send "y\r"
expect eof