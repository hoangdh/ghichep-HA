#!/bin/bash

## Khai báo bi?n
# $HOST1=node1
# $HOST2=node2
# $IP1=192.168.100.197
# $IP2=192.168.100.198
# $VIP=192.168.100.123
# $PASSWORD=Abcdef@6789

source var.cfg

cauhinh_2node(){

echo -e "\n$IP1 $HOST1\n$IP2 $HOST2" >> /etc/hosts
yum install httpd -y
cat > /etc/httpd/conf.d/status.conf << H2
<Location /server-status>
   SetHandler server-status
   Order Deny,Allow
   Deny from all
   Allow from 127.0.0.1
</Location>
H2

yum install pacemaker pcs -y
systemctl start pcsd.service
systemctl enable pcsd.service
echo "$PASSWORD" | passwd hacluster --stdin


}
cauhinh_1node()
{

pcs cluster auth $HOST1 $HOST2 --force -u hacluster -p $PASSWORD
pcs cluster setup --name webcluster $HOST1 $HOST2
pcs cluster start --all
systemctl enable corosync.service
systemctl enable pacemaker.service

pcs property set stonith-enabled=false
pcs property set no-quorum-policy=ignore

pcs resource create Cluster_VIP ocf:heartbeat:IPaddr2 ip=$VIP cidr_netmask=24 op monitor interval=20s

pcs resource create WebServer ocf:heartbeat:apache configfile=/etc/httpd/conf/httpd.conf statusurl="http://127.0.0.1/server-status" op monitor interval=20s

 pcs constraint colocation add WebServer Cluster_VIP INFINITY
}

read -p "Node may? " NODE
case $NODE in
    1)
            cauhinh_2node
            cauhinh_1node
            ;;
    2)
            cauhinh_2node
            ;;
esac



# for x in $IP1 $IP2
# do
    
# done 

# tmp=$(ip a | grep -w "$x")
    # if [ -n "$tmp" ]
    # then
        # IP=$x
        # NODE=`cat var.cfg | grep -w "$x" | awk -F = '{print $1}' | awk -F P {'print $2'}`
    
        # case $NODE in
            # 1)
                 # echo "NODE $NODE has IP address: $IP"
                    # ;;
            # 2)
                 # echo "NODE $NODE has IP address: $IP"
                    # ;;
         # esac
    # else
        # echo "Invaild node!"
    # fi