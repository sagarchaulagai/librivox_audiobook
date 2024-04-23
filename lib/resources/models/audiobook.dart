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

  Audiobook.empty()
      : title = '',
        id = '',
        description = '',
        totalTime = '',
        author = '',
        date = null,
        downloads = 0,
        subject = [],
        size = 0,
        rating = 0,
        reviews = 0,
        lowQCoverImage = '';

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
      if (!book["title"].toLowerCase().contains("thumbs") &&
          !book["creator"].toLowerCase().contains("librivox")) {
        audiobooks.add(Audiobook.fromJson(book));
      }
    }
    return audiobooks;
  }

  Map<String, Object?> toMap() {
    return {
      "title": title,
      "id": id,
      "description": description,
      "totalTime": totalTime,
      "author": author,
      "date": date,
      "downloads": downloads,
      "subject": subject,
      "size": size,
      "rating": rating,
      "reviews": reviews,
      "lowQCoverImage": lowQCoverImage,
    };
  }

  Audiobook.fromMap(Map<String, Object?> map)
      : title = map["title"] as String,
        id = map["id"] as String,
        description = map["description"] as String?,
        totalTime = map["totalTime"] as String?,
        author = map["author"] as String?,
        date = map["date"] as DateTime?,
        downloads = map["downloads"] as int?,
        subject = map["subject"] as List<dynamic>?,
        size = map["size"] as int?,
        rating = map["rating"] as double?,
        reviews = map["reviews"] as int?,
        lowQCoverImage = map["lowQCoverImage"] as String;
}
