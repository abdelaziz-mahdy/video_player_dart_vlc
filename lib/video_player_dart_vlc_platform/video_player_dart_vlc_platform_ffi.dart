import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:stream_transform/stream_transform.dart';

class VideoPlayerDartVlc extends VideoPlayerPlatform {
  Map<int, Player> players = {};
  //workaround to know if the player is initialized
  Map<int, int> durations = {};
  int counter = 0;

  /// Registers this class as the default instance of [PathProviderPlatform].
  static void registerWith() {
    VideoPlayerPlatform.instance = VideoPlayerDartVlc();

    return;
  }

  void _disposeAllPlayers() {
    for (final int videoPlayerId in players.keys) {
      dispose(videoPlayerId);
    }
    players.clear();
  }

  @override
  Widget buildView(int textureId) {
    return Video(
      player: players[textureId],

      // height: 1920.0,
      // width: 1080.0,
      // scale: 1.0, // default
      showControls: false,
    );
  }

  @override
  Future<int?> create(DataSource dataSource) async {
    counter++;
    String refer = "";
    if (dataSource.sourceType == DataSourceType.network) {
      refer = dataSource.httpHeaders["Referer"] ?? "";
    }
    //print('--http-referrer=' + refer);

    Player player = Player(
      id: counter,
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
      if (!await File.fromUri(Uri.parse(dataSource.uri!)).exists()) {
        throw Exception("${dataSource.uri!} not found ");
      }
      player.open(
        Media.file(
          File.fromUri(Uri.parse(dataSource.uri!)),
          //startTime: seekTo
        ),
      );
    }

    players[player.id] = player;
    return player.id;
  }

  @override
  Future<Duration> getPosition(int textureId) async {
    return players[textureId]!.position.position!;
  }

  @override
  Future<void> init() async {
    _disposeAllPlayers();

    DartVLC.initialize();
  }

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
    // print("disposed player $textureId");
    // players[textureId]!.playbackStream.listen((element) {
    //   print("is playing ${element.isPlaying}");
    // });
    // await players[textureId]!
    //     .playbackStream
    //     .firstWhere((event) => !event.isPlaying);
    pause(textureId);
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
    Stream<VideoEvent> initializedStream() async* {
      await for (final event in players[textureId]!.positionStream) {
        if (event.duration != Duration.zero) {
          if (!durations.containsKey(textureId) ||
              (durations[textureId] ?? 0) != event.duration!.inMicroseconds) {
            durations[textureId] = event.duration!.inMicroseconds;
            yield VideoEvent(
              eventType: VideoEventType.initialized,
              duration: event.duration,
              size: Size(players[textureId]!.videoDimensions.width.toDouble(),
                  players[textureId]!.videoDimensions.height.toDouble()),
              rotationCorrection: 0,
            );

            yield VideoEvent(
              buffered: [
                (DurationRange(
                    Duration.zero,
                    Duration(
                        seconds: ((100) *
                                players[textureId]!
                                    .position
                                    .duration!
                                    .inSeconds)
                            .round())))
              ],
              eventType: VideoEventType.bufferingUpdate,
            );
          }
        }
        yield VideoEvent(
          eventType: VideoEventType.unknown,
        );
      }
    }

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

    return isCompleted.mergeAll([initializedStream(), buffering]);
  }

  /// setLooping (ignored)
  @override
  Future<void> setLooping(int textureId, bool looping) => Future<void>.value();

  /// Sets the audio mode to mix with other sources (ignored)
  @override
  Future<void> setMixWithOthers(bool mixWithOthers) => Future<void>.value();
}
