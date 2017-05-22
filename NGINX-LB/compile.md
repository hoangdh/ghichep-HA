### Hướng dẫn biên dịch NGINX từ Source code


- **Bước 1**: Cài đặt các trình biên dịch

Để cài đặt nginx từ source, chúng ta phải cài đặt thêm cho máy chủ các trình biên dịch.

```
yum -y install gcc gcc-c++ pcre-devel zlib-devel \
libxml2-devel curl-devel libjpeg-devel libpng-devel \
libXpm-devel freetype-devel openldap-devel wget openssl-devel
```

- **Bước 2**: Tải `nginx` từ trang chủ

Chúng ta tải bản mới nhất từ [trang chủ](http://nginx.org/download/)

```
wget http://nginx.org/download/nginx-1.11.13.tar.gz
```

- **Bước 3**: Giải nén source code

```
tar -xzf nginx-1.11.13.tar.gz
```

- **Bước 4**: Biên dịch source

```
cd nginx-1.11.13

./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx \
 --conf-path=/etc/nginx/nginx.conf \
 --error-log-path=/var/log/nginx/error.log \
 --http-log-path=/var/log/nginx/access.log \
 --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock \
 --http-client-body-temp-path=/var/cache/nginx/client_temp \
 --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
 --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
 --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
 --http-scgi-temp-path=/var/cache/nginx/scgi_tem \
 --with-http_stub_status_module \
 --with-http_ssl_module \
 --with-stream
 
make

make install
```

- **Bước 5**: Cấu hình nginx

Sau khi cài đặt xong, chúng ta mở file cấu hình của nginx và thêm vào những dòng sau:

```
vi /etc/nginx/nginx.conf
```

```
...
stream {
      upstream stream_backend {
        zone tcp_servers 64k;
        server 192.168.100.140:3306;
        server 192.168.100.141:3306;
        server 192.168.100.142:3306;
    }
    server {
        listen 3306;
        proxy_pass stream_backend;
        proxy_connect_timeout 1s;
    }
}
```

Chú ý: Cấu hình PID cho NGINX, bằng cách thêm hoặc chỉnh sửa dòng

```
pid        /var/run/nginx.pid;
```

<img src="images/pid.png" />


Lưu lại file và thoát.

- **Bước 6**: Thêm systemd cho nginx

Tạo file systemd cho nginx

```
vi /lib/systemd/system/nginx.service
```

Nội dung như sau:

```
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

Phân quyền cho script:

```
chmod +x /lib/systemd/system/nginx.service
```

- **Bước 7**: Khởi động nginx

```
systemctl restart nginx
systemctl enable nginx
```

Kiểm tra bằng lệnh:

```
ss -npl | grep 3306
```

<img src="images/nginx-lb.png" />

Như vậy, nginx đã hoạt động và lắng nghe với port 3306.

Sau đó, chúng ta cùng [kiểm tra hoạt động](README.md#3) của nó.