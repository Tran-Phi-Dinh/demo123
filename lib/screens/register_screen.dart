import 'package:flutter/material.dart'; // Thư viện UI Flutter
import 'package:http/http.dart' as http; // Gọi API HTTP
import 'dart:convert'; // Xử lý JSON

// Widget màn hình đăng ký (Stateful vì có nhập liệu)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

// State của RegisterScreen
class _RegisterScreenState extends State<RegisterScreen> {
  final _user = TextEditingController(); // Controller lấy username
  final _pass = TextEditingController(); // Controller lấy password
  final _confirmPass = TextEditingController(); // Controller xác nhận password

  final String apiUrl = "http://localhost:3000"; // API backend

  // Hàm đăng ký tài khoản
  Future<void> register() async {
    // Kiểm tra rỗng
    if (_user.text.isEmpty || _pass.text.isEmpty) {
      _showMsg("Vui lòng điền đầy đủ thông tin");
      return;
    }

    // Kiểm tra mật khẩu trùng khớp
    if (_pass.text != _confirmPass.text) {
      _showMsg("Mật khẩu xác nhận không khớp");
      return;
    }

    try {
      // Gửi request POST đăng ký
      final res = await http.post(
        Uri.parse('$apiUrl/register'),
        headers: {'Content-Type': 'application/json'}, // Gửi dạng JSON
        body: jsonEncode({
          'username': _user.text,
          'password': _pass.text
        }),
      );

      final data = jsonDecode(res.body); // Parse dữ liệu trả về

      // Nếu đăng ký thành công
      if (data['success']) {
        _showMsg("Đăng ký thành công! Hãy đăng nhập.");

        if (!mounted) return;

        Navigator.pop(context); // Quay lại màn hình login
      } else {
        // Nếu thất bại thì show message từ server
        _showMsg(data['message']);
      }
    } catch (e) {
      // Lỗi kết nối server
      _showMsg("Lỗi kết nối Server");
    }
  }

  // Hàm hiển thị thông báo
  void _showMsg(String msg) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ĐĂNG KÝ TÀI KHOẢN"), // Tiêu đề
      ),

      body: Padding(
        padding: const EdgeInsets.all(30), // Khoảng cách viền
        child: Column(
          children: [

            // Ô nhập username
            TextField(
              controller: _user,
              decoration: const InputDecoration(
                  labelText: "Tên đăng nhập"),
            ),

            // Ô nhập password
            TextField(
              controller: _pass,
              obscureText: true, // Ẩn mật khẩu
              decoration: const InputDecoration(
                  labelText: "Mật khẩu"),
            ),

            // Ô nhập lại password
            TextField(
              controller: _confirmPass,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: "Xác nhận mật khẩu"),
            ),

            const SizedBox(height: 30),

            // Nút đăng ký
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: register, // Gọi hàm register
                child: const Text("TẠO TÀI KHOẢN"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}