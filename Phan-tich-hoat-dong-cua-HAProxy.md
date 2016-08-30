# Phân tích hoạt động của HAProxy

## 1. Mục đích của bài viết

- Bài viết phân tích cách hoạt động của HAProxy. 
- Giúp người đọc hiểu rõ hơn về mô hình
- Phân tích luồng hoạt động và các gói tin 

## 2. Giới thiệu giải pháp

### 2.1 Mô tả giải pháp HAProxy

HAProxy(High Availability Proxy) là một giải pháp mã nguồn mở về cân bằng tải có thể dùng cho nhiều dịch vụ chạy trên nền TCP, phù hợp với việc cân bằng tải với giao thức HTTP giúp ổn định phiên kết nối và các tiến trình Layer 7.

Cân bằng tải là một phương pháp phân phối khối lượng truy cập trên nhiều máy chủ nhằm tối ưu hóa tài nguyên hiện có đồng thời tối đa hóa thông lượng, giảm thời gian đáp ứng và tránh tình trạng quá tải cho một máy chủ.

### 2.2 Một số lợi ích khi sử dụng phương pháp cân bằng tải:

- Tăng khả năng đáp ứng, tránh tình trạng quá tải
- Tăng độ tin cậy và tính dự phòng cao
- Tăng tính bảo mật cho hệ thống

### 2.3 Mô tả hoạt động

- Bước 1: Request từ phía USER
- Bước 2: Request từ phía USER được HAProxy tiếp nhận và chuyển tới các Webserver
- Bước 3: Các Webserver xử lý và response lại HAProxy
- Bước 4: HAProxy tiếp nhận các response và gửi lại cho USER

<img width=50% src="http://image.prntscr.com/image/a755207f0c984ca9a62a267e2f8f1939.png" />

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
NIC: 192.168.100.2
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

<img src="http://image.prntscr.com/image/b8e2032a381746528baf779fbec09304.png" />

- Sau khi Trình duyệt tải xong trang, chúng ta quay lại cửa sổ `tcpdump` bấm tổ hợp `Ctrl` + `C` để dừng quá trình bắt gói tin.

<img src="http://image.prntscr.com/image/e3d2113f331545ae966c4c38a4b167a7.png" />

- Copy file `haproxy.pcap` vừa capture từ `tcpdump` về máy Windows 7 bằng WinSCP và mở bằng WireShark.

<img src="http://image.prntscr.com/image/0d50311ac5bd47e8b0fa7592f0313473.png" />

**Bước 2**: Lọc các gói tin `http` bằng cách gõ `http` vào ô `Filter` của WireShark và bấm `Apply`.

Hình ảnh dưới đây là khi tôi bấm vào bài viết `this-post...` của Website.

<img src="http://image.prntscr.com/image/2af90b30b9f4437ead18230a898753f6.png" />
(Phân tích hình)

Nhìn vào hình:
- Lần 1: chúng ta thấy request từ USER - 192.168.100.2 đến HAProxy - 192.168.100.191 (No.21). Sau đó, HAProxy chuyển request này đến Webserver 1 - 192.168.100.196 (No.23), Webserver 1 xử lý rồi gửi lại Response cho HAProxy (No.25). Cuối cùng, HAProxy gửi trả response cho USER (No. 27)
- Lần 2: Request (No.41) từ USER đến HAProxy, HAProxy chuyển request cho Webserver 2 - 192.168.100.198 (No.43), sau khi xử lý xong response lại được gửi lại HAProxy (No.45) và HAProxy trả response lại cho USER (No.47).

Đây là kiểu RoundRobin.
