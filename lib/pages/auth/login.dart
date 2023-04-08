import 'package:delzyscholars/pages/auth/otp.dart';
import 'package:delzyscholars/pages/auth/register.dart';
import 'package:delzyscholars/pages/categories.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool loading = false;
  bool phoneReady = false;
  bool passReady = false;

  // bool active = phoneReady && passReady;
  String err = '';
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final formGlobalKey = GlobalKey<FormState>();
  final formGlobalKey2 = GlobalKey<FormState>();

  void login() async {
    setState(() => loading = true);
    if (phoneReady && passReady) {
      final data = {
        "phoneNumber": _phoneController.text,
        "password": _passwordController.text
      };
      final dio = Dio();
      Response response = await dio
          .post('https://thoughtful-pullover-worm.cyclic.app/api/login', data: data);
      if (response.statusCode != 200) return;

      setState(() => loading = false);

      if (response.data['status'] == 'ok') {
        if (response.data['role'] == 'user') {
          final prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLoggedIn', true);
          prefs.setString('id', response.data['id']);
          goHome();
        }
      } else {
        setState(() => err = response.data['error']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe7f8ee),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: Image.asset('images/logo2.png'),
            ),
            const SizedBox(height: 40),
            const Center(
              child: Text(
                'Login',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff309255)),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Column(
              children: formData
                  .map((e) => myForm(
                      errMessage: e['errMessage'].toString(),
                      hintText: e['hintText'].toString(),
                      isPassword: e['isPassword'] as bool))
                  .toList(),
            ),
            // const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Don\'t have an account?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  // onPressed: () => {},
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (builder) => const Register())),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                          color: Color(0xff309255),
                          fontWeight: FontWeight.bold),
                    ))
              ],
            ),
            const SizedBox(height: 0),
            Center(
              child: Text(
                err,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                  onPressed: () => login(),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Color(
                          (phoneReady && passReady) ? 0xff309255 : 0xffdddddd)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)))),
                  child: loading
                      ? const Align(
                    alignment: Alignment.center,
                          child: CircularProgressIndicator(
                          color: Colors.white,
                        ))
                      : const Text(
                          'Login',
                          style: TextStyle(fontSize: 18),
                        )),
            )
          ],
        ),
      ),
    );
  }

  void goHome() => Navigator.push(
      context, MaterialPageRoute(builder: (builder) => const Categories()));

  bool visible = true;

  void phone(String pin) {
    if (formGlobalKey.currentState!.validate()) {
      formGlobalKey.currentState!.save();
      setState(() => phoneReady = true);
    } else {
      setState(() => {phoneReady = false, err = ''});
    }
  }

  void password(String pin) {
    if (formGlobalKey2.currentState!.validate()) {
      formGlobalKey2.currentState!.save();
      setState(() => passReady = true);
    } else {
      setState(() => {passReady = false, err = ''});
    }
  }

  final formData = [
    {
      "errMessage": 'Phone number must be eleven digits',
      "hintText": "Enter phone number",
      "isPassword": false,
    },
    {
      "errMessage": 'Password must be at least six characters long',
      "hintText": "Enter your password",
      "isPassword": true,
    },
  ];

  Widget myForm(
      {required String errMessage,
      required String hintText,
      required bool isPassword}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Form(
        key: isPassword ? formGlobalKey2 : formGlobalKey,
        child: TextFormField(
          controller: isPassword ? _passwordController : _phoneController,
          obscureText: isPassword ? visible : false,
          onChanged: (e) => isPassword ? password(e) : phone(e),
          validator: (pin) => (isPassword ? pin!.length < 6 : pin!.length != 11)
              ? errMessage
              : null,
          keyboardType: isPassword ? TextInputType.text : TextInputType.phone,
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: hintText,
              labelText: hintText,
              labelStyle: const TextStyle(color: Color(0xff309255)),
              filled: true,
              suffixIcon: isPassword
                  ? IconButton(
                      onPressed: () => setState(() => visible = !visible),
                      icon: Icon(
                        visible ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xff309255),
                      ),
                    )
                  : null,
              fillColor: Colors.white,
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: Color(0xff309255), width: 2)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xff309255), width: 2))),
        ),
      ),
    );
  }
}
