# Phân tích hoạt động của HAProxy

### Mô tả giải pháp
- HA ở trong web làm nhiệm vụ gì? ...

### Mô tả hoạt động (Các bước hoạt động đầu tiên là request của user, đến ha, đến web,...)

### Mục đích của bài viết

- Bài viết phân tích cách hoạt động của HAProxy. 
- Giúp người đọc hiểu rõ hơn về mô hình
- Phân tích luồng hoạt động 
- Khi có một request từ phía client đến HAProxy, tùy theo cơ chế đã cấu hình sẵn (các mode như RoundRobin, LeastConn, URI,...) mà HAProxy sẽ phân bố request đến các Web Server một cách hợp lý. Sau khi nhận được request từ HAProxy, Web Server sẽ xử lý và phản hồi lại HAProxy. Nhận được response, HAProxy sẽ gửi lại response đó đến client. Cụ thể các tiến trình, cách làm việc của HAProxy sẽ được phân tích ở bài viết dưới đây.

### Các thành phần cần thiết

#### Mô hình

<img width=75% src="http://image.prntscr.com/image/03604931beaa4fb6928eb478f0ad38bd.png" />

```
HAProxy 1
OS: CentOS 6
eth1: 192.168.100.191
keepalived + HAProxy

HAProxy 2
OS: CentOS 6
eth1: 192.168.100.191
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

**Yêu cầu**: 
- Trên USER (Windows 7) cài đặt  <a href="https://github.com/hoangdh/Wireshark">WireShark</a> (để đọc gói tin)
- Trên HAProxy cài đặt <a href="https://github.com/hoangdh/tcpdump-tonghop">TCPDUMP</a> (bắt gói tin)

### Các bước tiến hành:

Thực hiện quá trình bắt gói tin trên node HAProxy bằng `tcpdump`

```
tcpdump -i eth1 -p tcp -w /opt/haproxy.pcap
```

Sau khi chạy lệnh trên HAProxy, chúng ta dùng USER (Windows 7) để tạo request đến HAProxy.

<img src="http://image.prntscr.com/image/b8e2032a381746528baf779fbec09304.png" />

Sau khi Trình duyệt tải xong trang, chúng ta quay lại cửa sổ `tcpdump` bấm tổ hợp `Ctrl` + `C` để dừng quá trình bắt gói tin.

<img src="http://image.prntscr.com/image/e3d2113f331545ae966c4c38a4b167a7.png" />

Copy file `haproxy.pcap` vừa capture từ `tcpdump` về máy Windows 7 bằng WinSCP và mở bằng WireShark.

<img src="http://image.prntscr.com/image/0d50311ac5bd47e8b0fa7592f0313473.png" />

Lọc các gói tin `http` bằng cách gõ `http` vào ô `Filter` của WireShark và bấm `Apply`.

Hình ảnh dưới đây là khi tôi bấm vào bài viết `this-post...` của Website.

<img src="http://image.prntscr.com/image/2af90b30b9f4437ead18230a898753f6.png" />
(Phân tích hình)

Nhìn vào hình:
- Lần 1: chúng ta thấy request từ USER - 192.168.100.2 đến HAProxy - 192.168.100.191 (No.21). Sau đó, HAProxy chuyển request này đến Webserver 1 - 192.168.100.196 (No.23), Webserver 1 xử lý rồi gửi lại Response cho HAProxy (No.25). Cuối cùng, HAProxy gửi trả response cho USER (No. 27)
- Lần 2: Request (No.41) từ USER đến HAProxy, HAProxy chuyển request cho Webserver 2 - 192.168.100.198 (No.43), sau khi xử lý xong response lại được gửi lại HAProxy (No.45) và HAProxy trả response lại cho USER (No.47).

Đây là kiểu RoundRobin.
