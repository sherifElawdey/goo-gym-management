import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_pro_manager/core/l10n/l10n_ext.dart';
import 'package:gym_pro_manager/core/theme/app_spacing.dart';
import 'package:gym_pro_manager/core/utils/app_logger.dart';
import 'package:gym_pro_manager/core/utils/currency_formatter.dart';
import 'package:gym_pro_manager/core/utils/locale_number_parser.dart';
import 'package:gym_pro_manager/core/widgets/app_bottom_sheet.dart';
import 'package:gym_pro_manager/core/widgets/app_empty_state.dart';
import 'package:gym_pro_manager/core/widgets/app_error_view.dart';
import 'package:gym_pro_manager/core/widgets/app_filter_chips.dart';
import 'package:gym_pro_manager/core/widgets/app_loading_view.dart';
import 'package:gym_pro_manager/core/widgets/glass_card.dart';
import 'package:gym_pro_manager/core/widgets/gradient_button.dart';
import 'package:gym_pro_manager/core/widgets/member_avatar.dart';
import 'package:gym_pro_manager/core/widgets/status_badge.dart';
import 'package:gym_pro_manager/features/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:gym_pro_manager/features/attendance/presentation/widgets/register_member_sheet.dart';
import 'package:intl/intl.dart' hide TextDirection;

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _isYesterday(DateTime d) {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return d.year == y.year && d.month == y.month && d.day == y.day;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filters = [
      AppFilterOption(value: 'all', label: l10n.filterAll),
      AppFilterOption(value: 'member', label: l10n.filterMembers),
      AppFilterOption(value: 'non_member', label: l10n.filterVisitors),
    ];

    return BlocBuilder<AttendanceCubit, AttendanceState>(
      builder: (context, state) {
        final cubit = context.read<AttendanceCubit>();
        final selected = state is AttendanceLoadedState ? state.selectedDate : cubit.selectedDate;
        final filter = state is AttendanceLoadedState ? state.filter : cubit.filter;
        final messengerContext = context;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
              child: GradientButton(
                label: l10n.addVisitor,
                icon: Icons.person_add_alt_1_rounded,
                onPressed: () => _showVisitorSheet(context, messengerContext),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
              child: GradientButton(
                label: l10n.registerMemberAttendance,
                icon: Icons.how_to_reg_rounded,
                onPressed: () => _showRegisterMemberSheet(context, messengerContext),
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
              child: Row(
                children: [
                  _DateChip(
                    label: l10n.today,
                    selected: _isToday(selected),
                    onTap: () => cubit.setDate(DateTime.now()),
                  ),
                  _DateChip(
                    label: l10n.yesterday,
                    selected: _isYesterday(selected),
                    onTap: () => cubit.setDate(
                      DateTime.now().subtract(const Duration(days: 1)),
                    ),
                  ),
                  _DateChip(
                    label: DateFormat.MMMd('ar_EG').format(selected),
                    selected: !_isToday(selected) && !_isYesterday(selected),
                    icon: Icons.calendar_month_outlined,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selected,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        locale: const Locale('ar', 'EG'),
                      );
                      if (picked != null) cubit.setDate(picked);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
              child: AppFilterChips(
                options: filters,
                selected: filter,
                onSelected: cubit.setFilter,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildBody(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AttendanceState state) {
    final l10n = context.l10n;
    if (state is AttendanceLoadingState) {
      return const AppLoadingView();
    }
    if (state is AttendanceErrorState) {
      return AppErrorView(
        message: state.message,
        errorTitle: l10n.somethingWentWrong,
        retryLabel: l10n.tryAgain,
        onRetry: () => context.read<AttendanceCubit>().load(),
      );
    }
    if (state is! AttendanceLoadedState) {
      return const SizedBox.shrink();
    }
    if (state.records.isEmpty) {
      return AppEmptyState(
        title: l10n.noCheckInsToday,
        subtitle: l10n.noCheckInsSubtitle,
        icon: Icons.event_busy_rounded,
      );
    }

    final timeFmt = DateFormat.jm('ar_EG');
    return RefreshIndicator(
      onRefresh: () => context.read<AttendanceCubit>().load(),
      child: ListView.builder(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
        itemCount: state.records.length,
        itemBuilder: (context, index) {
          final item = state.records[index];
          final isMember = item.userType == 'member';
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  MemberAvatar(name: item.userName),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.userName, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          timeFmt.format(item.attendanceTime.toLocal()),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (item.amountPaid > 0)
                    Text(
                      CurrencyFormatter.format(item.amountPaid),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  const SizedBox(width: 8),
                  isMember
                      ? StatusBadge.member(context, l10n.memberBadge)
                      : StatusBadge.visitor(context, l10n.visitorBadge),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showRegisterMemberSheet(
    BuildContext context,
    BuildContext messengerContext,
  ) async {
    final l10n = context.l10n;
    final cubit = context.read<AttendanceCubit>();

    await AppBottomSheet.show(
      context: context,
      title: l10n.registerMemberSheetTitle,
      subtitle: l10n.registerMemberSheetSubtitle,
      child: RegisterMemberSheet(
        attendanceCubit: cubit,
        messengerContext: messengerContext,
      ),
    );
  }

  Future<void> _showVisitorSheet(
    BuildContext context,
    BuildContext messengerContext,
  ) async {
    final l10n = context.l10n;
    final cubit = context.read<AttendanceCubit>();
    final messenger = ScaffoldMessenger.of(messengerContext);

    final result = await AppBottomSheet.show<_VisitorInput>(
      context: context,
      title: l10n.newDailyVisitor,
      subtitle: l10n.visitorSheetSubtitle,
      child: const _AddVisitorSheetBody(),
    );

    if (result == null || !context.mounted) return;

    try {
      await cubit.addDailyVisitor(
        name: result.name,
        phone: result.phone,
        amount: result.amount,
      );
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.saveAndCheckIn)),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(AppLogger.userMessage(e))),
      );
    }
  }
}

class _VisitorInput {
  const _VisitorInput({
    required this.name,
    required this.phone,
    required this.amount,
  });

  final String name;
  final String phone;
  final double amount;
}

class _AddVisitorSheetBody extends StatefulWidget {
  const _AddVisitorSheetBody();

  @override
  State<_AddVisitorSheetBody> createState() => _AddVisitorSheetBodyState();
}

class _AddVisitorSheetBodyState extends State<_AddVisitorSheetBody> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: l10n.fullNameRequired,
            prefixIcon: const Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            labelText: l10n.phoneOptional,
            prefixIcon: const Icon(Icons.phone_outlined),
            hintText: l10n.phoneHint,
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _amountController,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            labelText: l10n.sessionPriceRequired,
            prefixIcon: const Icon(Icons.payments_outlined),
            hintText: l10n.amountHint,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 20),
        GradientButton(
          label: l10n.saveAndCheckIn,
          icon: Icons.check_rounded,
          onPressed: () {
            final name = _nameController.text.trim();
            final amount = parseLocalizedDouble(_amountController.text) ?? 0;
            if (name.isEmpty || amount <= 0) return;
            Navigator.of(context).pop(
              _VisitorInput(
                name: name,
                phone: _phoneController.text.trim(),
                amount: amount,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16),
              const SizedBox(width: 4),
            ],
            Text(label),
          ],
        ),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
