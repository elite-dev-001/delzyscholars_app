import 'dart:convert';
import 'dart:io';
import 'package:delzyscholars/pages/downloaded_video.dart';
import 'package:delzyscholars/pages/pdf_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Downloads extends StatefulWidget {
  const Downloads({Key? key}) : super(key: key);

  @override
  State<Downloads> createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  List<Map<String, dynamic>> videoDownloads = [];
  List<Map<String, dynamic>> pdfsDownloads = [];

  void getStringDownloads() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? stringDownloads = prefs.getStringList('downloads');

    if (stringDownloads != null) {
      for (var e in stringDownloads) {
        final Map<String, dynamic> decoded = json.decode(e);
        setState(() => decoded['type'] == 'video'
            ? videoDownloads.add(decoded)
            : pdfsDownloads.add(decoded));
      }
    } else {
      videoDownloads = [];
      pdfsDownloads = [];
    }
  }

  void playVideo(int index) {
    final asset = videoDownloads[index]['file'];
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => DownloadedVideo(asset: asset)));
  }

  void openPdf(int index) {
    final file = File(pdfsDownloads[index]['file']);
    final topic = pdfsDownloads[index]['topic'];
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PDFViewerPage(file: file, topic: topic)));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStringDownloads();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe7f8ee),
      appBar: AppBar(
        backgroundColor: const Color(0xff309255),
        title: const Text('Downloads'),
        elevation: 1.0,
      ),
      body: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * .06,
            child: Row(
                children:
                    texts.map((e) => myTabBar(e, texts.indexOf(e))).toList()),
          ),
          Padding(
              padding: const EdgeInsets.all(20.0),
              child: currentTab == 0
                  ? display(videoDownloads, 'Videos')
                  : display(pdfsDownloads, 'PDFs')),
        ],
      ),
    );
  }

  Widget display(List<Map<String, dynamic>> downloads, String text) {
    return Column(
      children: downloads.isEmpty
          ? [
              Center(
                child: Text('You have no downloaded $text'),
              )
            ]
          : downloads
              .map(
                (e) => ListTile(
                  onTap: () => currentTab == 0
                      ? playVideo(videoDownloads.indexOf(e))
                      : openPdf(pdfsDownloads.indexOf(e)),
                  leading: Icon(
                    currentTab == 0
                        ? Icons.video_library_outlined
                        : Icons.picture_as_pdf_outlined,
                    color: Colors.white,
                  ),
                  title: Text(
                    e['topic'],
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  tileColor: const Color(0xff309255),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              )
              .toList(),
    );
  }

  int currentTab = 0;
  List<String> texts = ['Videos', 'PDFs'];

  Widget myTabBar(String text, int index) {
    return GestureDetector(
      onTap: () => setState(() => currentTab = index),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        decoration: BoxDecoration(
            color: Color(currentTab == index ? 0xff309255 : 0xffffffff)),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(currentTab == index ? 0xffffffff : 0xff309255)),
          ),
        ),
      ),
    );
  }

// Future openFile({required String url}) async {
//   // OpenAppFile.open(url);
//   _controller = VideoPlayerController.asset(url);
// }
}
