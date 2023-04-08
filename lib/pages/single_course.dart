// import 'dart:convert';

import 'package:delzyscholars/pages/activate_page.dart';
import 'package:delzyscholars/pages/course_page.dart';

// import 'package:delzyscholars/pages/paystack/my_paystack.dart';
import 'package:delzyscholars/pages/preview.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_theoaks_paystack/flutter_theoaks_paystack.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:pay_with_paystack/pay_with_paystack.dart';

class SingleCourse extends StatefulWidget {
  const SingleCourse({Key? key, required this.course, this.id})
      : super(key: key);
  final dynamic course;
  final String? id;

  @override
  State<SingleCourse> createState() => _SingleCourseState();
}

class _SingleCourseState extends State<SingleCourse> {
  final plugin = PaystackPlugin();
  final oCcy = NumberFormat("#,##0.00", "en_US");
  bool? activated;

  final live = 'pk_live_6f16d735236a5774d9444768ec143fd99c87aea7';
  final test = 'pk_test_81b44119342883ffd970a7900732d9d6e00cd157';

  void getMaterialId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => activated = prefs.getBool(widget.course['_id']));
    debugPrint('activated: ${activated.toString()}');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMaterialId();
    plugin.initialize(
        publicKey: test);
  }

  @override
  Widget build(BuildContext context) {
    bool enrolled = List.from(widget.course['students']).contains(widget.id);
    debugPrint('enrolled: ${enrolled.toString()}');

    return Scaffold(
      backgroundColor: const Color(0xffe7f8ee),
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.4),
        child: SizedBox(
          // height: MediaQuery.of(context).size.height * 0.4,
          // width: MediaQuery.of(context).size.width,
          child: Image.network(widget.course['courseImg']),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: ListView(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * .55,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Course Code: ${widget.course['courseCode']}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff309255)),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(widget.course['title'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff309255))),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                            '₦ ${oCcy.format(double.tryParse(widget.course['courseAmount']))}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff309255))),
                      ],
                    ),
                    (!enrolled && activated == null)
                        ? Column(
                            children: btnData.map((e) => myBtn(e)).toList(),
                          )
                        : (enrolled && activated == null)
                            ? activation()
                            : gotoCourse()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  bool loading = false;

  Widget activation() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 14.0),
          child: Text(
              'You have enrolled for this class. Please '
              'proceed to the activation page to activate your material',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xff309255),
              )),
        ),
        myBtn('Pin Activation')
      ],
    );
  }

  Widget gotoCourse() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 14.0),
          child: Text(
              'Congratulations, your course has been '
              'activated successfully. You can now proceed to learn',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xff309255),
              )),
        ),
        SizedBox(
          height: 50,
          width: MediaQuery.of(context).size.width,
          child: ElevatedButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => CoursePage(
                          courses: widget.course['content'],
                          title: widget.course['title']))),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(const Color(0xff309255)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)))),
              child: const Text(
                'Proceed',
                style: TextStyle(fontSize: 18),
              )),
        )
      ],
    );
  }

  final btnData = ['Preview', 'Purchase Course'];

  void preview() => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (builder) => Preview(
              courses: widget.course['content'],
              title: widget.course['title'])));

  void pinPage({String? pin}) => Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (builder) => ActivatePage(
              pin: pin,
              materialId: widget.course['_id'],
              title: widget.course['title'],
              courses: widget.course['content'])));

  void purchaseCourse() async{
    setState(() => loading = true);
    final data = {"courseId": widget.course['_id']};
    final dio = Dio();
    Response response = await dio.patch('https://thoughtful-pullover-worm.cyclic.app/api/update/courses/${widget.id}', data: data);
    if(response.statusCode != 200) return;

    pinPage(pin: response.data['pin'].toString());
  }

  Widget myBtn(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: ElevatedButton(
            onPressed: text.toLowerCase() == 'preview'
                ? () => preview()
                : text.contains('Pin')
                    ? () => pinPage()
                    : () async {
                        final charge = Charge()
                          ..email = 'support@delzyscholars.com'
                          ..amount =
                              int.tryParse(widget.course['courseAmount'])! * 100
                          // ..accessCode = _makePaymentRequest('ref_${DateTime.now().millisecondsSinceEpoch}').toString()
                          ..reference =
                              'ref_${DateTime.now().millisecondsSinceEpoch}';
                        CheckoutResponse res = await plugin.checkout(context,
                            charge: charge,
                            method: CheckoutMethod.card,
                            fullscreen: true);
                        if (res.status) {
                          debugPrint('Charge was successful');
                          purchaseCourse();
                        } else {
                          debugPrint('Failed');
                        }
                      },
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(const Color(0xff309255)),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)))),
            child: (text != 'preview' && loading) ? const Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(color: Colors.white,),
            ) : Text(
              text,
              style: const TextStyle(fontSize: 18),
            )),
      ),
    );
  }
}

/**/

/*
                        PayWithPayStack().now(
                            context: context,
                            secretKey: 'sk_test_7c0fc28ca060d55b623f64938c72ba8267f22117',
                            customerEmail: 'wilsonchinedu001@gmail.com',
                            reference: DateTime.now().millisecondsSinceEpoch.toString(),
                            currency: 'NGN',
                            amount: (int.tryParse(widget.course['courseAmount'])! * 100).toString(),
                            transactionCompleted: pinPage,
                            transactionNotCompleted: (){
                              debugPrint('Failed');
                              Navigator.pop(context);
                            }
                        );
                      */
