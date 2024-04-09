import 'dart:convert';

import 'package:librivox_audiobook/resources/models/audiobook.dart';
import 'package:http/http.dart' as http;
import 'package:librivox_audiobook/resources/models/audiobook_file.dart';

const _commonParams =
    "q=collection:(librivoxaudio)&fl=runtime,avg_rating,num_reviews,title,description,identifier,creator,date,downloads,subject,item_size";

const _latestAudiobook =
    "https://archive.org/advancedsearch.php?$_commonParams&sort[]=addeddate+desc&output=json";

const _mostViewedInThisWeek =
    "https://archive.org/advancedsearch.php?$_commonParams&sort[]=week+desc&output=json";

const _mostDownloadedOfAllTime =
    "https://archive.org/advancedsearch.php?$_commonParams&sort[]=downloads+desc&output=json";

class ArchiveApi {
  Future<List<Audiobook>> getLatestAudiobook(int page, int rows) async {
    final response =
        await http.get(Uri.parse("$_latestAudiobook&page=$page&rows=$rows"));
    if (response.statusCode == 200) {
      return Audiobook.fromJsonArray(
          json.decode(response.body)['response']['docs']);
    } else {
      throw Exception('Failed to load audiobooks');
    }
  }

  Future<List<Audiobook>> getMostViewedWeeklyAudiobook(
      int page, int rows) async {
    final response = await http
        .get(Uri.parse("$_mostViewedInThisWeek&page=$page&rows=$rows"));
    if (response.statusCode == 200) {
      return Audiobook.fromJsonArray(
          json.decode(response.body)['response']['docs']);
    } else {
      throw Exception('Failed to load audiobooks');
    }
  }

  Future<List<Audiobook>> getMostDownloadedEverAudiobook(
      int page, int rows) async {
    final response = await http
        .get(Uri.parse("$_mostDownloadedOfAllTime&page=$page&rows=$rows"));
    if (response.statusCode == 200) {
      return Audiobook.fromJsonArray(
          json.decode(response.body)['response']['docs']);
    } else {
      throw Exception('Failed to load audiobooks');
    }
  }

  Future<List<AudiobookFile>> getAudiobookFiles(String identifier) async {
    final response = await http.get(Uri.parse(
        "https://archive.org/metadata/$identifier/files?output=json"));
    if (response.statusCode == 200) {
      Map resJson = json.decode(response.body);
      List<AudiobookFile> audiobookFiles = [];
      String? highQCoverImage;
      resJson["result"].forEach((item) {
        if (item["source"] == "original" && item["format"] == "JPEG") {
          highQCoverImage = item["name"];
        }
      });
      resJson["result"].forEach((item) {
        if (item["source"] == "original" && item["track"] != null) {
          item["identifier"] = identifier;
          item["highQCoverImage"] = highQCoverImage;
          audiobookFiles.add(AudiobookFile.fromJson(item));
        }
      });
      return audiobookFiles;
    } else {
      throw Exception('Failed to load audiobooks');
    }
  }
}
