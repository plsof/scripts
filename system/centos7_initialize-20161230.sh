#!/bin/bash

if [[ "$(whoami)" != "root" ]]; then
  
    echo "please run this script as root ." >&2
    exit 1
fi


yum -y install wget lrzsz
yum -y install dos2unix


#disable selinux
sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config
setenforce 0
 

yum -y install iscsi-initiator-utils 
yum -y install inotify-tools 


# [base], [addons], [updates], [extras] ... priority=1
# [centosplus],[contrib] ... priority=2
# Third Party Repos such as rpmforge ... priority=N  (where N is > 10 and based on your preference)
yum -y install yum-priorities

#wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
#wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
yum -y install epel-release

yum clean all && yum makecache && yum -y update
 

yum -y groupinstall "base"
#yum -y install net-tools
#yum -y install parted xfsprogs

yum -y install lsb


#http://repoforge.org/use/
#yum install --enablerepo=rpmforge-extras` xxx
#yum -y install http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm


echo "ipvsadm --set 120 10 120" >> /etc/rc.local
echo 'options ip_vs conn_tab_bits=20'>/etc/modprobe.d/ipvsadm.conf 
echo "options nf_conntrack hashsize=131072" > /etc/modprobe.d/nf_conntrack.conf 


#zone and ntp
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
printf 'ZONE="Asia/Shanghai"\nUTC=false\nARC=false' > /etc/sysconfig/clock
echo 'LANG="en_US.UTF-8"' > /etc/sysconfig/i18n
echo "0 3 * * * /usr/sbin/ntpdate cn.pool.ntp.org >& /dev/null" >>/var/spool/cron/root
echo "30 3 * * * /usr/sbin/ntpdate time-a.nist.gov >& /dev/null" >>/var/spool/cron/root
echo "30 4 * * * /usr/sbin/ntpdate time-b.nist.gov >& /dev/null" >>/var/spool/cron/root


#ulimit -SHn
echo "ulimit -SHn 102400" >> /etc/rc.local
cat >> /etc/security/limits.conf << EOF
 *           soft   nofile       102400
 *           hard   nofile       102400
 *           soft   nproc        102400
 *           hard   nproc        102400
EOF

sed -i 's/\*.*nproc.*1024$/\*       soft       nproc       102400/' /etc/security/limits.d/90-nproc.conf

#set ssh
sed -i 's/^GSSAPIAuthentication yes$/GSSAPIAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
systemctl restart sshd

 
#iptables
systemctl stop firewalld.service
systemctl disable firewalld.service

yum -y install iptables-services
cp /usr/libexec/iptables/iptables.init /etc/init.d/iptables
#
#cat > /etc/sysconfig/iptables << EOF
## Firewall configuration written by system-config-securitylevel
## Manual customization of this file is not recommended.
#*filter
#:INPUT DROP [0:0]
#:FORWARD ACCEPT [0:0]
#:OUTPUT ACCEPT [0:0]
#:syn-flood - [0:0]
#-A INPUT -i lo -j ACCEPT
#-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
#-A INPUT -p icmp -j ACCEPT
#-A INPUT -p tcp -m state --state NEW -m multiport --dports 65522,22 -j ACCEPT
#-A INPUT -d 224.0.0.0/8 -j ACCEPT
#-A INPUT -p vrrp -j ACCEPT
#-A INPUT -p tcp -m multiport --dports 80:89,8080:8089 -j ACCEPT 
#-A INPUT -p udp -m multiport --dports 18000:18900 -j ACCEPT
#-A INPUT -p icmp -m limit --limit 100/sec --limit-burst 100 -j ACCEPT
#-A INPUT -m state --state NEW -m tcp -p tcp --dport 10050 -j ACCEPT
#-A INPUT -p udp --sport 53 -j ACCEPT
#-A INPUT -p tcp --sport 53 -j ACCEPT
#-A INPUT -p icmp -m limit --limit 1/s --limit-burst 10 -j ACCEPT
#-A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j syn-flood
#-A INPUT -j REJECT --reject-with icmp-host-prohibited
#-A syn-flood -p tcp -m limit --limit 3/sec --limit-burst 6 -j RETURN
#-A syn-flood -j REJECT --reject-with icmp-port-unreachable
#COMMIT
#EOF
#systemctl restart iptables.service 
#systemctl enable iptables.service  
 

