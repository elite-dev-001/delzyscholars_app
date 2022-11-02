import 'package:delzyscholars/pages/pdf_viewer_page.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../api/pdf_api.dart';
import 'package:toast/toast.dart';

class Preview extends StatefulWidget {
  const Preview({Key? key, required this.courses, required this.title})
      : super(key: key);
  final List courses;
  final String title;

  @override
  State<Preview> createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {
  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
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
                  e['material'], e['status']))
              .toList(),
        ),
      ),
    );
  }

  Widget perCourse(int chapter, String topic, String url, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: ListTile(
        onTap: status.toLowerCase() == 'free'
            ? () async {
                final file = await PDFApi.loadNetwork(url);
                openPDF(context, file, topic);
              }
            : () => Toast.show(
                "Activate the course to have access to this material",
                duration: Toast.lengthLong),
        leading: Icon(
          status.toLowerCase() == 'free'
              ? Icons.lock_open_outlined
              : Icons.lock,
          color: Colors.white,
        ),
        title: Text(
          'Chapter ${chapter + 1}',
          style: const TextStyle(color: Colors.white),
        ),
        // dense: true,
        subtitle: Text(
          topic,
          style: const TextStyle(color: Color(0xffe7f8ee)),
        ),
        tileColor: const Color(0xff309255),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void openPDF(BuildContext context, File file, String topic) =>
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PDFViewerPage(
                file: file,
                topic: topic,
              )));
}
