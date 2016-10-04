### Hướng dẫn sử dụng

*Script có thể chạy trên một máy bất kỳ hoặc trên 1 trong 2 node.*

- Bước 1. Khai báo IP các node của bạn vào file `conf.cfg` theo mẫu:

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

- Bước 2. Copy các key ssh và đặt tên lần lượt theo mẫu `node1` và `node2` tương ứng với file key của các node

    *Lưu ý:* Các file trên phải nằm cùng thư mục với script.

- Bước 3. Phân quyền chạy cho script
    
    ```
    chmod 755 p_s.bash
    ```
- Bước 4. Chạy script

    ```
    ./p_s.bash
    ```
    
*Chúc các bạn thành công!*