# Cài đặt Keepalived và load-balancer cho Web Server

 **Chú ý**: Bài viết hướng dẫn Load-balancing cho Web Server với 2 module là nginx (ngx_http_upstream_module) và HAProxy. Hãy chọn 1 trong 2 module để cấu hình cho server của bạn, không cài đặt 2 module cùng lúc để tránh xung đột. Xin cảm ơn! 

### Mô hình cài đặt

Thông tin chung:

```
OS: CentOS 6
NIC: eth0
Web server: LAMP hoặc LEMP server
Load-balancer: nginx hoặc HAProxy
```

Thông tin riêng:

```
Loadbalance 1: 192.168.100.191
Loadbalance 2: 192.168.100.192
Virtual IP: 192.168.100.123
Web Server 1: 192.168.100.196
Web Server 2: 192.168.100.198
```

### 1. Cài đặt Keepalived để tạo Virtual IP

Trên Loadbalance1 (lb1) và Loadbalance2 (lb2), chúng ta cài đặt Keepalived để tạo một Virtual IP

```
yum install -y keepalived
```

Trên lb1, chúng ta cấu hình cho nó mode active (master):

```
vi /etc/keepalived/keepalived.conf
```

```
vrrp_script chk_haproxy {           # Requires keepalived-1.1.13
        script "killall -0 haproxy"     # cheaper than pidof
        interval 2                      # check every 2 seconds
        weight 2                        # add 2 points of prio if OK
}

vrrp_instance VI_1 {
        interface eth0
        state MASTER
        virtual_router_id 51
        priority 101   # 101 on master, 100 on backup
        virtual_ipaddress {
            192.168.100.123
        }
        track_script {
            chk_haproxy
        }
}
```

- **priority 101**: Chúng ta set lb1 làm master

**Quan trọng**: Cấu hình chia sẻ Virtual IP (Làm cả trên lb1 và lb2):

Thêm vào file `sysctl.conf`

```
echo "net.ipv4.ip_nonlocal_bind=1" >> /etc/sysctl.conf
```

Chạy lệnh để hệ thống nhận file cấu hình và kiểm tra lại xem đã có dòng vừa thêm chưa:

```
sysctl -p
```

Sau đó khởi động keepalived ở lb1

```
/etc/init.d/keepalived start
chkconfig keepalived on
```
Xem lại thông tin bằng lệnh:

```
ip addr sh eth0
```

Kết quả, chúng ta thấy một địa chỉ Virtual IP đã được tạo.

```
lb1:~# ip addr sh eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN qlen 1000
    link/ether 00:0c:29:63:f7:5c brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.191/24 brd 192.168.100.255 scope global eth0
    inet 192.168.100.123/32 scope global eth0
    inet6 fe80::20c:29ff:fe63:f75c/64 scope link
       valid_lft forever preferred_lft forever
```

Tương tự ở lb2, chúng ta mở fie cấu hình 

```
vi /etc/keepalived/keepalived.conf
```

```
vrrp_script chk_haproxy {           # Requires keepalived-1.1.13
        script "killall -0 haproxy"     # cheaper than pidof
        interval 2                      # check every 2 seconds
        weight 2                        # add 2 points of prio if OK
}

vrrp_instance VI_1 {
        interface eth0
        state MASTER
        virtual_router_id 51
        priority 100   # 101 on master, 100 on backup
        virtual_ipaddress {
            192.168.100.123
        }
        track_script {
            chk_haproxy
        }
}
```

- **priority 100**: Chúng ta set lb2 làm backup

Sau đó cũng khởi động keepalived ở lb2

```
/etc/init.d/keepalived start
chkconfig keepalived on
```
Xem lại thông tin bằng lệnh:

```
ip addr sh eth0
```

Không giống như ở lb1, là chúng ta sẽ thấy Virtual IP ở phần thông tin. Chỉ khi nào lb1 ngưng hoạt động, chúng ta mới có thể thấy Virtual IP.

```
lb2:~# ip addr sh eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN qlen 1000
    link/ether 00:0c:29:be:7b:3b brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.192/24 brd 192.168.100.255 scope global eth0
    inet6 fe80::20c:29ff:febe:7b3b/64 scope link
       valid_lft forever preferred_lft forever
```

## Chọn 1 trong 2 module bên dưới để làm load-balancer

- [NGINX - ngx_http_upstream_module] (#nginx)
- [HAProxy] (#haproxy)

### 2.1 Cài đặt nginx làm load-balancer <a name="nginx"></a>

Ở trên lb1 và lb2, chúng ta cài thêm nginx để làm load-balancer.

Để cài đặt nginx, chúng ta phải cài gói `epel-release` trước.

```
yum install -y epel-release
yum install nginx -y
```

Sau khi cài đặt xong, chúng ta thêm vào file cấu hình của nginx tại **lb1** và **lb2**

```
vi /etc/nginx/nginx.conf
```

Trong phần `http` của file cấu hình, chúng ta xóa hết những dòng mặc định và thêm

```
http {
     upstream backend {
		
        server 192.168.100.196 max_fails=3 fail_timeout=30s;
	server 192.168.100.198 max_fails=3 fail_timeout=30s;
    }

    server {
        listen 80;
        location / {
            proxy_pass http://backend;
        }
    }
}
```

- **backend**: chỉ là tên của `upstream`

Khởi động nginx và cho nó khởi động cùng với hệ thống:

```
service nginx start
chkconfig nginx on
```

Như vậy chúng ta đã cài đặt xong load-balancer bằng nginx. Ngoài ra, các bạn cũng có thể tham khảo thêm cách load-balancer bằng HAProxy theo hướng dẫn bên dưới.

### 2.2 Cài đặt HAProxy <a name="haproxy"></a>

Chúng ta cài đặt HAProxy ở trên cả 2 máy lb1 và lb2 như sau:

```
yum install -y haproxy
```

Sửa file cấu hình của HAProxy (Làm trên cả 2 máy lb1 và lb2)

```
cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg_orig
cat /dev/null > /etc/haproxy/haproxy.cfg
vi /etc/haproxy/haproxy.cfg
```

```
global
        log 127.0.0.1   local0
        log 127.0.0.1   local1 notice
        #log loghost    local0 info
        maxconn 4096
        #debug
        #quiet
        user haproxy
        group haproxy

defaults
        log     global
        mode    http
        option  httplog
        option  dontlognull
        retries 3
        redispatch
        maxconn 2000
        timeout connect  5000
        timeout client  10000
        timeout server  10000
		
listen webfarm 192.168.100.123:80 # Lắng nghe IP ảo
       mode http
       stats enable
       stats auth admin:1
       balance roundrobin
       cookie JSESSIONID prefix
       option httpclose
       option forwardfor
       #option httpchk HEAD /check.txt HTTP/1.0
       server srv1 192.168.100.196:80 cookie A check
       server srv2 192.168.100.198:80 cookie B check

```
- **stats enable**: Bật tính năng Webmin của HAProxy, truy cập vào: http://192.168.100.123/haproxy?stats
- **admin:1**: là User và Password để đăng nhập vào webmin của HAProxy

Bật HAProxy và chạy cùng hệ thống khi khởi động:

```
service haproxy start
chkconfig haproxy on
```

### 3. Tham khảo:

- Cài đặt keepalived và HAProxy: https://www.howtoforge.com/setting-up-a-high-availability-load-balancer-with-haproxy-keepalived-on-debian-lenny-p2
- nginx load-balancing: http://nginx.org/en/docs/http/load_balancing.html
