import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../database/dao/employee_dao.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();
  final EmployeeDao _employeeDao = EmployeeDao();

  bool _isCodeSent = false;
  String? _verificationCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/arrow_mm.png',
              height: 40,
              width: 40,
            ),
            SizedBox(width: 10),
            Text(
              'Login',
              style: TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
            ),
          ],
        ),
        backgroundColor: Color(0xFFAF2C3F),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 600;

          return isWideScreen
              ? Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              if (!_isCodeSent) ...[
                                _buildTextField(
                                  _emailController,
                                  'Email',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),
                                _buildTextField(
                                  _passwordController,
                                  'Password',
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        bool authenticated =
                                            await _employeeDao.authenticateUser(
                                          _emailController.text.toLowerCase(),
                                          _passwordController.text,
                                        );
                                        if (authenticated) {
                                          _verificationCode =
                                              _generateVerificationCode();
                                          await _sendVerificationCode(
                                              _emailController.text,
                                              _verificationCode!);
                                          await _employeeDao.saveVerificationCode(
                                            _emailController.text.toLowerCase(),
                                            _verificationCode!,
                                          );

                                          setState(() {
                                            _isCodeSent = true;
                                          });
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Invalid email or password')),
                                          );
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFAF2C3F),
                                      textStyle: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 18, // Increased font size
                                      ),
                                    ),
                                    child: Text('Login', style: TextStyle(fontFamily: 'Montserrat')),
                                  ),
                                ),
                              ] else ...[
                                _buildTextField(
                                  _codeController,
                                  'Verification Code',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the verification code';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        final code = await _employeeDao.getVerificationCode(
                                          _emailController.text.toLowerCase(),
                                        );

                                        if (code != null &&
                                            code.code == int.parse(_codeController.text) &&
                                            DateTime.now().difference(code.timestamp).inMinutes < 10) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => HomeScreen(
                                                  email: _emailController.text),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Invalid or expired verification code')),
                                          );
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFAF2C3F),
                                      textStyle: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 18, // Increased font size
                                      ),
                                    ),
                                    child: Text('Verify and Login', style: TextStyle(fontFamily: 'Montserrat')),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/MMLogo.jpg'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/MMLogo.jpg'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              if (!_isCodeSent) ...[
                                _buildTextField(
                                  _emailController,
                                  'Email',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),
                                _buildTextField(
                                  _passwordController,
                                  'Password',
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        bool authenticated =
                                            await _employeeDao.authenticateUser(
                                          _emailController.text.toLowerCase(),
                                          _passwordController.text,
                                        );
                                        if (authenticated) {
                                          _verificationCode =
                                              _generateVerificationCode();
                                          await _sendVerificationCode(
                                              _emailController.text,
                                              _verificationCode!);
                                          await _employeeDao.saveVerificationCode(
                                            _emailController.text.toLowerCase(),
                                            _verificationCode!,
                                          );

                                          setState(() {
                                            _isCodeSent = true;
                                          });
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Invalid email or password')),
                                          );
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFAF2C3F),
                                      textStyle: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 18, // Increased font size
                                      ),
                                    ),
                                    child: Text('Login', style: TextStyle(fontFamily: 'Montserrat')),
                                  ),
                                ),
                              ] else ...[
                                _buildTextField(
                                  _codeController,
                                  'Verification Code',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the verification code';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        final code = await _employeeDao.getVerificationCode(
                                          _emailController.text.toLowerCase(),
                                        );

                                        if (code != null &&
                                            code.code == int.parse(_codeController.text) &&
                                            DateTime.now().difference(code.timestamp).inMinutes < 10) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => HomeScreen(
                                                  email: _emailController.text),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Invalid or expired verification code')),
                                          );
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFAF2C3F),
                                      textStyle: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 18, // Increased font size
                                      ),
                                    ),
                                    child: Text('Verify and Login', style: TextStyle(fontFamily: 'Montserrat')),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFFAF2C3F), fontFamily: 'Montserrat'),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        obscureText: obscureText,
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              return null;
            },
        style: TextStyle(fontFamily: 'Montserrat'),
      ),
    );
  }

  String _generateVerificationCode() {
    final random = Random();
    final code = random.nextInt(900000) + 100000;
    return code.toString();
  }

  Future<void> _sendVerificationCode(String email, String code) async {
    final url = Uri.parse('http://localhost:3000/send-code');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );

    if (response.statusCode == 200) {
      print('Verification code sent: ${response.body}');
      print('Sending verification code $code to $email');
    } else {
      print('Error occurred while sending verification code: ${response.body}');
      print('Sending verification code $code to $email');
    }
  }
}
