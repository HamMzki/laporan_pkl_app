// lib/pages/jurnal/jurnal_list_page.dart

import 'package:flutter/material.dart';
import '../../models/jurnal.dart';
import '../../services/api_service.dart';
import 'create_jurnal_page.dart';
import 'jurnal_detail_page.dart';
import '../auth/login_page.dart';
import '../profile/profile_page.dart';


class JurnalListPage extends StatefulWidget {
  @override
  _JurnalListPageState createState() => _JurnalListPageState();
}

class _JurnalListPageState extends State<JurnalListPage> {
  late Future<List<Jurnal>> _jurnalsFuture = Future.value([]);
  String? _token;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final apiService = ApiService();
    _token = await apiService.getToken();

    if (_token != null) {
      // Hapus cache gambar sebelum memuat ulang
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      setState(() {
        _jurnalsFuture = apiService.getJurnals();
      });
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _refreshJurnals() {
    // Hapus cache gambar saat me-refresh daftar
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    setState(() {
      _jurnalsFuture = ApiService().getJurnals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Jurnal PKL'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await ApiService().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Jurnal>>(
        future: _jurnalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return RefreshIndicator(
              onRefresh: () async {
                _refreshJurnals();
              },
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Jurnal jurnal = snapshot.data![index];
                  return ListTile(
                    leading: jurnal.foto != null
                        ? Image.network(
                            jurnal.foto!, // Kembali ke URL asli
                            headers: {
                              "ngrok-skip-browser-warning": "true",
                              if (_token != null)
                                'Authorization': 'Bearer $_token',
                            },
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.error),
                          )
                        : Icon(Icons.image, size: 50),
                    title: Text(jurnal.judul),
                    subtitle: Text(
                      jurnal.deskripsi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => JurnalDetailPage(
                            jurnal: jurnal,
                            onUpdate: _refreshJurnals, // <-- DARI SINI
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          } else {
            return Center(child: Text('Tidak ada jurnal ditemukan.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateJurnalPage()),
          ).then((_) {
            _refreshJurnals();
          });
        },
      ),
    );
  }
}
