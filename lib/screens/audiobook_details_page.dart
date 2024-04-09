import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:librivox_audiobook/resources/archive_api.dart';
import 'package:librivox_audiobook/resources/models/audiobook.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudiobookDetailsPage extends StatefulWidget {
  final Audiobook audiobook;
  const AudiobookDetailsPage({
    super.key,
    required this.audiobook,
  });

  @override
  State<AudiobookDetailsPage> createState() => _AudiobookDetailsPageState();
}

class _AudiobookDetailsPageState extends State<AudiobookDetailsPage> {
  late SharedPreferences prefs;
  int currentIndexOfAudiobookPlaying = 0;

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    currentIndexOfAudiobookPlaying =
        prefs.getInt('currentIndexOfAudiobookPlaying') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.audiobook.title),
      ),
      body: FutureBuilder(
          future: ArchiveApi().getAudiobookFiles(
            widget.audiobook.id,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print(snapshot.data![0].highQCoverImage!);
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    CachedNetworkImage(
                      imageUrl: snapshot.data![0].highQCoverImage ??
                          widget.audiobook.lowQCoverImage,
                      placeholder: (context, url) {
                        return CachedNetworkImage(
                            imageUrl: widget.audiobook.lowQCoverImage);
                      },
                      errorWidget: (context, url, error) {
                        return const Icon(Icons.error);
                      },
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
