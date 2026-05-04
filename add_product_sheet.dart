import 'package:flutter/material.dart'; // Thư viện UI Flutter
import 'package:image_picker/image_picker.dart'; // Thư viện chọn ảnh từ máy
import 'dart:io'; // Xử lý file (dùng cho mobile)
import 'package:http/http.dart' as http; // Gọi API HTTP

// Widget BottomSheet để thêm sản phẩm mới
class AddProductSheet extends StatefulWidget {
  final Function onAdded; // Callback khi thêm thành công (reload dữ liệu)

  const AddProductSheet({super.key, required this.onAdded});

  @override
  State<AddProductSheet> createState() => _AddProductSheetState();
}

// State của AddProductSheet
class _AddProductSheetState extends State<AddProductSheet> {
  final _name = TextEditingController(); // Controller nhập tên món
  final _price = TextEditingController(); // Controller nhập giá món

  File? _image; // Lưu ảnh đã chọn (kiểu File)

  // Hàm chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery); // Mở gallery

    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path)); // Lưu ảnh
    }
  }

  // Hàm gửi dữ liệu lên server để thêm sản phẩm
  Future<void> _submit() async {
    // Nếu chưa nhập đủ thì không làm gì
    if (_name.text.isEmpty || _price.text.isEmpty) return;

    // Tạo request dạng multipart (vì có upload file)
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:3000/admin/add-product'),
    );

    // Thêm field text
    request.fields['name'] = _name.text;
    request.fields['price'] = _price.text;

    // Nếu có ảnh thì thêm vào request
    if (_image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _image!.path,
        ),
      );
    }

    // Gửi request
    var res = await request.send();

    // Nếu thành công
    if (res.statusCode == 200) {
      widget.onAdded(); // Gọi callback để reload danh sách
      Navigator.pop(context); // Đóng bottom sheet
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Đẩy UI lên khi bàn phím hiện
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Chiều cao theo nội dung
        children: [
          // Tiêu đề
          const Text(
            "THÊM MÓN MỚI",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          // Ô nhập tên món
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: "Tên món"),
          ),

          // Ô nhập giá món
          TextField(
            controller: _price,
            decoration: const InputDecoration(labelText: "Giá món"),
            keyboardType: TextInputType.number, // Bàn phím số
          ),

          const SizedBox(height: 15),

          // Khung chọn ảnh
          GestureDetector(
            onTap: _pickImage, // Nhấn để chọn ảnh
            child: Container(
              height: 100,
              width: double.infinity,
              color: Colors.grey[200],
              child: _image == null
                  ? const Icon(Icons.add_a_photo, size: 40) // Chưa có ảnh
                  : Image.file(_image!, fit: BoxFit.cover), // Hiển thị ảnh
            ),
          ),

          // Nút lưu
          ElevatedButton(
            onPressed: _submit, // Gọi hàm submit
            child: const Text("LƯU MÓN ĂN"),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}