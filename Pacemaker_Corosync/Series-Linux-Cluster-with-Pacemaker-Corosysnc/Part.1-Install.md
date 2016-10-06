# Series bài viết về Linux Cluster

## Phần 1. Cài đặt Pacemaker và Corosync trên CentOS 6

### 1. Giới thiệu

#### Corosync 

Corosync là một Cluster Engine mã nguồn mở. Nó làm nhiệm vụ truyền thông giữa các node trong một Cluster Engine. Corosync gửi thông tin cho nhau qua một port đã được cấu hình sẵn. Nó được kích hoạt trên tất cả các node trong Cluster để thông báo chính xác trạng thái hiện tại của node trong suốt thời gian hoạt động. Trong trường hợp một node bị lỗi, thông tin node ngay lập tức được cập nhật tới các node khác trong Cluster.

#### Pacemaker

Pacemaker là một phần mềm HA dùng để quản lý tài nguyên. Pacemaker có khả năng phát hiện và phục hồi những ứng dụng và thiết bị bị lỗi. Nó nắm giữ và quản lý những cấu hình của các ứng dụng. Trong trường hợp một node trong cụm tài nguyên nó quản lý bị lỗi, Pacemaker sẽ phát hiện và khởi động Resource khả dụng đã được cấu hình sẵn trong cụm Cluster.
