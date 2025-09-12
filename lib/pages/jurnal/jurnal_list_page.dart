// lib/pages/jurnal/jurnal_list_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/jurnal.dart';
import '../../services/api_service.dart';
import 'create_jurnal_page.dart';
import 'jurnal_detail_page.dart';
import '../auth/login_page.dart';
import '../profile/profile_page.dart';

class JurnalListPage extends StatefulWidget {
  const JurnalListPage({Key? key}) : super(key: key);

  @override
  _JurnalListPageState createState() => _JurnalListPageState();
}

class _JurnalListPageState extends State<JurnalListPage> {
  late Future<List<Jurnal>> _jurnalsFuture = Future.value([]);
  final ApiService _apiService = ApiService();
  String? _token;

  // juga simpan list penuh agar mudah difilter
  List<Jurnal> _allJurnals = [];

  // calendar state
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    _token = await _apiService.getToken();

    if (_token != null) {
      // bersihkan cache gambar sebelum ambil ulang
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      try {
        final jurnals = await _apiService.getJurnals();
        setState(() {
          _allJurnals = jurnals;
          _jurnalsFuture = Future.value(jurnals);
        });
      } catch (e) {
        setState(() {
          _jurnalsFuture = Future.error(e);
        });
      }
    } else {
      _redirectToLogin();
    }
  }

  Future<void> _refreshJurnals() async {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    try {
      final jurnals = await _apiService.getJurnals();
      setState(() {
        _allJurnals = jurnals;
        _jurnalsFuture = Future.value(jurnals);
      });
    } catch (e) {
      // keep previous state but show error via Future
      setState(() {
        _jurnalsFuture = Future.error(e);
      });
    }
  }

  void _redirectToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _logout() async {
    await _apiService.logout();
    _redirectToLogin();
  }

  // helper untuk membandingkan tanggal (hanya year-month-day)
  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Jurnal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline),
            tooltip: 'Profil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Kalender di atas
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) =>
                  _selectedDay != null && _isSameDate(day, _selectedDay!),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarFormat: CalendarFormat.week,
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: TextStyle(color: Colors.black87),
                weekendTextStyle: TextStyle(color: Colors.black87),
              ),
            ),
          ),

          // Info filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDay == null
                      ? 'Semua Jurnal'
                      : 'Jurnal pada ${DateFormat('dd MMMM yyyy').format(_selectedDay!)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                if (_selectedDay != null)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedDay = null; // reset filter
                      });
                    },
                    icon: Icon(Icons.close, size: 16),
                    label: Text('Reset Filter'),
                  ),
              ],
            ),
          ),

          // List Jurnal
          Expanded(
            child: FutureBuilder<List<Jurnal>>(
              future: _jurnalsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Gagal memuat jurnal: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final List<Jurnal> all = snapshot.data!;
                  if (_allJurnals.isEmpty) {
                    _allJurnals = all;
                  }
                  final filtered = _selectedDay == null
                      ? _allJurnals
                      : _allJurnals.where((j) {
                          return _isSameDate(j.tanggal, _selectedDay!);
                        }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Tidak ada jurnal pada tanggal ini.',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshJurnals,
                    child: ListView.builder(
                      padding: EdgeInsets.all(12),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final jurnal = filtered[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JurnalDetailPage(
                                  jurnal: jurnal,
                                  onUpdate: _refreshJurnals,
                                ),
                              ),
                            ).then(
                              (_) => _refreshJurnals(),
                            ); // Pastikan refresh saat kembali
                          },
                          child: Card(
                            elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                // Gambar dengan efek rounded corners
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                  child:
                                      jurnal.foto != null &&
                                          jurnal.foto!.isNotEmpty
                                      ? Image.network(
                                          jurnal.foto!,
                                          headers: {
                                            "ngrok-skip-browser-warning":
                                                "true",
                                            if (_token != null)
                                              'Authorization': 'Bearer $_token',
                                          },
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    width: 120,
                                                    height: 120,
                                                    color: Colors.grey[300],
                                                    child: Icon(
                                                      Icons.image_not_supported,
                                                      size: 40,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                        )
                                      : Container(
                                          width: 120,
                                          height: 120,
                                          color: Colors.grey[200],
                                          child: Icon(
                                            Icons.image,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                        ),
                                ),
                                // Konten Jurnal
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          jurnal.judul,
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          jurnal.deskripsi,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: Colors.grey[700],
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              size: 16,
                                              color: Colors.grey[500],
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              DateFormat(
                                                'HH:mm',
                                              ).format(jurnal.tanggal),
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: Colors.grey[500],
                                                  ),
                                            ),
                                            SizedBox(width: 16),
                                            Icon(
                                              Icons.calendar_today,
                                              size: 16,
                                              color: Colors.grey[500],
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              DateFormat(
                                                'dd MMM yyyy',
                                              ).format(jurnal.tanggal),
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: Colors.grey[500],
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return Center(child: Text('Tidak ada jurnal ditemukan.'));
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        tooltip: 'Tambah Jurnal',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateJurnalPage()),
          ).then((value) {
            if (value == true) {
              _refreshJurnals();
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
