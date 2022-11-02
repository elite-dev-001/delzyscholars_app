import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
// import 'package:path/path.dart';


class PDFViewerPage extends StatefulWidget {
  const PDFViewerPage({Key? key, required this.file, required this.topic}) : super(key: key);
  final File file;
  final String topic;

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {

  void blockScreenShot() async{
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    blockScreenShot();
  }

  @override
  Widget build(BuildContext context) {
    // final name = basename(widget.file.path);

    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xff309255),
        title: Text(widget.topic),
      ),
      body: PDFView(
        filePath: widget.file.path,
      ),
    );
  }
}
