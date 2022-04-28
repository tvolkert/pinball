import 'dart:async';

import 'package:flame/extensions.dart';
import 'package:pinball_components/pinball_components.dart';
import 'package:sandbox/stories/ball/basic_ball_game.dart';

class AndroidBumperAGame extends BallGame {
  AndroidBumperAGame()
      : super(
          color: const Color(0xFF0000FF),
          imagesFileNames: [
            Assets.images.androidBumper.a.lit.keyName,
            Assets.images.androidBumper.a.dimmed.keyName,
          ],
        );

  static const description = '''
    Shows how a AndroidBumperA is rendered.

    - Activate the "trace" parameter to overlay the body.
''';

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.followVector2(Vector2.zero());
    await add(
      AndroidBumper.a()..priority = 1,
    );

    await traceAllBodies();
  }
}