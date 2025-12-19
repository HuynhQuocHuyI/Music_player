import 'package:flutter/material.dart';
import '../utils/duration_formatter.dart';

class ProgressBar extends StatelessWidget {
  final Stream<Duration> positionStream;
  final Stream<Duration?> durationStream;
  final Function(Duration) onSeek;

  const ProgressBar({
    super.key,
    required this.positionStream,
    required this.durationStream,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: positionStream,
      builder: (context, positionSnapshot) {
        return StreamBuilder<Duration?>(
          stream: durationStream,
          builder: (context, durationSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            final duration = durationSnapshot.data ?? Duration.zero;
            final progress = duration.inMilliseconds > 0
                ? position.inMilliseconds / duration.inMilliseconds
                : 0.0;

            return Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                  ),
                  child: Slider(
                    value: progress.clamp(0.0, 1.0),
                    onChanged: (value) {
                      final newPosition = Duration(
                        milliseconds:
                            (value * duration.inMilliseconds).round(),
                      );
                      onSeek(newPosition);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DurationFormatter.format(position),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        DurationFormatter.format(duration),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
