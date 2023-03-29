## Video Player Dart VLC
Video Player Dart VLC is a platform interface for video player using dart_vlc to work on Windows and Linux. This interface allows you to play videos seamlessly in your flutter applications.
## How to use
To use Video Player Dart VLC in your application, follow the steps below:

1. Add the Video Player Dart VLC dependency in your `pubspec.yaml` file:


```
dependencies:
  video_player_dart_vlc: ^0.1.5
```
1. Import the package in your Dart code
```
import 'package:video_player_dart_vlc/video_player_dart_vlc.dart';
```
3. Initialize the Video Player Dart VLC interface in the main function of your app:</li></ol>
```
void main() {
  initVideoPlayerDartVlcIfNeeded();
  runApp(MyApp());
}
```

`video_player` is the package used for playing videos on Android, iOS, and web platforms.

`dart_vlc` is the package used for playing videos on Windows, Linux platforms.

