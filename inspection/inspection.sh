#!/bin/bash
######################################################
# Functions: this script for inspecting system status
# Info: be suitable for CentOS6/7
#   2017-10-12 pdd
######################################################

# set env path
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
source /etc/profile

# run this script with root
[ $(id -u) -gt 0 ] && echo "please use root run this script! " && exit 1

# system version
OS_Version=$(awk '{print $(NF-1)}' /etc/redhat-release)

# define inspecting log path
LOGPATH=/tmp/inspection
[ -d "$LOGPATH" ] || mkdir -p $LOGPATH
RESULTFILE="$LOGPATH/HostDailyCheck-`hostname`-`date +%Y%m%d`.txt"


function getCpuStatus(){
    echo ""
    echo "############################ Check CPU Status#############################"
    local Physical_CPUs=$(grep "physical id" /proc/cpuinfo| sort | uniq | wc -l)
    local Virt_CPUs=$(grep "processor" /proc/cpuinfo | wc -l)
    local CPU_Kernels=$(grep "cores" /proc/cpuinfo|uniq| awk -F ': ' '{print $2}')
    local CPU_Type=$(grep "model name" /proc/cpuinfo | awk -F ': ' '{print $2}' | sort | uniq)
    local CPU_Arch=$(uname -m)
    
    echo "物理CPU个数：$Physical_CPUs"
    echo "逻辑CPU个数：$Virt_CPUs"
    echo "每CPU核心数：$CPU_Kernels"
    echo "    CPU型号：$CPU_Type"
    echo "    CPU架构：$CPU_Arch"

    report_Physical_CPUs="$Physical_CPUs"
    report_Virt_CPUs="$Virt_CPUs"
    repor_CPU_Kernels="$CPU_Kernels"
    report_CPU_Type="$CPU_Type"
    report_CPU_Arch="$CPU_Arch"
}

function getMemStatus(){
    echo ""
    echo "############################ Check Memmory Usage ###########################"
    local MemTotal=$(grep MemTotal /proc/meminfo| awk '{print $2}') # KB
    local MemFree=$(grep MemFree /proc/meminfo| awk '{print $2}') # KB
    let MemUsed=MemTotal-MemFree
    local MemUsedPercent=$(awk -v Total=$MemTotal -v Used=$MemUsed 'BEGIN{if(Total==0){printf 100}else{printf "%f",Used*100/Total}}')
    
    echo " 内存总容量：$((MemTotal/1024))""MB"
    echo "   内存剩余：$((MemFree/1024))""MB"
    echo " 内存使用率：$MemUsedPercent""%"

    report_MemTotal=$((MemTotal/1024))"MB"
    report_MemFree=$((MemFree))"MB"
    report_MemUsedPercent=${MemUsedPercent}"%"
}

function getDiskStatus(){
    echo ""
    echo "############################ Check Disk Status ############################"
    df -hiP | sed 's/Mounted on/Mounted/' > /tmp/inode
    df -hTP | sed 's/Mounted on/Mounted/' > /tmp/disk
    join /tmp/disk /tmp/inode | awk '{print $1,$2,"|",$3,$4,$5,$6,"|",$8,$9,$10,$11,"|",$12}'| column -t
    local diskdata=$(df -TP | sed '1d' | awk '$2!="tmpfs"{print}') # KB
    local disktotal=$(echo "$diskdata" | awk '{total+=$3}END{print total}') # KB
    local diskused=$(echo "$diskdata" | awk '{total+=$4}END{print total}')  # KB
    local diskfree=$((disktotal-diskused)) # KB
    local diskusedpercent=$(echo $disktotal $diskused | awk '{if($1==0){printf 100}else{printf "%.2f",$2*100/$1}}')
    local inodedata=$(df -iTP | sed '1d' | awk '$2!="tmpfs"{print}')
    local inodetotal=$(echo "$inodedata" | awk '{total+=$3}END{print total}')
    local inodeused=$(echo "$inodedata" | awk '{total+=$4}END{print total}')
    local inodefree=$((inodetotal-inodeused))
    local inodeusedpercent=$(echo $inodetotal $inodeused | awk '{if($1==0){printf 100}else{printf "%.2f",$2*100/$1}}')

    echo "   硬盘总容量：$((disktotal/1024/1024))""GB"
    echo " 硬盘剩余容量：$((diskfree/1024/1024))""GB"
    echo "   硬盘使用率：$diskusedpercent""%"
    echo "    Inode总量：$((inodetotal/1000))""K"
    echo "Inode剩余数量：$((inodefree/1000))""K"
    echo "  Inode使用率：$inodeusedpercent""%"
    echo ""

    report_disktotal=$((disktotal/1024/1024))"GB"
    report_diskfree=$((diskfree/1024/1024))"GB"
    report_diskusedpercent=${diskusedpercent}"%"
    report_inodetotal=$((inodetotal/1000))"K"
    report_inodefree=$((inodefree/1000))"K"
    report_inodeusedpercent=${inodeusedpercent}"%"
}

