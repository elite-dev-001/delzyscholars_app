import 'dart:async';
import 'package:delzyscholars/pages/auth/register.dart';
import 'package:random_string/random_string.dart';

// import 'dart:math' show Random;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class Otp extends StatefulWidget {
  const Otp({Key? key}) : super(key: key);

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  bool isLoading = false;
  bool linearLoading = false;
  String err = '';
  final TextEditingController _controller = TextEditingController();
  final formGlobalKey = GlobalKey<FormState>();
  bool sentOtp = false;
  var timer = 60;
  Object? data;
  bool phoneReady = false;
  var otpPin = randomNumeric(4);

  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final pinKey = GlobalKey<FormState>();

  void callTime() {
    Timer(const Duration(seconds: 1), () {
      if (timer != 0) {
        setState(() => timer -= 1);
        callTime();
      } else {
        setState(() => otpPin = randomNumeric(4));
      }
    });
  }

  void verifyNumber(String number) async {
    setState(() => linearLoading = true);
    final dio = Dio();
    Response response = await dio.post(
        'https://thoughtful-pullover-worm.cyclic.app/api/verify/user',
        data: {"phoneNumber": number});
    if (response.statusCode != 200) return;
    setState(() => linearLoading = false);

    if(response.data['status'] == 'ok'){
      setState(() => {phoneReady = true, err = ''});
    }else {
      setState(() => err = response.data['error']);
    }
  }

  void requestOtp() async {
    data = {
      'from': 'DelsApp',
      "to": '+234${_controller.text}',
      "body":
          'Your One Time Password is $otpPin. Don\'t share with anybody. Expires in 60 secs'
    };
    if (phoneReady) {
      setState(() => isLoading = true);
      final dio = Dio();
      Response response = await dio.post('https://connect.routee.net/sms', options: Options(
          headers: {
            'Authorization': 'Bearer b6574828-0d72-4925-baa9-10a4a4fb7425'
          }
      ), data: data);
      if (response.statusCode != 200) return;
      // debugPrint(response.toString());
      setState(() {
        isLoading = false;
        sentOtp = true;
        callTime();
      });
    }
  }

  void resend() {
    setState(() {
      timer = 60;
    });
    requestOtp();
    debugPrint(otpPin);
  }

  void putPin(String pin) {
    if (formGlobalKey.currentState!.validate()) {
      formGlobalKey.currentState!.save();
      verifyNumber(pin);
    } else {
      setState(() => phoneReady = false);
      setState(() => err = '');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    const borderColor = Color.fromRGBO(23, 171, 144, 0.4);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );
    return Scaffold(
      backgroundColor: const Color(0xffe7f8ee),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 45.0),
        child: ListView(
          children: [
            const Center(
              child: Text(
                'Verification',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff309255)),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Center(
                child: Text(
              sentOtp
                  ? 'Enter the code sent to the number\n${_controller.text}'
                  : 'Enter your eleven digits phone number to receive your One-Time Password',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w500, height: 1.5),
            )),
            const SizedBox(
              height: 60,
            ),
            sentOtp
                ? Form(
                    key: pinKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Directionality(
                            textDirection: TextDirection.ltr,
                            child: Pinput(
                              controller: pinController,
                              focusNode: focusNode,
                              androidSmsAutofillMethod:
                                  AndroidSmsAutofillMethod.smsRetrieverApi,
                              listenForMultipleSmsOnAndroid: true,
                              defaultPinTheme: defaultPinTheme,
                              validator: (value) =>
                                  value == otpPin ? null : 'Incorrect pin',
                              hapticFeedbackType:
                                  HapticFeedbackType.lightImpact,
                              onCompleted: (pin) {
                                pin == otpPin
                                    ? Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (builder) => Register(
                                                  number: _controller.text,
                                                )))
                                    : null;
                              },
                              cursor: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 9),
                                    width: 22,
                                    height: 1,
                                    color: focusedBorderColor,
                                  ),
                                ],
                              ),
                              focusedPinTheme: defaultPinTheme.copyWith(
                                decoration:
                                    defaultPinTheme.decoration!.copyWith(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: focusedBorderColor),
                                ),
                              ),
                              submittedPinTheme: defaultPinTheme.copyWith(
                                decoration:
                                    defaultPinTheme.decoration!.copyWith(
                                  color: fillColor,
                                  borderRadius: BorderRadius.circular(19),
                                  border: Border.all(color: focusedBorderColor),
                                ),
                              ),
                              errorPinTheme: defaultPinTheme.copyBorderWith(
                                border: Border.all(color: Colors.redAccent),
                              ),
                            )),
                        // TextButton(
                        //   onPressed: () => pinKey.currentState!.validate(),
                        //   child: const Text('Validate'),
                        // ),
                      ],
                    ),
                  )
                : myForm(),
            const SizedBox(height: 10,),
            linearLoading
                ? const Align(
                    alignment: Alignment.center,
                    child: LinearProgressIndicator(color: Color(0xff309255),),
                  )
                : Center(child: Text(err, style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w500
            ),)),
            const SizedBox(
              height: 30,
            ),
            timer == 0
                ? Column(
                    children: [
                      const Text('Didn\'t receive code?'),
                      isLoading
                          ? const CircularProgressIndicator(
                              color: Color(0xff309255),
                            )
                          : TextButton(
                              onPressed: () => resend(),
                              child: const Text(
                                'Resend',
                                style: TextStyle(color: Color(0xff309255)),
                              ))
                    ],
                  )
                : sentOtp
                    ? Center(
                        child: Text(
                            '00 : ${timer.toString().length == 1 ? '0$timer' : timer}'))
                    : SizedBox(
                        height: 50,
                        child: ElevatedButton(
                            onPressed: () => requestOtp(),
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Color(
                                        phoneReady ? 0xff309255 : 0xffdddddd)),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)))),
                            child: isLoading
                                ? const Align(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Request OTP',
                                    style: TextStyle(fontSize: 18),
                                  )),
                      )
          ],
        ),
      ),
    );
  }

  Widget myForm() {
    return Form(
      key: formGlobalKey,
      child: TextFormField(
        controller: _controller,
        onChanged: (e) => putPin(e),
        validator: (pin) =>
            pin!.length != 11 ? 'Phone number must be 11 digits' : null,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'Enter phone number',
            labelText: 'Enter phone number',
            labelStyle: const TextStyle(color: Color(0xff309255)),
            filled: true,
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
    );
  }
}
