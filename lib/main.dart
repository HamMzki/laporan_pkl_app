import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:laporan_pkl_app/services/api_service.dart';
import 'pages/auth/login_page.dart';
import 'main_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final api = ApiService();
  final token = await api.getToken();

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Laporan PKL App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: token != null ? const MainApp() : LoginPage(),
    ),
  );
}
