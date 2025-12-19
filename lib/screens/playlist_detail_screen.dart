import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../providers/playlist_provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/song_tile.dart';
import 'now_playing_screen.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final PlaylistModel playlist;
  final List<SongModel> allSongs;

  const PlaylistDetailScreen({
    super.key,
    required this.playlist,
    required this.allSongs,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, playlistProvider, _) {
        final currentPlaylist = playlistProvider.playlists.firstWhere(
          (p) => p.id == playlist.id,
          orElse: () => playlist,
        );
        
        final songsInPlaylist = allSongs
            .where((song) => currentPlaylist.songIds.contains(song.id))
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(currentPlaylist.name),
            actions: [
              if (songsInPlaylist.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => _playAll(context, songsInPlaylist),
                ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showRenameDialog(context, currentPlaylist),
              ),
            ],
          ),
          body: songsInPlaylist.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_off,
                        size: 80,
                        color: Theme.of(context).hintColor,
                      ),
                      const SizedBox(height: 16),
                      const Text('No songs in this playlist'),
                      const SizedBox(height: 8),
                      Text(
                        'Add songs from your library',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.playlist_play,
                              size: 60,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentPlaylist.name,
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${songsInPlaylist.length} songs',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => _playAll(context, songsInPlaylist),
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text('Play All'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: songsInPlaylist.length,
                        itemBuilder: (context, index) {
                          final song = songsInPlaylist[index];
                          return Dismissible(
                            key: Key(song.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) {
                              playlistProvider.removeSongFromPlaylist(
                                currentPlaylist.id,
                                song.id,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Removed "${song.title}"'),
                                ),
                              );
                            },
                            child: SongTile(
                              song: song,
                              onTap: () => _playSong(context, songsInPlaylist, index),
                              onDelete: () {
                                playlistProvider.removeSongFromPlaylist(
                                  currentPlaylist.id,
                                  song.id,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  void _playAll(BuildContext context, List<SongModel> songs) {
    if (songs.isEmpty) return;
    final audioProvider = context.read<AudioProvider>();
    audioProvider.setPlaylist(songs, 0);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
    );
  }

  void _playSong(BuildContext context, List<SongModel> songs, int index) {
    final audioProvider = context.read<AudioProvider>();
    audioProvider.setPlaylist(songs, index);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
    );
  }

  void _showRenameDialog(BuildContext context, PlaylistModel playlist) {
    final controller = TextEditingController(text: playlist.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Playlist'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Playlist name',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  context.read<PlaylistProvider>().renamePlaylist(
                    playlist.id,
                    controller.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
