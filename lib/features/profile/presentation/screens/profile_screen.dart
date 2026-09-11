import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/localization/l10n_ext.dart';
import '../controllers/profile_controller.dart';
import '../widgets/change_password_dialog.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.profileTitle),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.user.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = controller.user.value;

        return RefreshIndicator(
          onRefresh: controller.fetchProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36.r,
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          user?.name.isNotEmpty == true
                              ? user!.name[0].toUpperCase()
                              : '?',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        user?.name ?? '—',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        user?.email ?? '—',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (user?.phone != null && user!.phone!.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          user.phone!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 8.w,
                        children: [
                          if (user?.isOwner == true)
                            Chip(
                              label: Text(context.l10n.roleOwner),
                              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                              labelStyle: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          if (user?.isTenant == true)
                            Chip(
                              label: Text(context.l10n.roleTenant),
                              backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.15),
                              labelStyle: TextStyle(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Assigned Flats Section
                Text(
                  context.l10n.assignedFlats,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Obx(() {
                  final flats = controller.flatService.availableFlats;
                  final activeFlat = controller.flatService.selectedFlat.value;

                  if (flats.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Text(context.l10n.selectFlat),
                      ),
                    );
                  }

                  return Column(
                    children: flats.map((flat) {
                      final isSelected = activeFlat?.id == flat.id;

                      return Card(
                        elevation: isSelected ? 2 : 0,
                        margin: EdgeInsets.only(bottom: 8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.apartment,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          title: Text(
                            flat.displayName,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text('${flat.buildingName} • Floor ${flat.floor}'),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                              : null,
                          onTap: () {
                            controller.flatService.selectFlat(flat);
                          },
                        ),
                      );
                    }).toList(),
                  );
                }),
                SizedBox(height: 24.h),

                // Preferences & Actions
                Text(
                  context.l10n.settings,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.lock_reset),
                        title: Text(context.l10n.changePassword),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => ChangePasswordDialog.show(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: Text(context.l10n.language),
                        trailing: Obx(() {
                          final isBn = controller.currentLocale.value.languageCode == 'bn';
                          return SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: 'en', label: Text('EN')),
                              ButtonSegment(value: 'bn', label: Text('বাং')),
                            ],
                            selected: {isBn ? 'bn' : 'en'},
                            onSelectionChanged: (val) {
                              final code = val.first;
                              controller.switchLanguage(Locale(code));
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    icon: const Icon(Icons.logout),
                    label: Text(context.l10n.logout),
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(context.l10n.logout),
                          content: Text(context.l10n.logoutConfirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: Text(context.l10n.cancel),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.error,
                                foregroundColor: theme.colorScheme.onError,
                              ),
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                controller.logout();
                              },
                              child: Text(context.l10n.logout),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      }),
    );
  }
}
