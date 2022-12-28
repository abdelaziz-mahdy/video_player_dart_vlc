import 'package:universal_platform/universal_platform.dart';

import '../video_player_dart_vlc_platform.dart';

void initVideoPlayerDartVlcIfNeeded() {
  if(UniversalPlatform.isWindows||UniversalPlatform.isLinux){
    VideoPlayerDartVlc.registerWith();
  }
}
