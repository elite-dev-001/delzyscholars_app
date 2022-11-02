import 'dart:io';

import 'package:delzyscholars/pages/auth/login.dart';
import 'package:delzyscholars/pages/home.dart';
import 'package:delzyscholars/pages/myCourses.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nav.dart';

class Categories extends StatefulWidget {
  const Categories({
    Key? key,
  }) : super(key: key);

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  bool loading = false;
  dynamic data;
  String? _id;
  String? name;
  bool? loggedIn;

  Future<bool> leaveApp() => showDialog(
      context: context,
      builder: (builder) => AlertDialog(
            title: const Text('Do you want to Exit?'),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                      onPressed: () => exit(0),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red)),
                      child: const Text('Yes')),
                ),
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.green)),
                      child: const Text('No')),
                ),
              ],
            ),
          )) as Future<bool>;

  void getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('id');
    loggedIn = prefs.getBool('isLoggedIn');
    // prefs.remove('6351b145573a49634e4d469d');
    if (loggedIn != null && id != null) {
      setState(() => loading = true);
      _id = id;
      final dio = Dio();
      Response response = await dio
          .get('https://delzyscholarsapi.herokuapp.com/api/get/one/$id');
      if (response.statusCode != 200) return;
      setState(() => loading = false);

      debugPrint(response.data[0].toString());
      data = response.data[0];
      name = response.data[0]['name'];
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void login() => Navigator.push(
      context, MaterialPageRoute(builder: (builder) => const Login()));

  void myCourse() => Navigator.push(
      context, MaterialPageRoute(builder: (builder) => MyCourses(id: _id!)));

  void logOut() {
    loggedIn == null
        ? login()
        : showDialog(
            context: context,
            builder: (builder) => AlertDialog(
                  title: const Text('Are you sure you want to logout?',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff000000))),
                  content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: btns
                          .map((e) =>
                              logBtn(e['text'].toString(), e['color'] as Color))
                          .toList()),
                ));
  }

  final btns = [
    {'text': 'Cancel', 'color': const Color(0xffdb1f35)},
    {'text': 'Yes', 'color': const Color(0xff019a62)},
  ];

  Widget logBtn(String text, Color color) {
    return SizedBox(
      width: 110,
      child: ElevatedButton(
          onPressed: text.toLowerCase() == 'yes'
              ? () async {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.remove('isLoggedIn');
                  prefs.remove('id');
                  exit(0);
                }
              : () => Navigator.of(context).pop(context),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(color),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)))),
          child: Text(text)),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => leaveApp(),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: NavigationDrawer(
          logOut: logOut,
          scaffoldKey: _scaffoldKey,
          name: name,
          id: _id.toString(),
        ),
        backgroundColor: const Color(0xffe7f8ee),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            icon: const Icon(Icons.menu),
          ),
          title: const Text('Categories'),
          centerTitle: true,
          backgroundColor: const Color(0xff309255),
        ),
        body: loading
            ? const Align(
                child: CircularProgressIndicator(
                  color: Color(0xff309255),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(30.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 20,
                  children: categories.map((e) => card(e)).toList(),
                ),
              ),
      ),
    );
  }

  final categories = [
    'ALL COURSES',
    'My COURSES',
    'UNIPORT',
    'RSUST',
    'IAUE',
    'WAEC',
    'JAMB',
    'POST-UTME',
  ];

  Widget card(String text) {
    return GestureDetector(
      onTap: text.toLowerCase() == 'my courses'
          ? (loggedIn == null ? login : myCourse)
          : () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (builder) => Home(
                        route: text.toLowerCase() == 'all courses' ? '' : text,
                        id: _id,
                      ))),
      child: Container(
        decoration: const BoxDecoration(
            color: Color(0xff309255),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(3))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.school,
              color: Colors.white,
              size: 30,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              text,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
