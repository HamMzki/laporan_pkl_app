import 'package:flutter/material.dart';
import '../../models/jurnal.dart';
import '../../services/api_service.dart';

class JurnalListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Jurnal')),
      body: FutureBuilder<List<Jurnal>>(
        future: ApiService().getJurnals(), // Panggil fungsi API di sini
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            // Jika data ada, tampilkan dalam ListView
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Jurnal jurnal = snapshot.data![index];
                return ListTile(
                  title: Text(jurnal.judul),
                  subtitle: Text(jurnal.deskripsi),
                );
              },
            );
          } else {
            return Center(child: Text('Tidak ada jurnal ditemukan.'));
          }
        },
      ),
    );
  }
}
