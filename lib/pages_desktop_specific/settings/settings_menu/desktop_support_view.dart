import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackduo/pages/settings_views/global_settings_view/support_view.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/themes/stack_colors.dart';
import 'package:stackduo/widgets/desktop/desktop_app_bar.dart';
import 'package:stackduo/widgets/desktop/desktop_scaffold.dart';

class DesktopSupportView extends ConsumerStatefulWidget {
  const DesktopSupportView({Key? key}) : super(key: key);

  static const String routeName = "/desktopSupportView";

  @override
  ConsumerState<DesktopSupportView> createState() => _DesktopSupportView();
}

class _DesktopSupportView extends ConsumerState<DesktopSupportView> {
  @override
  Widget build(BuildContext context) {
    debugPrint("BUILD: $runtimeType");
    return DesktopScaffold(
      background: Theme.of(context).extension<StackColors>()!.background,
      appBar: DesktopAppBar(
        isCompactHeight: true,
        leading: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
            ),
            Text(
              "Support",
              style: STextStyles.desktopH3(context),
            )
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 10, 0, 0),
            child: Row(
              children: const [
                SizedBox(
                  width: 576,
                  child: SupportView(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
