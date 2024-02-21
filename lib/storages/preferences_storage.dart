import 'package:xlist/constants/index.dart';
import 'package:get_storage/get_storage.dart';

class PreferencesStorage {
  // 初始化偏好设置存储
  static final _prefBox = () => GetStorage('PreferencesStorage');

  // Init
  Future<PreferencesStorage> init() async {
    await GetStorage.init('PreferencesStorage');
    return this;
  }

  // 是否是第一次启动
  final isFirstOpen = true.val('isFirstOpen', getBox: _prefBox);

  // 是否自动播放
  final isAutoPlay = true.val('isAutoPlay', getBox: _prefBox);

  // 是否后台播放
  final isBackgroundPlay = true.val('isBackgroundPlay', getBox: _prefBox);

  // 是否开启硬件解码
  final isHardwareDecode = true.val('isHardwareDecode', getBox: _prefBox);

  // 是否显示预览图
  final isShowPreview = true.val('isShowPreview', getBox: _prefBox);

  // 用户自定义的图片支持类型
  final imageSupportTypes =
      kSupportPreviewImageTypes.val('imageSupportTypes', getBox: _prefBox);

  // 用户自定义的视频支持类型
  final videoSupportTypes =
      kSupportPreviewVideoTypes.val('videoSupportTypes', getBox: _prefBox);

  // 用户自定义的音频支持类型
  final audioSupportTypes =
      kSupportPreviewAudioTypes.val('audioSupportTypes', getBox: _prefBox);

  // 用户自定义的文档支持类型
  final documentSupportTypes = kSupportPreviewDocumentTypes
      .val('documentSupportTypes', getBox: _prefBox);

  // 排序方式 - 按时间降序, 按时间升序, 按名称降序, 按名称升序
  final sortType = 0.val('sortType', getBox: _prefBox);

  // 布局方式 - 列表, 网格
  final layoutType = 0.val('layoutType', getBox: _prefBox);

  // 播放模式 - 列表循环, 单集循环, 播完暂停
  final playMode = 0.val('playMode', getBox: _prefBox);
}
