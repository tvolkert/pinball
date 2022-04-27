// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinball/game/game.dart';
import 'package:pinball/l10n/l10n.dart';
import 'package:pinball_components/pinball_components.dart';
import '../../../helpers/helpers.dart';

void main() {
  group('GameHud', () {
    late GameBloc gameBloc;

    const initialState = GameState(
      score: 1000,
      balls: 2,
      bonusHistory: [],
    );

    setUp(() async {
      gameBloc = MockGameBloc();
      await Future.wait<void>(BonusAnimation.loadAssets());

      whenListen(
        gameBloc,
        Stream.value(initialState),
        initialState: initialState,
      );
    });

    // We cannot use pumpApp when we are testing animation because
    // animation tests needs to be run and check in tester.runAsync
    Future<void> _pumpAppWithWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: BlocProvider<GameBloc>.value(
              value: gameBloc,
              child: GameHud(),
            ),
          ),
        ),
      );
    }

    group('renders ScoreView widget', () {
      testWidgets(
        'with the score',
        (tester) async {
          await tester.pumpApp(
            GameHud(),
            gameBloc: gameBloc,
          );

          expect(find.text(initialState.score.formatScore()), findsOneWidget);
        },
      );

      testWidgets(
        'on game over',
        (tester) async {
          final state = initialState.copyWith(
            bonusHistory: [GameBonus.dashNest],
            balls: 0,
          );

          whenListen(
            gameBloc,
            Stream.value(state),
            initialState: initialState,
          );
          await tester.pumpApp(
            GameHud(),
            gameBloc: gameBloc,
          );

          expect(find.byType(ScoreView), findsOneWidget);
          expect(find.byType(BonusAnimation), findsNothing);
        },
      );
    });

    for (final gameBonus in GameBonus.values) {
      testWidgets('renders BonusAnimation for $gameBonus', (tester) async {
        await tester.runAsync(() async {
          final state = initialState.copyWith(
            bonusHistory: [gameBonus],
          );
          whenListen(
            gameBloc,
            Stream.value(state),
            initialState: initialState,
          );

          await _pumpAppWithWidget(tester);
          await tester.pump();

          expect(find.byType(BonusAnimation), findsOneWidget);
        });
      });
    }

    testWidgets(
      'goes back to ScoreView after the animation',
      (tester) async {
        await tester.runAsync(() async {
          final state = initialState.copyWith(
            bonusHistory: [GameBonus.dashNest],
          );
          whenListen(
            gameBloc,
            Stream.value(state),
            initialState: initialState,
          );

          await _pumpAppWithWidget(tester);
          await tester.pump();
          // TODO(arturplaczek): remove magic number once this is merged:
          // https://github.com/flame-engine/flame/pull/1564
          await Future<void>.delayed(const Duration(seconds: 4));

          await expectLater(find.byType(ScoreView), findsOneWidget);
        });
      },
    );
  });
}