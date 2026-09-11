import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/localization/l10n_ext.dart';
import '../../domain/entities/maintenance_request_entity.dart';

class MaintenanceDetailsScreen extends StatelessWidget {
  final MaintenanceRequestEntity request;

  const MaintenanceDetailsScreen({
    super.key,
    required this.request,
  });

  int _getStepIndex(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.open:
        return 0;
      case MaintenanceStatus.inProgress:
        return 1;
      case MaintenanceStatus.resolved:
        return 2;
      case MaintenanceStatus.closed:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentStep = _getStepIndex(request.status);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.details),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              request.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 8.w,
              children: [
                Chip(
                  avatar: const Icon(Icons.category, size: 16),
                  label: Text(request.category.name.toUpperCase()),
                ),
                Chip(
                  avatar: const Icon(Icons.flag, size: 16),
                  label: Text(request.priority.name.toUpperCase()),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Text(
              context.l10n.status,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Stepper(
              physics: const NeverScrollableScrollPhysics(),
              currentStep: currentStep,
              controlsBuilder: (context, details) => const SizedBox.shrink(),
              steps: [
                Step(
                  title: Text(context.l10n.statusOpen),
                  subtitle: Text(request.createdAt),
                  isActive: currentStep >= 0,
                  state: currentStep > 0 ? StepState.complete : StepState.indexed,
                  content: const SizedBox.shrink(),
                ),
                Step(
                  title: Text(context.l10n.statusInProgress),
                  subtitle: request.assignedStaff != null
                      ? Text('${context.l10n.assignedTo}: ${request.assignedStaff}')
                      : null,
                  isActive: currentStep >= 1,
                  state: currentStep > 1 ? StepState.complete : StepState.indexed,
                  content: const SizedBox.shrink(),
                ),
                Step(
                  title: Text(context.l10n.statusResolved),
                  subtitle: request.resolvedAt != null
                      ? Text('${context.l10n.resolvedAt}: ${request.resolvedAt}')
                      : null,
                  isActive: currentStep >= 2,
                  state: currentStep > 2 ? StepState.complete : StepState.indexed,
                  content: const SizedBox.shrink(),
                ),
                Step(
                  title: Text(context.l10n.statusClosed),
                  isActive: currentStep >= 3,
                  state: currentStep >= 3 ? StepState.complete : StepState.indexed,
                  content: const SizedBox.shrink(),
                ),
              ],
            ),
            if (request.resolutionNotes != null &&
                request.resolutionNotes!.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.resolutionNotes,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      request.resolutionNotes!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
