import 'package:flutter/material.dart'; // Thư viện UI Flutter
import '../models/food_models.dart'; // Import model Product

// Widget hiển thị giỏ hàng dạng BottomSheet
class CartSheet extends StatefulWidget {
  final List<Product> cart; // Danh sách sản phẩm trong giỏ

  // Callback khi đặt hàng (truyền thêm địa chỉ, sđt, thanh toán)
  final Function(String address, String phone, String payment) onCheckout;

  const CartSheet({
    super.key,
    required this.cart,
    required this.onCheckout,
  });

  @override
  State<CartSheet> createState() => _CartSheetState();
}

// State của CartSheet
class _CartSheetState extends State<CartSheet> {
  // Controller lấy dữ liệu từ ô nhập
  final TextEditingController _addressController = TextEditingController(); // Địa chỉ
  final TextEditingController _phoneController = TextEditingController();   // SĐT

  // Giá trị phương thức thanh toán đang chọn
  String _selectedPayment = "Tiền mặt";

  // Danh sách các phương thức thanh toán
  final List<String> _paymentMethods = [
    "Tiền mặt",
    "Chuyển khoản",
    "Ví điện tử"
  ];

  @override
  void dispose() {
    _addressController.dispose(); // Giải phóng bộ nhớ controller
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tính tổng tiền giỏ hàng
    double total =
        widget.cart.fold(0, (sum, item) => sum + item.price);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        // Đẩy UI lên khi bàn phím mở
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),

      // Chiều cao 85% màn hình
      height: MediaQuery.of(context).size.height * 0.85,

      child: Column(
        children: [
          // Tiêu đề
          const Text(
            "THÔNG TIN ĐẶT HÀNG",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),

          const Divider(),

          // ===== 1. DANH SÁCH MÓN TRONG GIỎ =====
          Expanded(
            flex: 2,
            child: widget.cart.isEmpty
                // Nếu giỏ trống
                ? const Center(child: Text("Giỏ hàng trống"))
                // Nếu có sản phẩm
                : ListView.builder(
                    itemCount: widget.cart.length,
                    itemBuilder: (ctx, i) => ListTile(
                      leading: const Icon(
                        Icons.fastfood_outlined,
                        color: Colors.orange,
                      ),
                      title: Text(widget.cart[i].name), // Tên món
                      trailing:
                          Text("${widget.cart[i].price}đ"), // Giá
                    ),
                  ),
          ),

          const Divider(),

          // ===== 2. FORM NHẬP THÔNG TIN =====
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Nhập địa chỉ
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: "Địa chỉ nhận hàng",
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Nhập số điện thoại
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Số điện thoại",
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Tiêu đề chọn thanh toán
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Phương thức thanh toán:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Dropdown chọn phương thức thanh toán
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedPayment, // Giá trị hiện tại

                        // Tạo danh sách item
                        items: _paymentMethods.map((String method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Text(method),
                          );
                        }).toList(),

                        // Khi chọn giá trị mới
                        onChanged: (val) {
                          setState(() =>
                              _selectedPayment = val!);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(),

          // ===== 3. TỔNG TIỀN =====
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tổng cộng:",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "$total VNĐ",
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // ===== 4. NÚT XÁC NHẬN =====
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.all(15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),

              // Nếu giỏ trống thì disable nút
              onPressed: widget.cart.isEmpty
                  ? null
                  : () {
                      // Kiểm tra nhập liệu
                      if (_addressController.text
                              .trim()
                              .isEmpty ||
                          _phoneController.text
                              .trim()
                              .isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                                content: Text(
                                    "Vui lòng nhập đầy đủ địa chỉ và số điện thoại!")));
                        return;
                      }

                      // Gửi dữ liệu về Home (checkout)
                      widget.onCheckout(
                        _addressController.text.trim(),
                        _phoneController.text.trim(),
                        _selectedPayment,
                      );
                    },

              child: const Text(
                "XÁC NHẬN ĐẶT ĐƠN",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}