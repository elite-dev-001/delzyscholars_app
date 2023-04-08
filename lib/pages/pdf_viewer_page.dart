import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:path/path.dart';

class PDFViewerPage extends StatefulWidget {
  const PDFViewerPage(
      {Key? key, required this.file, required this.topic, this.pdfUrl})
      : super(key: key);
  final File file;
  final String topic;
  final String? pdfUrl;

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  bool downloaded = false;
  List<String> downloads = [];
  bool downloading = false;

  void blockScreenShot() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  void getDownloads() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.remove('downloads');
    downloads = prefs.getStringList('downloads') ?? [];
    setState(() => downloaded = prefs.getBool('pdfs${widget.topic}') ?? false);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // blockScreenShot();
    getDownloads();
  }

  @override
  Widget build(BuildContext context) {
    // final name = basename(widget.file.path);

    return Scaffold(
      appBar: AppBar(
        actions: [
          downloading
              ? LoadingAnimationWidget.fourRotatingDots(color: Colors.white, size: 30)
              : downloaded
              ? const Padding(
            padding: EdgeInsets.all(12.0),
            child: Icon(Icons.download_done_outlined),
          )
              : IconButton(
              onPressed: () =>
                  downloadFile(widget.pdfUrl!, 'pdf${widget.topic}'),
              icon: const Icon(Icons.download))
        ],
        backgroundColor: const Color(0xff309255),
        title: Text(widget.topic),
      ),
      body: PDFView(
        filePath: widget.file.path,
      ),
    );
  }

  Future<void> downloadFile(String url, String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => downloading = true);
    try {
      final appStorage = await getApplicationDocumentsDirectory();
      final file = File('${appStorage.path}/$name');

      final response = await Dio().get(url,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            receiveTimeout: 0,
          ));

      if (response.statusCode == 200) {
        setState(() {
          downloading = false;
          downloaded = true;
          prefs.setBool('pdfs${widget.topic}', true);
        });
        debugPrint('File downloaded successfully');
        final raf = file.openSync(mode: FileMode.write);
        raf.writeFromSync(response.data);
        await raf.close();

        final Map<String, dynamic> result = {
          'topic': widget.topic,
          'file': file.path,
          'type': 'pdf'
        };
        downloads.add(json.encode(result));
        await prefs.setStringList('downloads', downloads);
      } else {
        setState(() => downloading = false);
        debugPrint('Could not download');
      }

      // return file;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

}
