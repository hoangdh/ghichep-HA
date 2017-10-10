## Hướng dẫn cấu hình NGINX với MariaDB Cluster trên CentOS 7

### Menu

- [1. Giới thiệu](#1)
- [2. Các bước tiến hành](#2)
	- [2.1 Cài đặt Galera trên 3 node](#21)
	- [2.2 Cài đặt NGINX làm Load-balancer](#22)
- [3. Kiểm tra](#3)

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
vi /etc/my.cnf.d/galera.cnf
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

- **Bước 5:** Tắt SELinux và tường lửa Firewalld

Tắt tức thời trên từng node bằng lệnh:

```
setenforce 0
```

Chỉnh sửa file cấu hình của SELinux:

```
vi /etc/sysconfig/selinux
```

Sửa dòng `SELINUX=enforcing` thành `SELINUX=disabled`.

Nếu bạn sử dụng firewalld vui lòng thêm những rule sau:

```
firewall-cmd --permanent --add-port=3306/tcp
firewall-cmd --permanent --add-port=4567/tcp
firewall-cmd --permanent --add-port=873/tcp
firewall-cmd --reload
```

- **Chú thích**:

	- `3306` là port cho phép client truy vấn vào DB
	- `4567` Port liên hệ của cluster
	- `873` rsync đồng bộ dữ liệu với nhau


- **Bước 6**: Khởi động Galera Cluster

Đầu tiên trên `db01`, chúng ta đặt nó làm node master với lệnh sau:

```
galera_new_cluster
```

Sau khi lệnh trên được thực hiện thành công, chúng ta lần lượt chuyển sang 2 node còn lại và chạy lệnh

```
systemctl start mariadb
```

- **Bước 7**: Kiểm tra cluster đã hoạt động

```
mysql -u root -e "SHOW STATUS LIKE 'wsrep_cluster_size'"
```

<img src="images/checknode.png" />

- **Bước 7**: Cài đặt cơ bản MariaDB

Tiếp đến, chúng ta sử dụng script `mysql_secure_installation` cài đặt cơ bản MariaDB.

```
mysql_secure_installation
```

<img src="images/set1.png" />

- **Chú ý**
	
	- Làm bước này trên cả 3 node `db01`, `db02` và `db03`
	- `1` Nhập mật khẩu cũ. Do mới cài đặt, mật khẩu cũ là trống nên chúng ta bấm enter để chuyển qua bước tiếp theo.
	- `2` Chọn Y để đặt Password cho user `root` của MariaDB
	- `3` Xóa user anonymous
	- `4` Cho phép login root trên localhost
	- `5` Xóa database tên `test`
	- `6` Phân lại quyền trên các bảng

<a name="22"></a>
#### 2.2 Cài đặt NGINX làm Load-balancer

Các bước làm trên máy chủ `nginx-lb`.

- **Bước 1**: Cài đặt gói repo `epel-release`

Trên CentOS, chúng ta phải cài đặt thêm gói `epel-release` để thêm một số repo mở rộng để cài đặt một số gói, trong đó có `nginx`.

```
yum install -y epel-release
```

- **Bước 2**: Cài đặt `nginx`

```
yum install -y nginx
```

- **Bước 3**: Cấu hình `nginx`

Thêm vào file cấu hình của nginx phần load-balancing cho MariaDB

```
echo -e "stream {
      upstream stream_backend {
        zone tcp_servers 64k;
        server 192.168.100.140:3306;
        server 192.168.100.141:3306 backup;
        server 192.168.100.142:3306 backup;
    }
    server {
        listen 3306;
        proxy_pass stream_backend;
        proxy_connect_timeout 1s;
    }
}" >> /etc/nginx/nginx.conf
```

**Chú ý:** Phần cấu hình trên cho MariaDB Galera hoạt động **Active/Passive**. Nếu muốn Active/Active vui lòng xóa tùy chọn `backup` ở 2 node còn lại ở phần cấu hình.

- **Bước 4**: Khởi động `nginx`

```
systemctl restart nginx
systemctl enable nginx
```

- **Bước 5**: Kiểm tra hoạt động của `nginx`

```
ss -npl | grep 3306
```

<img src="images/nginx-lb.png" />

Như vậy, nginx đã hoạt động và lắng nghe với port 3306.

**Chú ý:** Nếu trong quá trình cài đặt và cấu hình NGINX có lỗi phát sinh, vui lòng tham khảo cách compile NGINX từ source code tại [đây](compile.md).

<a name="3"></a>
### 3. Kiểm tra

- **Bước 1**: Tạo user có quyền trên anyhost

Trên host `db01`, chúng ta đăng nhập vào mysql và tạo user `root` với quyền đăng nhập anyhost (%).

```
mysql -u root -p
```

<img src="images/cu1.png" />

Đăng nhập bằng password mà bạn đã đổi ở bên trên.

Tạo user và phân quyền.

```
CREATE USER 'root'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';
```

<img src="images/cu2.png" />

**Chú ý**: Thay `password` bằng mật khẩu bạn muốn đặt.

- **Bước 2**: Kết nối vào DB theo IP của nginx-lb

Cũng tại server `db01`, chúng ta kết nối tới Database bằng địa chỉ của `nginx-lb`

```
mysql -u root -p -h 192.168.100.139
```

<img src="images/t1.png" />

Chuyển xuống bước tiếp theo để tạo mới một database.

- **Bước 3**: Tạo DB `test` và xem lại

```
CREATE DATABASE test;
SHOW DATABASES;
```

<img src="images/t2.png" />

- **Bước 4**: Kiểm tra trên còn lại host.

```
mysql -u root -p
SHOW DATABASES;
```

Trên `db02`:

<img src="images/t3.png" />

Trên `db03`:

<img src="images/t4.png" />

### Cách "chữa trị" một cluster bị restart đồng thời hoặc tắt không đúng quy trình - split brain
- https://severalnines.com/blog/how-bootstrap-mysqlmariadb-galera-cluster

### Hiểu và giải quyết xung đột dữ liệu
- http://datacharmer.blogspot.com/2013/03/multi-master-data-conflicts-part-1.html
- http://datacharmer.blogspot.com/2013/03/multi-master-data-conflicts-part-2.html

### Tham khảo:

- http://linoxide.com/cluster/mariadb-centos-7-galera-cluster-haproxy/
- https://hack.idv.tw/wordpress/?p=4871
