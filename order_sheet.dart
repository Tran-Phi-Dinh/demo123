import 'package:flutter/material.dart'; // Thư viện UI Flutter
import '../models/food_models.dart'; // Import model FoodOrder

// Widget hiển thị danh sách đơn hàng (BottomSheet)
class OrderSheet extends StatelessWidget {
  final List<FoodOrder> orders; // Danh sách đơn hàng
  final bool isAdmin; // Kiểm tra có phải admin không
  final Function(int, String)? onUpdateStatus; // Callback cập nhật trạng thái (admin)
  final Function(int)? onCancelOrder; // Callback hủy đơn (user)

  const OrderSheet({
    super.key,
    required this.orders,
    required this.isAdmin,
    this.onUpdateStatus,
    this.onCancelOrder,
  });

  // Danh sách trạng thái chuẩn của đơn hàng
  static const List<String> statusOptions = [
    'Đang chờ duyệt',
    'Đã nhận đơn',
    'Đang chuẩn bị',
    'Đang chờ shipper',
    'Shipper đã lấy hàng',
    'Hoàn thành',
    'Đã hủy'
  ];

  // Hàm trả về màu tương ứng với trạng thái
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đã nhận đơn': return Colors.blue;
      case 'Đang chuẩn bị': return Colors.orange;
      case 'Đang chờ shipper': return Colors.purple;
      case 'Shipper đã lấy hàng': return Colors.teal;
      case 'Hoàn thành': return Colors.green;
      case 'Đã hủy': return Colors.red;
      default: return Colors.blueGrey;
    }
  }

  // Hàm trả về icon tương ứng với trạng thái
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Đã nhận đơn': return Icons.assignment_turned_in;
      case 'Đang chuẩn bị': return Icons.restaurant;
      case 'Đang chờ shipper': return Icons.local_shipping;
      case 'Shipper đã lấy hàng': return Icons.delivery_dining;
      case 'Hoàn thành': return Icons.check_circle;
      case 'Đã hủy': return Icons.cancel;
      default: return Icons.hourglass_empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Padding toàn bộ sheet
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),

      // Chiều cao 85% màn hình
      height: MediaQuery.of(context).size.height * 0.85,

      // Trang trí nền + bo góc
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),

      child: Column(
        children: [

          // Thanh nhỏ phía trên (drag indicator)
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 15), // khoảng cách dưới
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Tiêu đề (admin vs user)
          Text(
            isAdmin ? "QUẢN LÝ ĐƠN HÀNG" : "LỊCH SỬ ĐẶT MÓN",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),

          const SizedBox(height: 20),

          // ===== DANH SÁCH ĐƠN =====
          Expanded(
            child: orders.isEmpty
                // Nếu chưa có đơn
                ? const Center(child: Text("Chưa có đơn hàng nào"))
                // Nếu có đơn
                : ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (ctx, i) {
                      final order = orders[i]; // Lấy đơn
                      final statusColor = _getStatusColor(order.status); // Màu theo trạng thái

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),

                        // Card style
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),

                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),

                          child: IntrinsicHeight(
                            child: Row(
                              children: [

                                // Thanh màu bên trái (status)
                                Container(width: 6, color: statusColor),

                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),

                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [

                                        // ===== HEADER =====
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Đơn #${order.id}", // ID đơn
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey),
                                            ),

                                            // Badge trạng thái
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    _getStatusIcon(order.status), // icon
                                                    size: 14,
                                                    color: statusColor,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    order.status, // text trạng thái
                                                    style: TextStyle(
                                                      color: statusColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 12),

                                        // ===== DANH SÁCH MÓN =====
                                        Text(
                                          order.itemsDetail,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const Divider(height: 24),

                                        // ===== THÔNG TIN =====
                                        _buildRow(Icons.location_on, order.address, Colors.redAccent),
                                        const SizedBox(height: 6),

                                        _buildRow(Icons.phone, order.phone, Colors.blue),
                                        const SizedBox(height: 6),

                                        _buildRow(Icons.payment, "Thanh toán: ${order.paymentMethod}", Colors.green),

                                        const SizedBox(height: 15),

                                        // ===== FOOTER =====
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "${order.totalPrice}đ", // tổng tiền
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.redAccent,
                                              ),
                                            ),

                                            // Nếu admin thì dropdown đổi trạng thái
                                            if (isAdmin)
                                              _buildAdminMenu(order)

                                            // Nếu user và chưa duyệt thì cho hủy
                                            else if (order.status == 'Đang chờ duyệt')
                                              TextButton.icon(
                                                onPressed: () => onCancelOrder!(order.id),
                                                icon: const Icon(Icons.cancel, size: 18),
                                                label: const Text("Hủy đơn"),
                                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị 1 dòng icon + text
  Widget _buildRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  // Dropdown dành cho admin đổi trạng thái
  Widget _buildAdminMenu(FoodOrder order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),

      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),

      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          // Nếu trạng thái không hợp lệ thì dùng mặc định
          value: statusOptions.contains(order.status)
              ? order.status
              : statusOptions[0],

          // Tạo danh sách dropdown
          items: statusOptions.map((s) {
            return DropdownMenuItem(
              value: s,
              child: Text(
                s,
                style: TextStyle(
                  color: _getStatusColor(s), // màu theo trạng thái
                  fontSize: 13,
                ),
              ),
            );
          }).toList(),

          // Khi chọn trạng thái mới
          onChanged: (val) {
            if (val != null && onUpdateStatus != null) {
              onUpdateStatus!(order.id, val); // Gửi về Home
            }
          },
        ),
      ),
    );
  }
}