import 'dart:developer';
import 'package:animate_do/animate_do.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:belajar_flutter_perpus/view/auth/home_page.dart';
import 'package:belajar_flutter_perpus/view/auth/sign_up.dart';
import 'package:belajar_flutter_perpus/view/bar/dashboard.dart';

class LoginPage extends StatefulWidget {
  final String? successMessage;

  LoginPage({this.successMessage});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Dio _dio = Dio();
  bool _isLoading = false;
  bool _obscureText = true;

  Future<void> _login() async {
    final String apiUrl = "http://perpus-api.mamorasoft.com/api/login";

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _dio.post(
        apiUrl,
        data: {
          "username": _usernameController.text,
          "password": _passwordController.text,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      var jsonResponse = response.data;
      log(jsonResponse.toString());

      if (jsonResponse['status'] == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userToken', jsonResponse['data']['token']);

        Navigator.pushReplacementNamed(
          context,
          '/dashboard',
          arguments: {
            'user': jsonResponse['data']['user'],
            'token': jsonResponse['data']['token'],
            'namaMember': jsonResponse['data']['user']['nama'],
            'memberId': jsonResponse['data']['user']['id'],
          },
        );
      } else {
        _showErrorDialog(
            'Login Gagal',
            jsonResponse['message'] ??
                'Terjadi kesalahan yang tidak diketahui');
      }
    } catch (e) {
      log('Error: $e');
      _showErrorDialog('Error', 'Terjadi kesalahan, silakan coba lagi nanti.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: TextStyle(color: Colors.blue[800])),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: Colors.blue[800])),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[300]!, Colors.blue[700]!],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  FadeInDown(
                    duration: Duration(milliseconds: 1000),
                    child: Text(
                      "Selamat Datang",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 60),
                  FadeInUp(
                    duration: Duration(milliseconds: 1200),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _usernameController,
                              label: "Username",
                              icon: Icons.person,
                            ),
                            SizedBox(height: 25),
                            _buildTextField(
                              controller: _passwordController,
                              label: "Password",
                              icon: Icons.lock,
                              isPassword: true,
                            ),
                            SizedBox(height: 40),
                            _buildLoginButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  FadeInUp(
                    duration: Duration(milliseconds: 1500),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Belum punya akun? ",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/signup'),
                          child: Text(
                            "Daftar",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscureText : false,
        style: TextStyle(fontSize: 16, color: Colors.blue[800]),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blue[600]),
          prefixIcon: Icon(icon, color: Colors.blue[600]),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.blue[600],
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _login,
      child: _isLoading
          ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
          : Text(
              "Masuk",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 8,
        shadowColor: Colors.blue[300],
        minimumSize: Size(double.infinity, 60),
      ),
    );
  }
}
