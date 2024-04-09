import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:librivox_audiobook/resources/archive_api.dart';
import 'package:librivox_audiobook/resources/models/audiobook.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController _latestAudiobookScrollController = ScrollController();
  final ScrollController _mostViewedWeeklyScrollController = ScrollController();
  final ScrollController _mostDownloadedEverScrollController =
      ScrollController();
  final ArchiveApi _fetchAudiobookDetails = ArchiveApi();
  List<Audiobook> _latestAudiobooks = [];
  List<Audiobook> _mostViewedWeeklyAudiobooks = [];
  List<Audiobook> _mostDownloadedEverAudiobooks = [];
  bool _isLatestAudiobookLoading = false;
  bool _isMostViewedWeeklyLoading = false;
  bool _isMostDownloadedEverLoading = false;
  int _currentPageForLatestAudiobook = 1;
  int _currentPageForMostViewedWeekly = 1;
  int _currentPageForMostDownloadedEver = 1;

  final double _eachContainerWidth = 175;

  @override
  void initState() {
    super.initState();

    _latestAudiobookScrollController
        .addListener(_latestAudiobookScrollListener);
    _mostViewedWeeklyScrollController
        .addListener(_mostViewedAudiobookScrollListener);
    _mostDownloadedEverScrollController
        .addListener(_mostDownloadedEverAudiobookScrollListener);
    _fetchLatestAutiobookData();
    _fetchMostViewedWeeklyAudiobookData();
    _fetchMostDownloadedEverAudiobookData();
  }

  void _latestAudiobookScrollListener() {
    if (_latestAudiobookScrollController.position.pixels ==
        _latestAudiobookScrollController.position.maxScrollExtent) {
      _fetchLatestAutiobookData();
    }
  }

  void _mostViewedAudiobookScrollListener() {
    if (_mostViewedWeeklyScrollController.position.pixels ==
        _mostViewedWeeklyScrollController.position.maxScrollExtent) {
      _fetchMostViewedWeeklyAudiobookData();
    }
  }

  void _mostDownloadedEverAudiobookScrollListener() {
    if (_mostDownloadedEverScrollController.position.pixels ==
        _mostDownloadedEverScrollController.position.maxScrollExtent) {
      _fetchMostDownloadedEverAudiobookData();
    }
  }

  Future<void> _fetchLatestAutiobookData() async {
    if (!_isLatestAudiobookLoading) {
      setState(() {
        _isLatestAudiobookLoading = true;
      });
      try {
        final List<Audiobook> newData = await _fetchAudiobookDetails
            .getLatestAudiobook(_currentPageForLatestAudiobook, 10);
        setState(() {
          _latestAudiobooks.addAll(newData);
          _currentPageForLatestAudiobook++;
        });
      } catch (error) {
        print('Error fetching latest audiobooks: $error');
      } finally {
        setState(() {
          _isLatestAudiobookLoading = false;
        });
      }
    }
  }

  Future<void> _fetchMostViewedWeeklyAudiobookData() async {
    if (!_isMostViewedWeeklyLoading) {
      setState(() {
        _isMostViewedWeeklyLoading = true;
      });
      try {
        final List<Audiobook> newData = await _fetchAudiobookDetails
            .getMostViewedWeeklyAudiobook(_currentPageForMostViewedWeekly, 10);
        setState(() {
          _mostViewedWeeklyAudiobooks.addAll(newData);
          _currentPageForMostViewedWeekly++;
        });
      } catch (error) {
        print('Error fetching most viewed weekly audiobooks: $error');
      } finally {
        setState(() {
          _isMostViewedWeeklyLoading = false;
        });
      }
    }
  }

  Future<void> _fetchMostDownloadedEverAudiobookData() async {
    if (!_isMostDownloadedEverLoading) {
      setState(() {
        _isMostDownloadedEverLoading = true;
      });
      try {
        final List<Audiobook> newData =
            await _fetchAudiobookDetails.getMostDownloadedEverAudiobook(
                _currentPageForMostDownloadedEver, 10);
        setState(() {
          _mostDownloadedEverAudiobooks.addAll(newData);
          _currentPageForMostDownloadedEver++;
        });
      } catch (error) {
        print('Error fetching most downloaded ever audiobooks: $error');
      } finally {
        setState(() {
          _isMostDownloadedEverLoading = false;
        });
      }
    }
  }

  // This method is called when the user pulls down the screen
  // Currenlty, it is not implemented but we can implement it
  // using RefreshIndicator widget ...

  Future<void> _refreshData() async {
    setState(() {
      _latestAudiobooks = [];
      _mostViewedWeeklyAudiobooks = [];
      _mostDownloadedEverAudiobooks = [];
      _currentPageForLatestAudiobook = 1;
      _currentPageForMostViewedWeekly = 1;
      _currentPageForMostDownloadedEver = 1;
    });
    await _fetchLatestAutiobookData();
    await _fetchMostViewedWeeklyAudiobookData();
    await _fetchMostDownloadedEverAudiobookData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Librivox',
          style: GoogleFonts.ubuntu(),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ' Most Popular',
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    controller: _mostDownloadedEverScrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: _mostDownloadedEverAudiobooks.length + 1,
                    itemBuilder: (context, index) {
                      if (index < _mostDownloadedEverAudiobooks.length) {
                        return _buildAudiobookItem(
                            _mostDownloadedEverAudiobooks[index]);
                      } else if (_isMostDownloadedEverLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.orange,
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
                Text(
                  ' Popular This Week',
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    controller: _mostViewedWeeklyScrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: _mostViewedWeeklyAudiobooks.length + 1,
                    itemBuilder: (context, index) {
                      if (index < _mostViewedWeeklyAudiobooks.length) {
                        return _buildAudiobookItem(
                            _mostViewedWeeklyAudiobooks[index]);
                      } else if (_isMostViewedWeeklyLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.orange,
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
                Text(
                  ' Latest Audiobooks',
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    controller: _latestAudiobookScrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: _latestAudiobooks.length + 1,
                    itemBuilder: (context, index) {
                      if (index < _latestAudiobooks.length) {
                        return _buildAudiobookItem(_latestAudiobooks[index]);
                      } else if (_isLatestAudiobookLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.orange,
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAudiobookItem(Audiobook audiobook) {
    return Ink(
      width: _eachContainerWidth,
      height: 250,
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        child: InkWell(
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ),
          splashColor: Colors.orange,
          splashFactory: InkRipple.splashFactory,
          onTap: () {
            // Go to page audiobook_details_page.dart
            context.pushNamed('/audiobook_details', extra: audiobook);
            print('Tapped on ${audiobook.title}');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: CachedNetworkImage(
                  imageUrl: audiobook.lowQCoverImage,
                  width: _eachContainerWidth,
                  height: _eachContainerWidth,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: _eachContainerWidth,
                      child: Text(
                        audiobook.title,
                        style: GoogleFonts.ubuntu(
                          textStyle: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 14,
                          ),
                        ),
                        maxLines: 1,
                      ),
                    ),
                    Text(
                      audiobook.author ?? 'Unknown',
                      style: GoogleFonts.ubuntu(
                        textStyle: const TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: 12,
                        ),
                      ),
                      maxLines: 1,
                    ),
                    _buildRatingWidget(audiobook.rating ?? 0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingWidget(double rating) {
    return Row(
      children: [
        for (int i = 0; i < 5; i++)
          if (i < rating.floor())
            const Icon(
              Icons.star,
              color: Colors.orange,
              size: 14,
            )
          else if (i == rating.floor() && rating % 1 != 0)
            const Icon(
              Icons.star_half,
              color: Colors.orange,
              size: 14,
            )
          else
            const Icon(
              Icons.star_border,
              color: Colors.orange,
              size: 14,
            )
      ],
    );
  }

  @override
  void dispose() {
    _latestAudiobookScrollController.dispose();
    _mostViewedWeeklyScrollController.dispose();
    _mostDownloadedEverScrollController.dispose();
    super.dispose();
  }
}
