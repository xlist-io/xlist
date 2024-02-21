// 支持预览的图片类型
const List<dynamic> kSupportPreviewImageTypes = [
  'jpg',
  'jpeg',
  'png',
  'gif',
  'svg',
  'ico',
  'tiff',
  'bmp',
  'swf',
  'webp',
];

// 支持预览的视频类型
const List<dynamic> kSupportPreviewVideoTypes = [
  'mp4',
  'mkv',
  'avi',
  'mov',
  'rmvb',
  'webm',
  'wmv',
  'flv',
  '3gp',
  'mpeg',
  'mpg',
  'rm',
  'm4v',
  'f4v',
  'vob',
  'mts',
  'ts'
];

// 支持预览的音频类型
const List<dynamic> kSupportPreviewAudioTypes = [
  'mp3',
  'wav',
  'flac',
  'ac3',
  'aiff',
  'ape',
  'aac',
  'ogg',
  'wma',
  'm4a',
  'opus',
];

// 支持预览的文档类型
const List<dynamic> kSupportPreviewDocumentTypes = [
  'doc',
  'docx',
  'xls',
  'xlsx',
  'ppt',
  'pptx',
  'pdf',
  ...kSupportPreviewCodeTypes,
];

// 支持预览的代码文件类型
const List<dynamic> kSupportPreviewCodeTypes = [
  'txt',
  'md',
  'json',
  'xml',
  'js',
  'css',
  'html',
  'htm',
  'c',
  'h',
  'dart',
  'go',
  'java',
  'kt',
  'lua',
  'cpp',
  'hpp',
  'sql',
  'php',
  'py',
  'rb',
  'sh',
  'm',
  'swift',
  'vue',
  'graphql',
  'solidity',
];

// 代码类型映射到语言
const Map<String, String> kCodeLanguages = {
  'txt': '',
  'md': 'markdown',
  'json': 'json',
  'xml': 'xml',
  'js': 'javascript',
  'css': 'css',
  'html': 'xml',
  'htm': 'xml',
  'c': 'cpp',
  'h': 'cpp',
  'dart': 'dart',
  'go': 'go',
  'java': 'java',
  'kt': 'kotlin',
  'lua': 'lua',
  'cpp': 'cpp',
  'hpp': 'cpp',
  'sql': 'sql',
  'php': 'php',
  'py': 'python',
  'rb': 'ruby',
  'sh': 'bash',
  'm': 'objectivec',
  'swift': 'swift',
  'vue': 'vue',
  'graphql': 'graphql',
  'solidity': 'solidity',
};
