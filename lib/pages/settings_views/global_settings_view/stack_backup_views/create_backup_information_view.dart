import 'package:flutter/material.dart';
import 'package:stackduo/pages/settings_views/global_settings_view/stack_backup_views/create_backup_view.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/utilities/theme/stack_colors.dart';
import 'package:stackduo/widgets/background.dart';
import 'package:stackduo/widgets/custom_buttons/app_bar_icon_button.dart';
import 'package:stackduo/widgets/rounded_white_container.dart';

class CreateBackupInfoView extends StatelessWidget {
  const CreateBackupInfoView({Key? key}) : super(key: key);

  static const String routeName = "/createBackupInfo";

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Scaffold(
        backgroundColor: Theme.of(context).extension<StackColors>()!.background,
        appBar: AppBar(
          leading: AppBarBackButton(
            onPressed: () async {
              if (FocusScope.of(context).hasFocus) {
                FocusScope.of(context).unfocus();
                await Future<void>.delayed(const Duration(milliseconds: 75));
              }
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            "Create backup",
            style: STextStyles.navBarTitle(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Text(
                            "Info",
                            style: STextStyles.pageTitleH2(context),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        RoundedWhiteContainer(
                          child: Text(
                            // TODO: need info
                            "{lorem ipsum}",
                            style: STextStyles.baseXS(context),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        const Spacer(),
                        TextButton(
                          style: Theme.of(context)
                              .extension<StackColors>()!
                              .getPrimaryEnabledButtonStyle(context),
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(CreateBackupView.routeName);
                          },
                          child: Text(
                            "Next",
                            style: STextStyles.button(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
