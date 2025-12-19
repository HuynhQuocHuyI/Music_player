import 'package:on_audio_query/on_audio_query.dart';
import '../models/song_model.dart' as app_models;

class PlaylistService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<List<app_models.SongModel>> getAllSongs() async {
    try {
      final List<SongModel> audioList = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );
      return audioList
          .map((audio) => app_models.SongModel.fromAudioQuery(audio))
          .toList();
    } catch (e) {
      throw Exception('Error loading songs: $e');
    }
  }

  Future<List<app_models.SongModel>> getSongsByArtist(String artist) async {
    final allSongs = await getAllSongs();
    return allSongs.where((song) => song.artist == artist).toList();
  }

  Future<List<app_models.SongModel>> getSongsByAlbum(String album) async {
    final allSongs = await getAllSongs();
    return allSongs.where((song) => song.album == album).toList();
  }

  Future<List<app_models.SongModel>> searchSongs(String query) async {
    final allSongs = await getAllSongs();
    final lowerQuery = query.toLowerCase();
    return allSongs.where((song) {
      return song.title.toLowerCase().contains(lowerQuery) ||
          song.artist.toLowerCase().contains(lowerQuery) ||
          (song.album?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
}
