// Lớp Product dùng để lưu thông tin sản phẩm
class Product {
  final int id;          // ID của sản phẩm
  final String name;     // Tên sản phẩm
  final double price;    // Giá sản phẩm (kiểu double)
  final String image;    // Đường dẫn hoặc URL ảnh sản phẩm

  // Constructor (hàm khởi tạo) bắt buộc truyền đầy đủ dữ liệu
  Product({
    required this.id,     // Bắt buộc có id
    required this.name,   // Bắt buộc có tên
    required this.price,  // Bắt buộc có giá
    required this.image,  // Bắt buộc có ảnh
  });

  // Factory dùng để chuyển JSON -> đối tượng sản phẩm
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0, 
      // Lấy id từ JSON, nếu null thì gán = 0

      name: json['name'] ?? "Không tên", 
      // Lấy tên, nếu null thì gán "Không tên"

      price: (json['price'] ?? 0).toDouble(), 
      // Lấy price, nếu null = 0
      // toDouble() để tránh lỗi khi DB trả về int

      image: json['image'] ?? "", 
      // Lấy đường dẫn ảnh, nếu null thì để chuỗi rỗng
    );
  }
}

// ============================

// Lớp FoodOrder dùng để lưu thông tin đơn hàng
class FoodOrder {
  final int id;             // ID đơn hàng
  final String username;    // Tên người đặt
  final double totalPrice;  // Tổng tiền
  final String itemsDetail; // Chi tiết món ăn (dạng chuỗi)
  final String status;      // Trạng thái đơn hàng
  final String address;     // Địa chỉ giao hàng
  final String phone;       // Số điện thoại
  final String paymentMethod; // Phương thức thanh toán

  // Constructor bắt buộc truyền đầy đủ
  FoodOrder({
    required this.id,
    required this.username,
    required this.totalPrice,
    required this.itemsDetail,
    required this.status,
    required this.address,
    required this.phone,
    required this.paymentMethod,
  });

  // Factory nhà máy chuyển JSON -> sự vật FoodOrder
  factory FoodOrder.fromJson(Map<String, dynamic> json) {
    return FoodOrder(
      id: json['id'] ?? 0, 
      // Nếu không có id thì gán mặc định = 0

      username: json['username'] ?? "Khách", 
      // Nếu không có username thì mặc định "Khách"

      totalPrice: (json['total_price'] ?? 0).toDouble(), 
      // Lấy tổng tiền, ép sang double

      itemsDetail: json['items_detail'] ?? "", 
      // Chi tiết món ăn, nếu null thì rỗng

      status: json['status'] ?? "Đang chờ", 
      // Trạng thái mặc định là "Đang chờ"

      address: json['address'] ?? "Chưa có địa chỉ", 
      // Nếu chưa có địa chỉ thì gán mặc định

      phone: json['phone'] ?? "Chưa có SĐT", 
      // Nếu chưa có số điện thoại

      paymentMethod: json['payment_method'] ?? "Tiền mặt", 
      // Nếu chưa có phương thức thanh toán thì mặc định tiền mặt
    );
  }
}