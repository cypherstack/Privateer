import 'package:flutter/material.dart';
import 'package:stackduo/utilities/constants.dart';
import 'package:stackduo/utilities/text_styles.dart';
import 'package:stackduo/themes/stack_colors.dart';

class ThemeOption<T> extends StatelessWidget {
  const ThemeOption({
    Key? key,
    required this.onPressed,
    required this.onChanged,
    required this.label,
    required this.value,
    required this.groupValue,
  }) : super(key: key);

  final VoidCallback onPressed;
  final void Function(Object?) onChanged;
  final String label;
  final T value;
  final T groupValue;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      padding: const EdgeInsets.all(0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          Constants.size.circularBorderRadius,
        ),
      ),
      onPressed: onPressed,
      child: SizedBox(
        width: 200,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Radio<T>(
                    activeColor: Theme.of(context)
                        .extension<StackColors>()!
                        .radioButtonIconEnabled,
                    value: value,
                    groupValue: groupValue,
                    onChanged: onChanged,
                  ),
                ),
                const SizedBox(
                  width: 14,
                ),
                Text(
                  label,
                  style: STextStyles.desktopTextExtraSmall(context).copyWith(
                    color:
                        Theme.of(context).extension<StackColors>()!.textDark2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
