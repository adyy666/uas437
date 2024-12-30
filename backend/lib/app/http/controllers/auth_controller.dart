import 'dart:io';
import 'package:backend/app/models/user.dart';
import 'package:vania/vania.dart';

class AuthController extends Controller {
  /// **Register Endpoint**
  Future<Response> register(Request request) async {
    try {
      // Validasi request
      request.validate({
        'name': 'required',
        'email': 'required|email',
        'password': 'required|min_length:6|confirmed',
      }, {
        'name.required': 'Nama tidak boleh kosong',
        'email.required': 'Email tidak boleh kosong',
        'email.email': 'Format email tidak valid',
        'password.required': 'Password tidak boleh kosong',
        'password.min_length': 'Password harus terdiri dari minimal 6 karakter',
        'password.confirmed': 'Konfirmasi password tidak sesuai',
      });

      // Ambil input dari request
      final name = request.input('name');
      final email = request.input('email');
      var password = request.input('password');

      // Cek apakah user dengan email tersebut sudah ada
      var user = await User().query().where('email', '=', email).first();
      if (user != null) {
        return Response.json({
          "message": "User sudah ada",
        }, 409);
      }

      // Hash password sebelum disimpan
      password = Hash().make(password);

      // Simpan user ke database
      await User().query().insert({
        "name": name,
        "email": email,
        "password": password,
        "created_at": DateTime.now().toIso8601String(),
      });

      // Response sukses
      return Response.json({"message": "Berhasil mendaftarkan user"}, 201);
    } catch (e, stackTrace) {
      // Logging error untuk debugging
      print("Error di register: $e");
      print("Stack trace: $stackTrace");

      return Response.json({
        "message": "Terjadi kesalahan pada server",
        "error": e.toString(),
      }, HttpStatus.internalServerError);
    }
  }

  /// **Login Endpoint**
  Future<Response> login(Request request) async {
    try {
      // Validasi request
      request.validate({
        'email': 'required|email',
        'password': 'required|min_length:6',
      }, {
        'email.required': 'Email tidak boleh kosong',
        'email.email': 'Format email tidak valid',
        'password.required': 'Password tidak boleh kosong',
        'password.min_length': 'Password harus terdiri dari minimal 6 karakter',
      });

      // Ambil input dari request
      final email = request.input('email');
      var password = request.input('password');

      // Cek apakah user dengan email tersebut ada
      var user = await User().query().where('email', '=', email).first();
      if (user == null) {
        return Response.json({
          "message": "User belum terdaftar",
        }, HttpStatus.unauthorized);
      }

      // Verifikasi password
      if (!Hash().verify(password, user['password'])) {
        return Response.json({
          "message": "Password yang Anda masukkan salah",
        }, HttpStatus.unauthorized);
      }

      // Generate token
      final token = await Auth()
          .login(user)
          .createToken(expiresIn: Duration(days: 30), withRefreshToken: true);

      // Response sukses dengan token
      return Response.json({
        "message": "Berhasil login",
        "token": token,
      });
    } catch (e, stackTrace) {
      // Logging error untuk debugging
      print("Error di login: $e");
      print("Stack trace: $stackTrace");

      return Response.json({
        "message": "Terjadi kesalahan pada server",
        "error": e.toString(),
      }, HttpStatus.internalServerError);
    }
  }
}

final AuthController authController = AuthController();
