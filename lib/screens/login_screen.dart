import 'package:flutter/material.dart'; // Thư viện UI Flutter
import 'package:http/http.dart' as http; // Gọi API HTTP
import 'dart:convert'; // Xử lý JSON
import 'home_screen.dart'; // Màn hình trang chủ sau khi login
import 'register_screen.dart'; // Màn hình đăng ký

// Widget màn hình đăng nhập (Stateful vì có thay đổi dữ liệu)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// State của LoginScreen
class _LoginScreenState extends State<LoginScreen> {
  final _user = TextEditingController(); // Controller lấy dữ liệu ô username
  final _pass = TextEditingController(); // Controller lấy dữ liệu ô password

  final String apiUrl = "http://localhost:3000"; // Địa chỉ API backend

  // Hàm xử lý đăng nhập
  Future<void> login() async {
    // Kiểm tra nếu chưa nhập đủ thông tin
    if (_user.text.isEmpty || _pass.text.isEmpty) {
      _showSnackBar("Vui lòng nhập đầy đủ thông tin!");
      return;
    }

    try {
      // Gửi request POST lên server
      final res = await http.post(
        Uri.parse('$apiUrl/login'),
        headers: {'Content-Type': 'application/json'}, // Header JSON
        body: jsonEncode({
          'username': _user.text, 
          'password': _pass.text
        }), // Body gửi username + password
      );

      final data = jsonDecode(res.body); // Parse JSON response

      // Nếu đăng nhập thành công
      if (data['success']) {
        if (!mounted) return; // Kiểm tra widget còn tồn tại

        // Chuyển sang trang Home và truyền user
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FoodHomePage(user: data['user']),
          ),
        );
      } else {
        // Sai tài khoản hoặc mật khẩu
        _showSnackBar(data['message']);
      }
    } catch (e) {
      // Lỗi kết nối server
      _showSnackBar("Lỗi kết nối Server! Đảm bảo Backend đang chạy.");
    }
  }

  // Hàm hiển thị thông báo SnackBar
  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView( // Cho phép scroll khi bàn phím hiện
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Icon logo
              const Icon(Icons.restaurant_menu, size: 80, color: Colors.orange),

              const SizedBox(height: 10),

              // Tiêu đề
              const Text(
                "FOOD SYSTEM",
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange),
              ),

              // Mô tả
              const Text(
                "Đăng nhập để đặt món ngay",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 40),

              // Ô nhập username
              TextField(
                controller: _user,
                decoration: const InputDecoration(
                  labelText: "Tài khoản",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              // Ô nhập password
              TextField(
                controller: _pass,
                obscureText: true, // Ẩn mật khẩu
                decoration: const InputDecoration(
                  labelText: "Mật khẩu",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              // Nút đăng nhập
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, // Màu nút
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: login, // Gọi hàm login
                  child: const Text(
                    "ĐĂNG NHẬP",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Chuyển sang màn đăng ký
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Chưa có tài khoản?"),

                  TextButton(
                    onPressed: () {
                      // Điều hướng sang RegisterScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Đăng ký ngay",
                      style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}