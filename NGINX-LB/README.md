## Hướng dẫn cấu hình NGINX với MariaDB Cluster trên CentOS 7

### Menu

- [1. Giới thiệu](#)
- [2. Các bước tiến hành](#)
- [2.1 Cài đặt Galera trên 3 node](#)
- [2.2 Cài đặt NGINX làm Load-balancer](#)
- [3. Kiểm tra](#)

<a name="1"></a>
### 1. Giới thiệu

NGINX được biết đến là một Web Server khá nổi tiếng. Nhưng nó cũng là một load-balancer khá mạnh mẽ. Bài viết này sẽ hướng dẫn các bạn sử dụng NGINX làm một load-balancer cho MariaDB/MySQL trên CentOS 7.

#### Mô hình cài đặt

<img src="images/topo-nginx.png" width="75%" />

#### IP Planning

<img src="images/bangip.png" />

<a name="2"></a>
### 2. Các bước tiến hành

<a name="21"></a>
#### 2.1 Cài đặt Galera trên 3 node

<a name="22"></a>
#### 2.2 Cài đặt NGINX làm Load-balancer

<a name="3"></a>
### 3. Kiểm tra