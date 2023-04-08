import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class DownloadedVideo extends StatefulWidget {
  const DownloadedVideo({Key? key, required this.asset}) : super(key: key);
  final String asset;

  @override
  State<DownloadedVideo> createState() => _DownloadedVideoState();
}

class _DownloadedVideoState extends State<DownloadedVideo> {
  late VideoPlayerController _controller;
  late ChewieController chewieController;
  late Chewie playerWidget;

  @override
  void initState() {
    super.initState();
    File file = File(widget.asset);
    _controller = VideoPlayerController.file(file)
      ..addListener(() => setState(() {}))
      ..setLooping(true)
      ..initialize().then((_) => _controller.play());

    chewieController = ChewieController(
        videoPlayerController: _controller,
        showControls: true,
        looping: true,
        aspectRatio: 16 / 9,
        autoInitialize: true,
        autoPlay: true,
        fullScreenByDefault: true,
    );
    playerWidget = Chewie(controller: chewieController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe7f8ee),
      body: Center(
        child: _controller.value.isInitialized ? playerWidget : Container(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    chewieController.dispose();
  }
}

