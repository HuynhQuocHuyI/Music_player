import 'dart:io';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class ColorExtractor {
  static Future<Color> extractDominantColor(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return const Color(0xFF1DB954);
    }

    try {
      final imageProvider = FileImage(File(imagePath));
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
        maximumColorCount: 10,
      );

      return paletteGenerator.dominantColor?.color ?? const Color(0xFF1DB954);
    } catch (e) {
      return const Color(0xFF1DB954);
    }
  }

  static Future<List<Color>> extractColors(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return [const Color(0xFF1DB954), const Color(0xFF191414)];
    }

    try {
      final imageProvider = FileImage(File(imagePath));
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
        maximumColorCount: 5,
      );

      final colors = <Color>[];
      if (paletteGenerator.dominantColor != null) {
        colors.add(paletteGenerator.dominantColor!.color);
      }
      if (paletteGenerator.vibrantColor != null) {
        colors.add(paletteGenerator.vibrantColor!.color);
      }
      if (paletteGenerator.mutedColor != null) {
        colors.add(paletteGenerator.mutedColor!.color);
      }

      if (colors.isEmpty) {
        return [const Color(0xFF1DB954), const Color(0xFF191414)];
      }
      return colors;
    } catch (e) {
      return [const Color(0xFF1DB954), const Color(0xFF191414)];
    }
  }
}
