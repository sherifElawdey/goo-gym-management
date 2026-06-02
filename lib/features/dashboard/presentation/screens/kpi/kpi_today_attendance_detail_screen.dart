import 'package:flutter/material.dart';
import 'package:gym_pro_manager/core/l10n/l10n_ext.dart';
import 'package:gym_pro_manager/core/theme/app_spacing.dart';
import 'package:gym_pro_manager/core/utils/currency_formatter.dart';
import 'package:gym_pro_manager/core/widgets/app_empty_state.dart';
import 'package:gym_pro_manager/core/widgets/app_error_view.dart';
import 'package:gym_pro_manager/core/widgets/app_loading_view.dart';
import 'package:gym_pro_manager/core/widgets/glass_card.dart';
import 'package:gym_pro_manager/core/widgets/kpi_stat_card.dart';
import 'package:gym_pro_manager/core/widgets/member_avatar.dart';
import 'package:gym_pro_manager/core/widgets/status_badge.dart';
import 'package:gym_pro_manager/domain/entities/models.dart';
import 'package:gym_pro_manager/domain/repositories/gym_repository.dart';
import 'package:gym_pro_manager/injection_container.dart';
import 'package:intl/intl.dart' hide TextDirection;

class KpiTodayAttendanceDetailScreen extends StatefulWidget {
  const KpiTodayAttendanceDetailScreen({
    super.key,
    required this.onOpenAttendanceTab,
  });

  final VoidCallback onOpenAttendanceTab;

  @override
  State<KpiTodayAttendanceDetailScreen> createState() =>
      _KpiTodayAttendanceDetailScreenState();
}

class _KpiTodayAttendanceDetailScreenState extends State<KpiTodayAttendanceDetailScreen> {
  List<AttendanceRecord>? _records;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final today = DateTime.now();
      final todayKey = DateTime(today.year, today.month, today.day);
      final records = await sl<GymRepository>().attendanceByDate(todayKey);
      if (!mounted) return;
      setState(() {
        _records = records;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final timeFmt = DateFormat.jm('ar_EG');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.todayAttendance)),
      body: _loading
          ? const AppLoadingView()
          : _error != null
              ? AppErrorView(
                  message: _error!,
                  errorTitle: l10n.somethingWentWrong,
                  retryLabel: l10n.tryAgain,
                  onRetry: _load,
                )
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _load,
                        child: _records!.isEmpty
                            ? ListView(
                                children: [
                                  AppEmptyState(
                                    title: l10n.noCheckInsToday,
                                    subtitle: l10n.noCheckInsSubtitle,
                                    icon: Icons.event_busy_rounded,
                                  ),
                                ],
                              )
                            : ListView(
                                padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 16),
                                children: [
                                  KpiStatCard(
                                    label: l10n.todayAttendance,
                                    value: '${_records!.length}',
                                    icon: Icons.fact_check_rounded,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  ..._records!.map((item) {
                                    final isMember = item.userType == 'member';
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                      child: GlassCard(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            MemberAvatar(name: item.userName),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.userName,
                                                    style:
                                                        Theme.of(context).textTheme.titleMedium,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    timeFmt.format(
                                                      item.attendanceTime.toLocal(),
                                                    ),
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
                                                : StatusBadge.visitor(
                                                    context,
                                                    l10n.visitorBadge,
                                                  ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onOpenAttendanceTab();
                          },
                          child: Text(l10n.openInAttendanceTab),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
