import 'dart:math';
import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';

import 'package:xlist/common/index.dart';
import 'package:xlist/services/index.dart';
import 'package:xlist/helper/fijk_helper.dart';
import 'package:xlist/pages/video_player/index.dart';
import 'package:xlist/components/fijkplayer/slider.dart';
import 'package:xlist/components/fijkplayer/error_state.dart';

double speed = 1.0;
const double barHeight = 50.0;

class FijkDefaultPanel extends StatefulWidget {
  final FijkPlayer player;
  final BuildContext buildContext;
  final Size viewSize;
  final Rect texturePos;
  final String playerTitle;
  final List<Subtitle> subtitles;
  final List<String> subtitleNameList;
  final List<Map<String, String>> audioTracks;
  final List<Map<String, String>> timedTextTracks;
  final bool showPlaylist;
  final bool showTimedText;

  const FijkDefaultPanel({
    required this.player,
    required this.buildContext,
    required this.viewSize,
    required this.texturePos,
    required this.playerTitle,
    required this.subtitles,
    required this.subtitleNameList,
    required this.audioTracks,
    required this.timedTextTracks,
    this.showPlaylist = false,
    this.showTimedText = true,
  });

  @override
  _FijkDefaultPanelState createState() => _FijkDefaultPanelState();
}

