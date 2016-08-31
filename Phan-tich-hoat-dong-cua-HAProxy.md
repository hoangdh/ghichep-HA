# Phân tích hoạt động của HAProxy

###Mục lục:
[1. Mục đích của bài viết ](#1)

[2. Giới thiệu giải pháp ](#2)

- [2.1 Mô tả giải pháp ](#2.1)
- [2.2 Một số lợi ích ](#2.2)
- [2.3 Mô tả hoạt động ](#2.3)

[3. Các thành phần cần thiết ](#3)

- [3.1 Mô hình ](#3.1)
- [3.2 Yêu cầu ](#3.2)

[4. Phân tích hoạt động ](#4)

- [4.1 Chuẩn bị ](#4.1)
- [4.2 Phân tích ](#4.2)

[5. Kết luận ](#5)

<a name="1"></a>
## 1. Mục đích của bài viết

- Bài viết phân tích cách hoạt động của HAProxy. 
- Giúp người đọc hiểu rõ hơn về mô hình
- Phân tích luồng hoạt động của các gói tin 

<a name="2"></a>
## 2. Giới thiệu giải pháp

<a name="2.1"></a>
### 2.1 Mô tả giải pháp cân bằng tải sử dụng HAProxy

Cân bằng tải là một phương pháp phân phối khối lượng truy cập trên nhiều máy chủ nhằm tối ưu hóa tài nguyên hiện có đồng thời tối đa hóa thông lượng, giảm thời gian đáp ứng và tránh tình trạng quá tải cho một máy chủ.

**HAProxy** (High Availability Proxy) là một giải pháp mã nguồn mở về cân bằng tải có thể dùng cho nhiều dịch vụ chạy trên nền TCP (Layer 4), phù hợp với việc cân bằng tải với giao thức HTTP giúp ổn định phiên kết nối và các tiến trình Layer 7.

- Cân bằng tải ở Layer 4 chỉ thích hợp cho việc bạn có các webserver có cùng một ứng dụng. 
- Cân bằng tải ở Layer 7 có thể phân tải cho các ứng dụng trên một webserver có nhiều ứng dụng cùng domain.

<a name="2.2"></a>
### 2.2 Một số lợi ích khi sử dụng phương pháp cân bằng tải:

- Tăng khả năng đáp ứng, tránh tình trạng quá tải
- Tăng độ tin cậy và tính dự phòng cao
- Tăng tính bảo mật cho hệ thống

<a name="2.3"></a>
### 2.3 Mô tả hoạt động

- **Bước 1**: Request từ phía USER đến VIP của HAProxy
- **Bước 2**: Request từ phía USER được HAProxy tiếp nhận và chuyển tới các Webserver
- **Bước 3**: Các Webserver xử lý và response lại HAProxy
- **Bước 4**: HAProxy tiếp nhận các response và gửi lại cho USER bằng VIP

<img width=75% src="http://i1363.photobucket.com/albums/r714/HoangLove9z/luong-haproxy_zpsyoo7tyga.png" />

<a name="3"></a>
## 3. Các thành phần cần thiết

<a name="3.1"></a>
### 3.1 Mô hình

<img width=75% src="http://image.prntscr.com/image/03604931beaa4fb6928eb478f0ad38bd.png" />

Bài viết hướng dẫn cài đặt vui lòng tham khảo tại <a href="https://github.com/hoangdh/Cai-dat-Keepalived-va-loadbalancer-cho-web-server" target="_blank">đây</a>.

 | HAProxy 1 | HAProxy 2 | Web1 | Web2 | USER |
--- | --- | --- | ---| --- | --- |
OS | CentOS 6 | CentOS 6 | CentOS 6 | CentOS 6 | Windows 7 |
NIC | eth1 | eth0 | eth0 | eth0 | Local Area Connection |
IP | 192.168.100.191 | 192.168.100.199 | 192.168.100.196 | 192.168.100.198 | 192.168.100.22 |
Virtual IP | 192.168.100.123 | 192.168.100.123 | Không | Không | Không |
Package| HAProxy + keepalived |HAProxy + keepalived | APACHE + MariaDB | APACHE | Firefox, WireShark |

<a name="3.2"></a>
### 3.2 Yêu cầu:

- Trên USER (Windows 7) cài đặt  <a href="https://github.com/hoangdh/Wireshark" target="_blank">WireShark</a> (để đọc gói tin)
- Trên HAProxy cài đặt <a href="https://github.com/hoangdh/tcpdump-tonghop" target="_blank">TCPDUMP</a> (bắt gói tin)

<a name="4"></a>
## 4. Phân tích hoạt động

<a name="4.1"></a>
### 4.1 Chuẩn bị
 
**Bước 1**: Thực hiện quá trình bắt gói tin trên node `HAProxy`, `Web1`, `Web2` bằng `tcpdump`

#### Bắt gói trên HAProxy

```
tcpdump -i eth1 -p tcp -w /opt/haproxy.pcap
```

#### Bắt gói trên Web1

```
tcpdump -i eth0 -p tcp -w /opt/web1.pcap
```

#### Bắt gói trên  Web2

```
tcpdump -i eth0 -p tcp -w /opt/web2.pcap
```

**Bước 2**: Chúng ta dùng USER (Windows 7) để tạo request đến HAProxy.

<img src="http://image.prntscr.com/image/3199e49fe60d454fbcc4febb9ee1a395.png" />

Sau khi Trình duyệt tải xong trang, bấm Ctrl + F5 để tải lại trang một lần nữa.

**Bước 3:** Chúng ta quay lại cửa sổ `tcpdump` bấm tổ hợp `Ctrl` + `C` để dừng quá trình bắt gói tin.

<img src="http://image.prntscr.com/image/e3d2113f331545ae966c4c38a4b167a7.png" />

Copy file `haproxy.pcap` vừa capture từ `tcpdump` về máy Windows 7 bằng WinSCP.

<img src="http://image.prntscr.com/image/0d50311ac5bd47e8b0fa7592f0313473.png" />

**Bước 4**: Mở file bằng WireShark và lọc các gói tin `http` bằng cách gõ `http` vào ô `Filter` của WireShark và bấm `Apply`.

<img src="http://image.prntscr.com/image/3535cd4af7cd4dd0a30ae27878aa3780.png" />

#### Chú thích

- **No.**: Số thứ tự của bản tin đã capture được
- **Time**: Thời gian (giây) kể từ khi capture (<a href="https://www.wireshark.org/docs/wsug_html_chunked/ChWorkTimeFormatsSection.html" target="_blank">Chi tiết</a>)
- **Source**: Địa chỉ nguồn gửi bản tin
- **Destination**: Địa chỉ đích nhận bản tin
- **Protocol**: Giao thức sử dụng gửi, nhận bản tin
- **Length**: Kích thước của bản tin
- **Info**: Thông tin/Nội dung của bản tin

<a name="4.2"></a>
### 4.2 Phân tích

#### Bước 1:

<img src="http://image.prntscr.com/image/6800e8b045544380af5098e85f8462f7.png" />

- `No.35`, Người dùng có IP: 192.168.100.22 truy cập HTTP đến `HAProxy` thông qua IP VIP là 192.168.100.123 (1)
- `No.37`, `HAProxy` có địa chỉ 192.168.100.191 sẽ gửi bản tin truy cập HTTP của Người dùng đến `Webserver 1` có IP là 192.168.100.196 (2)
- `No.39`,  `Webserver 1` (192.168.100.196) xử lý request rồi gửi lại response cho `HAProxy` có địa chỉ là 192.168.100.191 (3)
- `No. 41`, `HAProxy` gửi trả response từ VIP là 192.168.100.123 đến người dùng có địa chỉ là 192.168.100.22 (4)

#### Bước 2:

<img src="http://image.prntscr.com/image/bcd36b5672024f849af3e12181db9c7a.png" />

- `No.55`, một request từ người dùng có địa chỉ 192.168.100.22 cũng đến VIP có địa chỉ là 192.168.100.123 của `HAProxy` (1)
- `No.57`, `HAProxy` có địa chỉ 192.168.100.191 chuyển request cho `Webserver 2` có IP là 192.168.100.198 (2)
- `No.59`, sau khi được `Webserver 2` - 192.168.100.198 xử lý xong, response được gửi lại `HAProxy` có địa chỉ là 192.168.100.191 (3)
- `No.61`, `HAProxy` có VIP là 192.168.100.123 trả lại response cho người dùng có địa chỉ là 192.168.100.22 (4)

=> Đây là kiểu RoundRobin.

### Phân tích file đã bắt được trên `Web1` và `Web2`:

- Các gói tin trên `Web 1`:

<img src="http://image.prntscr.com/image/784249db42494949a1ce60b493a9cc78.png" />


- Các gói tin trên `Web 2`:

<img src="http://image.prntscr.com/image/bd845b03aeae4ab683da984639d4db0f.png" />

Nhìn vào hình ảnh, chúng ta chỉ thấy luồng hoạt động giữa `HAProxy` (192.168.100.191) với các `Webserver` (192.168.100.196, 192.168.100.198) không nhìn thấy bất kỳ hoạt động nào của `USER` (192.168.100.22). Điều này cho thấy `USER` chỉ làm việc với `HAProxy` và tính an toàn được phát huy.

<a name="5"></a>
### 5. Kết luận

Trên đây là những phân tích giúp các bạn có thể hiểu rõ hơn về cơ chế hoạt động của HAProxy. Hy vọng giúp thêm các bạn mới nghiên cứu về giải pháp cân bằng tải, làm hệ thống của các bạn tăng hiệu năng và tính sẵn sàng đáp ứng được nhu cầu sử dụng của người dùng.