function getSystemStatus(){
    echo ""
    echo "############################ Check System Status ############################"
    if [ -e /etc/sysconfig/i18n ];then
        default_LANG="$(grep "LANG=" /etc/sysconfig/i18n | grep -v "^#" | awk -F '"' '{print $2}')"
    else
        default_LANG=$LANG
    fi
    local OS=$(uname -o)
    local Release=$(cat /etc/redhat-release 2>/dev/null)
    local Kernel=$(uname -r)
    local Hostname=$(uname -n)
    local SELinux=$(/usr/sbin/getenforce)
    local LastReboot=$(who -b | awk '{print $3,$4}')
    local uptime=$(uptime | sed -r 's/.*up ([^,]*), .*/\1/')

    echo "     系统：$OS"
    echo " 发行版本：$Release"
    echo "     内核：$Kernel"
    echo "   主机名：$Hostname"
    echo "  SELinux：$SELinux"
    echo "语言/编码：$default_LANG"
    echo " 最后启动：$LastReboot"
    echo " 运行时间：$uptime"
    echo ""

    report_OS="$OS"
    report_Release="$Release"
    report_Kernel="$Kernel"
    report_Hostname="$Hostname"
    report_SELinux="$SELinux"
    report_default_LANG="$default_LANG"
    report_LastReboot="$LastReboot"
    report_uptime="$uptime"
}

function getServiceStatus(){
    echo ""
    echo "############################ Check Service Status ############################"
    if [[ $OS_Version > 7 ]];then
        local conf=$(systemctl list-unit-files --type=service --state=enabled --no-pager | grep "enabled")
        local process=$(systemctl list-units --type=service --state=running --no-pager | grep ".service")
    else
        local conf=$(/sbin/chkconfig | grep ":on")
        local process=$(/sbin/service --status-all 2>/dev/null | grep "is running")
    fi

    echo "Service Configure"
    echo "--------------------------------"
    echo "$conf" | column -t
    echo ""
    echo "The Running Services"
    echo "--------------------------------"
    echo "$process"
}

function getAutoStartStatus(){
    echo ""
    echo "############################ Check Self-starting Services ##########################"
    local conf=$(grep -v "^#" /etc/rc.d/rc.local| sed '/^$/d')
    echo "$conf"
}

function getNetworkStatus(){
    echo ""
    echo "############################ Check Network ############################"
    local IP=$(ip -f inet addr | grep -v 127.0.0.1 |  grep inet | awk '{print $NF,$2}' | tr '\n' ',' | sed 's/,$//')
    local MAC=$(ip link | grep -v "LOOPBACK\|loopback" | awk '{print $2}' | sed 'N;s/\n//' | tr '\n' ',' | sed 's/,$//')
    local GATEWAY=$(ip route | grep default | awk '{print $3}')
    local DNS=$(grep nameserver /etc/resolv.conf| grep -v "#" | awk '{print $2}' | tr '\n' ',' | sed 's/,$//')

    echo ""
    echo "     IP: $IP"
    echo "    MAC: $MAC"
    echo "Gateway: $GATEWAY "
    echo "    DNS: $DNS"

    report_IP="$IP"
    report_MAC="$MAC"
    report_GATEWAY="$GATEWAY"
    report_DNS="$DNS"
}

function getListenStatus(){
    echo ""
    echo "############################ Check Connect Status ############################"
    local Listen=$(netstat -ntulp)
    local AllConnect=$(ss -an | awk 'NR>1 {++s[$1]} END {for(k in s) print k,s[k]}' | column -t)
    echo " 网络端口：$Listen"
    echo "TCP状态值：$AllConnect"
}

function getCronStatus(){
    echo ""
    echo "############################ Check Crontab ########################"
    for shell in $(grep -v "/sbin/nologin" /etc/shells)
    do
        for user in $(grep "$shell" /etc/passwd | awk -F: '{print $1}')
        do
            crontab -l -u $user >/dev/null 2>&1
            status=$?
            if [ $status -eq 0 ];then
                echo "$user"
                echo "-------------"
                crontab -l -u $user
                echo ""
            fi
        done
    done
}

