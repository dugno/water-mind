import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/models/daily_water_summary.dart';
import 'package:water_mind/src/core/services/hydration/daily_water_summary_provider.dart';
import 'package:water_mind/src/core/utils/date_time_utils.dart';
import 'package:water_mind/src/core/utils/enum/enum.dart';

/// Widget hiển thị tổng lượng nước uống theo ngày
class DailyWaterSummaryWidget extends ConsumerWidget {
  /// Ngày cần hiển thị
  final DateTime date;

  /// Constructor
  const DailyWaterSummaryWidget({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dailyWaterSummaryProvider(date));

    return summaryAsync.when(
      data: (summary) {
        if (summary == null) {
          return const Center(
            child: Text('Không có dữ liệu cho ngày này'),
          );
        }
        return _buildSummaryCard(context, summary);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Text('Đã xảy ra lỗi: $error'),
      ),
    );
  }

  /// Xây dựng card hiển thị tổng lượng nước uống
  Widget _buildSummaryCard(BuildContext context, DailyWaterSummary summary) {
    final theme = Theme.of(context);
    final dateText = DateTimeUtils.formatDate(summary.date);
    final progress = summary.progressPercentage.clamp(0.0, 1.0);
    final progressPercent = (progress * 100).toInt();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateText,
                  style: theme.textTheme.titleLarge,
                ),
                Icon(
                  summary.goalMet ? Icons.check_circle : Icons.water_drop,
                  color: summary.goalMet ? Colors.green : theme.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                summary.goalMet ? Colors.green : theme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tiến độ: $progressPercent%',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              'Tổng lượng nước đã uống:',
              summary.formattedTotalAmount,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              'Mục tiêu hàng ngày:',
              summary.formattedDailyGoal,
            ),
            if (!summary.goalMet) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                'Còn lại:',
                _formatAmount(summary.remainingAmount, summary.measureUnit),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Xây dựng hàng thông tin
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium,
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Định dạng lượng nước
  String _formatAmount(double amount, MeasureUnit unit) {
    if (unit == MeasureUnit.metric) {
      if (amount >= 1000) {
        return '${(amount / 1000).toStringAsFixed(1)} L';
      } else {
        return '${amount.toStringAsFixed(0)} ml';
      }
    } else {
      return '${amount.toStringAsFixed(1)} fl oz';
    }
  }
}

/// Widget hiển thị tổng lượng nước uống trong 7 ngày gần nhất
class WeeklyWaterSummaryWidget extends ConsumerWidget {
  /// Constructor
  const WeeklyWaterSummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(weeklyWaterSummaryProvider);

    return summariesAsync.when(
      data: (summaries) {
        if (summaries.isEmpty) {
          return const Center(
            child: Text('Không có dữ liệu cho 7 ngày gần nhất'),
          );
        }
        return _buildSummaryList(context, summaries);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Text('Đã xảy ra lỗi: $error'),
      ),
    );
  }

  /// Xây dựng danh sách tổng lượng nước uống
  Widget _buildSummaryList(BuildContext context, List<DailyWaterSummary> summaries) {
    return ListView.builder(
      itemCount: summaries.length,
      itemBuilder: (context, index) {
        final summary = summaries[index];
        return DailyWaterSummaryWidget(date: summary.date);
      },
    );
  }
}
