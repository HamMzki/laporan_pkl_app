import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:laporan_pkl_app/models/jurnal.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laporan_pkl_app/models/user.dart';

class ApiService {
  final String baseUrl = "https://jurnal-pkl-backend.infinityfreeapp.com/api";
  String? _token;

  //simpan token ke sharedpreference setelah login
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    _token = token;
  }

  //ambil token dari shared prefernces
  Future<String?> getToken() async {
    if (_token != null) {
      return _token; // Jika token sudah ada, langsung kembalikan
    }

    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    return _token;
  }

  //mendapdatkan data dari api
  Future<List<Jurnal>> getJurnals() async {
    // Try to get the authentication token
    final token = await getToken();
    // If no token is found, throw an exception
    if (token == null) {
      throw Exception('Tidak ada token ditemukan. Silakan login kembali.');
    }

    final uri = Uri.parse('$baseUrl/jurnals');
    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
      },
    );

    // Check if the response was successful (status code 200)
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Jurnal.fromJson(json)).toList();
    } else {
      // If the response was not successful, throw an exception with the status code
      throw Exception(
        'Gagal memuat jurnal. Status code: ${response.statusCode}. Response: ${response.body}',
      );
    }
  }

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      _token = responseData['access_token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
    } else {
      throw Exception('Login gagal. Periksa email dan password Anda.');
    }
  }

  Future<void> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Gagal mendaftar. Periksa kembali data Anda.');
    }
  }

  Future<Jurnal> createJurnal(
    String judul,
    String deskripsi,
    DateTime waktuKegiatan,
    File? fotoFile, {
    Uint8List? fotoBytes,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Autentikasi gagal. Silakan login kembali.');
    }

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/jurnals'));
    request.headers['Authorization'] = 'Bearer $token';

    final String tanggalFormatted = DateFormat(
      'yyyy-MM-dd HH:mm', // ganti format Y-m-d H:i ke yyyy-MM-dd HH:mm
    ).format(waktuKegiatan);

    // Tambahkan field
    request.fields['judul'] = judul;
    request.fields['deskripsi'] = deskripsi;
    request.fields['tanggal'] = tanggalFormatted;

    if (fotoFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'foto',
          fotoFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    } else if (fotoBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'foto',
          fotoBytes,
          filename: 'jurnal_photo.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    request.fields.forEach((key, value) {});

    var response = await request.send();

    // ===== PRINT RESPONSE =====
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      return Jurnal.fromJson(jsonDecode(responseBody));
    } else {
      throw Exception('Gagal membuat jurnal. Status: ${response.statusCode}');
    }
  }

  Future<Jurnal> updateJurnal(
    int id,
    String judul,
    String deskripsi,
    String tanggal,
    File? fotoFile, {
    Uint8List? fotoBytes,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Autentikasi gagal. Silakan login kembali.');
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/jurnals/$id'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'ngrok-skip-browser-warning': 'true',
      'Accept': 'application/json',
    });

    request.fields['_method'] = 'PUT';
    request.fields['judul'] = judul;
    request.fields['deskripsi'] = deskripsi;
    request.fields['tanggal'] = tanggal;
    if (fotoFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'foto',
          fotoFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    } else if (fotoBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'foto',
          fotoBytes,
          filename: 'jurnal_photo.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    try {
      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return Jurnal.fromJson(jsonDecode(responseBody));
      } else {
        String errorMessage =
            'Gagal memperbarui jurnal. Status: ${response.statusCode}';
        try {
          final errorData = jsonDecode(responseBody);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          } else if (errorData['errors'] != null) {
            final errors = errorData['errors'] as Map<String, dynamic>;
            errorMessage = errors.values.first.first.toString();
          }
        } catch (e) {
          errorMessage =
              'Gagal memperbarui jurnal. Respons server tidak valid.';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Gagal menghubungi server: ${e.toString()}');
    }
  }

  Future<void> deleteJurnal(int id) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Autentikasi gagal. Silakan login kembali.');
    }
    final response = await http.delete(
      Uri.parse('$baseUrl/jurnals/$id'),
      headers: <String, String>{'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus jurnal');
    }
  }

  Future<User> getUserProfile() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Autentikasi gagal. Silakan login kembali.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/user/'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Gagal mengambil data profil');
    }
  }

  Future<Map<String, dynamic>> updateUserProfile({
    File? fotoFile,
    Uint8List? fotoBytes,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/user/profile-photo'),
    );
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'ngrok-skip-browser-warning': 'true',
      'Accept': 'application/json',
    });

    if (fotoFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('photo', fotoFile.path),
      );
    } else if (fotoBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes('photo', fotoBytes, filename: 'photo.jpg'),
      );
    }

    // Tambahkan print untuk melihat URL yang dituju
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      final jsonResponse = jsonDecode(responseData.body);

      return jsonResponse;
    } else {
      final responseData = await http.Response.fromStream(response);

      throw Exception('Gagal mengunggah foto profil: ${responseData.body}');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _token = null;
  }
}
