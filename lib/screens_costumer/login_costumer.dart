import 'package:flutter/material.dart';
import 'package:flutter_application_10/screens_costumer/data_costumer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginCustomer extends StatefulWidget {
  const LoginCustomer({super.key});

  @override
  _LoginCustomerState createState() => _LoginCustomerState();
}

class _LoginCustomerState extends State<LoginCustomer> {
  final _memberIdController = TextEditingController();
  final _phonController = TextEditingController();
  String errorMessage = '';
  bool isLoading = false;

  void _login() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      var response = await http.post(
        Uri.parse('http://192.168.1.9:3000/member/login'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'id': _memberIdController.text,
          'phone_number': _phonController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final phoneNumber = data['phone_number'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemberDetailsScreen(phoneNumber: phoneNumber),
          ),
        );
      } else {
        setState(() {
          errorMessage = 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ค้นหา'),
        backgroundColor: Colors.green[800],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[100]!, Colors.green[300]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _memberIdController,
              decoration: InputDecoration(
                labelText: 'ชื่อผู้ใช้',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phonController,
              decoration: InputDecoration(
                labelText: 'รหัสผ่าน',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text('เข้าสู่ระบบ', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
