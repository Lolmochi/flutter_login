import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FuelPriceProvider with ChangeNotifier {
  List<Map<String, String>> fuelPrices = [];
  String datePrice = '';

  Future<void> fetchFuelPrices() async {
    final response = await http.get(Uri.parse('https://oil-price.bangchak.co.th/apioilprice2/th'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      if (data.isNotEmpty) {
        var oilData = data[0];
        var oilList = jsonDecode(oilData['OilList']);

        datePrice = oilData['OilDateNow'];
        fuelPrices = oilList.map<Map<String, String>>((oil) {
          return {
            'icon': oil['IconWeb2'].toString(),
            'priceToday': oil['PriceToday'].toString(),
            'priceTomorrow': oil['PriceTomorrow'].toString(),
          };
        }).toList();
      }
      notifyListeners(); // แจ้งให้ทุกหน้ารู้ว่าข้อมูลมีการเปลี่ยนแปลง
    }
  }
}
