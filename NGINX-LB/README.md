## Hướng dẫn cấu hình NGINX với MariaDB Cluster trên CentOS 7

### Menu

- [1. Giới thiệu](#)
- [2. Các bước tiến hành](#)
- [2.1 Cài đặt Galera trên 3 node](#)
- [2.2 Cài đặt NGINX làm Load-balancer](#)
- [3. Kiểm tra](#)

<a name="1"></a>
### 1. Giới thiệu

NGINX được biết đến là một Web Server khá nổi tiếng. Nhưng nó cũng là một load-balancer đầy mạnh mẽ. Bài viết này sẽ hướng dẫn các bạn sử dụng NGINX làm một load-balancer cho MariaDB/MySQL trên CentOS 7.

#### Mô hình cài đặt

<img src="images/topo-nginx.png" width="75%" />

#### IP Planning

<img src="images/bangip.png" />

<a name="2"></a>
### 2. Các bước tiến hành

<a name="21"></a>
#### 2.1 Cài đặt Galera trên 3 node

- **Bước 1**: Thêm repo cho MariaDB

Trên các node `db01`, `db02` và `db03` chúng ta cài đặt MariaDB lên 3 node này. Để cài đặt được MariaDB, chúng ta phải thêm repo cho chúng.

**Tạo file repo**

```
vi /etc/yum.repos.d/MariaDB.repo
```

**Thêm nội dung sau:**

```
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
```

- **Bước 2**: Thêm thông tin các host vào file `/etc/hosts`

```
vi /etc/hosts
```

Chèn thêm thông tin các host

```
...
192.168.100.140 db01
192.168.100.141 db02
192.168.100.142 db03
```
Lưu và thoát khỏi file.

- **Bước 3**: Cài đặt MariaDB trên lần lượt các node `db01`, `db02` và `db03`

```
yum install mariadb-server rsync
```

*Chờ khoảng 5-10p cho quá trình cài đặt diễn ra thành công.*

- **Bước 4**: Cấu hình Galera cho các node

Tạo file cấu hình Galera trên từng node với nội dung:

```
vi /etc/my.cnf.d/
```

Với node `db01`:

```
[galera]
# Mandatory settings
wsrep_on=ON
wsrep_provider=/usr/lib64/galera/libgalera_smm.so

#add your node ips here
wsrep_cluster_address="gcomm://192.168.100.140,192.168.100.141,192.168.100.142"
binlog_format=row
default_storage_engine=InnoDB
innodb_autoinc_lock_mode=2
#Cluster name
wsrep_cluster_name="galera_cluster"
# Allow server to accept connections on all interfaces.

bind-address=0.0.0.0

# this server ip, change for each server
wsrep_node_address="192.168.100.140"
# this server name, change for each server
wsrep_node_name="db01"

wsrep_sst_method=rsync
```

Sau đó lưu lại và thoát.

Tương tự trên `db02` và `db03`, chúng ta cũng tạo file trên và sửa thông tin cho đúng với từng node ở 2 trường `wsrep_node_address` và `wsrep_node_name`.

- **Bước 5**: Khởi động Galera Cluster

Đầu tiên trên `db01`, chúng ta đặt nó làm node master với lệnh sau:

```
galera_new_cluster
```

Sau khi lệnh trên được thực hiện thành công, chúng ta lần lượt chuyển sang 2 node còn lại và chạy lệnh

```
systemctl start mariadb
```

- **Bước 6**: Kiểm tra cluster đã hoạt động

```
mysql -u root -e "SHOW STATUS LIKE 'wsrep_cluster_size'"
```

- **Bước 7**: Cài đặt cơ bản MariaDB

Tiếp đến, chúng ta sử dụng script `mysql_secure_installation` cài đặt cơ bản MariaDB.

```
mysql_secure_installation
```

<a name="22"></a>
#### 2.2 Cài đặt NGINX làm Load-balancer

Các bước làm trên máy chủ `nginx-lb`.

- **Bước 1**: Cài đặt các trình biên dịch

Để cài đặt nginx từ source, chúng ta phải cài đặt thêm cho máy chủ các trình biên dịch.

```
yum -y install gcc gcc-c++ pcre-devel zlib-devel libxml2-devel curl-devel libjpeg-devel libpng-devel libXpm-devel freetype-devel openldap-devel wget
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
./configure --prefix=/etc/nginx --with-http_stub_status_module --with-http_ssl_module --with-stream
make
make install
```

- **Bước 5**: Cấu hình nginx
- **Bước 6**
- **Bước 7**

<a name="3"></a>
### 3. Kiểm tra