import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/audio_provider.dart';
import '../services/permission_service.dart';
import '../services/playlist_service.dart';
import '../models/song_model.dart';
import '../widgets/mini_player.dart';
import '../widgets/song_tile.dart';
import 'now_playing_screen.dart';
import 'all_songs_screen.dart';
import 'playlist_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PermissionService _permissionService = PermissionService();
  final PlaylistService _playlistService = PlaylistService();
  List<SongModel> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (!kIsWeb) {
      final hasStoragePermission =
          await _permissionService.requestStoragePermission();
      final hasAudioPermission =
          await _permissionService.requestAudioPermission();

      if (hasStoragePermission || hasAudioPermission) {
        await _loadSongs();
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadSongs() async {
    if (kIsWeb) return;
    try {
      final songs = await _playlistService.getAllSongs();
      setState(() {
        _songs = songs;
      });
    } catch (e) {
      debugPrint('Error loading songs: $e');
    }
  }

  void _removeSong(int index) {
    setState(() {
      _songs.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Song removed')),
    );
  }

  Future<void> _pickAndPlayMusic() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
        withData: kIsWeb,
      );

      if (result != null && result.files.isNotEmpty) {
        List<SongModel> pickedSongs = [];
        for (var file in result.files) {
          String fileName = file.name.replaceAll(RegExp(r'\.[^.]+$'), '');
          
          if (kIsWeb) {
            if (file.bytes != null) {
              pickedSongs.add(SongModel(
                id: DateTime.now().millisecondsSinceEpoch.toString() + file.name,
                title: fileName,
                artist: 'Unknown Artist',
                filePath: file.name,
                fileSize: file.size,
                bytes: file.bytes,
              ));
            }
          } else {
            if (file.path != null) {
              pickedSongs.add(SongModel(
                id: DateTime.now().millisecondsSinceEpoch.toString() + file.name,
                title: fileName,
                artist: 'Unknown Artist',
                filePath: file.path!,
                fileSize: file.size,
              ));
            }
          }
        }

        if (pickedSongs.isNotEmpty) {
          setState(() {
            _songs = [...pickedSongs, ..._songs];
          });

          if (mounted) {
            final messenger = ScaffoldMessenger.of(context);
            messenger.showSnackBar(
              SnackBar(
                content: Text('Added ${pickedSongs.length} song(s)'),
                backgroundColor: Theme.of(context).primaryColor,
              ),
            );

            final audioProvider = context.read<AudioProvider>();
            audioProvider.setPlaylist(_songs, 0);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              _buildHomeContent(),
              AllSongsScreen(
                songs: _songs, 
                onRefresh: _loadSongs,
                onDeleteSong: _removeSong,
              ),
              PlaylistScreen(allSongs: _songs),
              const SettingsScreen(),
            ],
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 56,
            child: MiniPlayer(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndPlayMusic,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music_outlined),
            activeIcon: Icon(Icons.library_music),
            label: 'Songs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_play_outlined),
            activeIcon: Icon(Icons.playlist_play),
            label: 'Playlists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadSongs,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              title: const Text('Music Player'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.folder_open),
                  onPressed: _pickAndPlayMusic,
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
              ],
            ),
            if (_songs.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_off,
                        size: 80,
                        color: Theme.of(context).hintColor,
                      ),
                      const SizedBox(height: 16),
                      const Text('No songs found'),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _pickAndPlayMusic,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Music'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Recently Played',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _songs.take(10).length,
                    itemBuilder: (context, index) {
                      final song = _songs[index];
                      return _buildRecentCard(song, index);
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'All Songs',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 140),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = _songs[index];
                      return SongTile(
                        song: song,
                        onTap: () => _playSong(index),
                        onDelete: () => _removeSong(index),
                      );
                    },
                    childCount: _songs.length,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCard(SongModel song, int index) {
    return GestureDetector(
      onTap: () => _playSong(index),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.music_note, size: 60),
            ),
            const SizedBox(height: 8),
            Text(
              song.title,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              song.artist,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _playSong(int index) {
    final audioProvider = context.read<AudioProvider>();
    audioProvider.setPlaylist(_songs, index);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
    );
  }
}