class _FijkDefaultPanelState extends State<FijkDefaultPanel>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  FijkPlayer get player => widget.player;
  Size get viewSize => widget.viewSize;
  Rect get texturePos => widget.texturePos;
  List<Subtitle> get subtitles => widget.subtitles;
  bool get showTimedText => widget.showTimedText;

  FijkState? _playerState;
  bool _isPlaying = false;

  Duration _currentPos = Duration();
  StreamSubscription? _currentPosSubs;

  // 是否显示各个组件
  bool _subtitleDrawerState = false;
  bool _audioDrawerState = false;
  bool _playlistDrawerState = false;

  AnimationController? _animationController;
  Animation<Offset>? _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );

    // init animation
    _animation = Tween(begin: Offset(1, 0), end: Offset.zero)
        .animate(_animationController!);

    // init plater state
    setState(() {
      _playerState = player.value.state;
    });
    if (player.value.duration.inMilliseconds > 0 && !_isPlaying) {
      setState(() {
        _isPlaying = true;
      });
    }

    // Listener
    _fijkValueListener();
    player.addListener(_fijkValueListener);
    _currentPosSubs = player.onCurrentPosUpdate.listen((v) {
      setState(() {
        _currentPos = v;
      });
    });
  }

  @override
  void dispose() {
    _currentPosSubs?.cancel();
    _animationController!.dispose();
    player.removeListener(_fijkValueListener);
    super.dispose();
  }

  // 获得播放器状态
  void _fijkValueListener() async {
    FijkValue value = player.value;

    if (value.duration.inMilliseconds > 0 && !_isPlaying) {
      setState(() {
        _isPlaying = true;
      });
    }

    setState(() {
      _playerState = value.state;
    });
  }

  // 切换字幕列表显示状态
  void changeSubtitleDrawerState(bool state) {
    if (state) {
      setState(() {
        _subtitleDrawerState = state;
      });
    }
    Future.delayed(Duration(milliseconds: 100), () {
      _animationController?.forward();
    });
  }

  // 切换音轨列表显示状态
  void changeAudioDrawerState(bool state) {
    if (state) {
      setState(() {
        _audioDrawerState = state;
      });
    }
    Future.delayed(Duration(milliseconds: 100), () {
      _animationController?.forward();
    });
  }

  // 切换播放列表显示状态
  void changePlaylistDrawerState(bool state) {
    if (state) {
      setState(() {
        _playlistDrawerState = state;
      });
    }
    Future.delayed(Duration(milliseconds: 100), () {
      _animationController?.forward();
    });
  }

  // 抽屉列表
  Widget _buildPublicDrawer(Widget child) {
    return Container(
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                await _animationController!.reverse();
                setState(() {
                  _subtitleDrawerState = false;
                  _audioDrawerState = false;
                  _playlistDrawerState = false;
                });
              },
            ),
          ),
          Container(
            child: SlideTransition(
              position: _animation!,
              child: Container(
                height: Get.height,
                width: 320,
                child: Scaffold(
                  backgroundColor: Colors.black.withOpacity(0.8),
                  appBar: AppBar(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    automaticallyImplyLeading: false,
                    elevation: 0.1,
                    actions: [
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () async {
                          await _animationController!.reverse();
                          setState(() {
                            _subtitleDrawerState = false;
                            _audioDrawerState = false;
                            _playlistDrawerState = false;
                          });
                        },
                      ),
                    ],
                  ),
                  body: Container(height: Get.height, child: child),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 字幕切换列表
  Widget _buildSubtitleList() {
    // 合并 subtitleNameList+timedTextTracks
    final _subtitleList = List<Map<String, String>>.empty(growable: true);
    widget.subtitleNameList.forEach((v) {
      _subtitleList.add({'label': v, 'key': v});
    });
    widget.timedTextTracks.forEach((v) {
      _subtitleList.add({
        'label': '${v['title']}(${v['language']})',
        'key': 'internal::${v['index']}',
      });
    });

    // 添加关闭字幕
    _subtitleList.add(
      {'label': 'fijkplayer_subtitle_close'.tr, 'key': 'close'},
    );

    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (context, index) => Divider(
        height: 0.5,
        indent: 10,
        endIndent: 10,
      ),
      itemCount: _subtitleList.length,
      itemBuilder: (context, index) {
        return CupertinoListTile(
          title: Container(
            child: Text(
              _subtitleList[index]['label'] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Get.textTheme.bodyLarge?.copyWith(
                color: _subtitleList[index]['key'] == 'close'
                    ? Colors.red
                    : Colors.white,
              ),
            ),
          ),
          onTap: () async {
            final value = _subtitleList[index]['key'];
            final videoPlayerController = Get.find<VideoPlayerController>();
            videoPlayerController.changeSubtitle(value: value);
            await _animationController!.reverse();
            Future.delayed(Duration(milliseconds: 500), () async {
              setState(() {
                _subtitleDrawerState = false;
              });
            });
          },
        );
      },
    );
  }

  // 音轨切换列表
  Widget _buildAudioList() {
    final _audioList = List<Map<String, String?>>.empty(growable: true);
    widget.audioTracks.forEach((v) {
      _audioList.add({
        'label': '${v['title']}(${v['language']})',
        'key': v['index'],
      });
    });

    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (context, index) => Divider(
        height: 0.5,
        indent: 10,
        endIndent: 10,
      ),
      itemCount: _audioList.length,
      itemBuilder: (context, index) {
        return CupertinoListTile(
          title: Container(
            child: Text(
              _audioList[index]['label'] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Get.textTheme.bodyLarge?.copyWith(
                color: _audioList[index]['key'] == 'close'
                    ? Colors.red
                    : Colors.white,
              ),
            ),
          ),
          onTap: () async {
            final value = _audioList[index]['key'];
            final videoPlayerController = Get.find<VideoPlayerController>();
            videoPlayerController.changeAudioTrack(value: value);
            await _animationController!.reverse();
            Future.delayed(Duration(milliseconds: 500), () async {
              setState(() {
                _audioDrawerState = false;
              });
            });
          },
        );
      },
    );
  }

  // 字幕
  Widget _buildSubtitle() {
    String timedText = '';
    if (showTimedText)
      timedText = player.value.timedText
          .replaceAll(RegExp(r'({.+?})'), '')
          .replaceAll('\\N', '\n')
          .trim();

    // 外挂的字幕
    final subtitle = subtitles.firstWhereOrNull(
      (s) => _currentPos >= s.startTime && _currentPos <= s.endTime,
    );
    if (subtitle != null && !showTimedText) timedText = subtitle.text;

    // 字幕样式
    final style = player.value.fullScreen || CommonUtils.isPad
        ? Get.textTheme.titleLarge
        : Get.textTheme.bodySmall;

    return Positioned(
      left: 0,
      right: 0,
      bottom: player.value.fullScreen ? 10 : 5,
      child: Center(
        child: Text(
          timedText,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: style?.copyWith(
            color: Colors.white,
            height: 1.3,
            fontFamily: 'PingFang SC',
            shadows: [
              Shadow(color: Colors.black38, offset: Offset(1, 1), blurRadius: 1)
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin
    Rect rect = player.value.fullScreen
        ? Rect.fromLTWH(
            0,
            0,
            widget.viewSize.width,
            widget.viewSize.height,
          )
        : Rect.fromLTRB(
            max(0.0, widget.texturePos.left),
            max(0.0, widget.texturePos.top),
            min(widget.viewSize.width, widget.texturePos.right),
            min(widget.viewSize.height, widget.texturePos.bottom),
          );

    List<Widget> ws = [];

    if (_playerState == FijkState.error) {
      ws.add(ErrorState(
        player: widget.player,
        playerTitle: widget.playerTitle,
      ));
    } else {
      ws.add(_buildSubtitle()); // 字幕

      // 抽屉组件 & 手势组件
      if (_subtitleDrawerState == true && widget.player.value.fullScreen) {
        ws.add(_buildPublicDrawer(_buildSubtitleList()));
      } else if (_audioDrawerState == true && widget.player.value.fullScreen) {
        ws.add(_buildPublicDrawer(_buildAudioList()));
      } else {
        ws.add(_buildGestureDetector(
          player: widget.player,
          texturePos: widget.texturePos,
          playerTitle: widget.playerTitle,
          viewSize: widget.viewSize,
          showNextEpisodeBtn: widget.showPlaylist,
          showSubtitleDrawerBtn: widget.subtitleNameList.isNotEmpty ||
              widget.timedTextTracks.isNotEmpty,
          showAudioDrawerBtn: widget.audioTracks.length > 1,
          showPlaylistDrawerBtn: false,
          changeSubtitleDrawerState: changeSubtitleDrawerState,
          changeAudioDrawerState: changeAudioDrawerState,
          changePlaylistDrawerState: changePlaylistDrawerState,
        ));
      }
    }

    return Positioned.fromRect(
      rect: rect,
      child: Stack(
        children: ws,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _buildGestureDetector extends StatefulWidget {
  final FijkPlayer player;
  final Size viewSize;
  final Rect texturePos;
  final String playerTitle;
  final bool showNextEpisodeBtn;
  final bool showSubtitleDrawerBtn;
  final bool showAudioDrawerBtn;
  final bool showPlaylistDrawerBtn;
  final Function changeSubtitleDrawerState;
  final Function changeAudioDrawerState;
  final Function changePlaylistDrawerState;

  _buildGestureDetector({
    Key? key,
    this.playerTitle = "",
    required this.player,
    required this.viewSize,
    required this.texturePos,
    required this.showNextEpisodeBtn,
    required this.showSubtitleDrawerBtn,
    required this.showAudioDrawerBtn,
    required this.showPlaylistDrawerBtn,
    required this.changeSubtitleDrawerState,
    required this.changeAudioDrawerState,
    required this.changePlaylistDrawerState,
  }) : super(key: key);

  @override
  _buildGestureDetectorState createState() => _buildGestureDetectorState();
}

class _buildGestureDetectorState extends State<_buildGestureDetector> {
  FijkPlayer get player => widget.player;

  Duration _duration = Duration();
  Duration _currentPos = Duration();
  Duration _bufferPos = Duration();

  // 滑动后值
  Duration _dargPos = Duration();

  bool _isTouch = false;

  bool _playing = false;
  bool _prepared = false;
  String? _exception;

  double? updatePrevDx;
  double? updatePrevDy;
  int? updatePosX;

  bool? isDargVerLeft;

  double? updateDargVarVal;

  bool varTouchInitSuc = false;

  bool _buffering = false;

  double _seekPos = -1.0;

  StreamSubscription? _currentPosSubs;
  StreamSubscription? _bufferPosSubs;
  StreamSubscription? _bufferingSubs;

  Timer? _hideTimer;
  bool _hideStuff = true;

  bool _hideSpeedStu = true;
  double _speed = speed;

  bool _isHorizontalMove = false;

  Map<String, double> speedList = {
    "2.0": 2.0,
    "1.8": 1.8,
    "1.5": 1.5,
    "1.2": 1.2,
    "1.0": 1.0,
  };

  // 初始化构造函数
  _buildGestureDetectorState();

  void initEvent() {
    _duration = player.value.duration;
    _currentPos = player.currentPos;
    _bufferPos = player.bufferPos;
    _prepared = player.state.index >= FijkState.prepared.index;
    _playing = player.state == FijkState.started;
    _exception = player.value.exception.message;
    _buffering = player.isBuffering;

    // 设置初始化的值，全屏与半屏切换后，重设
    setState(() {
      _speed = player.value.speed;
      // 每次重绘的时候，判断是否已经开始播放
      _hideStuff = !_playing ? false : true;
    });
    // 延时隐藏
    _startHideTimer();
  }

  @override
  void dispose() {
    super.dispose();
    _hideTimer?.cancel();

    player.removeListener(_playerValueChanged);
    _currentPosSubs?.cancel();
    _bufferPosSubs?.cancel();
    _bufferingSubs?.cancel();
  }

  @override
  void initState() {
    super.initState();

    initEvent();

    player.addListener(_playerValueChanged);

    _currentPosSubs = player.onCurrentPosUpdate.listen((v) {
      setState(() {
        _currentPos = v;
        // 后加入，处理fijkplay reset后状态对不上的bug，
        _playing = true;
        _prepared = true;
        _buffering = false;
      });
    });

    _bufferPosSubs = player.onBufferPosUpdate.listen((v) {
      setState(() {
        _bufferPos = v;
      });
    });

    final audioHandler = PlayerNotificationService.to.audioHandler;
    _bufferingSubs = player.onBufferStateUpdate.listen((v) {
      if (_prepared) {
        Future.delayed(Duration(milliseconds: 1000), () {
          audioHandler.updatePlaybackState(player);
        });
      }

      setState(() {
        _buffering = v;
      });
    });
  }

  void _playerValueChanged() async {
    FijkValue value = player.value;
    if (value.duration != _duration) {
      setState(() {
        _duration = value.duration;
      });
    }
    print('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
    print('++++++++ 是否开始播放 => ${value.state == FijkState.started} ++++++++');
    print('+++++++++++++++++++ 播放器状态 => ${value.state} ++++++++++++++++++++');
    print('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
    // 新状态
    bool playing = value.state == FijkState.started;
    bool prepared = value.prepared;
    String? exception = value.exception.message;
    // 状态不一致，修改
    if (playing != _playing ||
        prepared != _prepared ||
        exception != _exception) {
      setState(() {
        _playing = playing;
        _prepared = prepared;
        _exception = exception;
      });
    }
  }

  /// 长按屏幕快进
  ///
  /// [detills] 事件
  _onLongPressStart(LongPressStartDetails detills) {
    double clientW = widget.viewSize.width;
    double curTouchPosX = detills.globalPosition.dx;
    final isLeft = (curTouchPosX > (clientW / 2)) ? false : true; // 是否左边
    player.setSpeed(_speed * 3.0);
    setState(() {
      _hideTimer?.cancel();
      _hideStuff = false;
      _hideSpeedStu = true;
    });
  }

  _onLongPressEnd(LongPressEndDetails detills) {
    player.setSpeed(_speed);
    setState(() {
      _hideStuff = true;
      _hideSpeedStu = true;
    });
  }

  _onHorizontalDragStart(detills) {
    setState(() {
      updatePrevDx = detills.globalPosition.dx;
      updatePosX = _currentPos.inMilliseconds;
    });
  }

  _onHorizontalDragUpdate(detills) {
    double curDragDx = detills.globalPosition.dx;
    // 确定当前是前进或者后退
    int cdx = curDragDx.toInt();
    int pdx = updatePrevDx!.toInt();
    bool isBefore = cdx > pdx;

    // 计算手指滑动的比例
    int newInterval = pdx - cdx;
    double playerW = MediaQuery.of(context).size.width;
    int curIntervalAbs = newInterval.abs();
    double movePropCheck = (curIntervalAbs / playerW) * 100 * 0.3;

    // 计算进度条的比例
    double durProgCheck = _duration.inMilliseconds.toDouble() / 100;
    int checkTransfrom = (movePropCheck * durProgCheck).toInt();
    int dragRange =
        isBefore ? updatePosX! + checkTransfrom : updatePosX! - checkTransfrom;

    // 是否溢出 最大
    int lastSecond = _duration.inMilliseconds;
    if (dragRange >= _duration.inMilliseconds) {
      dragRange = lastSecond;
    }
    // 是否溢出 最小
    if (dragRange <= 0) {
      dragRange = 0;
    }
    //
    this.setState(() {
      _isHorizontalMove = true;
      _hideStuff = false;
      _isTouch = true;
      // 更新下上一次存的滑动位置
      updatePrevDx = curDragDx;
      // 更新时间
      updatePosX = dragRange.toInt();
      _dargPos = Duration(milliseconds: updatePosX!.toInt());
    });
  }

  _onHorizontalDragEnd(detills) {
    if (_duration.inMilliseconds != 0) player.seekTo(_dargPos.inMilliseconds);
    this.setState(() {
      _isHorizontalMove = false;
      _isTouch = false;
      _hideStuff = true;
      _currentPos = _dargPos;
    });
  }

  _onVerticalDragStart(detills) async {
    double clientW = widget.viewSize.width;
    double curTouchPosX = detills.globalPosition.dx;

    setState(() {
      // 更新位置
      updatePrevDy = detills.globalPosition.dy;
      // 是否左边
      isDargVerLeft = (curTouchPosX > (clientW / 2)) ? false : true;
    });
    // 大于 右边 音量 ， 小于 左边 亮度
    if (!isDargVerLeft!) {
      // 音量
      await FijkVolume.getVol().then((double v) {
        varTouchInitSuc = true;
        setState(() {
          updateDargVarVal = v;
        });
      });
    } else {
      // 亮度
      await FijkPlugin.screenBrightness().then((double v) {
        varTouchInitSuc = true;
        setState(() {
          updateDargVarVal = v;
        });
      });
    }
  }

  _onVerticalDragUpdate(detills) {
    if (!varTouchInitSuc) return null;
    double curDragDy = detills.globalPosition.dy;
    // 确定当前是前进或者后退
    int cdy = curDragDy.toInt();
    int pdy = updatePrevDy!.toInt();
    bool isBefore = cdy < pdy;
    // + -, 不满足, 上下滑动合法滑动值，> 3
    if (isBefore && pdy - cdy < 3 || !isBefore && cdy - pdy < 3) return null;
    // 区间
    double dragRange =
        isBefore ? updateDargVarVal! + 0.03 : updateDargVarVal! - 0.03;
    // 是否溢出
    if (dragRange > 1) {
      dragRange = 1.0;
    }
    if (dragRange < 0) {
      dragRange = 0.0;
    }
    setState(() {
      updatePrevDy = curDragDy;
      varTouchInitSuc = true;
      updateDargVarVal = dragRange;
      // 音量
      if (!isDargVerLeft!) {
        FijkVolume.setVol(dragRange);
      } else {
        FijkPlugin.setScreenBrightness(dragRange);
      }
    });
  }

  _onVerticalDragEnd(detills) {
    setState(() {
      varTouchInitSuc = false;
    });
  }

  void _playOrPause() {
    if (_playing == true) {
      player.pause();
    } else {
      player.start();
    }
  }

  void _cancelAndRestartTimer() {
    if (_hideStuff == true) {
      _startHideTimer();
    }

    setState(() {
      _hideStuff = !_hideStuff;
      if (_hideStuff == true) {
        _hideSpeedStu = true;
      }
    });
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      setState(() {
        _hideStuff = true;
        _hideSpeedStu = true;
      });
    });
  }

  // 底部控制栏 - 播放按钮
  Widget _buildPlayStateBtn(IconData iconData, Function cb) {
    return Ink(
      child: InkWell(
        onTap: () => cb(),
        child: Container(
          height: 30,
          child: Padding(
            padding: EdgeInsets.only(left: 5, right: 5),
            child: Icon(
              iconData,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // 控制器ui 底部
  Widget _buildBottomBar(BuildContext context) {
    // 计算进度时间
    double duration = _duration.inMilliseconds.toDouble();
    double currentValue = _seekPos > 0
        ? _seekPos
        : (_isHorizontalMove
            ? _dargPos.inMilliseconds.toDouble()
            : _currentPos.inMilliseconds.toDouble());
    currentValue = min(currentValue, duration);
    currentValue = max(currentValue, 0);

    // 计算缓存进度
    double cacheValue = _bufferPos.inMilliseconds.toDouble();
    cacheValue = min(cacheValue, duration);
    cacheValue = max(cacheValue, 0);

    // 计算底部吸底进度
    double curConWidth = MediaQuery.of(context).size.width;
    if (CommonUtils.isPad &&
        MediaQuery.of(context).orientation == Orientation.landscape) {
      curConWidth = 780.w;
    }

    double curTimePro = (currentValue / duration) * 100;
    double curBottomProW = (curConWidth / 100) * curTimePro;

    return Container(
      height: barHeight,
      child: Stack(
        children: [
          // 底部UI控制器
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedOpacity(
              opacity: _hideStuff ? 0.0 : 0.8,
              duration: Duration(milliseconds: 400),
              child: Container(
                height: barHeight,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color.fromRGBO(0, 0, 0, 0),
                      Color.fromRGBO(0, 0, 0, 0.4),
                    ],
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 7),
                    // 按钮 - 播放/暂停
                    _buildPlayStateBtn(
                      _playing
                          ? CupertinoIcons.pause_fill
                          : CupertinoIcons.play_fill,
                      _playOrPause,
                    ),
                    // 已播放时间
                    Padding(
                      padding: EdgeInsets.only(right: 5.0, left: 5),
                      child: Text(
                        '${FijkHelper.formatDuration(_currentPos)}',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // 播放进度 if 没有开始播放 占满，空ui， else fijkSlider widget
                    _duration.inMilliseconds == 0
                        ? Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: 5, left: 5),
                              child: NewFijkSlider(
                                colors: NewFijkSliderColors(
                                  cursorColor: Get.theme.primaryColor,
                                  playedColor: Get.theme.primaryColor,
                                ),
                                onChangeEnd: (double value) {},
                                value: 0,
                                onChanged: (double value) {},
                              ),
                            ),
                          )
                        : Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: 5, left: 5),
                              child: NewFijkSlider(
                                colors: NewFijkSliderColors(
                                  cursorColor: Get.theme.primaryColor,
                                  playedColor: Get.theme.primaryColor,
                                ),
                                value: currentValue,
                                cacheValue: cacheValue,
                                min: 0.0,
                                max: duration,
                                onChanged: (v) {
                                  _startHideTimer();
                                  setState(() {
                                    _seekPos = v;
                                  });
                                },
                                onChangeEnd: (v) {
                                  setState(() {
                                    player.seekTo(v.toInt());
                                    print("seek to $v");
                                    _currentPos = Duration(
                                        milliseconds: _seekPos.toInt());
                                    _seekPos = -1;
                                  });
                                },
                              ),
                            ),
                          ),
                    // 总播放时间
                    _duration.inMilliseconds == 0
                        ? Container(
                            child: const Text(
                              "00:00",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.only(right: 5.0, left: 5),
                            child: Text(
                              '${FijkHelper.formatDuration(_duration)}',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                    // 切换字幕按钮
                    widget.player.value.fullScreen &&
                            widget.showSubtitleDrawerBtn
                        ? Ink(
                            padding: EdgeInsets.all(5),
                            child: InkWell(
                              onTap: () {
                                widget.changeSubtitleDrawerState(true);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: 40,
                                height: 30,
                                child: Text(
                                  'fijkplayer_subtitle'.tr,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    // 切换音轨按钮
                    widget.player.value.fullScreen && widget.showAudioDrawerBtn
                        ? Ink(
                            padding: EdgeInsets.all(5),
                            child: InkWell(
                              onTap: () {
                                widget.changeAudioDrawerState(true);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: 40,
                                height: 30,
                                child: Text(
                                  'fijkplayer_audio_track'.tr,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    // 下一集
                    widget.showNextEpisodeBtn && widget.player.value.fullScreen
                        ? Ink(
                            padding: EdgeInsets.all(5),
                            child: InkWell(
                              onTap: () {
                                final _vp = Get.find<VideoPlayerController>();
                                _vp.currentIndex.value == _vp.objects.length - 1
                                    ? _vp.changePlaylist(0)
                                    : _vp.changePlaylist(
                                        _vp.currentIndex.value + 1);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: 45,
                                height: 30,
                                child: Text(
                                  'fijkplayer_next'.tr,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    // 倍数按钮
                    widget.player.value.fullScreen
                        ? Ink(
                            padding: EdgeInsets.all(5),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _hideSpeedStu = !_hideSpeedStu;
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: 40,
                                height: 30,
                                child: Text(
                                  _speed.toString() + " X",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    // 按钮 - 全屏/退出全屏
                    _buildPlayStateBtn(
                      widget.player.value.fullScreen
                          ? Icons.fullscreen_exit
                          : Icons.fullscreen,
                      () {
                        if (widget.player.value.fullScreen) {
                          player.exitFullScreen();
                        } else {
                          player.enterFullScreen();
                          widget.changeSubtitleDrawerState(false);
                          widget.changeAudioDrawerState(false);
                          widget.changePlaylistDrawerState(false);
                        }
                      },
                    ),
                    SizedBox(width: 7),
                    //
                  ],
                ),
              ),
            ),
          ),
          // 隐藏进度条，ui隐藏时出现
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _hideStuff &&
                    _duration.inMilliseconds != 0 &&
                    !player.value.fullScreen
                ? Container(
                    alignment: Alignment.bottomLeft,
                    height: 1.5,
                    color: Colors.transparent,
                    child: Container(
                      color: Get.theme.primaryColor,
                      width: curBottomProW is double ? curBottomProW : 0,
                      height: 1.5,
                    ),
                  )
                : Container(),
          )
        ],
      ),
    );
  }

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

  // 播放器顶部 返回 + 标题
  Widget _buildTopBar() {
    return AnimatedOpacity(
      opacity: _hideStuff ? 0.0 : 0.8,
      duration: Duration(milliseconds: 400),
      child: Container(
        height: barHeight,
        alignment: Alignment.bottomLeft,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomLeft,
            colors: [
              Color.fromRGBO(0, 0, 0, 0.5),
              Color.fromRGBO(0, 0, 0, 0),
            ],
          ),
        ),
        child: Container(
          height: barHeight,
          child: Row(
            children: <Widget>[
              _buildTopBackBtn(),
              Expanded(
                child: Container(
                  child: Text(
                    widget.playerTitle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // 居中播放按钮
  Widget _buildCenterPlayBtn() {
    return Container(
      color: Colors.transparent,
      height: double.infinity,
      width: double.infinity,
      child: Center(
        child: (_prepared && !_buffering) ||
                player.state == FijkState.initialized
            ? AnimatedOpacity(
                opacity: _hideStuff ? 0.0 : 0.7,
                duration: Duration(milliseconds: 400),
                child: GestureDetector(
                  child: Container(
                    height: 50.0,
                    width: 50.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey[800]?.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Icon(
                      _playing
                          ? CupertinoIcons.pause_fill
                          : CupertinoIcons.play_fill,
                      color: Colors.white,
                      size: 30.0,
                    ),
                  ),
                  onTap: _playOrPause,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: barHeight * (player.value.fullScreen ? 0.6 : 0.5),
                    height: barHeight * (player.value.fullScreen ? 0.6 : 0.5),
                    child: CircularProgressIndicator(
                      strokeWidth: 3.0,
                      valueColor:
                          AlwaysStoppedAnimation(Colors.white.withOpacity(0.7)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // build 滑动进度时间显示
  Widget _buildDargProgressTime() {
    return _isTouch
        ? Container(
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(5),
              ),
              color: Color.fromRGBO(0, 0, 0, 0.8),
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Text(
                '${FijkHelper.formatDuration(_dargPos)} / ${FijkHelper.formatDuration(_duration)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          )
        : Container();
  }

  // build 显示垂直亮度，音量
  Widget _buildDargVolumeAndBrightness() {
    // 不显示
    if (!varTouchInitSuc) return Container();

    IconData iconData;
    // 判断当前值范围，显示的图标
    if (updateDargVarVal! <= 0) {
      iconData = !isDargVerLeft!
          ? CupertinoIcons.volume_mute
          : CupertinoIcons.brightness_solid;
    } else if (updateDargVarVal! < 0.5) {
      iconData = !isDargVerLeft!
          ? CupertinoIcons.volume_down
          : CupertinoIcons.brightness_solid;
    } else {
      iconData = !isDargVerLeft!
          ? CupertinoIcons.volume_up
          : CupertinoIcons.brightness_solid;
    }
    // 显示，亮度 || 音量
    return Card(
      color: Color.fromRGBO(0, 0, 0, 0.8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(iconData, color: Colors.white),
            Container(
              width: 100,
              height: 3,
              margin: EdgeInsets.only(left: 8),
              child: LinearProgressIndicator(
                value: updateDargVarVal,
                backgroundColor: Colors.white54,
                valueColor: AlwaysStoppedAnimation(Get.theme.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // build 倍数列表
  List<Widget> _buildSpeedListWidget() {
    List<Widget> columnChild = [];
    speedList.forEach((String mapKey, double speedVals) {
      columnChild.add(
        Ink(
          child: InkWell(
            onTap: () {
              if (_speed == speedVals) return null;
              setState(() {
                _speed = speed = speedVals;
                _hideSpeedStu = true;
                player.setSpeed(speedVals);
              });
            },
            child: Container(
              alignment: Alignment.center,
              width: 50,
              height: 30,
              child: Text(
                mapKey + " X",
                style: TextStyle(
                  color: _speed == speedVals
                      ? Get.theme.primaryColor
                      : Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      );
      columnChild.add(
        Padding(
          padding: EdgeInsets.only(top: 5, bottom: 5),
          child: Container(
            width: 50,
            height: 1,
            color: Colors.white54,
          ),
        ),
      );
    });
    columnChild.removeAt(columnChild.length - 1);
    return columnChild;
  }

  // 播放器控制器 ui
  Widget _buildGestureDetector() {
    return GestureDetector(
      onTap: _cancelAndRestartTimer,
      onDoubleTap: _playOrPause,
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onVerticalDragStart: _onVerticalDragStart,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      child: AbsorbPointer(
        absorbing: _hideStuff,
        child: Column(
          children: <Widget>[
            // 播放器顶部控制器
            widget.player.value.fullScreen ? _buildTopBar() : SizedBox(),
            // 中间按钮
            Expanded(
              child: Stack(
                children: <Widget>[
                  // 顶部显示
                  Positioned(
                    top: widget.player.value.fullScreen ? 20 : 0,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 显示左右滑动快进时间的块
                        _buildDargProgressTime(),
                        // 显示上下滑动音量亮度
                        _buildDargVolumeAndBrightness()
                      ],
                    ),
                  ),
                  // 中间按钮
                  Align(
                    alignment: Alignment.center,
                    child: _buildCenterPlayBtn(),
                  ),
                  // 倍数选择
                  Positioned(
                    right: 35,
                    bottom: 0,
                    child: !_hideSpeedStu
                        ? Container(
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: _buildSpeedListWidget(),
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          )
                        : Container(),
                  ),
                ],
              ),
            ),
            // 播放器底部控制器
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildGestureDetector();
  }
}
