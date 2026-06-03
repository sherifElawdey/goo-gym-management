import 'package:flutter/material.dart';
import 'package:gym_pro_manager/core/l10n/l10n_ext.dart';
import 'package:gym_pro_manager/domain/entities/models.dart';

class GenderSelector extends StatelessWidget {
  const GenderSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final UserGender selected;
  final ValueChanged<UserGender> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.gender, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        SegmentedButton<UserGender>(
          segments: [
            ButtonSegment(
              value: UserGender.male,
              label: Text(l10n.genderMale),
              icon: const Icon(Icons.male_rounded),
            ),
            ButtonSegment(
              value: UserGender.female,
              label: Text(l10n.genderFemale),
              icon: const Icon(Icons.female_rounded),
            ),
          ],
          selected: {selected},
          onSelectionChanged: (selection) {
            if (selection.isNotEmpty) {
              onChanged(selection.first);
            }
          },
        ),
      ],
    );
  }
}
