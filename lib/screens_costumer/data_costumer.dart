import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MemberDetailsScreen extends StatelessWidget {
  final String phoneNumber;

  MemberDetailsScreen({required this.phoneNumber});

  Future<Map<String, dynamic>> fetchMemberData() async {
    final response = await http.get(Uri.parse('http://192.168.1.9:3000/member/$phoneNumber'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load member data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Member Details')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchMemberData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data found'));
          } else {
            final member = snapshot.data!['member'];
            final transactions = snapshot.data!['transactions'] as List<dynamic>;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${member['name']} ${member['surname']}', style: TextStyle(fontSize: 20)),
                  Text('Phone: ${member['phone_number']}', style: TextStyle(fontSize: 20)),
                  Text('Points: ${member['points']}', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 20),
                  Text('Transactions:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return ListTile(
                          title: Text('Fuel Type: ${transaction['fuel_type']}'),
                          subtitle: Text('Price: ${transaction['price']} - Points: ${transaction['points_earned']}'),
                          trailing: Text('Date: ${transaction['timestamp']}'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
