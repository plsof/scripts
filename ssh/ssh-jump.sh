#!/usr/bin/expect -f
#set timeout 1
set ip [lindex $argv 0]
set port "65522"
set uname "pdd"

spawn ssh -p $port $uname@$ip
expect {
  "*yes/no" { send "yes\r";exp_continue}
  "*password:" { send "123456\r" }
 }
expect "*$*"
send "sudo -i\r"
expect "*password*"
send "123456\r"
expect "*#*"
send "echo `date` WUXI_user access >> ~/access.log \r"
send "ifconfig|grep 'inet addr'|awk '{print \$2}' \r"
##expect eof
interact
