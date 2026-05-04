import 'package:flutter/material.dart'; // Thư viện UI chính của Flutter
import 'package:http/http.dart' as http; // Thư viện gọi API HTTP
import 'dart:convert'; // Dùng để encode/decode JSON
import 'dart:io'; // Xử lý file (chỉ dùng cho mobile)
import 'package:image_picker/image_picker.dart'; // Chọn ảnh từ thư viện
import 'package:flutter/foundation.dart' show kIsWeb; // Kiểm tra chạy web hay mobile

import '../models/food_models.dart'; // Import model Product, FoodOrder
import '../widgets/cart_sheet.dart'; // Widget hiển thị giỏ hàng
import '../widgets/order_sheet.dart'; // Widget hiển thị đơn hàng
import 'login_screen.dart'; // Màn hình đăng nhập

// Widget chính của trang
class FoodHomePage extends StatefulWidget {
  final dynamic user; // Lưu thông tin user (id, role)

  const FoodHomePage({super.key, required this.user});

  @override
  State<FoodHomePage> createState() => _FoodHomePageState();
}

// State của widget
class _FoodHomePageState extends State<FoodHomePage> {
  final String apiUrl = "http://localhost:3000"; // Địa chỉ API backend

  List<Product> products = []; // Danh sách sản phẩm
  List<Product> cart = [];     // Giỏ hàng
  List<FoodOrder> orders = []; // Danh sách đơn hàng

  bool isLoading = true; // Trạng thái loading

  @override
  void initState() {
    super.initState();
    _loadAll(); // Khi mở app thì load dữ liệu
  }

  // Load toàn bộ dữ liệu
  Future<void> _loadAll() async {
    await fetchProducts(); // Lấy sản phẩm
    await loadOrders();    // Lấy đơn hàng
    if (mounted) setState(() => isLoading = false); // Tắt loading
  }

  // ================= API SẢN PHẨM =================

  // Lấy danh sách sản phẩm
  Future<void> fetchProducts() async {
    try {
      final res = await http.get(Uri.parse('$apiUrl/products')); // Gọi API GET
      if (res.statusCode == 200) {
        List data = jsonDecode(res.body); // Chuyển JSON -> List
        setState(() => products =
            data.map((e) => Product.fromJson(e)).toList()); // Convert sang object
      }
    } catch (e) {
      _showSnackBar("❌ Lỗi kết nối máy chủ!");
    }
  }

