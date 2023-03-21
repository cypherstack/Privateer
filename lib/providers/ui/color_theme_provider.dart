import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackduo/utilities/theme/light_colors.dart';
import 'package:stackduo/utilities/theme/stack_colors.dart';

final colorThemeProvider = StateProvider<StackColors>(
    (ref) => StackColors.fromStackColorTheme(LightColors()));
