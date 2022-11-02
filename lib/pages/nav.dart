import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class NavigationDrawer extends StatefulWidget {
  const NavigationDrawer(
      {Key? key, required this.logOut, required this.scaffoldKey, this.name, required this.id})
      : super(key: key);
  final Function logOut;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String? name;
  final String id;

  @override
  State<NavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  bool? loginState;

  void checkLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => loginState = prefs.getBool('isLoggedIn'));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLoginState();
  }

  @override
  Widget build(BuildContext context) {
    final myItems = [
      {
        'icon': Icons.shopping_cart,
        'text': 'My Courses',
      },
      {
        'icon': Icons.book,
        'text': 'All Courses',
      },
      {
        'icon': Icons.school,
        'text': 'Uniport',
      },
      {
        'icon': Icons.school,
        'text': 'RSUST',
      },
      {
        'icon': Icons.school,
        'text': 'IAUE',
      },
      {
        'icon': Icons.school,
        'text': 'WAEC',
      },
      {
        'icon': Icons.school,
        'text': 'JAMB',
      },
      {
        'icon': Icons.school,
        'text': 'POST-UTME',
      },
      {
        'icon':
            loginState == null ? Icons.login_outlined : Icons.logout_outlined,
        'text': loginState == null ? 'Login' : 'Logout',
      },
    ];
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        children: [
          Container(
            height: 170,
            width: MediaQuery.of(context).size.width,
            color: const Color(0xff309255),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.white,
                ),
                Text(
                  'Welcome ${widget.name ?? ''}',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 31, left: 25),
            child: Column(
              children: myItems
                  .map(
                      (e) => items(e['icon'] as IconData, e['text'].toString()))
                  .toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget items(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: GestureDetector(
        onTap: (text == 'Login' || text == 'Logout')
            ? () => {
                  widget.scaffoldKey.currentState?.closeDrawer(),
                  widget.logOut()
                }
            : () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (builder) => Home(
                  route: text.toLowerCase() == ('all courses') ||
                      text.toLowerCase() == ('my courses')
                      ? ''
                      : text,
                  id: widget.id,
                ))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(
              icon,
              color: const Color(0xff309255),
            ),
            const SizedBox(
              width: 13,
            ),
            Text(
              text,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff000000)),
            )
          ],
        ),
      ),
    );
  }
}