#set sysctl
cp -f /etc/sysctl.conf /etc/sysctl.conf-first-install.bak
cat > /etc/sysctl.conf << EOF
net.ipv4.ip_forward = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
net.ipv4.tcp_max_tw_buckets = 120000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096 87380 4194304
net.ipv4.tcp_wmem = 4096 16384 4194304
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 262144
net.core.somaxconn = 262144
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 1024 65535
 
net.nf_conntrack_max = 1048576
net.netfilter.nf_conntrack_max = 1048576

#net.netfilter.nf_conntrack_tcp_timeout_established = 120
#net.netfilter.nf_conntrack_tcp_timeout_established = 180
#net.netfilter.nf_conntrack_tcp_timeout_established = 1200
net.netfilter.nf_conntrack_tcp_timeout_established = 7200

net.netfilter.nf_conntrack_tcp_timeout_time_wait = 120
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120

net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF
/sbin/sysctl -p


#define the backspace button can erase the last character typed
#echo 'stty erase ^H' >> /etc/profile
 
echo "syntax on" >> /root/.vimrc

#for irqbalance g_list_free_full
#http://blog.sina.com.cn/s/blog_5d28c79f0102vims.html
yum -y install glib2-devel


#some tools
yum -y install bash-completion
yum -y install bind-utils
yum -y install telnet openssh-clients


#python
yum -y install python-pip
pip install --upgrade pip
pip install pyinotify

#c/c++ developer tools for nginx
yum -y install gcc gdb c++ autoconf automake
yum -y install git kernel-devel kernel-headers
yum -y install readline-devel ncurses-devel
yum -y install zlib zlib-devel openssl pcre pcre-devel
yum -y install libcurl-devel curl-devel

#install requisite dirs
mkdir -p /data/{data,app,server,scripts,tmp,logs,tools}


#add user
groupadd -f sclc_ops
groupadd -f scyd_ops
groupadd -f wxzx_ops
cp -f /etc/sudoers /etc/sudoers.bak
grep -q "sclc_ops" /etc/sudoers | echo "%sclc_ops ALL=(ALL) ALL" >>/etc/sudoers
grep -q "scyd_ops" /etc/sudoers | echo "%scyd_ops ALL=(ALL) ALL" >>/etc/sudoers
grep -q "wxzx_ops" /etc/sudoers | echo "%wxzx_ops ALL=(ALL) ALL" >>/etc/sudoers

useradd pandongdong_cmsc08 -g sclc_ops
echo "E58H-pR2l8]IxEYg" | passwd pandongdong_cmsc08 --stdin

useradd pukelei_cmsc06 -g sclc_ops
echo "E58H-pR2l8]IxEYg" | passwd pukelei_cmsc06 --stdin

useradd lichangyong_cmsc01 -g sclc_ops
echo "E58H-pR2l8]IxEYg" | passwd lichangyong_cmsc01 --stdin

useradd tanglong_cmsc03 -g sclc_ops
echo "E58H-pR2l8]IxEYg" | passwd tanglong_cmsc03 --stdin

useradd chenhongliang_cmsc10 -g sclc_ops
echo "E58H-pR2l8]IxEYg" | passwd chenhongliang_cmsc10 --stdin

useradd chenquan_cmsc09 -g sclc_ops
echo "E58H-pR2l8]IxEYg" | passwd chenquan_cmsc09 --stdin

useradd fanrui_cmsc10 -g sclc_ops
echo "E58H-pR2l8]IxEYg" | passwd fanrui_cmsc10 --stdin


cp -f /etc/profile /etc/profile.bak
cat >>/etc/profile <<EOF
stty erase ^H
TMOUT=180
export TMOUT

#export HISTTIMEFORMAT="`whoami` : |  %F  | %T: |"
HISTFILESIZE=2000
HISTSIZE=2000
HISTTIMEFORMAT="%Y%m%d-%H%M%S: "
export HISTTIMEFORMAT
export PROMPT_COMMAND='{ command=$(history 1 | { read x y; echo $y; }); logger -p local1.notice -t bash -i "user=$USER,ppid=$PPID,from=$SSH_CLIENT,pwd=$PWD,command:$command"; }'
EOF

cat << EOF
+-------------------------------------------------+
|               optimizer is done                 |
|   it's recommond to restart this server !       |
+-------------------------------------------------+
EOF
