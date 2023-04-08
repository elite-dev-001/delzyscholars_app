// import 'dart:convert';
import 'package:delzyscholars/pages/auth/login.dart';
import 'package:delzyscholars/pages/single_course.dart';
import 'package:intl/intl.dart';
import 'package:delzyscholars/pages/activate_page.dart';
import 'package:delzyscholars/pages/course_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.route, this.id}) : super(key: key);
  final String route;
  final String? id;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = false;
  List allMaterials = [];
  List currentMaterial = [];
  String? selectedLevel;
  String? selectedSemester;
  String? selectedCat;

  void getAllMaterials() async {
    selectedCat = widget.route;
    final dio = Dio();
    setState(() => isLoading = true);
    Response response = await dio.get(
        'https://thoughtful-pullover-worm.cyclic.app/api/materials/get/all/materials?category=${widget.route}');
    if (response.statusCode != 200) return;

    debugPrint(response.data.toString());
    setState(() => isLoading = false);
    allMaterials = response.data['results'];
  }

  Future refresh() async {
    final dio = Dio();
    Response response = await dio.get(
        'https://thoughtful-pullover-worm.cyclic.app/api/materials/get/all/materials?category=${widget.route}');
    if (response.statusCode != 200) return;

    setState(() => (allMaterials = response.data['results']));
  }

  final oCcy = NumberFormat("#,##0.00", "en_US");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllMaterials();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe7f8ee),
      appBar: AppBar(
        backgroundColor: const Color(0xff309255),
        title: Text(widget.route.isEmpty ? 'All Courses' : widget.route),
        centerTitle: true,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
      body: selectedLevel != null
          ? semesters()
          : (selectedCat == 'UNIPORT' ||
                  selectedCat == 'RSUST' ||
                  selectedCat == 'IAUE')
              ? levels()
              : Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                          backgroundColor: Color(0xff309255),
                          color: Colors.white,
                        ))
                      : RefreshIndicator(
                          onRefresh: refresh,
                          child: currentMaterial.isEmpty
                              ? Center(
                                  child: Text(
                                    'No Available Courses for ${widget.route} this Moment',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Color(0xff309255),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600),
                                  ),
                                )
                              : ListView(
                                  children: currentMaterial
                                      .map(
                                        (e) => material(
                                            e['courseImg'].toString(),
                                            e['author'].toString(),
                                            e['category'].toString(),
                                            e['title'].toString(),
                                            e['courseCode'].toString(),
                                            e['courseAmount'].toString(),
                                            e['_id'].toString(),
                                            e),
                                      )
                                      .toList(),
                                ),
                        ),
                ),
    );
  }

  final currentSemesters = [
    'SEMESTER 1',
    'SEMESTER 2',
  ];

  Widget semesters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: currentSemesters
                .map((e) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            selectedSemester = e;
                            // debugPrint(currentMaterial.toString());
                            setState(() {
                              currentMaterial = allMaterials
                                  .takeWhile((e) =>
                                      (e?['level'] == selectedLevel &&
                                          e?['semester'] == selectedSemester))
                                  .toList();
                              // debugPrint(currentMaterial.toString());
                              selectedLevel = null;
                              selectedCat = null;
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                const Color(0xff309255)),
                          ),
                          child: Text(e),
                        ),
                      ),
                    ))
                .toList()),
      ),
    );
  }

  final currentLevels = [
    'BASIC',
    'LEVEL 100',
    'LEVEL 200',
    'LEVEL 300',
    'LEVEL 400',
  ];

  Widget levels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: currentLevels
                .map((e) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedLevel = e;
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                const Color(0xff309255)),
                          ),
                          child: Text(e),
                        ),
                      ),
                    ))
                .toList()),
      ),
    );
  }

  void nextPage(value, String id, String title, List courses) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => value == true
                ? CoursePage(
                    courses: courses,
                    title: title,
                  )
                : ActivatePage(
                    materialId: id,
                    title: title,
                    courses: courses,
                  )));
  }

  void gotoLogin() => Navigator.push(
      context, MaterialPageRoute(builder: (builder) => const Login()));

  void gotoCourse(dynamic courses) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (builder) => SingleCourse(
                course: courses,
                id: widget.id,
              )));

  void checkLogin(dynamic course) async {
    final prefs = await SharedPreferences.getInstance();
    final bool? isLoggedIn = prefs.getBool('isLoggedIn');

    (isLoggedIn != null && isLoggedIn) ? gotoCourse(course) : gotoLogin();
  }

  Widget material(String img, String author, String cat, String title,
      String code, String price, String materialId, dynamic courses) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: GestureDetector(
        onTap: () => checkLogin(courses),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xff309255)),
              borderRadius: BorderRadius.circular(15)),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: Image.network(
                  img,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    author,
                    style: const TextStyle(
                        color: Color(0xff52565b),
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                  Container(
                    width: 80,
                    height: 35,
                    decoration: BoxDecoration(
                        color: const Color(0xffe7f8ee),
                        borderRadius: BorderRadius.circular(5)),
                    child: Center(
                      child: Text(
                        cat,
                        style: const TextStyle(
                            color: Color(0xff309255), fontSize: 14),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xff212832),
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
              const SizedBox(height: 20),
              Text(
                'Course Code: $code',
                style: const TextStyle(
                    color: Color(0xff52565b),
                    fontWeight: FontWeight.w500,
                    fontSize: 15),
              ),
              const SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: BoxDecoration(
                    color: const Color(0xffeefbf3),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(
                  '₦ ${oCcy.format(double.tryParse(price))}',
                  style: const TextStyle(
                      color: Color(0xff309255),
                      fontWeight: FontWeight.w700,
                      fontSize: 18),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/*async {
          final prefs = await SharedPreferences.getInstance();
          final bool? activated = prefs.getBool(materialId);

          nextPage(activated, materialId, title, courses);
        }*/