  // Xóa sản phẩm
  Future<void> deleteProduct(int id) async {
    try {
      final res = await http.post(
        Uri.parse('$apiUrl/admin/delete-product'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}), // Gửi id cần xóa
      );
      if (res.statusCode == 200) {
        fetchProducts(); // Load lại danh sách
        _showSnackBar("🗑️ Đã xóa món ăn thành công");
      }
    } catch (e) {
      _showSnackBar("Lỗi khi xóa món!");
    }
  }

  // ================= API ĐƠN HÀNG =================

  // Lấy danh sách đơn hàng
  Future<void> loadOrders() async {
    try {
      final res = await http.get(Uri.parse(
          '$apiUrl/all-orders?user_id=${widget.user['id']}&role=${widget.user['role']}')); // Truyền user id + role
      if (res.statusCode == 200) {
        List data = jsonDecode(res.body);
        setState(() =>
            orders = data.map((e) => FoodOrder.fromJson(e)).toList()); // Convert sang object
      }
    } catch (e) {
      debugPrint("Lỗi tải đơn hàng: $e");
    }
  }

  // Đặt hàng
  Future<void> checkout(String address, String phone, String payment) async {
    if (cart.isEmpty) return; // Nếu giỏ rỗng thì không làm gì

    double total = cart.fold(0, (sum, item) => sum + item.price); // Tính tổng tiền
    String itemsDetail = cart.map((e) => e.name).join(", "); // Ghép tên món

    try {
      final res = await http.post(
        Uri.parse('$apiUrl/checkout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': widget.user['id'],
          'total_price': total,
          'items_detail': itemsDetail,
          'address': address,
          'phone': phone,
          'payment_method': payment
        }),
      );

      if (res.statusCode == 200) {
        setState(() => cart = []); // Xóa giỏ hàng
        if (!mounted) return;
        Navigator.pop(context); // Đóng popup
        _showSnackBar("🎉 Đặt hàng thành công!");
        loadOrders(); // Load lại đơn hàng
      }
    } catch (e) {
      _showSnackBar("Lỗi khi đặt hàng!");
    }
  }

  // Cập nhật trạng thái đơn hàng
  Future<void> updateStatus(int orderId, String status) async {
    try {
      final res = await http.post(
        Uri.parse('$apiUrl/admin/update-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'order_id': orderId, 'status': status}),
      );
      if (res.statusCode == 200) {
        loadOrders(); // Reload đơn hàng
        _showSnackBar("✅ Đã cập nhật trạng thái đơn.");
      }
    } catch (e) {
      _showSnackBar("Lỗi cập nhật!");
    }
  }

  // Hủy đơn hàng
  Future<void> cancelOrder(int orderId) async {
    try {
      final res = await http.post(
        Uri.parse('$apiUrl/order/cancel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'order_id': orderId}),
      );
      if (res.statusCode == 200) {
        _showSnackBar(jsonDecode(res.body)['message']);
        loadOrders(); // Load lại đơn
      }
    } catch (e) {
      _showSnackBar("Lỗi khi hủy đơn!");
    }
  }

  // ================= DIALOG THÊM/SỬA =================

  void _openProductDialog({Product? product}) {
    final nameCtrl = TextEditingController(text: product?.name ?? ""); // Input tên
    final priceCtrl = TextEditingController(
        text: product != null ? product.price.toInt().toString() : ""); // Input giá
    XFile? pickedFile; // Ảnh chọn

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 25,
              right: 25,
              top: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(product == null ? "THÊM MÓN MỚI" : "CHỈNH SỬA MÓN"),

              GestureDetector(
                onTap: () async {
                  final picked = await ImagePicker()
                      .pickImage(source: ImageSource.gallery); // Chọn ảnh
                  if (picked != null) setModalState(() => pickedFile = picked);
                },
                child: Container(
                  height: 140,
                  width: double.infinity,
                  child: pickedFile == null
                      ? (product != null && product.image.isNotEmpty
                          ? Image.network("$apiUrl${product.image}") // Ảnh cũ
                          : const Icon(Icons.add_a_photo)) // Chưa có ảnh
                      : (kIsWeb
                          ? Image.network(pickedFile!.path) // Web
                          : Image.file(File(pickedFile!.path))), // Mobile
                ),
              ),

              TextField(controller: nameCtrl), // Nhập tên
              TextField(controller: priceCtrl), // Nhập giá

              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isEmpty ||
                      priceCtrl.text.isEmpty) return;

                  String endPoint = product == null
                      ? '/admin/add-product'
                      : '/admin/update-product';

                  var request = http.MultipartRequest(
                      'POST', Uri.parse('$apiUrl$endPoint'));

                  if (product != null)
                    request.fields['id'] = product.id.toString();

                  request.fields['name'] = nameCtrl.text;
                  request.fields['price'] = priceCtrl.text;

                  if (pickedFile != null) {
                    if (kIsWeb) {
                      var bytes = await pickedFile!.readAsBytes();
                      request.files.add(http.MultipartFile.fromBytes(
                          'image', bytes,
                          filename: pickedFile!.name));
                    } else {
                      request.files.add(await http.MultipartFile.fromPath(
                          'image', pickedFile!.path));
                    }
                  }

                  var res = await request.send();
                  if (res.statusCode == 200) {
                    fetchProducts(); // Reload danh sách
                    if (context.mounted) Navigator.pop(context);
                    _showSnackBar("✅ Thành công!");
                  }
                },
                child: const Text("XÁC NHẬN"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI =================

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg))); // Hiển thị thông báo
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = widget.user['role'] == 'admin'; // Kiểm tra quyền

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? "QUẢN LÝ" : "THỰC ĐƠN"),
        actions: [
          IconButton(
              onPressed: () {
                loadOrders();
                showModalBottomSheet(
                    context: context,
                    builder: (ctx) => OrderSheet(
                          orders: orders,
                          isAdmin: isAdmin,
                          onUpdateStatus: updateStatus,
                          onCancelOrder: cancelOrder,
                        ));
              },
              icon: const Icon(Icons.history)),

          IconButton(
              onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (c) => const LoginScreen())),
              icon: const Icon(Icons.logout)),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (ctx, i) {
                final p = products[i];

                return ListTile(
                  leading: p.image.isNotEmpty
                      ? Image.network("$apiUrl${p.image}")
                      : const Icon(Icons.fastfood),

                  title: Text(p.name),
                  subtitle: Text("${p.price} VNĐ"),

                  trailing: isAdmin
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: () =>
                                    _openProductDialog(product: p),
                                icon: const Icon(Icons.edit)),

                            IconButton(
                                onPressed: () => _confirmDelete(p),
                                icon: const Icon(Icons.delete)),
                          ],
                        )
                      : ElevatedButton(
                          onPressed: () {
                            setState(() => cart.add(p)); // Thêm vào giỏ
                            _showSnackBar("Đã thêm vào giỏ!");
                          },
                          child: const Text("MUA"),
                        ),
                );
              },
            ),

      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _openProductDialog(), // Thêm món
              child: const Icon(Icons.add),
            )
          : (cart.isNotEmpty
              ? FloatingActionButton(
                  onPressed: () => showModalBottomSheet(
                      context: context,
                      builder: (ctx) =>
                          CartSheet(cart: cart, onCheckout: checkout)),
                  child: const Icon(Icons.shopping_cart),
                )
              : null),
    );
  }

  // Hộp thoại xác nhận xóa
  void _confirmDelete(Product p) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text("Xóa?"),
              content: Text("Xóa ${p.name}?"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Hủy")),

                TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      deleteProduct(p.id); // Gọi API xóa
                    },
                    child: const Text("Xóa")),
              ],
            ));
  }
}