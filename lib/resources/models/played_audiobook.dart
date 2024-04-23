import 'package:librivox_audiobook/resources/models/audiobook.dart';
import 'package:librivox_audiobook/resources/models/audiobook_file.dart';

class PlayedAudiobook {
  final String identifier;
  final int currentIndex;
  final int currentPosition;
  final Audiobook audiobook;
  final List<AudiobookFile> audiobookFiles;

  const PlayedAudiobook({
    required this.identifier,
    required this.currentIndex,
    required this.currentPosition,
    required this.audiobook,
    required this.audiobookFiles,
  });

  Map<String, Object?> toMap() {
    return {
      "identifier": identifier,
      "currentIndex": currentIndex,
      "currentPosition": currentPosition,
      "audiobook": audiobook.toMap(),
      "audiobookFiles": audiobookFiles.map((e) => e.toMap()).toList(),
    };
  }

  PlayedAudiobook.fromMap(Map<String, Object?> map)
      : identifier = map["identifier"] as String,
        currentIndex = map["currentIndex"] as int,
        currentPosition = map["currentPosition"] as int,
        audiobook = Audiobook.fromMap(map["audiobook"] as Map<String, Object?>),
        audiobookFiles = (map["audiobookFiles"] as List)
            .map((e) => AudiobookFile.fromMap(e as Map<String, Object?>))
            .toList();

  @override
  String toString() {
    return 'PlayedAudiobook{identifier: $identifier, currentIndex: $currentIndex, currentPosition: $currentPosition, audiobook: $audiobook, audiobookFiles: $audiobookFiles}';
  }
}
