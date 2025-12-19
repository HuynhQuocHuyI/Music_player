import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/main.dart';

void main() {
  testWidgets('Music player app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MusicPlayerApp());
    expect(find.text('Music Player'), findsOneWidget);
  });
}
