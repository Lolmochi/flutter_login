import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<Login> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String errorMessage = '';

  Future<void> _login() async {
    try {
      var response = await http.post(
        Uri.parse('http://192.168.1.9:3000/employee/login'), // เปลี่ยน URL ให้ตรงกับ API ของคุณ
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        // ทำงานเมื่อการล็อกอินสำเร็จ เช่นไปยังหน้าถัดไป
        Navigator.pushNamed(context, '/sales');
      } else if (response.statusCode == 404) {
        setState(() {
          errorMessage = 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง';
        });
      } else {
        setState(() {
          errorMessage = 'เกิดข้อผิดพลาดในการล็อกอิน';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load data';
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เข้าสู่ระบบ'),
        backgroundColor: Colors.green[800], // ปรับสีของ AppBar ให้เข้ากับธีม
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'ชื่อผู้ใช้',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'รหัสผ่าน',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700], // ปรับสีปุ่มให้เข้ากับธีม
              ),
              child: const Text('เข้าสู่ระบบ'),
            ),
            const SizedBox(height: 20),
            if (errorMessage.isNotEmpty) ...[
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 20),
            ],
            // เพิ่ม IconButton ตรงนี้
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.pushNamed(context, '/login_costumer');
              },
            ),
          ],
        ),
      ),
    );
  }
}