function getHowLongAgo(){
    # 计算一个时间戳离现在有多久了
    local datetime="$*"
    [ -z "$datetime" ] && echo "错误的参数：getHowLongAgo() $*"
    local Timestamp=$(date +%s -d "$datetime")    #转化为时间戳
    local Now_Timestamp=$(date +%s)
    local Difference_Timestamp=$(($Now_Timestamp-$Timestamp))
    local days=0;hours=0;minutes=0;
    local sec_in_day=$((60*60*24));
    local sec_in_hour=$((60*60));
    local sec_in_minute=60
    while (( $(($Difference_Timestamp-$sec_in_day)) > 1 ))
    do
        let Difference_Timestamp=Difference_Timestamp-sec_in_day
        let days++
    done
    while (( $(($Difference_Timestamp-$sec_in_hour)) > 1 ))
    do
        let Difference_Timestamp=Difference_Timestamp-sec_in_hour
        let hours++
    done
    echo "$days 天 $hours 小时前"
}

function getUserLastLogin(){
    # 获取用户最近一次登录的时间，含年份
    # 很遗憾last命令不支持显示年份，只有"last -t YYYYMMDDHHMMSS"表示某个时间之间的登录，
    # "last -t 20170101000000" 表示20160101000000 - 20170101000000的登陆信息？
    # 我们只能用最笨的方法了，对比今天之前和今年元旦之前（或者去年之前和前年之前……）某个用户
    # 登录次数，如果登录统计次数有变化，则说明最近一次登录是今年。
    local username=$1
    : ${username:="`whoami`"}
    local thisYear=$(date +%Y)
    local oldesYear=$(last | tail -n1 | awk '{print $NF}')
    local loginBeforeToday=$(($(last $username | wc -l)-2))
    while(( $thisYear >= $oldesYear))
    do
        local loginBeforeNewYearsDayOfThisYear=$(($(last $username -t $thisYear"0101000000" | wc -l)-2))
        if [ $loginBeforeToday -eq 0 ];then
            echo "Never Login"
            break
        elif [ $loginBeforeToday -gt $loginBeforeNewYearsDayOfThisYear ];then
            local lastDateTime=$(last -i $username | head -n1 | awk '{for(i=4;i<(NF-2);i++)printf"%s ",$i}')" $thisYear" #格式如: Sat Nov 2 20:33 2015
            lastDateTime=$(date "+%Y-%m-%d %H:%M:%S" -d "$lastDateTime")
            echo "$lastDateTime"
            break
        else
            thisYear=$((thisYear-1))
        fi
    done
}

function getUserStatus(){
    echo ""
    echo "############################ Check User ############################"
    # /etc/passwd the last modification time
    local pwdfile="$(cat /etc/passwd)"
    local Modify=$(stat /etc/passwd | grep Modify | tr '.' ' ' | awk '{print $2,$3}')
    echo "/etc/passwd The last modification time：$Modify ($(getHowLongAgo $Modify))"
    echo ""
    echo "User List"
    echo "--------"
    echo "$(
    echo "UserName UID GID HOME SHELL LasttimeLogin"
    for shell in $(grep -v "/sbin/nologin" /etc/shells)
    do
        for username in $(grep "$shell" /etc/passwd| awk -F: '{print $1}')
        do
            local userLastLogin="$(getUserLastLogin $username)"
            echo "$pwdfile" | grep -w "$username" |grep -w "$shell"| awk -F: -v lastlogin="$(echo "$userLastLogin" | tr ' ' '_')" '{print $1,$3,$4,$6,$7,lastlogin}'
        done
    done
    )" | column -t
    echo ""
    echo "Null Password User"
    echo "------------------"
    for shell in $(grep -v "/sbin/nologin" /etc/shells)
    do
        for user in $(echo "$pwdfile" | grep "$shell" | cut -d: -f1)
        do
            local r=$(awk -F: '$2=="!!"{print $1}' /etc/shadow | grep -w $user)
            if [ ! -z $r ];then
                echo $r
            fi
        done
    done
    echo ""
    echo "The Same UID User"
    echo "----------------"
    local UIDs=$(cut -d: -f3 /etc/passwd | sort | uniq -c | awk '$1>1{print $2}')
    for uid in $UIDs
    do
        echo -n "$uid";
        local r=$(awk -F: 'ORS="";$3=='"$uid"'{print ":",$1}' /etc/passwd)
        echo "$r"
        echo ""
    done
}

