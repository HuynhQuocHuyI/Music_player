import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlayerControls extends StatelessWidget {
  final bool isShuffleEnabled;
  final LoopMode loopMode;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onShuffle;
  final VoidCallback onRepeat;
  final Stream<bool> playingStream;

  const PlayerControls({
    super.key,
    required this.isShuffleEnabled,
    required this.loopMode,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onShuffle,
    required this.onRepeat,
    required this.playingStream,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(
              Icons.shuffle,
              color: isShuffleEnabled
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).iconTheme.color,
            ),
            iconSize: 28,
            onPressed: onShuffle,
          ),
          IconButton(
            icon: const Icon(Icons.skip_previous),
            iconSize: 40,
            onPressed: onPrevious,
          ),
          StreamBuilder<bool>(
            stream: playingStream,
            builder: (context, snapshot) {
              final isPlaying = snapshot.data ?? false;
              return Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                ),
                child: IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  iconSize: 40,
                  onPressed: onPlayPause,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            iconSize: 40,
            onPressed: onNext,
          ),
          IconButton(
            icon: Icon(
              _getRepeatIcon(),
              color: loopMode != LoopMode.off
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).iconTheme.color,
            ),
            iconSize: 28,
            onPressed: onRepeat,
          ),
        ],
      ),
    );
  }

  IconData _getRepeatIcon() {
    switch (loopMode) {
      case LoopMode.one:
        return Icons.repeat_one;
      case LoopMode.all:
      case LoopMode.off:
        return Icons.repeat;
    }
  }
}
