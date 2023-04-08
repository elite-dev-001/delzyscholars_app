import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class VideoApp extends StatefulWidget {
  const VideoApp({Key? key, required this.videoUrl, required this.topic})
      : super(key: key);
  final String videoUrl;
  final String topic;

  @override
  State<VideoApp> createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;
  bool loading = false;
  bool downloaded = false;
  List<String> downloads = [];
  bool downloading = false;

  void getDownloads() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.remove('downloads');
    downloads = prefs.getStringList('downloads') ?? [];
    downloaded = prefs.getBool('videos${widget.topic}') ?? false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDownloads();
    setState(() => loading = true);
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) => {setState(() => loading = false)});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe7f8ee),
      appBar: AppBar(
        actions: [
          loading
              ? LoadingAnimationWidget.fourRotatingDots(color: Colors.white, size: 30)
              : downloaded
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(Icons.download_done_outlined),
                    )
                  : IconButton(
                      onPressed: () =>
                          downloadFile(widget.videoUrl, 'video${widget.topic}'),
                      icon: const Icon(Icons.download))
        ],
        backgroundColor: const Color(0xff309255),
        title: Text(widget.topic),
      ),
      body: downloading
          ? SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Column(
                      children: [
                        LoadingAnimationWidget.staggeredDotsWave(
                            color: const Color(0xff309255), size: 70),
                        const Text(
                          'Your Video is Downloading...',
                          style: TextStyle(
                              color: Color(0xff309255),
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: loading
                  ? const CircularProgressIndicator(
                      color: Color(0xff309255),
                    )
                  : _controller.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller))
                      : Container(),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff309255),
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child:
            Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
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
          prefs.setBool('videos${widget.topic}', true);
        });
        debugPrint('File downloaded successfully');
        final raf = file.openSync(mode: FileMode.write);
        raf.writeFromSync(response.data);
        await raf.close();

        final Map<String, dynamic> result = {
          'topic': widget.topic,
          'file': file.path,
          'type': 'video'
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }
}
