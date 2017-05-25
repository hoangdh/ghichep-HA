#!/bin/bash
yum -y install gcc gcc-c++ make zlib-devel pcre-devel openssl-devel git wget geoip-devel epel-release

mkdir /opt/source/
cd /opt/source/
wget http://nginx.org/download/nginx-1.11.10.tar.gz
tar -xzf nginx-1.11.10.tar.gz
git clone git://github.com/vozlt/nginx-module-stream-sts.git
git clone https://github.com/vozlt/nginx-module-sts
git clone https://github.com/vozlt/nginx-module-vts

cd /opt/source/nginx-1.11.10

 ./configure --user=nginx --group=nginx --add-module=../nginx-module-sts/ --add-module=../nginx-module-vts/ --add-module=../nginx-module-stream-sts/ --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-mail --with-mail_ssl_module --with-file-aio --with-stream --with-http_geoip_module

useradd -r nginx
mkdir -p /var/cache/nginx/client_temp/
chown nginx. /var/cache/nginx/client_temp/

cat > /lib/systemd/system/nginx.service << H2
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/bin/kill -s HUP \$MAINPID
ExecStop=/bin/kill -s QUIT \$MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
H2

chmod a+rx /lib/systemd/system/nginx.service
systemctl start nginx
systemctl enable nginx