function getPasswordStatus {
    echo ""
    echo "############################ Check Password Status ############################"
    pwdfile="$(cat /etc/passwd)"
    echo ""
    echo "Password Expiration Check"
    echo "-------------------------"
    result=""
    for shell in $(grep -v "/sbin/nologin" /etc/shells);do
        for user in $(echo "$pwdfile" | grep "$shell" | cut -d: -f1);do
            get_expiry_date=$(/usr/bin/chage -l $user | grep 'Password expires' | cut -d: -f2)
            if [[ $get_expiry_date = ' never' || $get_expiry_date = 'never' ]];then
                printf "%-15s never expiration\n" $user
                result="$result,$user:never"
            else
                password_expiry_date=$(date -d "$get_expiry_date" "+%s")
                current_date=$(date "+%s")
                diff=$(($password_expiry_date-$current_date))
                let DAYS=$(($diff/(60*60*24)))
                printf "%-15s %s expiration after days\n" $user $DAYS
                result="$result,$user:$DAYS days"
            fi
        done
    done
    echo ""
    echo "Check The Password Policy"
    echo "------------"
    grep -v "#" /etc/login.defs | grep -E "PASS_MAX_DAYS|PASS_MIN_DAYS|PASS_MIN_LEN|PASS_WARN_AGE"
    echo ""
}

function getSudoersStatus(){
    echo ""
    echo "############################ Sudoers Check #########################"
    conf=$(grep -v "^#" /etc/sudoers| grep -v "^Defaults" | sed '/^$/d')
    echo "$conf"
    echo ""
}

function getProcessStatus(){
    echo ""
    echo "############################ Process Check ############################"
    if [ $(ps -ef | grep defunct | grep -v grep | wc -l) -ge 1 ];then
        echo ""
        echo "zombie process";
        echo "--------"
        ps -ef | head -n1
        ps -ef | grep defunct | grep -v grep
    fi
    echo ""
    echo "Merory Usage TOP10"
    echo "-------------"
    echo -e "PID %MEM RSS COMMAND
    $(ps aux | awk '{print $2, $4, $6, $11}' | sort -k3rn | head -n 10 )"| column -t
    echo ""
    echo "CPU Usage TOP10"
    echo "------------"
    top b -n1 | head -17 | tail -11
}

function getState(){
    if [[ $OS_Version < 7 ]];then
        if [ -e "/etc/init.d/$1" ];then
            if [ `/etc/init.d/$1 status 2>/dev/null | grep "is running" | wc -l` -ge 1 ];then
                r="active"
            else
                r="inactive"
            fi
        else
            r="unknown"
        fi
    else
        #CentOS 7+
        r="$(systemctl is-active $1 2>&1)"
    fi
    echo "$r"
}

function getFirewallStatus(){
    echo ""
    echo "############################ Firewall Check ##########################"
    # Firewall Status/Poilcy
    if [[ $OS_Version < 7 ]];then
        /etc/init.d/iptables status >/dev/null  2>&1
        status=$?
        if [ $status -eq 0 ];then
                s="active"
        elif [ $status -eq 3 ];then
                s="inactive"
        elif [ $status -eq 4 ];then
                s="permission denied"
        else
                s="unknown"
        fi
    else
        s="$(getState iptables)"
    fi
    echo "iptables: $s"
    echo ""
    echo "/etc/sysconfig/iptables"
    echo "-----------------------"
}

function getSSHStatus(){
    #SSHD Service Status,Configure
    echo ""
    echo "############################ SSH Check #############################"
    # Check the trusted host
    pwdfile="$(cat /etc/passwd)"
    echo "Service Status：$(getState sshd)"
    Protocol_Version=$(cat /etc/ssh/sshd_config | grep Protocol | awk '{print $2}')
    echo "SSH Protocol Version：$Protocol_Version"
    echo ""
    echo "Whether to allow ROOT remote login"
    echo "----------------------------------"
    config=$(grep PermitRootLogin /etc/ssh/sshd_config)
    firstChar=${config:0:1}
    if [ $firstChar == "#" ];then
        PermitRootLogin="yes"  #The default is to allow ROOT remote login
    else
        PermitRootLogin=$(echo $config | awk '{print $2}')
    fi
    echo "PermitRootLogin $PermitRootLogin"
}

function getZabbixStatus(){
    # Check Zabbix Serivce Status
    echo ""
    echo "######################### Zabbix Check ##############################"
    netstat -nltp | grep -v grep | grep zabbix > /dev/null 2>&1
    if [ $? -eq 0 ];then
       echo "Service Status": Zabbix is running!
    else
       echo "Service Status": Zabbix not running!
    fi
}

function check(){
    getSystemStatus
    getCpuStatus
    getMemStatus
    getDiskStatus
    getNetworkStatus
    getListenStatus
    getProcessStatus
    getServiceStatus
    getAutoStartStatus
    getCronStatus
    getUserStatus
    getPasswordStatus
    getSudoersStatus
    getSSHStatus
    getZabbixStatus
}

# Perform inspections and save the inspection results
echo "Check the result"
check | tee $RESULTFILE
