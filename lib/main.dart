import 'package:flutter/material.dart';
import 'screens_costumer/login_costumer.dart';
import 'screens_costumer/data_costumer.dart';
import 'screens_employer/login_FuelTransaction.dart';
import 'screens_employer/sales_FuelTransaction.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sales Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
          '/': (context) => const Login(),
          '/login_costumer': (context) => LoginCustomer(),
          '/sales': (context) => FuelTransactionScreen(),
          '/data_costumer': (context) => MemberDetailsScreen(phoneNumber: ''), // Set a default or empty value
      },
    );
  }
}
