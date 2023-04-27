import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stackduo/utilities/theme/light_colors.dart';
import 'package:stackduo/utilities/theme/stack_colors.dart';
import 'package:stackduo/widgets/custom_buttons/favorite_toggle.dart';

void main() {
  testWidgets("Test widget build", (widgetTester) async {
    final key = UniqueKey();

    await widgetTester.pumpWidget(
      ProviderScope(
        overrides: [],
        child: MaterialApp(
          theme: ThemeData(
            extensions: [
              StackColors.fromStackColorTheme(
                LightColors(),
              ),
            ],
          ),
          home: FavoriteToggle(
            onChanged: null,
            key: key,
          ),
        ),
      ),
    );

    expect(find.byType(FavoriteToggle), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
  });
}
