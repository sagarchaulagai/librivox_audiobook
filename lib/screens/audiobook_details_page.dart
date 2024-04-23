import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:librivox_audiobook/resources/archive_api.dart';
import 'package:librivox_audiobook/resources/models/audiobook.dart';
import 'package:librivox_audiobook/resources/services/database_helper.dart';

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
  int currentIndexOfAudiobookPlaying = 0;
  bool isNotInPlayingList = true;

  @override
  void initState() {
    super.initState();
    initPlayingList();
  }

  Future<void> initPlayingList() async {
    // using database helper we need to check if identifier rows contains widget.audiobook.identifeir or not
    // if it does then we need to get the currentIndex and set it to currentIndexOfAudiobookPlaying
    // else we need to insert a new row with identifier, currentIndex, currentPosition, audiobook and audiobookFiles
    // and set currentIndexOfAudiobookPlaying to 0

    DatabaseHelper databaseHelper = DatabaseHelper.instance;
    List<Map<String, Object?>> rows = await databaseHelper.queryAllRows();
    for (Map<String, Object?> row in rows) {
      if (row['identifier'] == widget.audiobook.id) {
        setState(() {
          currentIndexOfAudiobookPlaying = row['currentIndex'] as int;
          isNotInPlayingList = false;
        });
        return;
      }
    }

    databaseHelper.onUpdate.listen((row) {
      if (row['identifier'] == widget.audiobook.id) {
        setState(() {
          currentIndexOfAudiobookPlaying = row['currentIndex'] as int;
          isNotInPlayingList = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          //
          ),
      body: FutureBuilder(
          future: ArchiveApi().getAudiobookFiles(
            widget.audiobook.id,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: 200,
                            width: 200,
                            child: CachedNetworkImage(
                              imageUrl: snapshot.data![0].highQCoverImage ??
                                  widget.audiobook.lowQCoverImage,
                              fit: BoxFit.fill,
                              placeholder: (context, url) {
                                return CachedNetworkImage(
                                  imageUrl: widget.audiobook.lowQCoverImage,
                                  fit: BoxFit.fill,
                                );
                              },
                              errorWidget: (context, url, error) {
                                return CachedNetworkImage(
                                  imageUrl: widget.audiobook.lowQCoverImage,
                                  fit: BoxFit.fill,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.audiobook.title,
                        style: GoogleFonts.ubuntu(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      //const SizedBox(height: 10),
                      Text(
                        widget.audiobook.author ?? "N/A",
                        style: GoogleFonts.ubuntu(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            color: Colors.orange,
                            child: SizedBox(
                              height: 80,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.access_time,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          widget.audiobook.totalTime ?? "N/A",
                                          style: GoogleFonts.ubuntu(
                                            fontSize: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // a vertical line
                                  Container(
                                    height: 50,
                                    width: 1,
                                    color: Colors.white,
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.file_download,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          // change actual number of downloads to K for thousands and M for millions
                                          widget.audiobook.downloads != null
                                              ? widget.audiobook.downloads! >
                                                      999
                                                  ? widget.audiobook
                                                              .downloads! >
                                                          999999
                                                      ? "${(widget.audiobook.downloads! / 1000000).toStringAsFixed(1)}M"
                                                      : "${(widget.audiobook.downloads! / 1000).toStringAsFixed(1)}K"
                                                  : widget.audiobook.downloads
                                                      .toString()
                                              : "N/A",
                                          style: GoogleFonts.ubuntu(
                                            fontSize: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // a vertical line
                                  Container(
                                    height: 50,
                                    width: 1,
                                    color: Colors.white,
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          widget.audiobook.rating.toString(),
                                          style: GoogleFonts.ubuntu(
                                            fontSize: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Text(
                            "Description",
                            style: GoogleFonts.ubuntu(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          DescriptionText(
                            description: widget.audiobook.description ?? "N/A",
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Subjects",
                            style: GoogleFonts.ubuntu(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Wrap(
                            spacing: 5,
                            children: List.generate(
                              widget.audiobook.subject!.length,
                              (index) {
                                return Chip(
                                  label: Text(
                                    widget.audiobook.subject![index],
                                    style: GoogleFonts.ubuntu(
                                      fontSize: 13,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),

                          Text(
                            "Audio Files",
                            style: GoogleFonts.ubuntu(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // list tiles of audio files
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return Ink(
                                child: Card(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        currentIndexOfAudiobookPlaying = index;
                                        // prefs.setInt(
                                        //     'currentIndexOfAudiobookPlaying',
                                        //     currentIndexOfAudiobookPlaying);
                                      });
                                    },
                                    splashColor: Colors.orange,
                                    splashFactory: InkRipple.splashFactory,
                                    child: ListTile(
                                      tileColor:
                                          currentIndexOfAudiobookPlaying ==
                                                  index
                                              ? Colors.orange
                                              : null,
                                      onTap: () async {
                                        // update the current index of audiobook playing
                                        // and navigate to audiobook player
                                        // update database
                                        if (isNotInPlayingList) {
                                          DatabaseHelper databaseHelper =
                                              DatabaseHelper.instance;
                                          Map<String, Object?> row = {
                                            'identifier': widget.audiobook.id,
                                            'currentIndex': index,
                                            'currentPosition': 0,
                                            'audiobook': widget.audiobook
                                                .toMap()
                                                .toString(),
                                            'audiobookFiles':
                                                snapshot.data.toString(),
                                          };
                                          await databaseHelper
                                              .insertRecord(row);
                                        } else {
                                          DatabaseHelper databaseHelper =
                                              DatabaseHelper.instance;
                                          Map<String, Object?> row = {
                                            'identifier': widget.audiobook.id,
                                            'currentIndex': index,
                                          };
                                          await databaseHelper
                                              .updateRecord(row);
                                        }
                                        // Then update the state
                                        setState(() {
                                          currentIndexOfAudiobookPlaying =
                                              index;
                                        });
                                        context.pushNamed(
                                          '/audiobook_player',
                                          extra: {
                                            'audiobook': widget.audiobook,
                                            'audiobookFiles': snapshot.data,
                                            'index': index,
                                          },
                                        );
                                      },
                                      title: Text(
                                        snapshot.data![index].title ?? 'N/A',
                                        style: GoogleFonts.ubuntu(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        // convert this length in seconds to time format
                                        snapshot.data![index].length != null
                                            ? "${(snapshot.data![index].length! / 60).floor()} minutes"
                                            : 'N/A',
                                        style: GoogleFonts.ubuntu(
                                          fontSize: 13,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(
                                          currentIndexOfAudiobookPlaying ==
                                                  index
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                        ),
                                        onPressed: () {
                                          // TODO
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
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

class DescriptionText extends StatefulWidget {
  final String description;

  DescriptionText({
    required this.description,
  });

  @override
  _DescriptionTextState createState() => _DescriptionTextState();
}

class _DescriptionTextState extends State<DescriptionText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: _isExpanded
          ? Text(
              widget.description,
              style: GoogleFonts.ubuntu(
                fontSize: 13,
              ),
            )
          : RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(
                    text: widget.description.length > 300
                        ? widget.description.substring(0, 300)
                        : widget.description,
                    style: GoogleFonts.ubuntu(
                      fontSize: 13,
                    ),
                  ),
                  TextSpan(
                    text: ' ... Tap to read more',
                    style: GoogleFonts.ubuntu(
                      fontSize: 13,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
