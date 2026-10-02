import 'package:flutter_test/flutter_test.dart';
import 'package:siega_pokedexlist/main.dart';

void main() {
  testWidgets('PokedexApp loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PokedexApp());

    // Verify that the retro Pokédex banner title is rendered.
    expect(find.text('POKÉDEX'), findsOneWidget);
  });
}
