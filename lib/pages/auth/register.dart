import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'login.dart';

class Register extends StatefulWidget {
  const Register({Key? key, required this.number}) : super(key: key);
  final String number;

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool visible = true;
  bool btnValid = false;
  String err = '';
  bool loading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cPasswordController = TextEditingController();

  final nameGlobalKey = GlobalKey<FormState>();
  final numberGlobalKey = GlobalKey<FormState>();
  final emailGlobalKey = GlobalKey<FormState>();
  final passwordGlobalKey = GlobalKey<FormState>();
  final cPasswordGlobalKey = GlobalKey<FormState>();

  void handleChange(GlobalKey<FormState> formState) {
    setState(() => err = '');
    final globalData = [
      nameGlobalKey.currentState!,
      numberGlobalKey.currentState!,
      emailGlobalKey.currentState!,
      passwordGlobalKey.currentState!,
      cPasswordGlobalKey.currentState!
    ];
    if (formState.currentState!.validate()) {
      formState.currentState!.save();
    }

    setState(
        () => btnValid = globalData.every((element) => element.validate()));
  }

  void register() async {
    if (btnValid) {
      setState(() => loading = true);
      final data = {
        "name": nameController.text,
        "phoneNumber": widget.number,
        "email": emailController.text,
        "password": passwordController.text,
        "confirmPassword": cPasswordController.text
      };
      final dio = Dio();
      Response response = await dio.post(
          'https://thoughtful-pullover-worm.cyclic.app/api/create/user',
          data: data);
      if (response.statusCode != 200) return;

      setState(() => loading = false);
      if (response.data['status'] == 'ok') {
        login();
      } else {
        setState(() => err = 'Email has already been used');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController numberController =
        TextEditingController(text: widget.number);

    final formData = [
      {
        "errMessage": 'Name must be at least 4 characters',
        "hintText": 'Enter your name',
        "controller": nameController,
        "formGlobalKey": nameGlobalKey,
        "onchange": (e) => handleChange(nameGlobalKey),
        "validate": (e) => e.length < 4,
        "isPassword": false
      },
      {
        "errMessage": 'Phone number must be 11 digits',
        "hintText": 'Enter phone number',
        "controller": numberController,
        "formGlobalKey": numberGlobalKey,
        "onchange": (e) => handleChange(numberGlobalKey),
        "validate": (e) => e.length != 11,
        "isPassword": false,
        "keyType": TextInputType.phone,
        "readOnly": true
      },
      {
        "errMessage": 'Invalid email address',
        "hintText": 'Enter email address',
        "controller": emailController,
        "formGlobalKey": emailGlobalKey,
        "onchange": (e) => handleChange(emailGlobalKey),
        "validate": (e) => !e.contains('@'),
        "isPassword": false,
        "keyType": TextInputType.emailAddress
      },
      {
        "errMessage": 'Password must be at lease 6 characters',
        "hintText": 'Enter password',
        "controller": passwordController,
        "formGlobalKey": passwordGlobalKey,
        "onchange": (e) => handleChange(passwordGlobalKey),
        "validate": (e) => e.length < 6,
        "isPassword": true
      },
      {
        "errMessage": 'Password does not match',
        "hintText": 'Confirm your password',
        "controller": cPasswordController,
        "formGlobalKey": cPasswordGlobalKey,
        "onchange": (e) => handleChange(cPasswordGlobalKey),
        "validate": (e) => e != passwordController.text,
        "isPassword": true
      },
    ];
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
            const SizedBox(height: 60),
            const Center(
              child: Text(
                'Register',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff309255)),
              ),
            ),
            Column(
              children: formData
                  .map((e) => myForm(
                      errMessage: e['errMessage'].toString(),
                      hintText: e['hintText'].toString(),
                      controller: e['controller'] as TextEditingController,
                      formGlobalKey: e['formGlobalKey'] as GlobalKey<FormState>,
                      onchange: e['onchange'] as Function,
                      validate: e['validate'] as Function,
                      isPassword: e['isPassword'] as bool,
                      keyType: e['keyType'] as TextInputType?,
                      readOnly: e['readOnly'] as bool?))
                  .toList(),
            ),
            const SizedBox(height: 30),
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
                  onPressed: () => register(),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Color(btnValid ? 0xff309255 : 0xffdddddd)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)))),
                  child: loading
                      ? const Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Register',
                          style: TextStyle(fontSize: 18),
                        )),
            )
          ],
        ),
      ),
    );
  }

  void login() => Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (builder) => const Login()));

  Widget myForm(
      {required String errMessage,
      required String hintText,
      required TextEditingController controller,
      required GlobalKey<FormState> formGlobalKey,
      required Function onchange,
      required Function validate,
      required bool isPassword,
      TextInputType? keyType,
      bool? readOnly}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Form(
        key: formGlobalKey,
        child: TextFormField(
          controller: controller,
          obscureText: isPassword ? visible : false,
          onChanged: (e) => onchange(e),
          validator: (pin) => validate(pin) ? errMessage : null,
          keyboardType: keyType ?? TextInputType.text,
          readOnly: readOnly ?? false,
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
                      const BorderSide(color: Color(0xff309255), width: 1))),
        ),
      ),
    );
  }
}
