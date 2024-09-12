import 'package:animate_do/animate_do.dart';
import 'package:belajar_flutter_perpus/view/auth/home_page.dart';
import 'package:belajar_flutter_perpus/view/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String sUrl = "http://perpus-api.mamorasoft.com/api/";
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _retypePasswordController =
      TextEditingController();
  bool visible = true;

  Future<void> _register() async {
    if (_nameController.text.isEmpty ||
        _userNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _retypePasswordController.text.isEmpty ||
        _passwordController.text != _retypePasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields correctly.")),
      );
      return;
    }

    var params = "register";
    var dio = Dio();
    try {
      setState(() {
        visible = false;
      });
      var response = await dio.post(sUrl + params, data: {
        'name': _nameController.text,
        'username': _userNameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'confirm_password': _retypePasswordController.text,
      });

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
      } else {
        var errorMessage = response.data['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage.toString())),
        );
      }
    } catch (e) {
      print('Error during registration: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred. Please try again.")),
      );
    } finally {
      setState(() {
        visible = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  FadeInUp(
                    duration: Duration(milliseconds: 1000),
                    child: Text(
                      "Daftar",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  FadeInUp(
                    duration: Duration(milliseconds: 1200),
                    child: Text(
                      "Daftar untuk membuat akun perpus anda",
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  FadeInUp(
                    duration: Duration(milliseconds: 1200),
                    child:
                        makeInput(controller: _nameController, label: "Name"),
                  ),
                  FadeInUp(
                    duration: Duration(milliseconds: 1300),
                    child: makeInput(
                        controller: _userNameController, label: "Username"),
                  ),
                  FadeInUp(
                    duration: Duration(milliseconds: 1400),
                    child:
                        makeInput(controller: _emailController, label: "Email"),
                  ),
                  FadeInUp(
                    duration: Duration(milliseconds: 1500),
                    child: makeInput(
                        controller: _passwordController,
                        label: "Password",
                        obscureText: true),
                  ),
                  FadeInUp(
                    duration: Duration(milliseconds: 1600),
                    child: makeInput(
                        controller: _retypePasswordController,
                        label: "Confirm Password",
                        obscureText: true),
                  ),
                ],
              ),
              FadeInUp(
                duration: Duration(milliseconds: 1700),
                child: Container(
                  padding: EdgeInsets.only(top: 3, left: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.black),
                  ),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: _register,
                    color: Colors.greenAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      "Daftar",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                  ),
                ),
              ),
              FadeInUp(
                duration: Duration(milliseconds: 1800),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Sudah memiliki Akun?"),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      },
                      child: Text(
                        " Masuk Sekarang",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget makeInput({controller, label, obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
        SizedBox(
          height: 5,
        ),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400)),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400)),
          ),
        ),
        SizedBox(
          height: 30,
        ),
      ],
    );
  }
}
