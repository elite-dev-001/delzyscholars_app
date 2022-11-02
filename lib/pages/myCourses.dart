import 'package:delzyscholars/pages/single_course.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';




class MyCourses extends StatefulWidget {
  const MyCourses({Key? key, required this.id}) : super(key: key);
  final String id;

  @override
  State<MyCourses> createState() => _MyCoursesState();
}

class _MyCoursesState extends State<MyCourses> {
  List myMaterials = [];
  bool isLoading = false;

  void getAllMaterials() async {
    final dio = Dio();
    setState(() => isLoading = true);
    Response response = await dio.get(
        'https://delzyscholarsapi.herokuapp.com/api/materials/get/all/materials');
    if (response.statusCode != 200) return;


    setState(() => isLoading = false);
    final allMaterials = List.from(response.data['results']);
    myMaterials = allMaterials.where((element) => element['students'].contains(widget.id)).toList();
    debugPrint(myMaterials.toString());
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
        title: const Text('My Courses'),
        centerTitle: true,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: isLoading
            ? const Center(
            child: CircularProgressIndicator(
              backgroundColor: Color(0xff309255),
              color: Colors.white,
            ))
            : myMaterials.isEmpty
                ? const Center(
              child: Text(
                'You have not purchased any course material at the moment',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xff309255),
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            )
                : ListView(
              children: myMaterials
                  .map(
                    (e) => material(
                    e['courseImg'].toString(),
                    e['author'].toString(),
                    e['category'].toString(),
                    e['title'].toString(),
                    e['courseCode'].toString(),
                    e['courseAmount'].toString(),
                    e['_id'].toString(),
                    e
                ),
              )
                  .toList(),
            ),
      ),
    );
  }


  void gotoCourse(dynamic courses) => Navigator.push(
      context, MaterialPageRoute(builder: (builder) => SingleCourse(course: courses, id: widget.id,)));


  Widget material(String img, String author, String cat, String title,
      String code, String price, String materialId, dynamic courses) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: GestureDetector(
        onTap: () => gotoCourse(courses),
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
                child: const Text(
                  'Go to Course',
                  style: TextStyle(
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
