import 'dart:ffi';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final XFile video;

  const CustomVideoPlayer({required this.video, super.key});

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController? videoController;
  Duration currentPosition = Duration();

  @override
  void initState() {
    super.initState();

    initializeController();
  }

  initializeController() async {
    videoController = VideoPlayerController.file(
      File(widget.video.path),
    );

    await videoController!.initialize();

    videoController!.addListener(() { //videoController 값이 변경될 때마다 실행.
      final currentPosition = videoController!.value.position;

      setState(() {
        this.currentPosition = currentPosition;
      });
    });
    //UI를 새로 빌드.
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    //VideoController가 null이면 로딩바를 띄운다.
    if (videoController == null) {
      return CircularProgressIndicator();
    }
    return AspectRatio(
        aspectRatio: videoController!.value.aspectRatio,
        child: Stack(
          children: [
            VideoPlayer(
                videoController!
            ),
            _Controls(
                onReversePressed: onReversePressed,
                onPlayPressed: onPlayPressed,
                onForwardPressed: onForwardPressed,
                isPlaying: videoController!.value.isPlaying,
            ),
            _NewVideo(
                onPressed: onNewVideoPressed
            ),
            _SliderBottom(
                currentPosition: currentPosition,
                maxPosition: videoController!.value.duration,
                onSliderChanged: onSliderChanged
            )
          ],
        )
    );
  }

  void onSliderChanged(double val) {
    videoController!.seekTo(
      Duration(
        seconds: val.toInt()
      )
    );
  }
  void onNewVideoPressed() {

  }

  void onReversePressed() {
    final currentPosition = videoController!.value.position;

    Duration position = Duration();

    if (currentPosition.inSeconds > 3) {
      position = currentPosition - Duration(seconds: 3);
    }
    videoController!.seekTo(position);
  }
  
  void onForwardPressed() {
    final maxPosition = videoController!.value.duration;
    final currentPosition = videoController!.value.position;

    Duration position = maxPosition;

    if ((maxPosition - Duration(seconds: 3)).inSeconds > currentPosition.inSeconds) {
      position = currentPosition + Duration(seconds: 3);
    }
    videoController!.seekTo(position);
  }

  void onPlayPressed() {
    // 이미 실행중 이면 중지 , 아니면 실행
    setState(() {
      if (videoController!.value.isPlaying) {
        videoController!.pause();
      } else {
        videoController!.play();
      }  
    });
  }
}

class _Controls extends StatelessWidget {
  final VoidCallback onPlayPressed;
  final VoidCallback onReversePressed;
  final VoidCallback onForwardPressed;
  final bool isPlaying;

  const _Controls({
      required this.onPlayPressed,
      required this.onForwardPressed,
      required this.onReversePressed,
      required this.isPlaying,
      super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(
      color: Colors.black.withOpacity(0.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          renderIconButton(
              onPressed: onReversePressed,
              iconData: Icons.rotate_left
          ),
          renderIconButton(
              onPressed: onPlayPressed,
              iconData: isPlaying ? Icons.pause : Icons.play_arrow
          ),
          renderIconButton(
              onPressed: onForwardPressed,
              iconData: Icons.rotate_right
          )
        ],
      ),
    );
  }

  Widget renderIconButton({
    required VoidCallback onPressed,
    required IconData iconData,
  }) {
    return IconButton(
        onPressed: onPressed,
        iconSize: 30.0,
        color: Colors.white,
        icon: Icon(
            iconData
        )
    );
  }
}

class _NewVideo extends StatelessWidget {
  final VoidCallback onPressed;

  const _NewVideo({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0, //오른쪽 끝에서부터 0픽셀만큼 이동
      child: IconButton(
          onPressed: onPressed,
          color: Colors.white,
          iconSize: 30.0,
          icon: Icon(
              Icons.photo_camera_back
          )
      ),
    );
  }
}

class _SliderBottom extends StatelessWidget {
  final Duration currentPosition;
  final Duration maxPosition;
  final ValueChanged<double> onSliderChanged;

  const _SliderBottom({required this.currentPosition, required this.maxPosition, required this.onSliderChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Text(
              "${currentPosition.inMinutes}:${(currentPosition.inSeconds % 60).toString().padLeft(2, "0")}",
              style: TextStyle(
                  color: Colors.white
              ),
            ),
            Expanded(
              child: Slider(
                value: currentPosition.inSeconds.toDouble(),
                onChanged: onSliderChanged,
                max: maxPosition.inSeconds.toDouble(),
                min: 0,//최대 길이
              ),
            ),
            Text(
              "${maxPosition.inMinutes}:${(maxPosition.inSeconds % 60).toString().padLeft(2, "0")}",
              style: TextStyle(
                  color: Colors.white
              ),
            )
          ],
        ),
      ),
    );
  }
}

