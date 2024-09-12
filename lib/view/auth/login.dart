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
        // Save token to SharedPreferences
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
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Login Failed'),
              content:
                  Text(jsonResponse['message'] ?? 'Unknown error occurred'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      log('Error: $e');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred, please try again later.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
              (Route<dynamic> route) => false,
            );
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 20),
                    FadeInUp(
                      duration: Duration(milliseconds: 1000),
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    FadeInUp(
                      duration: Duration(milliseconds: 1200),
                      child: Text(
                        "Masukkan Akun Anda",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: <Widget>[
                          FadeInUp(
                            duration: Duration(milliseconds: 1200),
                            child: makeInput(
                              label: "Username",
                              controller: _usernameController,
                            ),
                          ),
                          FadeInUp(
                            duration: Duration(milliseconds: 1300),
                            child: makeInput(
                              label: "Password",
                              obscureText: true,
                              controller: _passwordController,
                            ),
                          ),
                          SizedBox(height: 10),
                          FadeInUp(
                            duration: Duration(milliseconds: 1400),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.only(top: 3, left: 3),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(color: Colors.black),
                                  ),
                                  child: MaterialButton(
                                    minWidth: 120,
                                    height: 50,
                                    onPressed: _login,
                                    color: Colors.greenAccent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: _isLoading
                                        ? CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          )
                                        : Text(
                                            "Login",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          FadeInUp(
                            duration: Duration(milliseconds: 1500),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("Belum Punya Akun?"),
                                SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/signup',
                                    );
                                  },
                                  child: Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget makeInput(
      {required String label,
      bool obscureText = false,
      required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
