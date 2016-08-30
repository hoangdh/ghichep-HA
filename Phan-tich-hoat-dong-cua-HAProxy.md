# Phân tích hoạt động của HAProxy

## 1. Mục đích của bài viết

- Bài viết phân tích cách hoạt động của HAProxy. 
- Giúp người đọc hiểu rõ hơn về mô hình
- Phân tích luồng hoạt động của các gói tin 

## 2. Giới thiệu giải pháp

### 2.1 Mô tả giải pháp HAProxy

**HAProxy** (High Availability Proxy) là một giải pháp mã nguồn mở về cân bằng tải có thể dùng cho nhiều dịch vụ chạy trên nền TCP, phù hợp với việc cân bằng tải với giao thức HTTP giúp ổn định phiên kết nối và các tiến trình Layer 7.

Cân bằng tải là một phương pháp phân phối khối lượng truy cập trên nhiều máy chủ nhằm tối ưu hóa tài nguyên hiện có đồng thời tối đa hóa thông lượng, giảm thời gian đáp ứng và tránh tình trạng quá tải cho một máy chủ.

### 2.2 Một số lợi ích khi sử dụng phương pháp cân bằng tải:

- Tăng khả năng đáp ứng, tránh tình trạng quá tải
- Tăng độ tin cậy và tính dự phòng cao
- Tăng tính bảo mật cho hệ thống

### 2.3 Mô tả hoạt động

- Bước 1: Request từ phía USER đến VIP của HAProxy
- Bước 2: Request từ phía USER được HAProxy tiếp nhận và chuyển tới các Webserver
- Bước 3: Các Webserver xử lý và response lại HAProxy
- Bước 4: HAProxy tiếp nhận các response và gửi lại cho USER bằng VIP

<img width=75% src="http://i1363.photobucket.com/albums/r714/HoangLove9z/luong-haproxy_zpsyoo7tyga.png" />

## 3. Các thành phần cần thiết

### 3.1 Mô hình

<img width=75% src="http://image.prntscr.com/image/03604931beaa4fb6928eb478f0ad38bd.png" />

Bài viết hướng dẫn cài đặt vui lòng tham khảo tại <a href="https://github.com/hoangdh/Cai-dat-Keepalived-va-loadbalancer-cho-web-server" target="_blank">đây</a>.

```
HAProxy 1
OS: CentOS 6
eth1: 192.168.100.191
VIP: 192.168.100.123
keepalived + HAProxy

HAProxy 2
OS: CentOS 6
eth1: 192.168.100.199
VIP: 192.168.100.123
keepalived + HAProxy

Web1:
OS: CentOS 6
eth0: 192.168.100.196
APACHE + MariaDB

Web2:
OS: CentOS 6
eth0: 192.168.100.198
APACHE

USER:
OS: Windows 7
NIC: 192.168.100.22
Brower: Firefox
```

### 3.2 Yêu cầu:

- Trên USER (Windows 7) cài đặt  <a href="https://github.com/hoangdh/Wireshark" target="_blank">WireShark</a> (để đọc gói tin)
- Trên HAProxy cài đặt <a href="https://github.com/hoangdh/tcpdump-tonghop" target="_blank">TCPDUMP</a> (bắt gói tin)

## 4. Các bước tiến hành:

**Bước 1**: 
- Thực hiện quá trình bắt gói tin trên node HAProxy bằng `tcpdump`

```
tcpdump -i eth1 -p tcp -w /opt/haproxy.pcap
```

- Sau khi chạy lệnh trên HAProxy, chúng ta dùng USER (Windows 7) để tạo request đến HAProxy.

<img src="http://image.prntscr.com/image/3199e49fe60d454fbcc4febb9ee1a395.png" />

- Sau khi Trình duyệt tải xong trang, bấm Ctrl + F5 để tải lại trang một lần nữa. Sau khi tải trang 2 lần, chúng ta quay lại cửa sổ `tcpdump` bấm tổ hợp `Ctrl` + `C` để dừng quá trình bắt gói tin.

<img src="http://image.prntscr.com/image/e3d2113f331545ae966c4c38a4b167a7.png" />
- Copy file `haproxy.pcap` vừa capture từ `tcpdump` về máy Windows 7 bằng WinSCP và mở bằng WireShark.

<img src="http://image.prntscr.com/image/0d50311ac5bd47e8b0fa7592f0313473.png" />
**Bước 2**: Lọc các gói tin `http` bằng cách gõ `http` vào ô `Filter` của WireShark và bấm `Apply`.

<img src="http://image.prntscr.com/image/3535cd4af7cd4dd0a30ae27878aa3780.png" />

###Nhìn vào hình:
- Lần 1:

<img src="http://image.prntscr.com/image/6cf4b77077a34f5aa8d24339e462e1e4.png" />

Chúng ta thấy request từ USER - 192.168.100.22 đến VIP của HAProxy - 192.168.100.123 (No.35). Sau đó, HAProxy - 192.168.100.191 chuyển request này đến Webserver 1 - 192.168.100.196 (No.37), Webserver 1 xử lý rồi gửi lại Response cho HAProxy (No.39). Cuối cùng, HAProxy gửi trả response cho USER (No. 41)
- Lần 2: 

<img src="http://image.prntscr.com/image/bca8245e3efd480cb92c61a837f0b88e.png" />

Request (No.55) từ USER cũng đến VIP của HAProxy, HAProxy chuyển request cho Webserver 2 - 192.168.100.198 (No.57), sau khi xử lý xong response lại được gửi lại HAProxy (No.59) và HAProxy trả response lại cho USER (No.61).

Đây là kiểu RoundRobin.
