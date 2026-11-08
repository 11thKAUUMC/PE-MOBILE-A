import 'package:flutter/material.dart';

class EditProfileButton extends StatelessWidget {
  const EditProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: 129,
      height: 41,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
          side: BorderSide(color: colors.primary, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text('프로필 수정'),
      ),
    );
  }
}
