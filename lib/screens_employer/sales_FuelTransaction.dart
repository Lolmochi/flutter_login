import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math'; // Import for random number generation

class FuelTransactionScreen extends StatefulWidget {
  @override
  _FuelTransactionScreenState createState() => _FuelTransactionScreenState();
}

class _FuelTransactionScreenState extends State<FuelTransactionScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  String selectedFuelType = 'ดีเซลพรีเมี่ยม';
  String baseUrl = 'http://192.168.1.9:3000';

  /// Function to generate a random 10-digit transaction ID
  String generateTransactionId() {
    final random = Random();
    return List.generate(10, (_) => random.nextInt(10)).join();
  }

  /// Function to submit the transaction to the backend server
  Future<void> submitTransaction() async {
    final phone = phoneController.text.replaceAll('-', '').trim();
    final price = double.tryParse(priceController.text);

    if (phone.isEmpty || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกเบอร์โทรและราคาที่ถูกต้อง.')),
      );
      return;
    }

    final transactionId = generateTransactionId(); // Generate unique transaction ID

    try {
      // Check if the member exists
      final memberResponse = await http.get(
        Uri.parse('$baseUrl/member/$phone'),
      );

      if (memberResponse.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่พบหมายเลขสมาชิกนี้.')),
        );
        return;
      }

      // Submit the transaction with the generated transaction ID
      final transactionResponse = await http.post(
        Uri.parse('$baseUrl/transaction'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'transaction_id': transactionId, // Include transaction ID
          'phone_number': phone,
          'fuel_type': selectedFuelType,
          'price': price,
        }),
      );

      if (transactionResponse.statusCode == 200) {
        final transaction = json.decode(transactionResponse.body);
        final pointsEarned = transaction['pointsEarned'] ?? 0;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptScreen(
              transactionId: transactionId, // Pass transaction ID to receipt screen
              phoneNumber: phone,
              fuelType: selectedFuelType,
              price: price,
              pointsEarned: pointsEarned,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('บันทึกการขายล้มเหลว!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด. กรุณาลองใหม่อีกครั้ง.')),
      );
    }
  }

  /// Function to confirm the transaction before submission
  Future<void> confirmTransaction() async {
    final phone = phoneController.text.replaceAll('-', '').trim();
    final price = double.tryParse(priceController.text);

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ยืนยันการทำรายการ'),
          content: Text(
              'เบอร์โทร: $phone\nประเภทน้ำมัน: $selectedFuelType\nราคา: ฿${price?.toStringAsFixed(2)}\nคุณต้องการทำรายการนี้หรือไม่?'),
          actions: <Widget>[
            TextButton(
              child: Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel the transaction
              },
            ),
            TextButton(
              child: Text('ยืนยัน'),
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm the transaction
              },
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await submitTransaction();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('บันทึกการขายน้ำมัน'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Phone Number Input
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'เบอร์โทร'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 10),
            // Fuel Type Dropdown
            DropdownButtonFormField<String>(
              value: selectedFuelType,
              decoration: InputDecoration(labelText: 'ประเภทน้ำมัน'),
              onChanged: (value) {
                setState(() {
                  selectedFuelType = value!;
                });
              },
              items: <String>[
                'ดีเซลพรีเมี่ยม',
                'ไฮดีเซล',
                'ไฮพรีเมียม 97',
                'e85',
                'e20',
                'แก็สโซฮอล 91',
                'แก็สโซฮอล 95'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            // Price Input
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'ราคา'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            // Submit Button
            ElevatedButton(
              onPressed: confirmTransaction,
              child: Text('บันทึก'),
            ),
          ],
        ),
      ),
    );
  }
}

class ReceiptScreen extends StatelessWidget {
  final String transactionId;
  final String phoneNumber;
  final String fuelType;
  final double price;
  final int pointsEarned;

  const ReceiptScreen({
    required this.transactionId,
    required this.phoneNumber,
    required this.fuelType,
    required this.price,
    required this.pointsEarned,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ใบเสร็จ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction ID
            Text(
              'รหัสธุรกรรม: $transactionId',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Divider(),
            // Phone Number
            Text(
              'เบอร์โทร: $phoneNumber',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            // Fuel Type
            Text(
              'ประเภทน้ำมัน: $fuelType',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            // Price
            Text(
              'ราคา: ฿${price.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            // Points Earned
            Text(
              'คะแนนที่ได้รับ: $pointsEarned',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
