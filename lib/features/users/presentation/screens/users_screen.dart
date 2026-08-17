import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_pro_manager/core/constants/app_constants.dart';
import 'package:gym_pro_manager/core/l10n/l10n_ext.dart';
import 'package:gym_pro_manager/core/theme/app_colors.dart';
import 'package:gym_pro_manager/core/theme/app_spacing.dart';
import 'package:gym_pro_manager/core/utils/app_logger.dart';
import 'package:gym_pro_manager/core/utils/currency_formatter.dart';
import 'package:gym_pro_manager/core/utils/locale_number_parser.dart';
import 'package:gym_pro_manager/core/widgets/app_bottom_sheet.dart';
import 'package:gym_pro_manager/core/widgets/app_empty_state.dart';
import 'package:gym_pro_manager/core/widgets/app_error_view.dart';
import 'package:gym_pro_manager/core/widgets/app_filter_chips.dart';
import 'package:gym_pro_manager/core/widgets/app_loading_view.dart';
import 'package:gym_pro_manager/core/widgets/app_search_field.dart';
import 'package:gym_pro_manager/core/widgets/glass_card.dart';
import 'package:gym_pro_manager/core/widgets/gradient_button.dart';
import 'package:gym_pro_manager/core/widgets/member_avatar.dart';
import 'package:gym_pro_manager/core/widgets/status_badge.dart';
import 'package:gym_pro_manager/domain/entities/models.dart';
import 'package:gym_pro_manager/features/users/presentation/cubit/users_cubit.dart';
import 'package:gym_pro_manager/features/users/presentation/screens/member_profile_screen.dart';
import 'package:gym_pro_manager/features/users/presentation/widgets/gender_selector.dart';
import 'package:intl/intl.dart' hide TextDirection;

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filters = [
      AppFilterOption(value: 'all', label: l10n.filterAll),
      AppFilterOption(value: 'members', label: l10n.filterMembers),
      AppFilterOption(value: 'non_members', label: l10n.filterVisitors),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
          child: GradientButton(
            label: l10n.addMember,
            icon: Icons.person_add_rounded,
            onPressed: () => _showAddMemberSheet(context),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
          child: AppSearchField(
            hintText: l10n.searchNameOrPhone,
            onChanged: (v) => context.read<UsersCubit>().search(v),
          ),
        ),
        const SizedBox(height: 8),
        BlocBuilder<UsersCubit, UsersState>(
          builder: (context, state) {
            final filter = state is UsersLoadedState ? state.filter : 'all';
            return AppFilterChips(
              options: filters,
              selected: filter,
              onSelected: context.read<UsersCubit>().setFilter,
            );
          },
        ),
        BlocBuilder<UsersCubit, UsersState>(
          builder: (context, state) {
            if (state is! UsersLoadedState || state.filter != 'members') {
              return const SizedBox.shrink();
            }
            final genderFilters = [
              AppFilterOption(value: 'all', label: l10n.filterGenderAll),
              AppFilterOption(value: 'male', label: l10n.genderMale),
              AppFilterOption(value: 'female', label: l10n.genderFemale),
            ];
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AppFilterChips(
                options: genderFilters,
                selected: state.genderFilter,
                onSelected: context.read<UsersCubit>().setGenderFilter,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        BlocBuilder<UsersCubit, UsersState>(
          builder: (context, state) {
            if (state is! UsersLoadedState || state.filter != 'members') {
              return const SizedBox.shrink();
            }
            final cubit = context.read<UsersCubit>();
            return _MembersSubscriptionControls(
              subscriptionMonth: state.subscriptionMonth,
              subscriptionSort: state.subscriptionSort,
              onMonthChanged: cubit.setSubscriptionMonth,
              onSortChanged: cubit.setSubscriptionSort,
            );
          },
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildBody(context)),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<UsersCubit, UsersState>(
      builder: (context, state) {
        if (state is UsersLoadingState) {
          return const AppLoadingView();
        }
        if (state is UsersErrorState) {
          return AppErrorView(
            message: state.message,
            errorTitle: l10n.somethingWentWrong,
            retryLabel: l10n.tryAgain,
            onRetry: () => context.read<UsersCubit>().load(),
          );
        }
        if (state is! UsersLoadedState || state.users.isEmpty) {
          final hasMonthFilter =
              state is UsersLoadedState &&
              state.filter == 'members' &&
              state.subscriptionMonth != null;
          return AppEmptyState(
            title: state is UsersLoadedState && (state.query.isNotEmpty || hasMonthFilter)
                ? l10n.noResultsFound
                : l10n.noMembersYet,
            subtitle: state is UsersLoadedState && state.query.isNotEmpty
                ? l10n.tryDifferentSearch
                : state is UsersLoadedState && hasMonthFilter
                    ? l10n.tryDifferentSearch
                    : l10n.addMembersFromButton,
            icon: Icons.people_outline_rounded,
          );
        }
        final dateFmt = DateFormat.yMMMd('ar_EG');
        return RefreshIndicator(
          onRefresh: () => context.read<UsersCubit>().load(),
          child: ListView.builder(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
            itemCount: state.users.length,
            itemBuilder: (context, index) {
              final user = state.users[index];
              return Padding(
                key: ValueKey(user.id),
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: GlassCard(
                  onTap: () {
                    MemberProfileScreen.open(
                      context,
                      user: user,
                      usersCubit: context.read<UsersCubit>(),
                      onChanged: () => context.read<UsersCubit>().load(silent: true),
                    );
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      MemberAvatar(name: user.name),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text(
                              user.phone.isEmpty ? l10n.noPhone : user.phone,
                              style: Theme.of(context).textTheme.bodyMedium,
                              textDirection: TextDirection.ltr,
                            ),
                            if (user.activeSubscription != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${l10n.subscriptionEndDate}: ${dateFmt.format(user.activeSubscription!.endDate)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (user.isMember) ...[
                        const SizedBox(width: 4),
                        StatusBadge(
                          label: user.gender == UserGender.female
                              ? l10n.genderFemale
                              : l10n.genderMale,
                          color: user.gender == UserGender.female
                              ? AppColors.accentRed
                              : AppColors.primary,
                        ),
                      ],
                      const SizedBox(width: 4),
                      user.isMember
                          ? StatusBadge.member(context, l10n.memberBadge)
                          : StatusBadge.visitor(context, l10n.visitorBadge),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_left_rounded,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showAddMemberSheet(BuildContext context) async {
    final l10n = context.l10n;
    final cubit = context.read<UsersCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final result = await AppBottomSheet.show<_AddMemberInput>(
      context: context,
      title: l10n.newMemberSheetTitle,
      subtitle: l10n.newMemberSheetSubtitle,
      child: _AddMemberSheetBody(usersCubit: cubit),
    );

    if (result == null || !context.mounted) return;

    try {
      if (result.renewUserId != null) {
        final amount = result.subscriptionFee - result.discount;
        final startKey = DateTime(
          result.startDate.year,
          result.startDate.month,
          result.startDate.day,
        );
        final endDate = startKey.add(
          const Duration(days: AppConstants.defaultSubscriptionDurationDays),
        );
        await cubit.updateUser(
          userId: result.renewUserId!,
          name: result.name,
          phone: result.phone,
        );
        await cubit.renewMemberSubscription(
          userId: result.renewUserId!,
          startDate: startKey,
          endDate: endDate,
          amount: amount,
        );
        if (!context.mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.subscriptionRenewed)),
        );
      } else {
        await cubit.addMember(
          name: result.name,
          phone: result.phone,
          startDate: result.startDate,
          gender: result.gender,
          subscriptionFee: result.subscriptionFee,
          discount: result.discount,
        );
        if (!context.mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.memberAddedSuccess)),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(AppLogger.userMessage(e))),
      );
    }
  }
}

class _MembersSubscriptionControls extends StatelessWidget {
  const _MembersSubscriptionControls({
    required this.subscriptionMonth,
    required this.subscriptionSort,
    required this.onMonthChanged,
    required this.onSortChanged,
  });

  final DateTime? subscriptionMonth;
  final String subscriptionSort;
  final ValueChanged<DateTime?> onMonthChanged;
  final ValueChanged<String> onSortChanged;

  static const _allMonthsValue = 'all';

  static String _monthKey(DateTime month) =>
      '${month.year}-${month.month.toString().padLeft(2, '0')}';

  static DateTime? _monthFromKey(String key) {
    if (key == _allMonthsValue) return null;
    final parts = key.split('-');
    if (parts.length != 2) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    if (year == null || month == null) return null;
    return DateTime(year, month, 1);
  }

  static List<DateTime> _monthOptions({int count = 24}) {
    final now = DateTime.now();
    return List.generate(count, (i) => DateTime(now.year, now.month - i, 1));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final monthFmt = DateFormat.yMMMM('ar_EG');
    final selectedMonthKey =
        subscriptionMonth != null ? _monthKey(subscriptionMonth!) : _allMonthsValue;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: selectedMonthKey,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.filterByMonth,
              isDense: true,
              prefixIcon: const Icon(Icons.calendar_month_rounded, size: 20),
            ),
            items: [
              DropdownMenuItem(
                value: _allMonthsValue,
                child: Text(l10n.clearMonthFilter),
              ),
              ..._monthOptions().map(
                (month) => DropdownMenuItem(
                  value: _monthKey(month),
                  child: Text(monthFmt.format(month)),
                ),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              onMonthChanged(_monthFromKey(value));
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: subscriptionSort,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.sortMembersBy,
              isDense: true,
              prefixIcon: const Icon(Icons.sort_rounded, size: 20),
            ),
            items: [
              DropdownMenuItem(value: 'none', child: Text(l10n.sortByDefault)),
              DropdownMenuItem(
                value: 'start_asc',
                child: Text('${l10n.sortByStartDate} — ${l10n.sortAscending}'),
              ),
              DropdownMenuItem(
                value: 'start_desc',
                child: Text('${l10n.sortByStartDate} — ${l10n.sortDescending}'),
              ),
              DropdownMenuItem(
                value: 'end_asc',
                child: Text('${l10n.sortByEndDate} — ${l10n.sortAscending}'),
              ),
              DropdownMenuItem(
                value: 'end_desc',
                child: Text('${l10n.sortByEndDate} — ${l10n.sortDescending}'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              onSortChanged(value);
            },
          ),
        ],
      ),
    );
  }
}

class _AddMemberInput {
  const _AddMemberInput({
    required this.name,
    required this.phone,
    required this.startDate,
    required this.gender,
    required this.subscriptionFee,
    required this.discount,
    this.renewUserId,
  });

  final String name;
  final String phone;
  final DateTime startDate;
  final UserGender gender;
  final double subscriptionFee;
  final double discount;
  final String? renewUserId;
}

class _AddMemberSheetBody extends StatefulWidget {
  const _AddMemberSheetBody({required this.usersCubit});

  final UsersCubit usersCubit;

  @override
  State<_AddMemberSheetBody> createState() => _AddMemberSheetBodyState();
}

class _AddMemberSheetBodyState extends State<_AddMemberSheetBody> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _feeController = TextEditingController(
    text: AppConstants.defaultMonthlySubscriptionFeeEgp.toStringAsFixed(0),
  );
  final _discountController = TextEditingController();
  DateTime _startDate = DateTime.now();
  UserGender _gender = UserGender.male;
  GymUser? _selectedUser;
  List<GymUser> _candidates = const [];
  bool _loadingCandidates = true;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    try {
      final users = await widget.usersCubit.loadUsersForSuggestion();
      if (!mounted) return;
      setState(() {
        _candidates = users;
        _loadingCandidates = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingCandidates = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nameFocusNode.dispose();
    _feeController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _selectUser(GymUser user) {
    final now = DateTime.now();
    final fee = user.activeSubscription?.amount ??
        AppConstants.defaultMonthlySubscriptionFeeEgp;
    setState(() {
      _selectedUser = user;
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      _gender = user.gender;
      _startDate = DateTime(now.year, now.month, now.day);
      _feeController.text = fee.toStringAsFixed(0);
      _discountController.clear();
    });
    _nameFocusNode.unfocus();
  }

  void _clearSelection() {
    setState(() => _selectedUser = null);
  }

  List<GymUser> _filterCandidates(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty || _selectedUser != null) return const [];
    return _candidates
        .where((u) {
          final name = u.name.toLowerCase();
          final phone = u.phone.toLowerCase();
          return name.contains(q) || (phone.isNotEmpty && phone.contains(q));
        })
        .take(8)
        .toList();
  }

  void _submit() {
    final l10n = context.l10n;
    final name = _nameController.text.trim();
    final feeValue = parseLocalizedDouble(_feeController.text);
    final discountValue = parseLocalizedDouble(_discountController.text.trim()) ?? 0;
    if (name.isEmpty) return;
    if (feeValue == null || feeValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invalidSubscriptionFee)),
      );
      return;
    }
    if (discountValue < 0 || discountValue > feeValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invalidDiscount)),
      );
      return;
    }
    Navigator.of(context).pop(
      _AddMemberInput(
        name: name,
        phone: _phoneController.text.trim(),
        startDate: _startDate,
        gender: _gender,
        subscriptionFee: feeValue,
        discount: discountValue,
        renewUserId: _selectedUser?.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateFmt = DateFormat.yMMMd('ar_EG');
    final subscriptionFee = parseLocalizedDouble(_feeController.text) ?? 0;
    final discount = parseLocalizedDouble(_discountController.text.trim()) ?? 0;
    final amount = subscriptionFee - discount;
    final endDate = DateTime(_startDate.year, _startDate.month, _startDate.day).add(
      const Duration(days: AppConstants.defaultSubscriptionDurationDays),
    );
    final isRenew = _selectedUser != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isRenew) ...[
          Material(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            child: ListTile(
              contentPadding: const EdgeInsetsDirectional.only(start: 12, end: 4),
              leading: const Icon(Icons.autorenew_rounded, color: AppColors.primary),
              title: Text(l10n.renewExistingMemberBanner(_selectedUser!.name)),
              subtitle: Text(l10n.renewExistingMemberTitle),
              trailing: IconButton(
                onPressed: _clearSelection,
                icon: const Icon(Icons.close_rounded),
                tooltip: l10n.clearSelectedMember,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        RawAutocomplete<GymUser>(
          textEditingController: _nameController,
          focusNode: _nameFocusNode,
          optionsBuilder: (TextEditingValue value) {
            if (_loadingCandidates || isRenew) {
              return const Iterable<GymUser>.empty();
            }
            return _filterCandidates(value.text);
          },
          displayStringForOption: (user) => user.name,
          onSelected: _selectUser,
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.fullNameRequired,
                hintText: l10n.memberSuggestionsHint,
                prefixIcon: const Icon(Icons.person_outline),
                suffixIcon: _loadingCandidates
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            final list = options.toList();
            if (list.isEmpty) return const SizedBox.shrink();
            return Align(
              alignment: AlignmentDirectional.topStart,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240, minWidth: 280),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final user = list[index];
                      return ListTile(
                        dense: true,
                        leading: MemberAvatar(name: user.name, size: 36),
                        title: Text(user.name),
                        subtitle: user.phone.isEmpty
                            ? null
                            : Text(user.phone, textDirection: TextDirection.ltr),
                        trailing: user.isMember
                            ? StatusBadge.member(context, l10n.memberBadge)
                            : StatusBadge.visitor(context, l10n.visitorBadge),
                        onTap: () => onSelected(user),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _startDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              locale: const Locale('ar', 'EG'),
            );
            if (picked != null) {
              setState(() => _startDate = picked);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: l10n.subscriptionStartDate,
              prefixIcon: const Icon(Icons.calendar_today_outlined),
              suffixIcon: const Icon(Icons.chevron_left_rounded),
            ),
            child: Text(dateFmt.format(_startDate)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _feeController,
          textDirection: TextDirection.ltr,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: l10n.subscriptionFeeRequired,
            prefixIcon: const Icon(Icons.payments_outlined),
            hintText: l10n.amountHint,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.subscriptionSummary(
            CurrencyFormatter.format(amount > 0 ? amount : 0),
            dateFmt.format(endDate),
          ),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 12),
        GenderSelector(
          selected: _gender,
          onChanged: (g) => setState(() => _gender = g),
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
          controller: _discountController,
          textDirection: TextDirection.ltr,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: l10n.discountOptional,
            prefixIcon: const Icon(Icons.discount_outlined),
            hintText: l10n.amountHint,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 20),
        GradientButton(
          label: isRenew ? l10n.renewSubscription : l10n.saveMember,
          icon: isRenew ? Icons.autorenew_rounded : Icons.check_rounded,
          onPressed: _submit,
        ),
      ],
    );
  }
}

