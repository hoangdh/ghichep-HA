# Phân tích hoạt động của HAProxy

### Mục đích của bài viết

- Bài viết phân tích cách hoạt động của HAProxy. Khi có một request từ phía client đến HAProxy, tùy theo cơ chế đã cấu hình sẵn (các mode như RoundRobin, LeastConn, URI,...) mà HAProxy sẽ phân bố request đến các Web Server một cách hợp lý. Sau khi nhận được request từ HAProxy, Web Server sẽ xử lý và phản hồi lại HAProxy. Nhận được response, HAProxy sẽ gửi lại response đó đến client. Cụ thể các tiến trình, cách làm việc của HAProxy sẽ được phân tích ở bài viết dưới đây.

### Các thành phần cần thiết

#### Mô hình

<img width=50% src="http://image.prntscr.com/image/067e2cd01f2c4d908a37af18f43854a0.png" />

```
HAProxy
OS: CentOS 6
eth1: 192.168.100.191

Web1:
OS: CentOS 6
eth0: 192.168.100.196

Web2:
OS: CentOS 6
eth0: 192.168.100.198

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

<img src="http://image.prntscr.com/image/c77f950d48de44adbe4ac50bee8b695a.png" />

Nhìn vào hình, chúng ta thấy request từ USER - 192.168.100.2 đến HAProxy - 192.168.100.191 (No.208). Sau đó, HAProxy chuyển request này đến Web Server - 192.168.100.196 (No.209), Web Server xử lý rồi gửi lại Response cho HAProxy (No.236). Cuối cùng, HAProxy gửi trả response cho USER (No. 240)
