## Video Player Dart VLC
Video Player Dart VLC is a platform interface for video player using dart_vlc to work on Windows and Linux. This interface allows you to play videos seamlessly in your flutter applications.

### Note: this package allows video_player to work across platforms excluding macos

`video_player` is the package used for playing videos on Android, iOS, and web platforms.

`dart_vlc` is the package used for playing videos on Windows, Linux platforms.



## How to use
To use Video Player Dart VLC in your application, follow the steps below:



## 1. Setup

### Windows

Everything is already set up.

### Linux

For using this plugin on Linux, you must have [VLC](https://www.videolan.org) & [libVLC](https://www.videolan.org/vlc/libvlc.html) installed.

**On Ubuntu/Debian:**

```bash
sudo apt-get install vlc
```

```bash
sudo apt-get install libvlc-dev
```

**On Fedora:**

```bash
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
```

```bash
sudo dnf install vlc
```

```bash
sudo dnf install vlc-devel
```

2. Add the Video Player Dart VLC dependency in your `pubspec.yaml` file:
```
dependencies:
  video_player_dart_vlc: ^0.1.6
```
3. Import the package in your Dart code
```
import 'package:video_player_dart_vlc/video_player_dart_vlc.dart';
```
4. Initialize the Video Player Dart VLC interface in the main function of your app
```
void main() {
  initVideoPlayerDartVlcIfNeeded();
  runApp(MyApp());
}
```

