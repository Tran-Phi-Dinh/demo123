import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  // Đảm bảo các dịch vụ hệ thống của Flutter đã sẵn sàng
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FoodApp());
}

class FoodApp extends StatelessWidget {
  const FoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food App',
      // Tắt banner debug ở góc phải màn hình
      debugShowCheckedModeBanner: false,
      
      // Định nghĩa Theme chung cho toàn bộ App
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true, // Sử dụng giao diện hiện đại hơn
        scaffoldBackgroundColor: Colors.grey[100], // Màu nền nhẹ nhàng cho toàn app
      ),
      
      // Màn hình bắt đầu luôn là Login
      home: const LoginScreen(),
    );
  }
}