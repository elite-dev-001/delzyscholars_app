import 'package:delzyscholars/api/pdf_api.dart';
import 'package:delzyscholars/pages/pdf_viewer_page.dart';
import 'package:delzyscholars/pages/video_app.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:loading_animation_widget/loading_animation_widget.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({Key? key, required this.courses, required this.title})
      : super(key: key);
  final List courses;
  final String title;

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  bool loading = false;

  void playVideo(String url, String topic) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VideoApp(
                  videoUrl: url,
                  topic: topic,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe7f8ee),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xff309255),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 30),
        child: ListView(
          children: widget.courses
              .map((e) => perCourse(widget.courses.indexOf(e), e['topic'],
                  e['material'], e['video']))
              .toList(),
        ),
      ),
    );
  }

  Widget perCourse(int chapter, String topic, String url, String videoUrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            border: Border.all(color: const Color(0xff309255), width: 5),
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(
              'Chapter ${chapter + 1} : $topic',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xff309255),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            ListTile(
              onTap: () => playVideo(videoUrl, topic),
              leading: const Icon(
                Icons.video_library_outlined,
                color: Colors.white,
              ),
              title: const Text(
                'Video Tutorial',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              // dense: true,
              // subtitle: Text(topic, style: const TextStyle(
              //     color: Color(0xffe7f8ee)
              // ),),
              tileColor: const Color(0xff309255),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            const SizedBox(
              height: 15,
            ),
            ListTile(
              onTap: () => loadPdf(url, topic),
              leading: const Icon(
                Icons.picture_as_pdf_outlined,
                color: Colors.white,
              ),
              title: const Text(
                'PDF Material',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              trailing: loading
                  ? LoadingAnimationWidget.threeArchedCircle(
                      color: Colors.white, size: 30)
                  : null,
              // dense: true,
              // subtitle: Text(topic, style: const TextStyle(
              //   color: Color(0xffe7f8ee)
              // ),),
              tileColor: const Color(0xff309255),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ],
        ),
      ),
    );
  }

  void loadPdf(String url, String topic) async {
    setState(() => loading = true);
    PDFApi.loadNetwork(url).then((file) {
      setState(() {
        loading = false;
        openPDF(context, file, topic, url);
      });
    });
  }

  void openPDF(BuildContext context, File file, String topic, String url) =>
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PDFViewerPage(
                file: file,
                topic: topic,
                pdfUrl: url,
              )));
}
