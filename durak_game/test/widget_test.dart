import 'package:flutter_test/flutter_test.dart';
import 'package:durak_game/main.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Main menu smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => GameEngineWrapper()),
        ],
        child: const DurakApp(),
      ),
    );

    expect(find.text('Durak Game'), findsOneWidget);
    expect(find.text('Host Game'), findsOneWidget);
    expect(find.text('Join Game'), findsOneWidget);
  });
}
