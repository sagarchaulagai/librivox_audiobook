import 'dart:async';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:librivox_audiobook/resources/models/audiobook.dart';
import 'package:librivox_audiobook/resources/models/audiobook_file.dart';
import 'package:librivox_audiobook/resources/services/database_helper.dart';
import 'package:rxdart/rxdart.dart';

class AudiobookPlayerPage extends StatefulWidget {
  final Audiobook audiobook;
  final List<AudiobookFile> audiobookFiles;
  final int index;
  const AudiobookPlayerPage({
    super.key,
    required this.audiobook,
    required this.audiobookFiles,
    required this.index,
  });

  @override
  State<AudiobookPlayerPage> createState() => _AudiobookPlayerPageState();
}

class _AudiobookPlayerPageState extends State<AudiobookPlayerPage> {
  late AudioPlayer _audioPlayer;
  late ConcatenatingAudioSource _playlist;
  late StreamSubscription<int?> _playlistIndexSubscription;
  int myAudioIndex = 0;

  Stream<PositionData> get _positionDataStream {
    return Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
      _audioPlayer.positionStream,
      _audioPlayer.bufferedPositionStream,
      _audioPlayer.durationStream,
      (position, bufferedPosition, duration) {
        return PositionData(
          position,
          bufferedPosition,
          duration ?? Duration.zero,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _playlist = ConcatenatingAudioSource(children: [
      for (int i = 0; i < widget.audiobookFiles.length; i++)
        AudioSource.uri(
          Uri.parse(widget.audiobookFiles[i].url!),
          tag: MediaItem(
            id: i.toString(),
            title: widget.audiobookFiles[i].name ?? '',
            album: widget.audiobook.title,
            artUri: Uri.parse(
              widget.audiobook.lowQCoverImage,
            ),
          ),
        ),
    ]);

    _audioPlayer = AudioPlayer();
    _init();
    _playlistIndexSubscription =
        _audioPlayer.currentIndexStream.listen((index) async {
      if (index != null && mounted) {
        //update current index in database
        await DatabaseHelper.instance.updateRecord({
          DatabaseHelper.columnIdentifier: widget.audiobook.id,
          DatabaseHelper.columnCurrentIndex: index,
        });
        setState(() {
          myAudioIndex = index;
        });
      }
    });
  }

  Future<void> _init() async {
    myAudioIndex = widget.index; // unused
    await _audioPlayer.setAudioSource(
      _playlist,
      initialIndex: widget.index,
    );

    _audioPlayer.play();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _playlistIndexSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.audiobook.title,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: widget.audiobookFiles[0].highQCoverImage ??
                        widget.audiobook.lowQCoverImage,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => CachedNetworkImage(
                      imageUrl: widget.audiobook.lowQCoverImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 10,
                    child: Text(
                      widget.audiobookFiles[myAudioIndex].track.toString(),
                      style: GoogleFonts.ubuntu(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          const Shadow(
                            color: Colors.black,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.audiobookFiles[myAudioIndex].title ?? '',
              style: GoogleFonts.ubuntu(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.audiobook.author ?? '',
              style: GoogleFonts.ubuntu(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            StreamBuilder<PositionData>(
              stream: _positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return ProgressBar(
                  progressBarColor: Colors.orange,
                  thumbColor: Colors.orange,
                  baseBarColor: Colors.orange.shade100,
                  bufferedBarColor: Color.fromARGB(255, 228, 172, 88)!,
                  progress: positionData?.position ?? Duration.zero,
                  buffered: positionData?.bufferedPosition ?? Duration.zero,
                  total: positionData?.duration ?? Duration.zero,
                  onSeek: _audioPlayer.seek,
                );
              },
            ),
            const SizedBox(
              height: 10,
            ),
            Controls(audioPlayer: _audioPlayer),
          ],
        ),
      ),
    );
  }
}

class Controls extends StatelessWidget {
  final AudioPlayer audioPlayer;
  const Controls({
    super.key,
    required this.audioPlayer,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Icon for 10 seconds rewind
        IconButton(
          onPressed: () {
            audioPlayer
                .seek(audioPlayer.position - const Duration(seconds: 10));
          },
          icon: const Icon(
            Icons.replay_10,
          ),
          iconSize: 32.0,
        ),
        IconButton(
          onPressed: () {
            audioPlayer.seekToPrevious();
          },
          icon: const Icon(
            Icons.skip_previous,
          ),
          iconSize: 32.0,
        ),
        StreamBuilder<PlayerState>(
          stream: audioPlayer.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return const SizedBox(
                height: 32,
                width: 32,
                child: CircularProgressIndicator(
                  color: Colors.orange,
                ),
              );
            } else if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_arrow),
                iconSize: 32.0,
                onPressed: audioPlayer.play,
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: const Icon(Icons.pause),
                iconSize: 32.0,
                onPressed: audioPlayer.pause,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.replay),
                iconSize: 32.0,
                onPressed: () => audioPlayer.seek(Duration.zero),
              );
            }
          },
        ),
        IconButton(
          onPressed: () {
            audioPlayer.seekToNext();
          },
          icon: const Icon(
            Icons.skip_next,
          ),
          iconSize: 32.0,
        ),
        // Icon for 10 seconds forward
        IconButton(
          onPressed: () {
            audioPlayer
                .seek(audioPlayer.position + const Duration(seconds: 10));
          },
          icon: const Icon(
            Icons.forward_10,
          ),
          iconSize: 32.0,
        ),
      ],
    );
  }
}

class PositionData {
  const PositionData(
    this.position,
    this.bufferedPosition,
    this.duration,
  );
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
}
