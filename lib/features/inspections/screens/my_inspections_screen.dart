import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/inspection_provider.dart';
import '../../../core/models/inspection_model.dart';
import '../../../constants/colors.dart';

class MyInspectionsScreen extends StatefulWidget {
  final String currentUserId;

  const MyInspectionsScreen({super.key, required this.currentUserId});

  @override
  State<MyInspectionsScreen> createState() => _MyInspectionsScreenState();
}

class _MyInspectionsScreenState extends State<MyInspectionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InspectionProvider>().loadInspections();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Inspections',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: Consumer<InspectionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(provider.upcoming, provider, isUpcoming: true),
              _buildList(provider.past, provider, isUpcoming: false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(
    List<InspectionModel> inspections,
    InspectionProvider provider, {
    required bool isUpcoming,
  }) {
    if (inspections.isEmpty) {
      return _buildEmptyState(isUpcoming);
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadInspections(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: inspections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildInspectionCard(inspections[index], provider);
        },
      ),
    );
  }

  Widget _buildInspectionCard(
    InspectionModel inspection,
    InspectionProvider provider,
  ) {
    final isOwner = inspection.ownerId == widget.currentUserId;
    final otherName = isOwner ? inspection.requesterName : inspection.ownerName;
    final roleLabel = isOwner
        ? 'Inspection request from'
        : 'Your inspection with';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: inspection.propertyImage != null
                    ? Image.network(
                        inspection.propertyImage!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imageFallback(),
                      )
                    : _imageFallback(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inspection.propertyTitle ?? 'Property',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$roleLabel ${otherName ?? 'User'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(inspection.status),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Iconsax.calendar, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  _formatDate(inspection.displayDate),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Iconsax.clock, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  _formatTime(inspection.displayDate),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (inspection.requesterNote != null &&
              inspection.requesterNote!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Note: ${inspection.requesterNote}',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
          if (inspection.ownerNote != null &&
              inspection.ownerNote!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Owner note: ${inspection.ownerNote}',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
          if (inspection.isPending || inspection.isRescheduled) ...[
            const SizedBox(height: 14),
            _buildActionButtons(inspection, provider, isOwner),
          ],
          if (inspection.isConfirmed) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleCancel(inspection, provider),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleComplete(inspection, provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Mark Done'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    InspectionModel inspection,
    InspectionProvider provider,
    bool isOwner,
  ) {
    if (isOwner) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _handleCancel(inspection, provider),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Decline'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _handleConfirm(inspection, provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Confirm'),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _handleCancel(inspection, provider),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: BorderSide(color: AppColors.error),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text('Cancel Request'),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'confirmed':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'rescheduled':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.grey;
        break;
      case 'cancelled':
        color = AppColors.error;
        break;
      default:
        color = AppColors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      width: 56,
      height: 56,
      color: AppColors.primary.withValues(alpha: 0.1),
      child: const Icon(Iconsax.home, color: AppColors.primary, size: 24),
    );
  }

  Widget _buildEmptyState(bool isUpcoming) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.calendar, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            isUpcoming ? 'No upcoming inspections' : 'No past inspections',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isUpcoming
                ? 'Schedule an inspection from any\nproperty listing.'
                : 'Completed and cancelled inspections\nwill appear here.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _handleConfirm(
    InspectionModel inspection,
    InspectionProvider provider,
  ) async {
    final ok = await provider.confirmInspection(inspection.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Inspection confirmed' : 'Failed to confirm'),
          backgroundColor: ok ? Colors.green : AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleCancel(
    InspectionModel inspection,
    InspectionProvider provider,
  ) async {
    final ok = await provider.cancelInspection(inspection.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Inspection cancelled' : 'Failed to cancel'),
          backgroundColor: ok ? AppColors.grey : AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleComplete(
    InspectionModel inspection,
    InspectionProvider provider,
  ) async {
    final ok = await provider.completeInspection(inspection.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Marked as completed' : 'Failed to update'),
          backgroundColor: ok ? Colors.green : AppColors.error,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
