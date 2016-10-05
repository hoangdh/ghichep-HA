## Hướng dẫn sử dụng

[1. Giới thiệu ](#1)

[2. Yêu cầu](#2)

[3. Các bước thực hiện](#3)

<a name="1"></a>
### 1. Giới thiệu

Script dưới đây sẽ giúp các bạn cài đặt và cấu hình tự động HA cho Web mô hình 2 node hoạt động theo cơ chế Active - Passive. Các bạn có thể xem bài hướng dẫn cài đặt bằng tay ở <a href="https://github.com/hoangdh/ghichep-HA/blob/master/Pacemaker_Corosync/1.Huong-dan-cai-dat-Pacemaker-Corosync.md">đây</a> để hiểu rõ hơn quá trình làm việc của script.

<a name="2"></a>
### 2. Yêu cầu:

- Trên các node phải triển khai SSH-Key (Không có passphare)
- Các SSH-Key phải được đặt tên theo node. Key của node thứ nhất có tên là `node1`, key của node thứ hai có tên là `node2`
- Các file cấu hình `var.cfg`, script `p_s.bash` và SSH-Key của các node phải nằm trong cùng một thư mục.

*Script có thể chạy trên một máy bất kỳ hoặc trên 1 trong 2 node.*

<a name="3"></a>
### 3. Các bước thực hiện

- **Bước 1**: Khai báo thông tin các node của bạn vào file `var.cfg` theo mẫu:

    ```
        export PASSWORD=Abcdef@6789
        export IP1=192.168.100.197
        export IP2=192.168.100.198
        export VIP=192.168.100.123
        export HOST1=node1
        export HOST2=node2
    ```
    
    **Chú thích**:
    - `PASSWORD`: là mật khẩu của user `hacluster`
    - `IP1` là địa chỉ IP của node 1
    - `IP2` là địa chỉ IP của node 2
    - `VIP` là địa chỉ IP ảo
    - `HOST1` là tên của node 1, tên này được ghi trong file `hosts`
    - `HOST2` tương tự như trên, là tên của node 2

- **Bước 2**: Kiểm tra lại các file cấu hình `var.cfg`, script `p_s.bash` và SSH-Key của các node trong thư mục

- **Bước 3**: Phân quyền chạy cho script
    
    ```
    chmod 755 p_s.bash
    ```
- **Bước 4**: Chạy script

    ```
    ./p_s.bash
    ```
    
*Chúc các bạn thành công!*