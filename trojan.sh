#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#开始菜单
start_menu(){
  clear
echo && echo -e " Linserver一键安装脚本
  
————————————请选择安装类型————————————
 ${Green_font_prefix}1.${Font_color_suffix} xrayr_trojan
 ${Green_font_prefix}2.${Font_color_suffix} esc 
————————————————————————————————" && echo

	
echo
read -p " 请输入数字 [0-9]:" num
case "$num" in
	1)
	xrayr_trojan
	;;
	2)
	exit 1
	;;
	*)
	clear
	echo -e "${Error}:请输入正确数字 [1-15]"
	sleep 5s
	start_menu
	;;
esac
}

#安装docker
dockerinstall(){
echo "检查Docker......"
	docker -v
    if [ $? -eq  0 ]; then
        echo "检查到Docker已安装!"
    else
    	echo "安装docker环境..."
        docker version > /dev/null || curl -fsSL get.docker.com | bash
        service docker restart
        sudo systemctl enable docker.service
        curl -fsSL https://get.docker.com | bash -s docker
        echo "安装docker环境...安装完成并设置开机启动"
    fi
    sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}



#防火墙和必要组件
suidaoanquan(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
	
    systemctl stop firewalld
    systemctl mask firewalld
    if [[ "${release}" == "centos" ]]; then
      yum -y install bc #小树对比
	  yum -y install unzip
	  yum -y install git
	  yum install -y iptables
      yum install iptables-services -y
	  iptables -F
      iptables -P INPUT ACCEPT
      iptables -X
	   echo -e "Centos防火墙设置完成"
	   elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
	   apt -y install bc #小树对比
	   apt -y install unzip
	   apt -y install git
	   apt install -y iptables
       apt install iptables-services -y
	   iptables -F
       iptables -P INPUT ACCEPT
       iptables -X
	   echo -e "防火墙设置完成"
	   fi	
}



xrayr_trojan()
{
    suidaoanquan
    dockerinstall
    git clone https://github.com/Lin-UN/XrayR
    cd XrayR
    read -p "请输入面板网站(结尾不要带/ 例如：https://baidu.com): " Userurl
	read -p "请输入面板key: " UserKey
	read -p "请输入面板的节点id: " UserNODE_ID
	read -p "请输入节点域名(用于申请SSL证书): " UserHost
	sed -i "s#https://baidu.com#${Userurl}#" /root/XrayR/config.yml
    sed -i "s/123/$UserKey/" /root/XrayR/config.yml
    sed -i "s/999/$UserNODE_ID/" /root/XrayR/config.yml
    sed -i "s/node1.test.com/$UserHost/" /root/XrayR/config.yml
    docker-compose up -d
    echo "0 4 * * * service docker restart" >> /var/spool/cron/root
    systemctl restart crond
}


#这里开始
cd /root/
start_menu
timedatectl set-timezone Asia/Shanghai
