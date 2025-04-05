#!/bin/bash

# backup /etc/rsyslog.conf
if [ ! -f /etc/rsyslog.conf.bak ]; then
    cp /etc/rsyslog.conf /etc/rsyslog.conf.bak
fi

# 取消注释
sed -i 's/#$ModLoad imudp/$ModLoad imudp/' /etc/rsyslog.conf
sed -i 's/#$UDPServerRun 514/$UDPServerRun 514/' /etc/rsyslog.conf

# check local2 if exists
grep -q "local2\.\*     /var/log/haproxy.log" /etc/rsyslog.conf

if [ $? -eq 0 ]; then
    echo "Local2 exists"
else
    sed -i '/local7\.\*/i local2.*     /var/log/haproxy.log' /etc/rsyslog.conf
    echo "Add local2 successfully"
fi

systemctl restart rsyslog.service
