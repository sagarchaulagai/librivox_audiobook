const String _base = "https://archive.org/download";

class AudiobookFile {
  final String? identifier;
  final String? title;
  final String? name;
  final String? url;
  final double? length;
  final int? track;
  final int? size;
  final String? highQCoverImage;

  AudiobookFile.fromJson(Map json)
      : identifier = json["identifier"],
        title = json["title"],
        name = json["name"],
        track = int.parse(json["track"].split("/")[0]),
        size = int.parse(json["size"]),
        length = double.parse(json["length"]),
        url = "$_base/${json['identifier']}/${json['name']}",
        highQCoverImage =
            "$_base/${json['identifier']}/${json["highQCoverImage"]}";

  static List<AudiobookFile> fromJsonArray(List jsonFiles) {
    List<AudiobookFile> audiobookFiles = <AudiobookFile>[];
    for (var jsonFile in jsonFiles) {
      audiobookFiles.add(AudiobookFile.fromJson(jsonFile));
    }
    return audiobookFiles;
  }

  Map<String, Object?> toMap() {
    return {
      "identifier": identifier,
      "title": title,
      "name": name,
      "track": track,
      "size": size,
      "length": length,
      "url": url,
      "highQCoverImage": highQCoverImage,
    };
  }

  AudiobookFile.fromMap(Map<String, Object?> map)
      : identifier = map["identifier"] as String,
        title = map["title"] as String,
        name = map["name"] as String,
        track = map["track"] as int,
        size = map["size"] as int,
        length = map["length"] as double,
        url = map["url"] as String,
        highQCoverImage = map["highQCoverImage"] as String;
}
