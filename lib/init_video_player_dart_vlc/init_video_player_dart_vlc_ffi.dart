import 'package:universal_platform/universal_platform.dart';

import '../video_player_dart_vlc_platform/video_player_dart_vlc_platform_ffi.dart';

void initVideoPlayerDartVlcIfNeeded() {
  if(UniversalPlatform.isWindows||UniversalPlatform.isLinux){
    VideoPlayerDartVlc.registerWith();
  }
}
