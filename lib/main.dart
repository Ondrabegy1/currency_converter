import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

void main() {
  runApp(CurrencyConverterApp());
}

class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CurrencyConverter(),
    );
  }
}

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({super.key});

  @override
  _CurrencyConverterState createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  final String apiUrl = 'https://api.exchangerate-api.com/v4/latest/USD';
  List<String> currencies = [];
  String fromCurrency = 'USD';
  String toCurrency = 'EUR';
  double rate = 0.0;
  double amount = 1.0;
  double result = 0.0;

  @override
  void initState() {
    super.initState();
    fetchCurrencies();
  }

  Future<void> fetchCurrencies() async {
    var response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        currencies = (data['rates'] as Map<String, dynamic>).keys.toList();
        rate = data['rates'][toCurrency];
      });
    } else {
      throw Exception('Failed to load currencies');
    }
  }

  Future<void> fetchConversionRate() async {
    var response = await http.get(Uri.parse('https://api.exchangerate-api.com/v4/latest/$fromCurrency'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        rate = data['rates'][toCurrency];
        result = amount * rate;
      });
    } else {
      throw Exception('Failed to load conversion rate');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: fromCurrency,
              onChanged: (value) {
                setState(() {
                  fromCurrency = value!;
                  fetchConversionRate();
                });
              },
              items: currencies.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: toCurrency,
              onChanged: (value) {
                setState(() {
                  toCurrency = value!;
                  fetchConversionRate();
                });
              },
              items: currencies.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Amount'),
              onChanged: (value) {
                setState(() {
                  amount = double.tryParse(value) ?? 1.0;
                  result = amount * rate;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'Converted Amount: ${NumberFormat.currency(symbol: '').format(result)} $toCurrency',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
