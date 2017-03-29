# Các khái niệm của HA

#### HA hệ thống có 2 lý do

- Hệ thống bị ngưng hoạt động
- Tránh mất mát dữ liệu

### Redundancy và failover

- Dự phòng được trang bị trên các node giống nhau, tại một thời điểm nếu 1 node có vấn đề thì node kia lên thay thế
- Có thể dự phòng về phần mềm và phần cứng như:
    - Các phần cứng về mạng như switch, router
    - Các ứng dụng và dịch vụ tự động chuyển đổi
    - Các thành phần lưu trữ
    - Về cơ sở hạ tầng: Điều hòa, bình chữa cháy
- Sự thay thế giữa các node khi có sự cố phải có timeout ít nhất
- Các node đảm bảo hoạt động độc lập với nhau và khi 1 node gặp sự cố, node kia có thể thay thế tức thời
- Một hệ thống phải đảm bảo uptime lớn hơn 99,99%


### Dịch vụ Stateless và Stateful

#### Stateless

- Với các dịch vụ stateless, chúng ta HA bằng dự phòng một node tương tự và cân bằng tải giữa chúng
- Các dịch vụ stateless của OpenStack: nova-api, nova-conductor, glance-api, keystone-api, neutron-api,...

#### Stateful

- Là các dịch vụ có thông điệp trả về khác nhau, một action được thực hiện sẽ có nhiều request trả về
- Để HA cho các dịch vụ kiểu này ngta thường sử dụng mô hình Active/Active hoặc Active/Passive

### Active/Active và Active/Passive

#### Active/Passive

- Một cụm máy chủ được cấu hình cùng một dịch vụ nhưng chỉ có một máy hoạt động, các máy chủ khác lắng nghe và đồng bộ các dữ liệu thay đổi về mình
- Các request được lắng nghe trên 1 VIP

#### Active/Active

- Các máy chủ hoạt động song song với nhau và các request được điều tiết đến các máy chủ thông qua một load-balancer như HAProxy

### Clusters and quorums

- Quorum được kích hoạt khi số node lớn hơn 3 và số node phải là số lẻ
- Các node hoạt động phải lớn hơn nửa số node có trong cluster (Một cluster có 5 node thì số node phải lớn hơn 5/2 + 1, như vậy tối thiểu phải có 3 node hoạt động trong cluster này)
