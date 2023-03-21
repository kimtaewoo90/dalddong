import 'package:dalddong/dalddongScreens/dalddongVote/dv_vote_screen.dart';
import 'package:dalddong/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() {

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  group('MyWidget tests', () {
    testWidgets('MyWidget has a title', (WidgetTester tester) async {
      // Arrange
      final widget = VoteScreen(dalddongId: 'mnBgFPvhqz35kny', voteDates: [DateTime.now(), DateTime.now(),DateTime.now(),DateTime.now(),DateTime.now()],);

      // Act
      await tester.pumpWidget(widget);

      // Assert
      // expectect(find.text('Test Title'), findsOneWidget);
    });
  });
}
