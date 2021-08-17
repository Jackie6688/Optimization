#!/usr/bin/env bash
stdout() {
    echo -e "\033[32m$1\033[0m"
}

if [[ -f /etc/redhat-release ]]; then
    release="centos"
elif cat /etc/issue | grep -q -E -i "raspbian|debian"; then
    release="debian"
elif cat /etc/issue | grep -q -E -i "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
    release="centos"
elif cat /proc/version | grep -q -E -i "raspbian|debian"; then
    release="debian"
elif cat /proc/version | grep -q -E -i "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
    release="centos"
else
    stdout "--------------------------------------------------"
    stdout "                  不支持的操作系统                  "
    stdout "--------------------------------------------------"

    exit 1
fi

stdout "--------------------------------------------------"
stdout "                   正在更新系统中                   "
stdout "--------------------------------------------------"
if [[ ${release} == "centos" ]]; then
    yum makecache
    yum install epel-release -y
    yum update -y
else
    apt update
    apt dist-upgrade -y
fi

stdout "----------------安装中----------------------"
if [[ ${release} == "centos" ]]; then
    yum install haveged -y
else
    apt install haveged -y
fi

stdout "--------------------------------------------------"
stdout "                配置中                  "
stdout "--------------------------------------------------"
systemctl disable haveged
systemctl enable haveged
systemctl restart haveged

stdout "--------------------------------------------------"
stdout "                 优化中                "
stdout "--------------------------------------------------"
echo "fs.file-max = 65535" >/etc/sysctl.conf
echo "net.core.rmem_max = 67108864" >>/etc/sysctl.conf
echo "net.core.wmem_max = 67108864" >>/etc/sysctl.conf
echo "net.core.netdev_max_backlog = 250000" >>/etc/sysctl.conf
echo "net.core.somaxconn = 65535" >>/etc/sysctl.conf
echo "net.ipv4.tcp_syncookies = 1" >>/etc/sysctl.conf
echo "net.ipv4.tcp_tw_reuse = 1" >>/etc/sysctl.conf
echo "net.ipv4.tcp_fin_timeout = 30" >>/etc/sysctl.conf
echo "net.ipv4.tcp_keepalive_time = 1200" >>/etc/sysctl.conf
echo "net.ipv4.ip_local_port_range = 10000 65000" >>/etc/sysctl.conf
echo "net.ipv4.tcp_max_syn_backlog = 8192" >>/etc/sysctl.conf
echo "net.ipv4.tcp_max_tw_buckets = 5000" >>/etc/sysctl.conf
echo "net.ipv4.tcp_fastopen = 3" >>/etc/sysctl.conf
echo "net.ipv4.tcp_rmem = 4096 87380 67108864" >>/etc/sysctl.conf
echo "net.ipv4.tcp_wmem = 4096 65536 67108864" >>/etc/sysctl.conf
echo "net.ipv4.tcp_mtu_probing = 1" >>/etc/sysctl.conf
echo "net.core.default_qdisc = fq" >>/etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control = bbr" >>/etc/sysctl.conf
echo "* soft nofile 65535" >/etc/security/limits.conf
echo "* hard nofile 65535" >>/etc/security/limits.conf
echo "* soft nproc 65535" >>/etc/security/limits.conf
echo "* hard nproc 65535" >>/etc/security/limits.conf
sysctl -p

stdout "--------------------------------------------------"
stdout "                 已完成                "
stdout "--------------------------------------------------"
stdout "               @Ted686488              "

exit 0
