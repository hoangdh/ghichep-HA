#!/bin/bash

## Khai báo bi?n
# $HOST1=node1
# $HOST2=node2
# $IP1=192.168.100.197
# $IP2=192.168.100.198
# $VIP=192.168.100.123
# $PASSWORD=Abcdef@6789

source var.cfg
caidatchung()
{
ssh -i node$1 root@$2 "setenforce 0 && sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config"
ssh -i node$1 root@$2 "echo -e "$IP1 $HOST1" >> /etc/hosts && echo -e "$IP2 $HOST2" >> /etc/hosts"
ssh -i node$1 root@$2 "yum install httpd pacemaker pcs -y"
cat > status.conf << H2
<Location /server-status>
   SetHandler server-status
   Order Deny,Allow
   Deny from all
   Allow from 127.0.0.1
</Location>
H2
scp -i node$1 status.conf root@$2:/etc/httpd/conf.d/
ssh -i node$1 root@$2 "systemctl start pcsd.service && systemctl enable pcsd.service && echo "$PASSWORD" | passwd hacluster --stdin"
ssh -i node$1 root@$2 "systemctl enable corosync.service && systemctl enable pacemaker.service"
}
caidatrieng()
{
    ssh -i node$1 root@$2 "pcs cluster auth $HOST1 $HOST2 --force -u hacluster -p $PASSWORD"
    ssh -i node$1 root@$2 "pcs cluster setup --name webcluster $HOST1 $HOST2"
    ssh -i node$1 root@$2 "pcs cluster start --all"
    ssh -i node$1 root@$2 "pcs property set stonith-enabled=false"
    ssh -i node$1 root@$2 "pcs property set no-quorum-policy=ignore"
    ssh -i node$1 root@$2 "pcs resource create Cluster_VIP ocf:heartbeat:IPaddr2 ip=$VIP cidr_netmask=24 op monitor interval=20s"
    ssh -i node$1 root@$2 "pcs resource create WebServer ocf:heartbeat:apache configfile=/etc/httpd/conf/httpd.conf statusurl="http://127.0.0.1/server-status" op monitor interval=20s"
    ssh -i node$1 root@$2 "pcs constraint colocation add WebServer Cluster_VIP INFINITY"
}

for ip in $IP2 $IP1
do
    NODE=`cat var.cfg | grep -w "$ip" | awk -F = '{print $1}' | awk -F P {'print $2'}`
    if [ "$NODE" = "2" ]
    then
        echo "Cai dat Node $NODE"
        caidatchung $NODE $ip
    else
         echo "Cai dat Node $NODE"
        caidatchung $NODE $ip
        caidatrieng $NODE $ip
    fi
done 