import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:stream_transform/stream_transform.dart';

class VideoPlayerDartVlc extends VideoPlayerPlatform {
  Map<int, Player> players = {};

  /// Registers this class as the default instance of [PathProviderPlatform].
  static void registerWith() {
    VideoPlayerPlatform.instance = VideoPlayerDartVlc();
    return DartVLC.initialize();
  }

  @override
  Widget buildView(int textureId) {
    return Video(
      player: players[textureId],
      showControls: false,
    );
  }

  @override
  Future<int?> create(DataSource dataSource) async {
    Random random = Random();
    int randomNumber = random.nextInt(1000);
    String refer = "";
    if (dataSource.sourceType == DataSourceType.network) {
      refer = dataSource.httpHeaders["Referer"] ?? "";
    }
    //print('--http-referrer=' + refer);

    Player player = Player(
      id: randomNumber,
      commandlineArguments: [
        //"-vvv",
        '--http-referrer=' + refer,
        '--http-reconnect',
        '--sout-livehttp-caching',
        '--network-caching=60000',
        '--file-caching=60000'
      ],
      //registerTexture: !Platform.isWindows
    ); // create a new video controller
    if (dataSource.sourceType == DataSourceType.asset) {
      player.open(
        Media.asset(dataSource.asset!),
        // autoStart: _autoplay,
      );
    } else if (dataSource.sourceType == DataSourceType.network) {
      // print(dataSource.source!);
      player.open(
        Media.network(
          dataSource.uri,
          // timeout: Duration(seconds: 10),
          //startTime: seekTo
        ),
      );
    } else {
      if (!await File(dataSource.uri!).exists()) {
        throw Exception("${dataSource.uri!} not found ");
      }
      player.open(
        Media.file(
          File(dataSource.uri!),
          //startTime: seekTo
        ),
      );
    }
    Completer waitingForTextureId = Completer();
    player.textureId.addListener(() {
      players[player.textureId.value!] = player;

      waitingForTextureId.complete();
    });
    await waitingForTextureId.future;
    return player.textureId.value!;
  }

  @override
  Future<Duration> getPosition(int textureId) async {
    return players[textureId]!.position.duration!;
  }

  @override
  Future<void> init() async {}

  @override
  Future<void> pause(int textureId) async {
    return players[textureId]!.pause();
  }

  @override
  Future<void> play(int textureId) async {
    return players[textureId]!.play();
  }

  @override
  Future<void> seekTo(int textureId, Duration position) async {
    return players[textureId]!.seek(position);
  }

  @override
  Future<void> setPlaybackSpeed(int textureId, double speed) async {
    assert(speed > 0);
    return players[textureId]!.setRate(speed);
  }

  @override
  Future<void> setVolume(int textureId, double volume) async {
    return players[textureId]!.setVolume(volume);
  }

  @override
  Future<void> dispose(int textureId) async {
    players[textureId]!.dispose();
    players.remove(textureId);
    return;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    Stream<VideoEvent> isCompleted =
        players[textureId]!.playbackStream.map((event) {
      if (event.isCompleted) {
        return VideoEvent(
          eventType: VideoEventType.completed,
        );
      }
      return VideoEvent(
        eventType: VideoEventType.unknown,
      );
    });
    Stream<VideoEvent> initialized =
        players[textureId]!.videoDimensionsStream.map((event) {
      return VideoEvent(
        eventType: VideoEventType.initialized,
        duration: players[textureId]!.position.duration,
        size: Size(event.width.toDouble(), event.height.toDouble()),
        rotationCorrection: 0,
      );
    });
    Stream<VideoEvent> buffering =
        players[textureId]!.bufferingProgressStream.map((event) {
      if (event != 100) {
        return VideoEvent(
          buffered: [
            (DurationRange(
                Duration.zero,
                Duration(
                    seconds: ((event / 100) *
                            players[textureId]!.position.duration!.inSeconds)
                        .round())))
          ],
          eventType: VideoEventType.bufferingUpdate,
        );
      } else {
        return VideoEvent(eventType: VideoEventType.bufferingEnd);
      }
    });
    return isCompleted.mergeAll([initialized, buffering]);
  }

  @override
  Future<void> setLooping(int textureId, bool looping) {
    // TODO: implement setLooping
    throw UnimplementedError();
  }

  /// Sets the audio mode to mix with other sources (ignored)
  @override
  Future<void> setMixWithOthers(bool mixWithOthers) => Future<void>.value();
}
