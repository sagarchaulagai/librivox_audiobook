class Audiobook {
  final String title;
  final String id;
  final String? description;
  final String? totalTime;
  final String? author;
  final DateTime? date;
  final int? downloads;
  final List<dynamic>? subject;
  final int? size;
  final double? rating;
  final int? reviews;
  final String lowQCoverImage;

  Audiobook.fromJson(Map jsonAudiobook)
      : id = jsonAudiobook["identifier"] ?? '',
        title = jsonAudiobook["title"] ?? '',
        totalTime = jsonAudiobook["runtime"],
        author = jsonAudiobook["creator"] ?? 'Unknown',
        date = jsonAudiobook['date'] != null
            ? DateTime.parse(jsonAudiobook["date"])
            : null,
        downloads = jsonAudiobook["downloads"] ?? 0,
        subject = jsonAudiobook["subject"] is String
            ? [jsonAudiobook["subject"]]
            : jsonAudiobook["subject"],
        size = jsonAudiobook["item_size"],
        rating = jsonAudiobook["avg_rating"] != null
            ? double.parse(jsonAudiobook["avg_rating"].toString())
            : null,
        reviews = jsonAudiobook["num_reviews"],
        description = jsonAudiobook["description"],
        lowQCoverImage =
            "https://archive.org/services/get-item-image.php?identifier=${jsonAudiobook['identifier']}";

  static List<Audiobook> fromJsonArray(List jsonAudiobook) {
    List<Audiobook> audiobooks = <Audiobook>[];
    for (var book in jsonAudiobook) {
      audiobooks.add(Audiobook.fromJson(book));
    }
    return audiobooks;
  }
}
