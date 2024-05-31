#! /bin/bash
#Block-IPs-from-countries
#Github:https://github.com/iiiiiii1/Block-IPs-from-countries
#Blog:https://www.moerats.com/

Green="\033[32m"
Font="\033[0m"

countries=("cn")
iplist=()

#root权限
root_need(){
    if [[ $EUID -ne 0 ]]; then
        echo "Error:This script must be run as root!" 1>&2
        exit 1
    fi
}

#清除iptables input规则
clear_input_rule(){
iptables -F INPUT
echo -e "${Green}已清除所有INPUT规则！${Font}"
}

#清除ipset规则
clear_ipset_rules() {
ipset -F
echo -e "${Green}已清除所有IPSET规则！${Font}"
}

#添加默认规则
add_default_rules() {
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -j ACCEPT -p icmp
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -P INPUT DROP
echo -e "${Green}已设置INPUT规则默认DENY${Font}"
}

#添加国家ip规则
accept_ipset(){
#添加ipset规则
GEOIP=$1
echo -e "${Green}正在下载IPs data...${Font}"
wget -P /tmp http://www.ipdeny.com/ipblocks/data/countries/$GEOIP.zone 2> /dev/null
#检查下载是否成功
    if [ -f "/tmp/"$GEOIP".zone" ]; then
	 echo -e "${Green}IPs data下载成功！${Font}"
    else
	 echo -e "${Green}下载失败，请检查你的输入！${Font}"
	 echo -e "${Green}代码查看地址：http://www.ipdeny.com/ipblocks/data/countries/${Font}"
    exit 1
    fi
#创建规则
ipset -N $GEOIP hash:net
for i in $(cat /tmp/$GEOIP.zone ); do ipset -A $GEOIP $i; done
rm -f /tmp/$GEOIP.zone
echo -e "${Green}规则添加成功，即将开始添加ip！${Font}"
#开始封禁
iptables -I INPUT -p tcp -m set --match-set "$GEOIP" src -j ACCEPT
iptables -I INPUT -p udp -m set --match-set "$GEOIP" src -j ACCEPT
echo -e "${Green}所指定国家($GEOIP)的ip添加成功！${Font}"
}

#添加ip段规则
accept_iplist(){
IP=$1
iptables -I INPUT -s $IP -j ACCEPT
echo -e "${Green}所指定IP($IP)添加成功！${Font}"
}

#检查系统版本
check_release(){
    if [ -f /etc/redhat-release ]; then
        release="centos"
    elif cat /etc/issue | grep -Eqi "debian"; then
        release="debian"
    elif cat /etc/issue | grep -Eqi "ubuntu"; then
        release="ubuntu"
    elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
        release="centos"
    elif cat /proc/version | grep -Eqi "debian"; then
        release="debian"
    elif cat /proc/version | grep -Eqi "ubuntu"; then
        release="ubuntu"
    elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
        release="centos"
    fi
}

#检查ipset是否安装
check_ipset(){
    if [ -f /sbin/ipset ]; then
        echo -e "${Green}检测到ipset已存在，并跳过安装步骤！${Font}"
    elif [ "${release}" == "centos" ]; then
        yum -y install ipset
    else
        apt-get -y install ipset
    fi
}

#开始菜单
main(){
root_need
check_release
check_ipset

clear

clear_input_rule
clear_ipset_rules
echo -e "———————————————————————————————————————"
echo -e "${Green}Linux VPS一键白名单指定国家所有的IP访问${Font}"
echo -e "${Green}指定的国家或地区[${countries[@]}]${Font}"
echo -e "${Green}指定的IP段[${iplist[@]}]${Font}"
echo -e "———————————————————————————————————————"

for i in ${countries[@]}; do
	accept_ipset $i
done

for i in ${iplist[@]}; do
	accept_iplist $i
done

#设置默认规则
add_default_rules
}
main