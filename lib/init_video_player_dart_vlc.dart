import 'package:universal_platform/universal_platform.dart';
import 'package:video_player_dart_vlc/video_player_dart_vlc.dart';

void initVideoPlayerDartVlcIfNeeded() {
  if(UniversalPlatform.isWindows||UniversalPlatform.isLinux){
    VideoPlayerDartVlc.registerWith();
  }
}
