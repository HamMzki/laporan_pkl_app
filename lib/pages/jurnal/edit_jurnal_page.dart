import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import '../../models/jurnal.dart';
import '../../services/api_service.dart';

class EditJurnalPage extends StatefulWidget {
  final Jurnal jurnal;
  final VoidCallback? onUpdate;

  EditJurnalPage({required this.jurnal, this.onUpdate});

  @override
  State<EditJurnalPage> createState() => _EditJurnalPageState();
}

class _EditJurnalPageState extends State<EditJurnalPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late TextEditingController _judulController;
  late TextEditingController _deskripsiController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  File? _pickedFile;
  Uint8List? _pickedFileBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print('--- initState: Memuat data jurnal ---');
    print('Jurnal ID: ${widget.jurnal.id}');
    print('Judul: ${widget.jurnal.judul}');
    print('Deskripsi: ${widget.jurnal.deskripsi}');
    print('Tanggal: ${widget.jurnal.tanggal}');

    _judulController = TextEditingController(text: widget.jurnal.judul);
    _deskripsiController = TextEditingController(text: widget.jurnal.deskripsi);

    _selectedDate = widget.jurnal.tanggal;
    _selectedTime = TimeOfDay.fromDateTime(widget.jurnal.tanggal);
    print('Tanggal awal: $_selectedDate');
    print('Jam awal: $_selectedTime');
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    print('--- _pickImage: Memilih gambar ---');
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      print('Gambar berhasil dipilih dari galeri.');
      if (kIsWeb) {
        setState(() {
          picked.readAsBytes().then((bytes) {
            setState(() {
              _pickedFileBytes = bytes;
              _pickedFile = null;
              print('Mode Web: bytes gambar telah disimpan.');
            });
          });
        });
      } else {
        setState(() {
          _pickedFile = File(picked.path);
          _pickedFileBytes = null;
          print(
            'Mode Mobile: file gambar telah disimpan. Path: ${_pickedFile!.path}',
          );
        });
      }
    } else {
      print('Tidak ada gambar yang dipilih.');
    }
  }

  Future<void> _pickDate() async {
    print('--- _pickDate: Membuka date picker ---');
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        print('Tanggal baru dipilih: $_selectedDate');
      });
    }
  }

  Future<void> _pickTime() async {
    print('--- _pickTime: Membuka time picker ---');
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        print('Jam baru dipilih: $_selectedTime');
      });
    }
  }

  Future<void> _saveJurnal() async {
    print('--- _saveJurnal: Memulai proses penyimpanan ---');
    if (!_formKey.currentState!.validate()) {
      print('Validasi form gagal.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final waktuKegiatanLengkap = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // ✅ PERBAIKAN: Format tanggal sesuai dengan Y-m-d H:i
    final String tanggalFormatted = DateFormat(
      'yyyy-MM-dd HH:mm',
    ).format(waktuKegiatanLengkap);

    print('Menggabungkan Tanggal dan Jam: $waktuKegiatanLengkap');
    print(
      'Mengirim tanggal dalam format: $tanggalFormatted',
    ); // Tampilkan format yang benar
    print('Mengirim ke API...');

    try {
      await _apiService.updateJurnal(
        widget.jurnal.id,
        _judulController.text,
        _deskripsiController.text,
        tanggalFormatted, // Menggunakan variabel yang sudah diformat
        _pickedFile,
        fotoBytes: _pickedFileBytes,
      );

      print('✅ Jurnal berhasil diperbarui. Navigasi kembali.');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Jurnal berhasil diperbarui!')));

      if (widget.onUpdate != null) {
        widget.onUpdate!();
      }

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      print('❌ Gagal memperbarui jurnal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui jurnal: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
        print('Proses selesai. Loading dinonaktifkan.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Jurnals',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _judulController,
                        decoration: InputDecoration(
                          labelText: 'Judul',
                          hintText: 'Masukkan judul jurnal...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Judul tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _deskripsiController,
                        decoration: InputDecoration(
                          labelText: 'Deskripsi',
                          hintText: 'Tuliskan deskripsi kegiatan...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Deskripsi tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickDate,
                      icon: Icon(Icons.calendar_today),
                      label: Text(
                        '${DateFormat('dd-MM-yyyy').format(_selectedDate)}',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickTime,
                      icon: Icon(Icons.access_time),
                      label: Text(
                        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: _pickedFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _pickedFile!,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          )
                        : _pickedFileBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              _pickedFileBytes!,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          )
                        : (widget.jurnal.foto != null &&
                              widget.jurnal.foto!.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.jurnal.foto!,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 200,
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: Text('Gambar gagal dimuat'),
                                    ),
                                  ),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 50,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Pilih Foto',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveJurnal,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Simpan Perubahan'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
