import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../widgets/song_tile.dart';
import 'now_playing_screen.dart';

class AllSongsScreen extends StatefulWidget {
  final List<SongModel> songs;
  final VoidCallback onRefresh;

  const AllSongsScreen({
    super.key,
    required this.songs,
    required this.onRefresh,
  });

  @override
  State<AllSongsScreen> createState() => _AllSongsScreenState();
}

class _AllSongsScreenState extends State<AllSongsScreen> {
  String _searchQuery = '';
  List<SongModel> _filteredSongs = [];

  @override
  void initState() {
    super.initState();
    _filteredSongs = widget.songs;
  }

  @override
  void didUpdateWidget(AllSongsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.songs != oldWidget.songs) {
      _filterSongs(_searchQuery);
    }
  }

  void _filterSongs(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredSongs = widget.songs;
      } else {
        _filteredSongs = widget.songs.where((song) {
          return song.title.toLowerCase().contains(query.toLowerCase()) ||
              song.artist.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: _filterSongs,
              decoration: InputDecoration(
                hintText: 'Search songs...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredSongs.length} songs',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextButton.icon(
                  onPressed: () => _playAll(context),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play All'),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => widget.onRefresh(),
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 140),
                itemCount: _filteredSongs.length,
                itemBuilder: (context, index) {
                  final song = _filteredSongs[index];
                  return SongTile(
                    song: song,
                    onTap: () => _playSong(context, index),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _playSong(BuildContext context, int index) {
    final audioProvider = context.read<AudioProvider>();
    audioProvider.setPlaylist(_filteredSongs, index);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
    );
  }

  void _playAll(BuildContext context) {
    if (_filteredSongs.isNotEmpty) {
      _playSong(context, 0);
    }
  }
}
