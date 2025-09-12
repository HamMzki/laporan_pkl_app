import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';

class CreateJurnalPage extends StatefulWidget {
  @override
  _CreateJurnalPageState createState() => _CreateJurnalPageState();
}

class _CreateJurnalPageState extends State<CreateJurnalPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _pickedFile;
  Uint8List? _pickedFileBytes;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _pickedFileBytes = bytes;
          _pickedFile = null;
        });
      } else {
        setState(() {
          _pickedFile = File(pickedFile.path);
          _pickedFileBytes = null;
        });
      }
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _saveJurnal() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      final waktuKegiatanLengkap = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      print('---Payload Jurnal---');
      print({
        'judul': _judulController.text,
        'deskripsi': _deskripsiController.text,
        'tanggal': waktuKegiatanLengkap.toIso8601String(),
        'foto': _pickedFile != null
            ? _pickedFile!.path
            : (_pickedFileBytes != null ? 'bytes data' : 'null'),
      });

      try {
        await ApiService().createJurnal(
          _judulController.text,
          _deskripsiController.text,
          waktuKegiatanLengkap,
          _pickedFile,
          fotoBytes: _pickedFileBytes,
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Jurnal berhasil dibuat!')));
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal membuat jurnal: $e')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Tanggal dan jam harus dipilih')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambah Jurnal Baru',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Judul Field
                  TextFormField(
                    controller: _judulController,
                    decoration: InputDecoration(
                      labelText: 'Judul Jurnal',
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Judul tidak boleh kosong'
                        : null,
                  ),
                  SizedBox(height: 20),
                  // Deskripsi Field
                  TextFormField(
                    controller: _deskripsiController,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 5,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Deskripsi tidak boleh kosong'
                        : null,
                  ),
                  SizedBox(height: 20),
                  // Date and Time Pickers
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickDate,
                          icon: Icon(Icons.calendar_today),
                          label: Text(
                            _selectedDate == null
                                ? 'Pilih Tanggal'
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
                            _selectedTime == null
                                ? 'Pilih Jam'
                                : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Photo Picker and Preview
                  Column(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.photo_library),
                        label: Text('Pilih Foto'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: _pickedFile != null
                            ? Image.file(_pickedFile!, fit: BoxFit.cover)
                            : (_pickedFileBytes != null
                                  ? Image.memory(
                                      _pickedFileBytes!,
                                      fit: BoxFit.cover,
                                    )
                                  : Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image,
                                            size: 50,
                                            color: Colors.grey[600],
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Tidak ada foto yang dipilih',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Save Button
                  ElevatedButton(
                    onPressed: _saveJurnal,
                    child: Text('Simpan Jurnal'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      elevation: 5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
