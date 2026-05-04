const express = require('express'); // Import framework Express
const mysql = require('mysql2'); // Thư viện kết nối MySQL
const cors = require('cors'); // Cho phép gọi API từ Flutter (khác domain)
const multer = require('multer'); // Upload file (ảnh)
const path = require('path'); // Xử lý đường dẫn file
const fs = require('fs'); // Làm việc với file system

const app = express(); // Khởi tạo app Express

app.use(cors()); // Cho phép tất cả request từ bên ngoài
app.use(express.json()); // Cho phép đọc JSON từ body

// ===== CẤU HÌNH LƯU ẢNH =====
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const dir = './uploads'; // Thư mục lưu ảnh
        if (!fs.existsSync(dir)) fs.mkdirSync(dir); // Nếu chưa có thì tạo
        cb(null, dir); // Trả về thư mục lưu
    },
    filename: (req, file, cb) => {
        // Đặt tên file = timestamp + đuôi file (.jpg, .png)
        cb(null, Date.now() + path.extname(file.originalname));
    }
});

const upload = multer({ storage: storage }); // Khởi tạo middleware upload

// Public thư mục uploads => Flutter truy cập ảnh qua URL
app.use('/uploads', express.static('uploads'));

// ===== KẾT NỐI DATABASE =====
const db = mysql.createPool({
    host: 'localhost', 
    user: 'root', 
    password: '', 
    database: 'app_foods' 
});

// PHÂN QUYỀN ADMIN
const isAdmin = (req, res, next) => {
    const { role } = req.body;
    
    if (role !== 'admin') {
        return res.status(403).send({ 
            success: false, 
            message: "Chỉ admin mới được phép!" 
        });
    }
    next();
};

// ===== AUTH =====

// API đăng nhập
app.post('/login', (req, res) => {
    const { username, password } = req.body; // Lấy dữ liệu từ client

    db.query(
        "SELECT id, username, role FROM users WHERE username = ? AND password = ?",
        [username, password], // Truyền tham số chống SQL injection
        (err, result) => {
            if (err) return res.status(500).send(err);

            if (result.length > 0)
                res.send({ success: true, user: result[0] }); // Thành công
            else
                res.send({ success: false, message: "Sai tài khoản!" }); // Thất bại
        }
    );
});

// API đăng ký
app.post('/register', (req, res) => {
    const { username, password } = req.body;

    // Kiểm tra username đã tồn tại chưa
    db.query(
        "SELECT * FROM users WHERE username = ?",
        [username],
        (err, result) => {
            if (err) return res.status(500).send(err);

            if (result.length > 0)
                return res.send({ success: false, message: "Tên tài khoản đã tồn tại!" });

            // Nếu chưa có thì insert
            const query = "INSERT INTO users (username, password, role) VALUES (?, ?, 'user')";
            db.query(query, [username, password], (err) => {
                if (err) return res.status(500).send(err);
                res.send({ success: true, message: "Đăng ký thành công!" });
            });
        }
    );
});

// ===== PRODUCTS =====

// API lấy danh sách món ăn
app.get('/products', (req, res) => {
    db.query("SELECT * FROM products", (err, result) => {
        if (err) return res.status(500).send(err);
        res.send(result); // Trả danh sách sản phẩm
    });
});

// API thêm món ăn (có upload ảnh)
app.post('/admin/add-product', isAdmin, upload.single('image'), (req, res) => {
    const { name, price } = req.body;

    // Nếu có upload ảnh thì lấy đường dẫn
    const imageUrl = req.file ? `/uploads/${req.file.filename}` : '';

    const query = "INSERT INTO products (name, price, image) VALUES (?, ?, ?)";
    db.query(query, [name, price, imageUrl], (err) => {
        if (err) {
            console.error(err);
            return res.status(500).send(err);
        }
        res.send({ success: true, message: "Thêm món thành công!" });
    });
});

// ===== ĐƠN HÀNG =====

// API lấy tất cả đơn hàng
app.get('/all-orders', (req, res) => {
    const { user_id, role } = req.query;

    // Query join bảng users để lấy username
    let query = `
        SELECT orders.*, users.username 
        FROM orders 
        JOIN users ON orders.user_id = users.id `;

    let params = [];

    // Nếu không phải admin thì chỉ lấy đơn của user
    if (role !== 'admin') {
        query += " WHERE orders.user_id = ?";
        params.push(user_id);
    }

    query += " ORDER BY orders.created_at DESC"; // Sắp xếp mới nhất

    db.query(query, params, (err, result) => {
        if (err) return res.status(500).send(err);
        res.send(result);
    });
});

// API đặt hàng
app.post('/checkout', (req, res) => {
    const { user_id, total_price, items_detail, address, phone, payment_method } = req.body;

    // Kiểm tra thiếu thông tin
    if (!address || !phone)
        return res.status(400).send({ success: false, message: "Thiếu thông tin" });

    const query = `
        INSERT INTO orders 
        (user_id, total_price, items_detail, address, phone, payment_method, status) 
        VALUES (?, ?, ?, ?, ?, ?, 'Đang chờ duyệt')
    `;

    db.query(query, [user_id, total_price, items_detail, address, phone, payment_method], (err) => {
        if (err) return res.status(500).send(err);
        res.send({ success: true });
    });
});

// API hủy đơn
app.post('/order/cancel', (req, res) => {
    const { order_id } = req.body;

    // Chỉ cho hủy khi đang chờ duyệt
    db.query(
        "UPDATE orders SET status = 'Đã hủy' WHERE id = ? AND status = 'Đang chờ duyệt'",
        [order_id],
        (err, result) => {
            if (err) return res.status(500).send(err);

            res.send({ success: result.affectedRows > 0 }); // true nếu update thành công
        }
    );
});

// API admin cập nhật trạng thái
app.post('/admin/update-order', isAdmin, (req, res) => {
    const { order_id, status } = req.body;

    db.query(
        "UPDATE orders SET status = ? WHERE id = ?",
        [status, order_id],
        (err) => {
            if (err) return res.status(500).send(err);
            res.send({ success: true });
        }
    );
});

// ===== SỬA SẢN PHẨM =====
app.post('/admin/update-product', isAdmin, upload.single('image'), (req, res) => {
    const { id, name, price } = req.body;

    let query = "UPDATE products SET name = ?, price = ? WHERE id = ?";
    let params = [name, price, id];

    // Nếu có upload ảnh mới
    if (req.file) {
        query = "UPDATE products SET name = ?, price = ?, image = ? WHERE id = ?";
        params = [name, price, `/uploads/${req.file.filename}`, id];
    }

    db.query(query, params, (err) => {
        if (err) return res.status(500).send(err);
        res.send({ success: true, message: "Cập nhật thành công!" });
    });
});

// ===== XÓA SẢN PHẨM =====
app.post('/admin/delete-product', isAdmin, (req, res) => {
    const { id } = req.body;

    db.query("DELETE FROM products WHERE id = ?", [id], (err) => {
        if (err) return res.status(500).send(err);
        res.send({ success: true, message: "Đã xóa món ăn!" });
    });
});

// ===== CHẠY SERVER =====
app.listen(3000, () =>
    console.log("🚀 Server running at http://localhost:3000")
);