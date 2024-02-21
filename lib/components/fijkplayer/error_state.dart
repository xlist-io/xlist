import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fijkplayer/fijkplayer.dart';

import 'package:xlist/helper/index.dart';
import 'package:xlist/pages/video_player/index.dart';

const double barHeight = 50.0;

class ErrorState extends StatelessWidget {
  final FijkPlayer player;
  final String playerTitle;
  final bool single; // 是否是单页面视频播放

  const ErrorState({
    Key? key,
    required this.player,
    required this.playerTitle,
    this.single = true,
  }) : super(key: key);

  // 返回按钮
  Widget _buildTopBackBtn() {
    return IconButton(
      icon: Icon(CupertinoIcons.chevron_back),
      padding: EdgeInsets.only(
        left: 10.0,
        right: 10.0,
      ),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      color: Colors.white,
      onPressed: () => player.exitFullScreen(),
    );
  }

  // 可以共用的架子
  Widget _buildPublicFrameWidget({
    required Widget slot,
    Color? bgColor,
  }) {
    return Container(
      color: bgColor,
      child: Stack(
        children: [
          player.value.fullScreen
              ? Positioned(
                  left: 0,
                  top: 0,
                  right: 0,
                  child: Container(
                    height: barHeight,
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      height: barHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          _buildTopBackBtn(),
                          Expanded(
                            child: Container(
                              child: Text(
                                playerTitle,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Container(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: 0,
            child: Center(child: slot),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildPublicFrameWidget(
      bgColor: Colors.black,
      slot: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: 0,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 50, color: Colors.white),
                  SizedBox(height: 5),
                  ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      elevation: MaterialStateProperty.all(0),
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                    onPressed: () {
                      // 切换视频
                      final dataSource = player.dataSource!;
                      player.reset().then((value) async {
                        if (!single) player.setVolume(0.0);
                        final _vp = Get.find<VideoPlayerController>();
                        await FijkHelper.setFijkOption(
                          player,
                          headers: _vp.httpHeaders,
                        );
                        await player.setOption(
                          FijkOption.playerCategory,
                          'seek-at-start',
                          _vp.currentPos.value.inMilliseconds,
                        );
                        player.setDataSource(dataSource, autoPlay: true);
                      });
                    },
                    child: Text(
                      'fijkplayer_retry'.tr,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
