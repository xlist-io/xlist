import 'dart:math';
import 'dart:async';

import 'package:get/get.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:audio_service/audio_service.dart';

import 'package:xlist/constants/index.dart';
import 'package:xlist/pages/audio_player/index.dart';
import 'package:xlist/pages/video_player/index.dart';

// PlayerNotificationService https://pub.dev/packages/audio_service
class PlayerNotificationService extends GetxService {
  static PlayerNotificationService get to => Get.find();

  late PlayerNotificationHandler _audioHandler;
  PlayerNotificationHandler get audioHandler => _audioHandler;

  // Init
  Future<PlayerNotificationService> init() async {
    _audioHandler = await AudioService.init(
      builder: () => PlayerNotificationHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'io.xlist.channel.audio',
        androidNotificationChannelName: 'Xlist playback',
        androidNotificationOngoing: true,
        rewindInterval: const Duration(seconds: 15),
        fastForwardInterval: const Duration(seconds: 15),
      ),
    );
    return this;
  }
}

class PlayerNotificationHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  late StreamController<PlaybackState> streamController;

  // Convert fijkplayer state into audio_service state.
  static final FIJK_TO_PROCESSING_STATE = {
    FijkState.idle: AudioProcessingState.idle,
    FijkState.initialized: AudioProcessingState.idle,
    FijkState.asyncPreparing: AudioProcessingState.buffering,
    FijkState.prepared: AudioProcessingState.ready,
    FijkState.started: AudioProcessingState.ready,
    FijkState.paused: AudioProcessingState.ready,
    FijkState.stopped: AudioProcessingState.ready,
    FijkState.error: AudioProcessingState.error,
    FijkState.end: AudioProcessingState.completed,
    FijkState.completed: AudioProcessingState.completed,
  };

  Function? _play;
  Function? _pause;
  Function? _seek;
  Function? _stop;

  bool? _isVideo;
  bool? _isPlaylist;

  void setVideoFunctions(
      Function play, Function pause, Function seek, Function stop) {
    _play = play;
    _pause = pause;
    _seek = seek;
    _stop = stop;
  }

  /// Initialise our audio handler.
  PlayerNotificationHandler();

  @override
  Future<void> play() async => _play!();

  @override
  Future<void> pause() async => _pause!();

  @override
  Future<void> seek(Duration position) async => _seek!(position.inMilliseconds);

  @override
  Future<void> stop() async => _stop!();

  @override
  Future<void> skipToPrevious() async {
    try {
      if (!_isPlaylist!) return;

      // Get the current video/audio player controller.
      dynamic _vp = _isVideo ?? false
          ? Get.find<VideoPlayerController>()
          : Get.find<AudioPlayerController>();

      // If the current play mode is shuffle, change the playlist to a random index.
      final _playMode =
          _isVideo ?? false ? _vp.playMode.val : _vp.playMode.value;
      if (_playMode == PlayMode.SHUFFLE) {
        _vp.changePlaylist(Random().nextInt(_vp.objects.length));
        return;
      }

      // Change the current index to the previous index.
      _vp.currentIndex.value == 0
          ? _vp.changePlaylist(_vp.objects.length - 1)
          : _vp.changePlaylist(_vp.currentIndex.value - 1);
    } catch (e) {}
  }

  @override
  Future<void> skipToNext() async {
    try {
      if (!_isPlaylist!) return;

      // Get the current video/audio player controller.
      dynamic _vp = _isVideo ?? false
          ? Get.find<VideoPlayerController>()
          : Get.find<AudioPlayerController>();

      // If the current play mode is shuffle, change the playlist to a random index.
      final _playMode =
          _isVideo ?? false ? _vp.playMode.val : _vp.playMode.value;
      if (_playMode == PlayMode.SHUFFLE) {
        _vp.changePlaylist(Random().nextInt(_vp.objects.length));
        return;
      }

      // Change the current index to the next index.
      _vp.currentIndex.value == _vp.objects.length - 1
          ? _vp.changePlaylist(0)
          : _vp.changePlaylist(_vp.currentIndex.value + 1);
    } catch (e) {}
  }

  /// Initialise our stream controller and start listening to fijkplayer events.
  /// [player] is the fijkplayer instance.
  void initializeStreamController(
      FijkPlayer player, bool isPlaylist, bool isVideo) {
    _isVideo = isVideo;
    _isPlaylist = isPlaylist;
    void _fijkValueListener() => updatePlaybackState(player);
    void startStream() => player.addListener(_fijkValueListener);
    void stopStream() {
      player.removeListener(_fijkValueListener);
      streamController.close();
    }

    // Start the stream
    streamController = StreamController<PlaybackState>(
      onListen: startStream,
      onPause: stopStream,
      onResume: startStream,
      onCancel: stopStream,
    );
  }

  /// Broadcast media item changes.
  /// [player] is the fijkplayer instance.
  void updatePlaybackState(FijkPlayer player) {
    bool _isPlaying() => player.value.state == FijkState.started;

    // AudioProcessingState
    AudioProcessingState _processingState() {
      if (player.isBuffering) return AudioProcessingState.buffering;
      return FIJK_TO_PROCESSING_STATE[player.value.state] ??
          AudioProcessingState.idle;
    }

    streamController.add(PlaybackState(
      controls: [
        _isPlaylist ?? false
            ? MediaControl.skipToPrevious
            : MediaControl.rewind,
        if (_isPlaying()) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        _isPlaylist ?? false
            ? MediaControl.skipToNext
            : MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: _processingState(),
      playing: _isPlaying(),
      updatePosition: player.currentPos,
      bufferedPosition: player.bufferPos,
      speed: player.value.speed,
    ));
  }
}
