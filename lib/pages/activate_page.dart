import 'package:delzyscholars/pages/course_page.dart';
// import 'package:delzyscholars/pages/preview.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivatePage extends StatefulWidget {
  const ActivatePage(
      {Key? key,
      this.pin,
      required this.materialId,
      required this.title,
      required this.courses})
      : super(key: key);
  final String materialId;
  final String title;
  final List courses;
  final String? pin;

  @override
  State<ActivatePage> createState() => _ActivatePageState();
}

class _ActivatePageState extends State<ActivatePage> {
  bool isLoading = false;
  String err = '';
  final TextEditingController _controller = TextEditingController();
  final formGlobalKey = GlobalKey<FormState>();

  void checkPin(String pin) async {
    debugPrint(pin);
    final dio = Dio();
    final data = {"activationPin": pin, "materialId": widget.materialId};
    Response response = await dio.patch(
        'https://delzyscholarsapi.herokuapp.com/api/activation/use/pin',
        data: data);
    debugPrint(response.data.toString());
    if (response.statusCode != 200) return;
    setState(() => isLoading = false);
    if (response.data['status'] != 'ok') {
      setState(() => err = response.data['message']);
    } else {
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool(widget.materialId, true);
      nextPage();
    }
  }

  void nextPage() => Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (builder) => CoursePage(
                courses: widget.courses,
                title: widget.title,
              )));

  void putPin(String pin) {
    if (formGlobalKey.currentState!.validate()) {
      formGlobalKey.currentState!.save();
      setState(() => isLoading = true);
      checkPin(pin);
    } else {
      setState(() => isLoading = false);
      setState(() => err = '');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.pin != null){
      _controller.text = widget.pin!;
      checkPin(widget.pin!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe7f8ee),
      appBar: AppBar(
        title: const Text('Activate your Material'),
        backgroundColor: const Color(0xff309255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Column(
                  children: [
                    const Text(
                      'Input your 8 digit activation pin to activate and have access to ',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Color(0xff309255),
                          fontWeight: FontWeight.w700,
                          fontSize: 18),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
                Column(
                  children: [
                    Form(
                      key: formGlobalKey,
                      child: TextFormField(
                        controller: _controller,
                        onChanged: (e) => putPin(e),
                        validator: (pin) =>
                            pin!.length != 8 ? 'Pin must be 8 digits' : null,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'Enter 8 digits Activation pin',
                            labelText: 'Enter 8 digits Activation Pin',
                            labelStyle:
                                const TextStyle(color: Color(0xff309255)),
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                    color: Color(0xff309255), width: 2)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Color(0xff309255), width: 2))),
                      ),
                    ),
                    isLoading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            child: Align(
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(
                                  backgroundColor: Color(0xff309255),
                                  color: Colors.white,
                                )),
                          )
                        : const SizedBox(
                            height: 10,
                          ),
                    Text(
                      err,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.red,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    )
                  ],
                ),
              ],
            ),
            // SizedBox(
            //   width: MediaQuery.of(context).size.width,
            //   height: 50,
            //   child: ElevatedButton(
            //     onPressed: () => Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (builder) => Preview(
            //                 courses: widget.courses, title: widget.title))),
            //     style: ButtonStyle(
            //         backgroundColor:
            //             MaterialStateProperty.all(const Color(0xff309255)),
            //         shape: MaterialStateProperty.all(RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(12)))),
            //     child: const Text('Preview Course'),
            //   ),
            // )
          ],
        ),
      ),
    );
  }

// String validate(String err) => err.length < 8 ? 'Pin must be 8 digits' : '';
}
