#!/bin/bash
#VNET 一键部署脚本
function check_system(){
if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
    release='CentOS'
    PM='yum'
elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release; then
    release='RHEL'
    PM='yum'
elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
    release='Aliyun'
    PM='yum'
elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
    release='Fedora'
    PM='yum'
elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
    release='Debian'
    PM='apt'
elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
    release='Ubuntu'
    PM='apt'
elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
    release='Raspbian'
    PM='apt'
else
    release='Unknow'
fi
bit=`uname -m`
if ! [[ ${release} == "Unknow" ]] && [[ ${bit} == "x86_64" ]]; then
echo -e "当前系统为[${release} ${bit}],\033[32m  可以搭建\033[0m"
else
echo -e "\033[31m 脚本停止运行(●°u°●)​ 」，请更换centos7.x 64位系统运行此脚本 \033[0m"
exit 0;
fi
}

function install(){
clear
check_system
# 检测依赖
if ! [ -x "$(command -v wget)" ]; then
    echo "缺少wget,自动安装"
    ${PM} install wget -y
fi

echo '设置每天几点几分重启节点'
read -p " 按下回车默认0时， 小时(0-23): " -r -e -i 7 hour
read -p " 按下回车默认30分，分钟(0-59): " -r -e -i 30 minute
read -p " 面板地址(带http[s]://xxxxx): " -r -e -i https://api.0599.pro  api_host
read -p " 面板通讯密钥(节点管理->节点授权中): " -r -e  api_key
read -p " 节点id: " -r -e  node_id

cd /root/
#清理上次下载
rm -rf vnet_latest.tar.gz vnet

#下载vnet最新版本压缩包
wget https://kitami-hk.oss-cn-hongkong.aliyuncs.com/vnet_2.0.3.tar.gz -O vnet_latest.tar.gz
mkdir -p /root/vnet
tar -xzvf vnet_latest.tar.gz -C vnet

cd /root/vnet
chmod +x vnet

# 生成配置文件
cat > config.json << EOF
{
    "node_id":$node_id,
    "key": "$api_key",
    "api_host": "$api_host"
}
EOF
echo "配置已生成"

# 服务安装
ln -P vnet.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable vnet
systemctl start vnet
echo "服务已安装"

# 关闭防火墙
if [[ ${release} == "CentOs" ]]; then
    systemctl stop firewalld
    systemctl disable firewalld.service
    echo "防火墙已关闭"
fi

echo "$minute $hour * * * systemctl restart vnet" >> /etc/crontab
echo "已设置自动重启"
}

uninstal(){
clear
echo "卸载vnet"
systemctl stop vnet
systemctl disable vnet
rm -rf /root/vnet
rm -rf /etc/systemd/system/vnet.service
systemctl daemon-reload
sed -i "/root/d" /etc/crontab
sed -i "/vnet/d" /etc/crontab
echo "卸载完成"
}

start_menu(){
clear
echo -e "
-- VNET管理脚本 --
1. 安装vnet
2. 卸载vnet
3. 退出"
echo
read -p "请输入数字{1,2,3}:" num
case "$num" in
1)
install
exit 0
;;
2)
uninstal
exit 0
;;
3)
exit 1
;;
esac
echo "请输入正确的数字: {1,2,3}"
sleep 3
start_menu
}

start_menu
