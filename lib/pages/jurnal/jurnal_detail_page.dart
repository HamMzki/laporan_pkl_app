import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/jurnal.dart';
import '../../services/api_service.dart';
import 'edit_jurnal_page.dart';

class JurnalDetailPage extends StatefulWidget {
  final Jurnal jurnal;
  final VoidCallback onUpdate;

  JurnalDetailPage({required this.jurnal, required this.onUpdate});

  @override
  State<JurnalDetailPage> createState() => _JurnalDetailPageState();
}

class _JurnalDetailPageState extends State<JurnalDetailPage> {
  late Jurnal _jurnal;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _jurnal = widget.jurnal;
  }

  Future<void> _deleteJurnal() async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jurnal'),
        content: const Text('Apakah Anda yakin ingin menghapus jurnal ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.deleteJurnal(widget.jurnal.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jurnal berhasil dihapus!')),
        );
        widget.onUpdate();
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menghapus jurnal: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _jurnal.judul,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Jurnal',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditJurnalPage(jurnal: _jurnal),
                ),
              ).then((_) {
                widget.onUpdate();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Hapus Jurnal',
            onPressed: _deleteJurnal,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image section with a rounded container
              if (_jurnal.foto != null)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      _jurnal.foto!,
                      height: 260,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 260,
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 80,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              // Date and time section
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    DateFormat('dd MMMM yyyy').format(_jurnal.tanggal),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.access_time, size: 20, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    DateFormat('HH:mm').format(_jurnal.tanggal),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Title and description section in a card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _jurnal.judul,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Divider(color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text(
                        _jurnal.deskripsi,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
